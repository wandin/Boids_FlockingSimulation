-- Importing vector's library
local vector = require "libraries/game-tools.vector"

-- Window's settings
local windowWidth = 1280
local windowHeight = 768

love.window.setTitle("Boids - Flocking Simulation")
love.window.setMode(windowWidth, windowHeight)

-- Creating a new boid
local function createBoid()
    return {
        position = vector(windowWidth / 2, windowHeight / 2),--love.math.random(0, windowWidth), love.math.random(0, windowHeight)),
        velocity = vector(love.math.random(-200, 200), love.math.random(-200, 200)),
        maxSpeed = 200,         -- Top speed
        cohesionWeight = 1,     -- Cohesion rule's weight
        separationWeight = 1,   -- Separation rule's weight
        alignmentWeight = 1     -- Alignment rule's weight
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
        love.graphics.setColor(0.4, 1, 0.6)

        local angle = math.atan2(b.velocity.y, b.velocity.x)
        drawBoid ("fill", b.position.x, b.position.y, 20, 10 , angle)
    end

end

function love.update(dt)

    -- UPDATE BOID POSITION!

    for i, b in ipairs(boids) do
        -- Atualizar a posição com base na velocidade e no tempo decorrido (dt)
        b.position = b.position + b.velocity * dt

        -- Verificar se o boid atingiu as bordas da tela e ajustar sua posição e velocidade se necessário
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
