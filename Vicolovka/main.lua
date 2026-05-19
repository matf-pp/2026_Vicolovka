require "Object"
require "Character"

Map = {
        {1, 0, 1, 1, 1, 1, 0, 1, 1, 0, 1, 1, 1, 1, 0, 1},
        {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
        {1, 1, 0, 1, 1, 0, 1, 1, 1, 1, 0, 1, 1, 0, 1, 1},
        {1, 1, 0, 1, 1, 0, 1, 1, 1, 1, 0, 1, 1, 0, 1, 1},
        {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
        {1, 0, 1, 1, 1, 1, 0, 1, 1, 0, 1, 1, 1, 1, 0, 1},
        {1, 0, 1, 1, 1, 1, 0, 1, 1, 0, 1, 1, 1, 1, 0, 1},
        {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
        {1, 1, 0, 1, 1, 0, 1, 1, 1, 1, 0, 1, 1, 0, 1, 1},
        {1, 1, 0, 1, 1, 0, 1, 1, 1, 1, 0, 1, 1, 0, 1, 1},
        {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
        {1, 0, 1, 1, 1, 1, 0, 1, 1, 0, 1, 1, 1, 1, 0, 1},
}


local tileSize = 50;

world = love.physics.newWorld(0,0)

entities = {} -- TODO: add all entities to this table than load with foreach

function love.load()
        love.window.setMode(800, 600)
        
        --player load
        player = Character:new(world, 1 * tileSize + 20, 0 * tileSize + 20, 25, 35, 128)

        --screen borders load
        addWindowBorders(love.graphics.getWidth(), love.graphics.getHeight())

        

        
end

function love.update(dt)
        world:update(dt)

        --player upadate
        player:update(dt) 
        
                           

end


function love.draw()
        for y, row in ipairs(Map) do          --this is tmp test map 
                for x, tile in ipairs(row) do --TODO: implement map as objects
                        if tile == 1 then
                                love.graphics.setColor(0.2, 0.2, 0.2)
                        else
                                love.graphics.setColor(0.8, 0.8, 0.8)
                        end
                        love.graphics.rectangle("fill", (x-1)*tileSize, (y-1)*tileSize, tileSize, tileSize)
                end
        end

        --adds borders outside the window
        drawWindowBorders(love.graphics.getWidth(), love.graphics.getHeight())
        
        -- player draw
        player:render()

end

function addWindowBorders (sizeX, sizeY) 
        -- wrapper func creates screen borders as objects on edges of screen
        upperBound = Object:new(world, 0, -100, sizeX, 100, "static")
        lowerBound = Object:new(world, 0, sizeY, sizeX, 100, "static")
        leftBound = Object:new(world, -100, 0, 100, sizeY, "static")
        rightBound = Object:new(world, sizeX, 0, 100, sizeY, "static")

end

function drawWindowBorders ()
        -- wrapper func draws 4 rectangles on the edges of screen
        upperBound:render()
        lowerBound:render()
        leftBound:render()
        rightBound:render()
         
end

