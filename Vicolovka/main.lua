require "Object"
require "Character"
require "Enemy"
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

tileSize = 32;

GameState = "StarMenu"

local startButton = {
        x = 0,
        y = 0,
        width = 200,
        height = 60,
        text = "START GAME"
}

Start_witches = 150
LVL = 1
Map_width = 18
Map_height = 17
Num_kids = 1;
--Gen_Map sada vraca matricu objekata sa svojim tipom i teksturom
Map = Gen_Map(Map_width, Map_height, tileSize, world) -- pogledaj mapGen functions za odredjivanje dimenzija 
List_of_kids = {}
Entities.place_child(Map, Num_kids, List_of_kids)
Entities.place_gun(Map, 3*LVL)



local forest = love.graphics.newImage("Assets/Vicolovka_forest.png")



entities = {} -- TODO: add all entities to this table than load with foreach

function love.load()
        love.window.setMode(Map_width*tileSize, Map_height*tileSize)

        startButton.x = (love.graphics.getWidth() - startButton.width) / 2
        startButton.y = (love.graphics.getHeight() - startButton.height) / 2
        
        --player load
        player = Character:new(world, 9 * tileSize, 13 * tileSize, 128) -- namestio sam spawn na 9 col 13 row
        Objectives = #List_of_kids

        --enemy load
        Map[8][math.floor(Map_width/2) - 1].entity = Entities.create("purpleWitch");
        Map[8][math.floor(Map_width/2) - 2].entity = Entities.create("blueWitch");
        Map[8][math.floor(Map_width/2) + 1].entity = Entities.create("redWitch");

        
        --screen borders load
        addWindowBorders(love.graphics.getWidth(), love.graphics.getHeight())
        
end

function love.update(dt)
        if GameState == "GameOn" then
                world:update(dt)
                if(Objectives <= 0) then
                        Trigger_next_lvl()
                end
                if LVL == 3 then
                        GameState = "Victory"
                end

                if Start_witches == 0 then
                        enemy1 = Enemy:new(world, 10 * tileSize, (math.floor(Map_width/2))*tileSize, 100, "normal")
                        enemy2 = Enemy:new(world, 10 * tileSize, (math.floor(Map_width/2))*tileSize, 100, "ambush")
                        enemy3 = Enemy:new(world, 10 * tileSize, (math.floor(Map_width/2))*tileSize, 100, "normalWatcher")
                        Map[8][math.floor(Map_width/2) - 1].entity = nil
                        Map[8][math.floor(Map_width/2) - 2].entity = nil
                        Map[8][math.floor(Map_width/2) + 1].entity = nil
                        Start_witches = -1
                else Start_witches = Start_witches - 1 end

                --player upadate
                player:update(dt) 
                --enemy update
                if enemy1 then
                        enemy1:update(dt)
                end
                if enemy2 then
                        enemy2:update(dt)
                end
                if enemy3 then
                        enemy3:update(dt)
                end

                local player_x = math.floor(player.x / tileSize) + 1
                local player_y = math.floor(player.y / tileSize) + 1 

                if enemy1 and enemy2 and enemy3 then

                        -- Tvoje linije za računanje pločica:
                        local enemy1_x = math.floor(enemy1.x / tileSize) + 1
                        local enemy1_y = math.floor(enemy1.y / tileSize) + 1
                        local enemy2_x = math.floor(enemy2.x / tileSize) + 1
                        local enemy2_y = math.floor(enemy2.y / tileSize) + 1
                        local enemy3_x = math.floor(enemy3.x / tileSize) + 1
                        local enemy3_y = math.floor(enemy3.y / tileSize) + 1

                        -- Naš novi if uslov za proveru iste pločice:
                        if (player_x == enemy1_x and player_y == enemy1_y) or
                        (player_x == enemy2_x and player_y == enemy2_y) or
                        (player_x == enemy3_x and player_y == enemy3_y) then
                        
                        if GameState == "GameOn" then
                                TriggergameEnd()
                        end
                        end
                end
                
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
        if GameState == "StarMenu" then
                -- Pozadina za početni ekran
                love.graphics.clear(0.1, 0.1, 0.1)

                -- Naslov igre
                love.graphics.setFont(love.graphics.newFont(24)) 
                love.graphics.printf("VICOLOVKA", 0, startButton.y - 80, love.graphics.getWidth(), "center")

                -- Crtanje dugmeta (Pravougaonik)
                love.graphics.setColor(0.2, 0.6, 0.2) -- Zelena boja dugmeta
                love.graphics.rectangle("fill", startButton.x, startButton.y, startButton.width, startButton.height, 10) -- 10 je zaobljeni ugao

                -- Tekst na dugmetu
                love.graphics.setColor(1, 1, 1) -- Bela boja za tekst
                love.graphics.printf(startButton.text, startButton.x, startButton.y + 18, startButton.width, "center")

        elseif GameState == "GameOn" then
                for y, row in ipairs(Map) do          --this is tmp test map 
                        for x, tile in ipairs(row) do   --TODO: implement map as objects
                                tile:renderTile()
                        end
                end

                --adds borders outside the window
                drawWindowBorders(love.graphics.getWidth(), love.graphics.getHeight())
                
                -- player draw
                player:render() 
                -- enemy draw
                if enemy1 then
                        enemy1:render()
                end
                if enemy2 then
                        enemy2:render()
                end
                if enemy3 then
                        enemy3:render()
                end
        elseif GameState == "GameOver" then
        -- Crna pozadina za Game Over ekran
                love.graphics.clear(0, 0, 0)
                
                love.graphics.setFont(love.graphics.newFont(24))
                love.graphics.printf("GAME OVER", 0, love.graphics.getHeight() / 2 - 40, love.graphics.getWidth(), "center")
                
                love.graphics.setFont(love.graphics.newFont(16))
                love.graphics.printf("Press 'R' to Restart", 0, love.graphics.getHeight() / 2 + 10, love.graphics.getWidth(), "center")

        elseif GameState == "Victory" then
                love.graphics.clear(0, 0, 0)
                
                love.graphics.setFont(love.graphics.newFont(24))
                love.graphics.printf("VICTORY", 0, love.graphics.getHeight() / 2 - 40, love.graphics.getWidth(), "center")
                
                love.graphics.setFont(love.graphics.newFont(16))
                love.graphics.printf("Press 'R' to Restart", 0, love.graphics.getHeight() / 2 + 10, love.graphics.getWidth(), "center")
        end
end

function addWindowBorders (sizeX, sizeY) 
        -- wrapper func creates screen borders as objects on edges of screen
        upperBound = Object:new(world, sizeX/2, -50, sizeX, 100, sizeX, 100, "static", "wall")
        lowerBound = Object:new(world, sizeX/2, sizeY + 50, sizeX, 100, sizeX, 100, "static", "wall")
        leftBound = Object:new(world, -50, sizeY/2, 100, sizeY, 100, sizeY, "static", "wall")
        rightBound = Object:new(world, sizeX + 50, sizeY/2, 100, sizeY, 100, sizeY, "static", "wall")

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

function love.mousepressed(x, y, button, istouch, presses)
    if GameState == "StarMenu" and button == 1 then
        -- Uzimamo tačnu poziciju miša na ekranu
        local mouseX, mouseY = love.mouse.getPosition()

        -- Provera da li je klik unutar koordinata dugmeta
        if mouseX >= startButton.x and mouseX <= startButton.x + startButton.width and
           mouseY >= startButton.y and mouseY <= startButton.y + startButton.height then
            
            GameState = "GameOn"
        end
    end
end

function Trigger_next_lvl()

        world:destroy() 
        

        world = love.physics.newWorld(0, 0)

        LVL = LVL + 1
        Map_width = Map_width + 8
        Map_height = Map_height + 4
        Num_kids = Num_kids + 1
        
        -- 4. Generišemo mapu u NOVOM svetu
        Map = Gen_Map(Map_width, Map_height, tileSize, world) 
        List_of_kids = {}
        Entities.place_child(Map, Num_kids, List_of_kids)
        Entities.place_gun(Map, 3*LVL)
        

        love.load()
end


function Reset_Game()
        -- 1. Uništavamo ceo fizički svet da očistimo sve stare zidove, igrače i granice
        if world then world:destroy() end
        world = love.physics.newWorld(0, 0)
        -- 2. Vraćamo dimenzije mape i broj dece na početne vrednosti (Level 1)
        Start_witches = 150
        LVL = 1
        Map_width = 18
        Map_height = 17
        Num_kids = 1

        -- 3. Generišemo ponovo početnu mapu i decu
        Map = Gen_Map(Map_width, Map_height, tileSize, world) 
        List_of_kids = {}
        Entities.place_child(Map, Num_kids, List_of_kids)
        Entities.place_gun(Map, 3*LVL)

        enemy1 = nil
        enemy2 = nil
        enemy3 = nil

        -- 4. Pozivamo love.load() da ponovo stvori igrača i granice prozora na pravoj rezoluciji
        love.load()

        -- 5. Vraćamo igru na početni meni (ili stavi "GameOn" ako želiš da igra krene odmah bez menija)
        GameState = "StarMenu"
end

function love.keypressed(key)
        -- Proveravamo da li je pritisnut taster 'r' i da li je stanje igre "GameOver"
        if key == "r" and (GameState == "GameOver" or GameState == "Victory") then
                Reset_Game()
        end
end

