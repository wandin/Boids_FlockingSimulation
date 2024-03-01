-- Importing vector's library
local vector = require "libraries/game-tools.vector"

-- Window's settings
local windowWidth = 1280
local windowHeight = 768

love.window.setTitle("Boids - Flocking Simulation")
love.window.setMode(windowWidth, windowHeight)

-- Creating a new boid
local function createBoid()
    local startPosition = vector(math.random(0, windowWidth), math.random(0,windowHeight))
    
    return{
        position = startPosition,
        velocity = vector(love.math.random(50, 200), love.math.random(50, 200)),
        acceleration = vector.ZERO,         -- Top speed
        colour = {math.random(0,1), math.random(0,1), math.random(0,1)},
        maxForce = 0.2,
        maxSpeed = 200
    }
end

-- Inicialização do jogo
function love.load()
    -- add to Lista de boids
    boids = {}
    for i = 1, 50 do
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

    flock(boids)

    -- UPDATE BOID POSITION!

    for i, b in pairs(boids) do

        local aligment = align(boids)
        b.acceleration = aligment


        -- Atualizar a posição com base na velocity e no tempo decorrido (dt)
        b.position = b.position + b.velocity * dt
        b.velocity = b.velocity + b.acceleration * dt

      --[[   -- Verificar se o boid atingiu as bordas da tela e ajustar sua posição e velocity se necessário
        if b.position.x < 0 then
            b.position.x = 0
            -- Ajustar o ângulo para apontar para a direita
            b.velocity.x = math.abs(b.velocity.x)
        elseif b.position.x > windowWidth then
            b.position.x = windowWidth
            -- Ajustar o ângulo para apontar para a esquerda
            b.velocity.x = -math.abs(b.velocity.x)
        end
        if b.position.y < 0 then
            b.position.y = 0
            -- Ajustar o ângulo para apontar para baixo
            b.velocity.y = math.abs(b.velocity.y)
        elseif b.position.y > windowHeight then
            b.position.y = windowHeight
            -- Ajustar o ângulo para apontar para cima
            b.velocity.y = -math.abs(b.velocity.y)
        end]]


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
    local radius = 100
    local steeringForce = vector.ZERO
    local totalBoids = 0

    maxSpeed = 0
    for _, boid in pairs(boids) do

        for _, otherboid in ipairs(boids) do

            local distance = vector.distanceTo(boid.position, otherboid.position)

            if boid ~= otherboid and distance < radius then

                steeringForce = steeringForce + otherboid.velocity
                totalBoids = totalBoids + 1
            end
        end
   
        if totalBoids > 0 then
            steeringForce = steeringForce / totalBoids
            steeringForce = steeringForce - boid.velocity
            vector.normalized(steeringForce * math.min(0, boid.maxSpeed, boid.maxForce))

        end
    end
    return steeringForce

end


function cohesion(boids)
    local radius = 100
    local steeringForce = vector.ZERO
    local totalBoids = 0

    maxSpeed = 0
    for _, boid in pairs(boids) do

        for _, otherboid in ipairs(boids) do

            local distance = vector.distanceTo(boid.position, otherboid.position)

            if boid ~= otherboid and distance < radius then

                steeringForce = steeringForce + otherboid.velocity
                totalBoids = totalBoids + 1
            end
        end
   
        if totalBoids > 0 then
            steeringForce = steeringForce / totalBoids
            steeringForce = steeringForce - boid.position
            vector.normalized(steeringForce * math.min(0, boid.maxSpeed, boid.maxForce))
            steeringForce = steeringForce - boid.velocity

        end
    end
    return steeringForce

end


function flock(boids)
    for _,b in pairs(boids) do
        local alignment = align(boids)
        local cohesion = cohesion(boids)
        b.acceleration = alignment + cohesion
    end
end