require "Object"
require "Character"
require "mapGen"
require "Entities"

world = love.physics.newWorld(0,0)

--[[
mapSizes(width x Height) :
                18x17 rez -> 576x544
                26x21 rez -> 832x672
                34x25 rez -> 1088x800
                42x29 rez -> 1344x928
                50x33 rez -> 1600x1056
]]

local tileSize = 32;

GameState = "GameOn"

Map_width = 26
Map_height = 21
--Gen_Map sada vraca matricu objekata sa svojim tipom i teksturom
Map = Gen_Map(Map_width, Map_height, tileSize, world) -- pogledaj mapGen functions za odredjivanje dimenzija 
List_of_kids = {}
Entities.place_child(Map, 2, List_of_kids)



local forest = love.graphics.newImage("Assets/Vicolovka_forest.png")



entities = {} -- TODO: add all entities to this table than load with foreach

function love.load()
        love.window.setMode(Map_width*tileSize, Map_height*tileSize)
        
        --player load
        player = Character:new(world, 9 * tileSize, 13 * tileSize, 128) -- namestio sam spawn na 9 col 13 row
        Objectives = #List_of_kids
        --screen borders load
        addWindowBorders(love.graphics.getWidth(), love.graphics.getHeight())
        
end

function love.update(dt)
        if GameState == "GameOn" then
                world:update(dt)
                if(Objectives <= 0) then
                        TriggergameEnd()
                end

                --player upadate
                player:update(dt) 
                local player_x = math.floor(player.x / tileSize) + 1
                local player_y = math.floor(player.y / tileSize) + 1 
                local player_tile = nil

                if Map[player_y] and Map[player_y][player_x] then
                        player_tile = Map[player_y][player_x]
                end


                if player_tile ~= nil and player_tile.entity and player_tile.entity.isChild == true then
                        Objectives = Objectives - 1
                        player_tile.entity = nil
                elseif player_tile ~= nil then
                        player_tile.entity = nil
                end     
        end
end


function love.draw()
        if GameState == "GameOn" then
                for y, row in ipairs(Map) do          --this is tmp test map 
                        for x, tile in ipairs(row) do   --TODO: implement map as objects
                                tile:renderTile()
                        end
                end

                --adds borders outside the window
                drawWindowBorders(love.graphics.getWidth(), love.graphics.getHeight())
                
                -- player draw
                player:render()     
        elseif GameState == "GameOver" then
                love.graphics.print("GAME OVER", 400, 300)
                love.graphics.print("Press 'R' to Restart", 400, 350)
        end
end

function addWindowBorders (sizeX, sizeY) 
        -- wrapper func creates screen borders as objects on edges of screen
        upperBound = Object:new(world, sizeX/2, -50, sizeX, 100, sizeX, 100, "static")
        lowerBound = Object:new(world, sizeX/2, sizeY + 50, sizeX, 100, sizeX, 100, "static")
        leftBound = Object:new(world, -50, sizeY/2, 100, sizeY, 100, sizeY, "static")
        rightBound = Object:new(world, sizeX + 50, sizeY/2, 100, sizeY, 100, sizeY, "static")

end

function drawWindowBorders ()
        -- wrapper func draws 4 rectangles on the edges of screen
        upperBound:render()
        lowerBound:render()
        leftBound:render()
        rightBound:render()
end


function TriggergameEnd()
        GameState = "GameOver"
end