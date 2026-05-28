require "Object"
require "Character"
require "mapGen"


World = love.physics.newWorld(0,0)

local tileSize = 32;

Map_width = 26
Map_height = 21
--Gen_Map sada vraca matricu objekata sa svojim tipom i teksturom
Map = Gen_Map(Map_width, Map_height, tileSize, World) -- pogledaj mapGen functions za odredjivanje dimenzija 



-- dodate promenljive samo za test tekstura
local forest = love.graphics.newImage("Assets/Vicolovka_forest.png")
--local walltile = love.graphics.newImage("Assets/Vicolovka_grass.png")
--local pathtile = love.graphics.newImage("Assets/Vicolovka_path.png")


entities = {} -- TODO: add all entities to this table than load with foreach

function love.load()
        love.window.setMode(Map_width*tileSize, Map_height*tileSize)
        
        --player load
        player = Character:new(World, 9 * tileSize, 13 * tileSize, 10, 20, 128) -- namestio sam spawn na 9 col 13 row

        --screen borders load
        addWindowBorders(love.graphics.getWidth(), love.graphics.getHeight())
        
end

function love.update(dt)
        World:update(dt)

        --player upadate
        player:update(dt) 
        
                           

end

function love.draw()
        for y, row in ipairs(Map) do          --this is tmp test map 
                for x, tile in ipairs(row) do   --TODO: implement map as objects
                        if tile.tile_type ~= "ghostBox" then
                                tile:renderTile()
                                if tile.tile_type == "wall" then
                                        love.graphics.draw(forest, (x-1)*tileSize, (y-1)*tileSize - 8)
                                end
                        end
                end
        end

        --adds borders outside the window
        drawWindowBorders(love.graphics.getWidth(), love.graphics.getHeight())
        
        -- player draw
        player:render()

end

function addWindowBorders (sizeX, sizeY) 
        -- wrapper func creates screen borders as objects on edges of screen
        upperBound = Object:new(World, 0, -100, sizeX, 100, "static")
        lowerBound = Object:new(World, 0, sizeY, sizeX, 100, "static")
        leftBound = Object:new(World, -100, 0, 100, sizeY, "static")
        rightBound = Object:new(World, sizeX, 0, 100, sizeY, "static")

end

function drawWindowBorders ()
        -- wrapper func draws 4 rectangles on the edges of screen
        upperBound:render()
        lowerBound:render()
        leftBound:render()
        rightBound:render()
         
end

