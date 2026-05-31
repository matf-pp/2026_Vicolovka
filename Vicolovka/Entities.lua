math.randomseed(os.time())

local entitiesDef = {
    forest = {
        --properties(if it has any)
        isStatic = true,
        isChild = false,
        isGun = false,
        --rendering(renders on x and y cords of the tile that has it)
        texture = love.graphics.newImage("Assets/Vicolovka_forest.png"),
        x_offset = 0,
        y_offset = -8
        --
    },

    breadCrumb = {
        --properties
        isStatic = true,
        isChild = false,
        isGun = false,
        --rendering
        texture = love.graphics.newImage("Assets/Vicolovka_BreadCrumb.png"), -- make texture
        x_offset = 0,
        y_offset = 0
    },

    boy = {
        --properties
        isStatic = true,
        isChild = true,
        isGun = false,
        --rendering
        texture = love.graphics.newImage("Assets/Vicolovka_ChildMale.png"), -- make texture
        x_offset = 0,
        y_offset = 0
    },

    girl = {
        --properties
        isStatic = true,
        isChild = true,
        isGun = false,
        --rendering
        texture = love.graphics.newImage("Assets/Vicolovka_ChildFemale.png"), -- make texture
        x_offset = 0,
        y_offset = 0
    },

    gun = {
        --properties
        isStatic = true,
        isChild = false,
        isGun = true,
        --rendering
        texture = love.graphics.newImage("Assets/Vicolovka_Gun.png"),
        x_offset = 0,
        y_offset = 0
    },

    blueWitch = {
        --properties
        isStatic = true,
        isChild = false,
        isGun = false,
        --rendering
        texture = love.graphics.newImage("Assets/Vicolovka_WitchBlue.png"),
        x_offset = 0,
        y_offset = 0
    },
    redWitch = {
        --properties
        isStatic = true,
        isChild = false,
        isGun = false,
        --rendering
        texture = love.graphics.newImage("Assets/Vicolovka_WitchRed.png"),
        x_offset = 0,
        y_offset = 0
    },
    purpleWitch = {
        --properties
        isStatic = true,
        isChild = false,
        isGun = false,
        --rendering
        texture = love.graphics.newImage("Assets/Vicolovka_WitchPurple.png"),
        x_offset = 0,
        y_offset = 0
    },
    clydeWitch = {
        --properties
        isStatic = true,
        isChild = false,
        isGun = false,
        --rendering
        texture = love.graphics.newImage("Assets/Vicolovka_WitchClyde.png"),
        x_offset = 0,
        y_offset = 0
    },


    
}

Entities = {} -- empty table serves as a factory for entities

function Entities.create(type)
    local def = entitiesDef[type]
    if not def then return nil end

    if def.isStatic then
        return def;
    end
end


function Entities.place_child(map, num, list_of_kids)
    local possible_locations = {}
    local possible_child = {"boy", "girl"}
    for y = 1 , #map do
        for x = 1 , #map[y] do
            if(map[y][x].tile_type == "path" and (x < 3 or x > #map[y] - 2) and (y < 3 or y > #map - 2)) then
                table.insert(possible_locations, {x,y})
            end
        end
    end

    for i = 1, num do
        if #possible_locations == 0 then
            break
        end
        local chosen_position = math.random(1, #possible_locations)
        local child_tile = possible_locations[chosen_position]
        table.remove(possible_locations, chosen_position)
        local chosen_child = math.random(1, #possible_child)
        local child = possible_child[chosen_child]

        map[child_tile[2]][child_tile[1]].entity = Entities.create(child)
        table.insert(list_of_kids, child_tile)
    end
end

function Entities.place_gun(map, num)
    local possible_locations = {}
    local possible_child = {"boy", "girl"}
    for y = 1 , #map do
        for x = 1 , #map[y] do
            if(map[y][x].tile_type == "path") then
                table.insert(possible_locations, {x,y})
            end
        end
    end

    for i = 1, num do
        if #possible_locations == 0 then
            break
        end
        local chosen_position = math.random(1, #possible_locations)
        local gun_tile = possible_locations[chosen_position]
        table.remove(possible_locations, chosen_position)

        map[gun_tile[2]][gun_tile[1]].entity = Entities.create("gun")
    end
end