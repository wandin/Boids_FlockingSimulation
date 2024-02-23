function love.load()

    local title =  "Boids - Flocking Simulation"
    love.window.setTitle(title)

    background = love.graphics.newImage("sprites/background.png")


    boids = {}
    boids.speed = 200;
    boids.position = love.math.Vectornew(0,0)


end


function love.update(deltaTime)


end


function love.draw()

    love.graphics.setColor(1,1,1)
    love.graphics.draw(background, 0,0,nil, 1.5,1.5)

    -- boids
    local x, y, angle = 200, 100, math.pi/4
    drawBoid ("fill", x, y, 40, 20 , angle)    
end

function drawBoid (mode, x, y, length, width , angle) -- position, length, width and angle

    love.graphics.push()
    love.graphics.translate(x,y)
    love.graphics.rotate( angle )
	love.graphics.polygon(mode, -length/2, -width /2, -length/2, width /2, length/2,0)
	love.graphics.pop()
    love.graphics.setColor(1,1,0)
end