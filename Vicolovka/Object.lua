-- template object with default atributes all objects have
Object = { 
    x = 0,
    y = 0,
    local_x = 1,
    local_y = 1,
    tile_type = "",
    height = 0,
    width = 0,
    hitboxWidth = 0,
    hitboxHeight = 0,
    texture = nil,
    type = ""
}
Object.__index = Object

function Object:new(world, x, y, width, height, hitboxWidth, hitboxHeight, type)
    local this = {
        x = x,
        y = y,
        local_x = 1, -- dodatne kordinate za vece slike poput ghostBox za obican tile su default 1 1
        local_y = 1,
        width = width,
        height = height,
        hitboxWidth = hitboxWidth,
        hitboxHeight = hitboxHeight,
        texture = nil, -- TODO: make textures
        type = type
    }

    setmetatable(this, self)

    if world then --moze se proslediti nil u konstruktor pa se pravi obj bez collidera
        makeCollider(world, this, type)
    end

    return this

end

function Object:renderTile()
    if self.texture then
        if self.tile_type == "ghostBox" then
            love.graphics.draw(self.texture, self.quad, self.x - self.width/2, self.y - self.height/2)
        else
            love.graphics.draw(self.texture, self.x - self.width/2, self.y - self.height/2) -- (self.x-1)*self.width (self.y-1)*self.height
            if self.entitie then
                love.graphics.draw(self.entitie.texture, self.x - self.width/2 + self.entitie.x_offset, self.y - self.height/2 + self.entitie.y_offset)
            end
        end
    end
    love.graphics.setColor(1,1,1)
end

function Object:render()
    if self.texture then
        --local texture = love.graphics.newImage(self.texture)
        love.graphics.draw(self.texture, self.x - self.width/2, self.y - self.height/2)
    end
    love.graphics.setColor(1,1,1)
end

function makeCollider(world, obj, type)
    obj.body = love.physics.newBody(world, obj.x, obj.y, type)
    obj.shape = love.physics.newRectangleShape(obj.hitboxWidth, obj.hitboxHeight)
    obj.fixture = love.physics.newFixture(obj.body, obj.shape)
    obj.body:setFixedRotation(true)
    
end
