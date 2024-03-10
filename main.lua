-- Importing vector's library
local vector = require "libraries/hump.vector"

-- Window's settings
local windowWidth = 800
local windowHeight = 600

love.window.setTitle("Boids - Flocking Simulation")
love.window.setMode(windowWidth, windowHeight)

-- Creating a new boid
local function createBoid()
    local startPosition = vector.new(math.random(0, windowWidth), math.random(0,windowHeight))
    
    local magnitude = love.math.random(2, 100)   -- Magnitude aleatória entre 2 e 4
    local direction = vector.new(love.math.random(-1, 1), love.math.random(-1, 1))

    --local direction = vector.new(love.math.random() * 2 - 1, love.math.random() * 2 - 1)
    direction:normalizeInplace()
    local sumvelocity = direction * magnitude  -- Ajustar magnitude da velocidade


    return{
        colour = {math.random(0.2,1), math.random(0.2,1), math.random(0.2,1)},
        position = startPosition,
        velocity = sumvelocity,
        acceleration = vector.new(0,0),         
        maxForce = 3    ,
        maxSpeed = 100
    }
end

-- Inicialização do jogo
function love.load()
    -- adding boids to array
    boids = {}
    for i = 1, 30 do
        boid = table.insert(boids, createBoid())
    end
end


function love.draw()
 
    for i,b in ipairs(boids) do
        love.graphics.setColor(b.colour)
        local angle = math.atan2(b.velocity.y, b.velocity.x)
        drawBoid ("fill", b.position.x, b.position.y, 20, 10 , angle)
    end
end


function love.update(dt)

    align(boids)
    cohesion(boids)
    separation(boids)
    for i, b in pairs(boids) do
        -- UPDATE BOID POSITION!
        b.position = b.position + b.velocity * dt
        b.velocity = b.velocity + b.acceleration * dt
        b.velocity = b.velocity:trimInplace(b.maxSpeed)

       if b.position.x < 0 then
            b.position.x = windowWidth
        elseif b.position.x > windowWidth then
            b.position.x = 0
        end
        if b.position.y < 0 then
            b.position.y = windowHeight
        elseif b.position.y > windowHeight then
            b.position.y = 0
        end
    end    
end


function drawBoid (mode, x, y, length, width , angle) -- position, length, width and angle
    love.graphics.push()
	love.graphics.translate(x, y)
	love.graphics.rotate( angle )
	love.graphics.polygon(mode, -length/2, -width /2, -length/2, width /2, length/2, 0)
	love.graphics.pop() 
end


function align(boids)
    local radius = 5000
    local steeringForce = vector.new(0,0)
    local totalBoids = 0

    for _, boid in pairs(boids) do
        for _, otherboid in ipairs(boids) do
            local distance = boid.position:dist(otherboid.position)
            if boid ~= otherboid and distance < radius then
                steeringForce = steeringForce + otherboid.velocity
                totalBoids = totalBoids + 1
            end
        end
        
        if totalBoids > 0 then
            steeringForce = steeringForce / totalBoids
            steeringForce = steeringForce:normalizeInplace()                -- normalize to set magnitude below
            steeringForce = steeringForce * boid.maxSpeed               -- multiplying by maxSpeed after normalizing (kinda setMag)
            steeringForce = steeringForce - boid.velocity
            steeringForce = steeringForce:trimInplace(boid.maxForce)    -- limiting to maxForce
        
            boid.acceleration = boid.acceleration + steeringForce
        end
    end
end

function separation(boids)
    local radius = 5000

    for _, boid in pairs(boids) do
        local steeringForce = vector.new(0, 0)
        local totalBoids = 0

        for _, otherboid in ipairs(boids) do
            local distance = boid.position:dist(otherboid.position)

            if boid ~= otherboid and distance < radius then
                local distanceMultiplied = distance * distance
                local distanceToOthers = otherboid.position - boid.position
                distanceToOthers = distanceToOthers / distanceMultiplied
                steeringForce = steeringForce + distanceToOthers
                totalBoids = totalBoids + 1
            end
        end

        if totalBoids > 0 then
            steeringForce = steeringForce / totalBoids
            steeringForce = steeringForce:normalizeInplace()            -- normalize to set magnitude below
            steeringForce = steeringForce * boid.maxSpeed               -- multiplying by maxSpeed after normalizing (kinda setMag)
            steeringForce = steeringForce - boid.velocity
            steeringForce = steeringForce:trimInplace(boid.maxForce)    -- limiting to maxForce
            boid.acceleration = boid.acceleration + steeringForce
        end
    end
end

function cohesion(boids)
    local radius = 10000
    local steeringForce = vector.new(0,0)
    local totalBoids = 0

    for _, boid in pairs(boids) do
        for _, otherboid in ipairs(boids) do
            local distance = boid.position:dist(otherboid.position)

            if boid ~= otherboid and distance < radius then

                steeringForce = steeringForce + otherboid.position
                totalBoids = totalBoids + 1
            end
            if totalBoids > 0 and boid.colour == otherboid.colour then
                steeringForce = steeringForce / totalBoids
                steeringForce = steeringForce - boid.position
                steeringForce = steeringForce:normalizeInplace() * boid.maxSpeed
                steeringForce = steeringForce - boid.velocity
                steeringForce = steeringForce:trimInplace(boid.maxForce)
    
                boid.acceleration = boid.acceleration + steeringForce
            end
        end
    end
end
