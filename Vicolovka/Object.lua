-- template object with default atributes all objects have
Object = { 
    x = 0,
    y = 0,
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
        width = width,
        height = height,
        texture = nil, -- TODO: make textures
        type = type
    }

    setmetatable(this, self)

    makeCollider(world, this, type)

    return this

end

function Object:render()
    --if self.texture then
    --    love.graphics.texture(texture, self.x, self.y) -- TODO: make texture
    --end
    love.graphics.setColor(1,1,1)
    love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
end

function makeCollider(world, obj, type)
    obj.body = love.physics.newBody(world, obj.x, obj.y, type)
    obj.shape = love.physics.newRectangleShape(obj.width/2, obj.height/2, obj.width, obj.height)
    obj.fixture = love.physics.newFixture(obj.body, obj.shape)
    obj.body:setFixedRotation(true)
    
end