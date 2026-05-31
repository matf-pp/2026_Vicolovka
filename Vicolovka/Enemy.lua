require "AStar"

Enemy = setmetatable({}, Object)
Enemy.__index = Enemy

local enemyTexture = love.graphics.newImage("Assets/Vicolovka_Pulsifer1.png")
local width, height = enemyTexture:getDimensions()

function Enemy:findScatterTarget()
    if self.enemyType == "normal" then
        for y = 1, #Map do
            for x = Map_width, 1, -1 do
                if isWalkable(Map[y][x]) then
                    return x, y
                end
            end
        end
    elseif self.enemyType == "ambush" then
        for y = 1, #Map do
            for x = 1,#Map[1] do
                if isWalkable(Map[y][x]) then
                    return x, y
                end
            end
        end
    elseif self.enemyType == "normalWatcher" then
        for y = Map_height, 1, -1 do
            for x = 1, Map_width do
                if isWalkable(Map[y][x]) then
                    return x, y
                end
            end
        end
    elseif self.enemyType == "ambushWatcher" then
        for y = Map_height, 1, -1 do
            for x = Map_width, 1, -1 do
                if isWalkable(Map[y][x]) then
                    return x, y
                end
            end
        end
    end
end

function Enemy:new(world, x, y, speed, enemyType) 
    local this = Object:new(world, x, y, width, height, width*0.6, height * 0.8, "dynamic", "enemy")
    setmetatable(this, self)
    this.speed = speed
    this.enemyType = enemyType
    this.path = nil
    this.pathIndex = 1
    this.repathTimer = 0

    this.mode = "scatter"
    this.modeTimer = 7
    this.scatterCounter = 1
    this.scatterDuration = 7
    this.chaseDuration = 25

    this.scatterX, this.scatterY = this:findScatterTarget()

    if enemyType == "normalWatcher" or enemyType == "ambushWatcher" then
        this.playerTriggered = false
        this.mode = "chaseChild"
    end

    if enemyType == "normal" then
        this.texture = love.graphics.newImage("Assets/Vicolovka_WitchPurple.png")
    elseif enemyType == "ambush" then
        this.texture = love.graphics.newImage("Assets/Vicolovka_WitchRed.png")
    elseif enemyType == "normalWatcher" then
        this.texture = love.graphics.newImage("Assets/Vicolovka_WitchBlue.png")
    elseif enemyType == "ambushWatcher" then
        this.texture = love.graphics.newImage("Assets/Vicolovka_WitchClyde.png")
    end
    
    return this
end

function Enemy:getWatchedChildTile()
    if List_of_kids and #List_of_kids > 0 then
        return List_of_kids[1][1], List_of_kids[1][2]
    end
    return nil, nil
end

function Enemy:getWatchedChildTile2()
    if List_of_kids and #List_of_kids > 0 then
        return List_of_kids[2][1], List_of_kids[2][2]
    end
    return nil, nil
end

local function worldToTile(x, y, tileSize)
    local tileX = math.floor(x / tileSize) + 1
    local tileY = math.floor(y / tileSize) + 1

    return tileX, tileY
end

function Enemy:findChaseTarget(px, py)
    

    local tx, ty = worldToTile(px, py, tileSize)

    if self.enemyType == "normal" or self.enemyType == "normalWatcher" or self.enemyType == "ambushWatcher" then
        return tx, ty
    elseif self.enemyType == "ambush" then
        local offsetX = 0
        local offsetY = 0

        if love.keyboard.isDown("up") then
            offsetY = -5
        elseif love.keyboard.isDown("down") then
            offsetY = 5
        elseif love.keyboard.isDown("left") then
            offsetX = -5
        elseif love.keyboard.isDown("right") then
            offsetX = 5
        end

        tx = tx + offsetX
        ty = ty + offsetY

        tx = math.max(1, math.min(tx, Map_width))
        ty = math.max(1, math.min(ty, Map_height))

        return tx, ty
    end

end

function Enemy:switchMode()
    if self.enemyType == "normal" or self.enemyType == "ambush" then
        if self.mode == "chase" and self.scatterCounter <= 3 then
            self.mode = "scatter"
            self.modeTimer = self.scatterDuration   
            self.scatterCounter = self.scatterCounter + 1
        else
            self.mode = "chase"
            self.modeTimer = self.chaseDuration
        end
    end
    self.path = nil
    self.pathIndex = 1
end

function Enemy:switchMode2()
    if self.playerTriggered then
        self.mode = "chasePlayer"
        self.modeTimer = self.chaseDuration
        self.path = nil
        self.pathIndex = 1
        self.repathTimer = 0
        return
    end

    if self.mode == "chaseChild" then
        self.mode = "scatter"
        self.modeTimer = self.scatterDuration

    elseif self.mode == "scatter" then
        self.mode = "chaseChild"
        self.modeTimer = self.chaseDuration

    else
        self.mode = "chaseChild"
        self.modeTimer = self.chaseDuration
    end

    self.path = nil
    self.pathIndex = 1
    self.repathTimer = 0
end
function Enemy:update(dt) 
    self.modeTimer = self.modeTimer - dt
    self.repathTimer = self.repathTimer - dt


    if self.enemyType ~= "normalWatcher" and
       self.enemyType ~= "ambushWatcher" then

        if self.modeTimer <= 0 then
            self:switchMode()
        end
    end

    if self.repathTimer <= 0 then
        local enemyX, enemyY = self.body:getPosition()
        

        local startX, startY = worldToTile(enemyX, enemyY, tileSize)

        local endX, endY 

        if (self.enemyType == "normalWatcher" or self.enemyType == "ambushWatcher") and not self.playerTriggered then

            local px, py = player.body:getPosition()
            local ptx, pty = worldToTile(px, py, tileSize)

            local cx, cy
            if self.enemyType == "normalWatcher" then
                cx, cy = self:getWatchedChildTile()
            elseif self.enemyType == "ambushWatcher" then
                cx, cy = self:getWatchedChildTile2()
            end
            if ptx == cx and pty == cy then
                self.playerTriggered = true
                self.mode = "chasePlayer"
                self.repathTimer = 0
            end
        end

        if self.enemyType == "normal" or self.enemyType == "ambush" then

            if self.mode == "chase" then
                local px, py = player.body:getPosition()
                endX, endY = self:findChaseTarget(px, py)
            
            else
                endX = self.scatterX
                endY = self.scatterY
            end

        elseif self.enemyType == "normalWatcher" or self.enemyType == "ambushWatcher" then
            
            local cx, cy
            if self.mode == "chaseChild" then
                if self.enemyType == "normalWatcher" then
                    cx, cy = self:getWatchedChildTile()
                elseif self.enemyType == "ambushWatcher" then
                    cx, cy = self:getWatchedChildTile2()
                end

                endX = cx
                endY = cy

            elseif self.mode == "scatter" then
                endX, endY = self.scatterX, self.scatterY

            elseif self.mode == "chasePlayer" then
                local px, py = player.body:getPosition()
                endX, endY = self:findChaseTarget(px, py)
            end
        end

        self.path = AStar(Map, startX, startY, endX, endY)

        self.pathIndex = 1
        self.repathTimer = 1
    end

    if self.path and self.path[self.pathIndex] then
        local node = self.path[self.pathIndex]

        local targetX = (node.x - 1) * tileSize + tileSize/2

        local targetY = (node.y - 1) * tileSize + tileSize/2

        local ex, ey = self.body:getPosition()

        local dx = targetX - ex
        local dy = targetY - ey

        local dist = math.sqrt(dx*dx + dy*dy)

        if dist < 10 then

            self.body:setPosition(targetX, targetY)

            self.body:setLinearVelocity(0, 0)

            self.pathIndex = self.pathIndex + 1
            if self.enemyType == "normalWatcher" or self.enemyType == "ambushWatcher" then

                if self.pathIndex > #self.path then

                    if self.playerTriggered then
                        self.mode = "chasePlayer"

                    elseif self.mode == "chaseChild" then
                        self.mode = "scatter"

                    elseif self.mode == "scatter" then
                        self.mode = "chaseChild"
                    end

                    self.path = nil
                    self.pathIndex = 1
                    self.repathTimer = 0
                end
            end
        else
            dx = dx / dist
            dy = dy / dist

            self.body:setLinearVelocity(dx * self.speed, dy * self.speed)
        end
    else
        self.body:setLinearVelocity(0,0)
    end
    self.x, self.y = self.body:getPosition()
end

