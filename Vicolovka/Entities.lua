local entitiesDef = {
    forest = {
        --properties(if it has any)
        isStatic = true,
        --rendering(renders on x and y cords of the tile that has it)
        texture = love.graphics.newImage("Assets/Vicolovka_forest.png"),
        x_offset = 0,
        y_offset = -8
        --
    },

    breadCrumb = {
        --properties
        isStatic = true,
        --rendering
        texture = nil, -- make texture
        x_offset = 0,
        y_offset = 0
    },

    child = {
        --properties
        isStatic = true,
        --rendering
        texture = nil, -- make texture
        x_offset = 0,
        y_offset = 0
    },

    gun = {
        --properties
        isStatic = false,
        --rendering
        texture = nil, -- make texture
        x_offset = 0,
        y_offset = 0
    }
}

Entities = {} -- empty table serves as a factory for entities

function Entities.create(type)
    local def = entitiesDef[type]
    if not def then return nil end

    if def.isStatic then
        return def;
    else
        -- TODO implement dinamic entities and how to return them
    end
end