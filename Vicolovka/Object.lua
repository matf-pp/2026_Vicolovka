-- template object with default atributes all objects have
Object = { 
    x = 0,
    y = 0,
    local_x = 1,
    local_y = 1,
    tile_type = "",
    height = 0,
    width = 0,
    texture = nil,
    type = ""
}
Object.__index = Object

function Object:new(world, x, y, width, height, type)
    local this = {
        x = x,
        y = y,
        local_x = 1, -- dodatne kordinate za vece slike poput ghostBox za obican tile su default 1 1
        local_y = 1,
        width = width,
        height = height,
        texture = nil, -- TODO: make textures
        type = type
    }

    setmetatable(this, self)

    makeCollider(world, this, type)

    return this

end

function Object:renderTile()
    if self.texture then
        --local texture = love.graphics.newImage(self.texture)
        love.graphics.draw(self.texture, (self.x-1)*self.width, (self.y-1)*self.height) -- TODO: make texture
    end
    love.graphics.setColor(1,1,1)
end

function Object:render()
    if self.texture then
        --local texture = love.graphics.newImage(self.texture)
        love.graphics.draw(self.texture, self.x, self.y) -- TODO: make texture
    end
    love.graphics.setColor(1,1,1)
end

function makeCollider(world, obj, type)
    obj.body = love.physics.newBody(world, obj.x, obj.y, type)
    obj.shape = love.physics.newRectangleShape(obj.width/2, obj.height/2, obj.width, obj.height)
    obj.fixture = love.physics.newFixture(obj.body, obj.shape)
    obj.body:setFixedRotation(true)
    
end
