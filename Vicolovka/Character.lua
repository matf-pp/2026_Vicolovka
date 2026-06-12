--tamplate used for player atributes
Character = setmetatable({}, Object)
Character.__index = Character

local playerTexture = love.graphics.newImage("Assets/Vicolovka_Pulsifer1.png")
local width, height = playerTexture:getDimensions()

function Character:create(world, x, y, speed) 
    local this = Object:new(world, x, y, width, height, width*0.6, height * 0.75, "dynamic", "player")
    setmetatable(this, self)
    this.speed = speed
    
    this.texture = playerTexture
    return this
end

function Character:update(dt)
    local dx, dy = 0, 0
    if love.keyboard.isDown("right") then
        dx = self.speed
    end
    if love.keyboard.isDown("left") then
        dx = - self.speed
    end
    if love.keyboard.isDown("up") then
        dy = - self.speed
    end
    if love.keyboard.isDown("down") then
        dy = self.speed
    end
    self.body:setLinearVelocity(dx, dy)
    self.x, self.y = self.body:getPosition()
end

function Character:getTile(game)
    local player_x, player_y = self:getPosition(game.tileSize)
    local player_tile = nil

    if game.map[player_y] and game.map[player_y][player_x] then
        player_tile = game.map[player_y][player_x]
    end

    return player_tile
end

function Character:getPosition(tileSize)
    local player_x = math.floor(self.x / tileSize) + 1
    local player_y = math.floor(self.y / tileSize) + 1

    return player_x, player_y
end


