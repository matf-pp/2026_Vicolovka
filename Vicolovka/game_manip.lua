local game = {
    state = "",
    --
    world = nil,
    player = nil, 
    lvl = nil,
    score = nil,
    objective = nil,
    enemies = {},
    --
    tileSize = nil,
    mapWidth = nil,
    mapHeight = nil,
    map = {},
    numKids = nil,
    kids = {},
    --
    witchClock = nil,
    gunClock = nil,
}

local startButton = {
    x = 0,
    y = 0,
    width = 200,
    height = 60,
    text = "START GAME"
}

Game = {}

function Game.init()
    game.world = love.physics.newWorld(0,0)
    game.mapWidth = 18
    game.mapHeight = 17
    game.numKids = 2
    game.tileSize = 32
    game.score = 0
    game.lvl = 1
    game.state = "StartMenu"
    game.witchClock = 5
    game.enemies = {}

    game.map = Gen_Map(game.mapWidth, game.mapHeight, game.tileSize, game.world)
    game.kids = {}
    Entities.place_child(game.map, game.numKids, game.kids)
    Entities.place_gun(game.map, 1)
    game.objective = #game.kids
end

function Game.nextLvL()
    game.world:destroy()

    game.world = love.physics.newWorld(0,0)

    game.gunClock = 0
    game.witchClock = 5
    game.lvl = game.lvl + 1
    game.mapWidth = game.mapWidth + 8
    game.mapHeight = game.mapHeight + 4
    game.numKids = game.numKids + 1

    game.map = Gen_Map(game.mapWidth, game.mapHeight, game.tileSize, game.world)
    game.kids = {}
    Entities.place_child(game.map, game.numKids, game.kids)
    Entities.place_gun(game.map, 1)

    game.enemies = {}
    game.objective = #game.kids

    love.load()
end

function Game.start()
    game.state = "GameOn"
end
function Game.over()
    game.state = "GameOver"
end
function Game.Victory()
    game.state = "Victory"
end

function Game.reset()
    if game.world then game.world:destroy() end

    game.state = ""

    love.load()
end

function Game.load()
    startButton.x = (love.graphics.getWidth() - startButton.width) / 2
    startButton.y = (love.graphics.getHeight() - startButton.height) / 2

    game.player = Character:create(game.world, 9*game.tileSize, 13*game.tileSize, 128)

    Entities.houseWitches(game)
    Game.addWindowBorders()
end

function Game.addWindowBorders()

    local sizeX = love.graphics.getWidth()
    local sizeY = love.graphics.getHeight()

    UpperBound = Object:new(game.world, sizeX/2, -50, sizeX, 100, sizeX, 100, "static", "wall")
    LowerBound = Object:new(game.world, sizeX/2, sizeY + 50, sizeX, 100, sizeX, 100, "static", "wall")
    LeftBound = Object:new(game.world, -50, sizeY/2, 100, sizeY, 100, sizeY, "static", "wall")
    RightBound = Object:new(game.world, sizeX + 50, sizeY/2, 100, sizeY, 100, sizeY, "static", "wall")

end

function Game.drawWindowBorders()
    if UpperBound then
        UpperBound:render()
    end
    if LowerBound then
        LowerBound:render()
    end
    if LeftBound then
        LeftBound:render()
    end
    if RightBound then
        RightBound:render()
    end
end

function Game.loadStartMenu()
    love.graphics.clear(0.1, 0.1, 0.1)

    love.graphics.setFont(love.graphics.newFont(24)) 
    love.graphics.printf("VICOLOVKA", 0, startButton.y - 80, love.graphics.getWidth(), "center")

    love.graphics.setColor(0.2, 0.6, 0.2) 
    love.graphics.rectangle("fill", startButton.x, startButton.y, startButton.width, startButton.height, 10) 

    love.graphics.setColor(1, 1, 1) -- Bela boja za tekst
    love.graphics.printf(startButton.text, startButton.x, startButton.y + 18, startButton.width, "center")
end

function Game.loadGameOver()
    love.graphics.clear(0, 0, 0)
                
    love.graphics.setFont(love.graphics.newFont(24))
    love.graphics.printf("GAME OVER", 0, love.graphics.getHeight() / 2 - 40, love.graphics.getWidth(), "center")

    love.graphics.setFont(love.graphics.newFont(18))
    love.graphics.printf("Final Score: " .. game.score, 0, love.graphics.getHeight() / 2 - 10, love.graphics.getWidth(), "center")
                
    love.graphics.setFont(love.graphics.newFont(16))
    love.graphics.printf("Press 'R' to Restart", 0, love.graphics.getHeight() / 2 + 10, love.graphics.getWidth(), "center")    
end

function Game.loadVictory()

    love.graphics.clear(0, 0, 0)    
    love.graphics.setFont(love.graphics.newFont(24))
    love.graphics.printf("VICTORY", 0, love.graphics.getHeight() / 2 - 40, love.graphics.getWidth(), "center")

    love.graphics.setFont(love.graphics.newFont(18))
    love.graphics.printf("Final Score: " .. game.score, 0, love.graphics.getHeight() / 2 - 10, love.graphics.getWidth(), "center")
                
    love.graphics.setFont(love.graphics.newFont(16))
    love.graphics.printf("Press 'R' to Restart", 0, love.graphics.getHeight() / 2 + 10, love.graphics.getWidth(), "center")
end

function Game.drawScore()
    love.graphics.setColor(1, 1, 1) -- Bela boja za tekst
    love.graphics.setFont(love.graphics.newFont(18))     
    love.graphics.print("SCORE: " .. game.score, 15, 15)
end

function Game.render()
    for y, row in ipairs(game.map) do
        for x, tile in ipairs(row) do
            tile:renderTile()
        end
    end

    Game.drawWindowBorders()
    game.player:render()
    
    for i = 1, 4 do
        local witch = game.enemies[i]
        if witch then
            witch:render()
        end
    end

    Game.drawScore()
end

function Game.startWitches()
    local enemyTypes = {"normal", "ambush", "normalWatcher", "ambushWatcher"}
    for i = 1, 4  do
        local y = (math.floor(game.mapWidth/2))*game.tileSize
        local x = 10*game.tileSize

        local witch = Enemy:create(game, x, y, 80, enemyTypes[i])
        game.enemies[i] = witch
    end
    Entities.unHouseWitches(game)
end

function Game.updateTile(player_tile, dt)

    if player_tile ~= nil and player_tile.entity and player_tile.entity.isChild == true then
        game.objective = game.objective - 1
        game.score = game.score + 100
        player_tile.entity = nil
    elseif player_tile ~= nil and player_tile.entity and player_tile.entity.isGun == true then
        game.gunClock = 8.0
        player_tile.entity = nil
    elseif player_tile ~= nil and player_tile.entity ~= nil then
        player_tile.entity = nil
        game.score = game.score + 10
    end

end

function Game.update(dt)
    if game.world then
        game.world:update(dt)
    end
    game.player:update(dt)
    for i = 1, 4 do
        local witch = game.enemies[i]
        if witch then
            witch:update(dt, game)
        end
    end

    local player_tile = game.player:getTile(game)
    Game.updateTile(player_tile, dt)
    
end

function Game.checkColisionNoGun()
    local player_x, player_y = game.player:getPosition(game.tileSize)
    for i = 1, 4 do
        local witch = game.enemies[i]
        if witch then
            local enemy_x, enemy_y = witch:getPosition(game.tileSize)
            if player_x == enemy_x and player_y == enemy_y then 
                Game.over() 
                break
            end
        end
    end
end

function Game.checkColisionWithGun()
    local player_x, player_y = game.player:getPosition(game.tileSize)
    for i = 1, 4 do
        local witch = game.enemies[i]
        if witch ~= nil then
            local enemy_x, enemy_y = witch:getPosition(game.tileSize)
            
            if player_x == enemy_x and player_y == enemy_y then 

                if witch.body then witch.body:destroy() end

                game.enemies[i] = nil
                game.score = game.score + 200
                Entities.killWitch(i, game)
            end
        end
    end
end


local Module = {
    data = game,
    start = startButton,
    funcs = Game
}

return Module



