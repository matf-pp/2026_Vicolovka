Enemy = setmetatable({}, Object)
Enemy.__index = Enemy

--local enemyTexture = ...
--local width, height = enemyTexture:getDimensions() TODO:enemy texture

function Enemy:new(world, x, y, speed, type) 
    local this = Object:new(world, x, y, width, height, width*0.6, height * 0.85, "dynamic")
    setmetatable(this, self)
    this.speed = speed
    this.enemyType = enemyType

    this.texture = enemyTexture
    return this
end

function Character:update(dt) -- TODO: make pathfinding
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

local node = {
    x = 0,
    y = 0,
    g = 0, -- currrent path length
    h = 0, -- est. path length
    f = 0, -- g + h
    parent = nil
}

local function distance(x1, y1, x2, y2) -- manhattan distance from node to node
    return math.abs(x1 - x2) + math.abs(y1 - y2)
end

local function nodeInList(list, x, y)
    for _,node in ipairs(list) do
        if node.x == x and node.y == y then
            return node
        end
    end
    return nil
end

function isWalkable(tile)
    return tile.tile_type == "path" or "ghostBox"
end

function A*(Map, startX, startY, endX, endY)
    local openSet = {}
    local closedSet = {}

    local startNode = {
        x = startX,
        y = startY,
        g = 0,
        h = distance(startX, startY, endX, endY)
    }

    startNode.f = startNode.g + startNode.h

    table.insert(openSet, startNode)

    while #openSet > 0 do
        local currIndex = 1
        local current = openSet[1]

        for i, node in ipairs(openSet) do
            if node.f < current.f then
                current = node
                currIndex = i
            end
        end

        if current.x == endX and current.y == endY then

            local path = {}

            while current do
                table.insert(path, 1, {x = current.x, y = current.y})
                current = current.parent
            end
            return path
        end

        table.remove(openSet, currIndex)
        table.insert(closedSet, current)

        local directions = {
            {1, 0},
            {-1, 0},
            {0, 1},
            {0, -1}
        }

        for _, dir in ipairs(directions) do
            
            local nx = current.x + dir[1]
            local ny = current.y + dir[2]

            if nx >= 1 and ny >= 1 and ny <= #grid and nx <= #grid[1] then

                if isWalkable(Map[nx][ny]) then

                    if not nodeInList(closedSet, nx, ny) then

                        local g = current.g + 1
                        local h = distance(nx, ny, endX, endY)
                        local f = g + h

                        local existing = nodeInList(openSet, nx, ny)

                        if not existing then

                            table.insert(openSet, {
                                x = nx,
                                y = ny,
                                g = g,
                                h = h,
                                f = f,
                                parent = current
                            })

                        elseif g < existing.g then
                            existing.g = g
                            existing.f = g + existing.h
                            existing.parent = current
                        end
                    end
                end
            end
        end
    end

    return nil
end