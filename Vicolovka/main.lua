require "Object"
require "Character"
require "Enemy"
require "mapGen"
require "Entities"

local game_manip = require("game_manip")
local Game = game_manip.funcs
local game = game_manip.data
local startButton = game_manip.start


function love.load()
    if game.state == "" then
        Game.init()
    end

    love.window.setMode(game.mapWidth*game.tileSize, game.mapHeight*game.tileSize)

    Game.load()
end

function love.update(dt)
    if game.state == "GameOn" then
        if game.objective <= 0 then
            Game.nextLvL()
            return
        end
        if game.lvl == 4 then
            Game.Victory()
            return
        end

        if game.witchClock ~= nil then
            game.witchClock = game.witchClock - dt
            if game.witchClock <= 0 then
                Game.startWitches()
                game.witchClock = nil
            end
        end
        
        Game.update(dt)

        if game.gunClock and game.gunClock > 0 then
            Game.checkColisionWithGun()
            game.gunClock = game.gunClock - dt
        else
            Game.checkColisionNoGun()
        end
    end   
end


function love.draw()
    if game.state == "StartMenu" then
        Game.loadStartMenu()
    elseif game.state == "GameOn" then
        Game.render()
    elseif game.state == "GameOver" then
        Game.loadGameOver()
    elseif game.state == "Victory" then
        Game.loadVictory()
    end
end


function love.mousepressed(x, y, button, istouch, presses)
    if game.state == "StartMenu" and button == 1 then
       
        local mouseX, mouseY = love.mouse.getPosition()

        -- Provera da li je klik unutar koordinata dugmeta
        if x >= startButton.x and x <= startButton.x + startButton.width and
           y >= startButton.y and y <= startButton.y + startButton.height then
            
            Game.start()
        end
    end
end

function love.keypressed(key)
       
        if key == "r" and (game.state == "GameOver" or game.state == "Victory") then
                Game.reset()
        end
end

