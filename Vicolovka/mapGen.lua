math.randomseed(os.time())

O_shape = {{0,0}}
I_shape = {{0,0}, {0, 1}}
L_shape = {{0,0}, {-1, 0}, {0, 1}}
T_shape = {{0,0}, {0, 1}, {0, 2}, {1, 1}}
X_shape = {{0,0}, {1, 0}, {2, 0}, {1, -1}, {1, 1}}

Shapes = {O_shape, I_shape, L_shape, T_shape, X_shape}

local function map_init(width, height)
    local map = {}
    for row = 1, height do
        map[row] = {}
        for col = 1, width do
            if (row == 4 or row == 5) and (col == 1 or col == 2) then
                map[row][col] = -2
            else
                map[row][col] = -1
            end
        end
    end
    return map
end

local function rotate(shape)
    local rotate = {}
    for i = 1, #shape do
        local x = shape[i][1]
        local y = shape[i][2]

        rotate[i] = {-y, x}
    end
    return rotate
end

local function put_start(map)
    
    local start
    repeat
        start = math.random(1, #map)
    until start ~= 4 and start ~= 5

    map[start][1] = 0

    return start
end

local function check_shape(x, y, shape, map)
    for i = 1, #shape do
        local dx = shape[i][1]
        local dy = shape[i][2]

        local target_x = x + dx
        local target_y = y + dy

            
        if target_y < 1 or target_y > #map or target_x < 1 or target_x > #map[1] then
            return false
        elseif y == 7 and dy == 1 then
            return false
        elseif y == 8 and dy == -1 then
            return false
        elseif map[target_y][target_x] == -2 then
            return false
        elseif map[target_y][target_x] > 0 then
            return false
        end
    end 

    return true
end

local function get_valid_shapes(x, y, map)
    local check_shape_shapes = {}

    for _, shape in ipairs(Shapes) do
        local r_sh = shape
        if shape == O_shape then
            if check_shape(x, y, r_sh, map) then
                table.insert(check_shape_shapes, r_sh)
            end
        elseif shape == I_shape then
            for i = 1, 2 do
                if check_shape(x, y, r_sh, map) then
                    table.insert(check_shape_shapes, r_sh)
                end

                r_sh = rotate(r_sh)
            end
        else
           for i = 1, 4 do
                if check_shape(x, y, r_sh, map) then
                    table.insert(check_shape_shapes, r_sh)
                end

                r_sh = rotate(r_sh)
            end 
        end
    end

    return check_shape_shapes
end

local function next_pos(start_y, map)
    for y = start_y, #map do
        if map[y][1] == -1 then return 1 , y end
    end

    for x = 1, #map[1] do
        for y = 1, #map do
            if map[y][x] == -1 then return x, y end
        end
    end

    return -1, -1
end

local function put_shape(x, y, shape, map, num)

    for i = 1, #shape do
        local dx = shape[i][1]
        local dy = shape[i][2]

        map[y + dy][x + dx] = num
    end
    
    num = num + 1
    return num
end

local function tetris_gen(map)
    local tile_num = 0
    local start = put_start(map)

    local y = start
    local x = 1 
    local max_steps = #map * #map[1]

    for step = 1, max_steps do
        local valid_shapes = get_valid_shapes(x, y, map)

        if #valid_shapes > 0 then
            local chosen_shape = valid_shapes[math.random(#valid_shapes)]
            tile_num = put_shape(x, y, chosen_shape, map, tile_num)
        elseif map[y][x] == -1 then
            map[y][x] = tile_num
            tile_num = tile_num + 1
        end

        x, y = next_pos(y, map)
        if x == -1 then break end
    end

end

local function map_expand(map)
    local row = #map
    local col = #map[1]

    local ex_row = (row * 2) - 1
    local ex_col = (col * 2) - 1
    local ex_map = {}

    for i = 1, ex_row do
        ex_map[i] = {}
        for j = 1, ex_col do
            ex_map[i][j] = -1
        end
    end

    for y = 1, row do
        for x = 1, col do
            local ex = (x * 2) - 1
            local ey = (y * 2) - 1
            ex_map[ey][ex] = map[y][x]
        end
    end

    return ex_map
end

local function create_roads(map)
    -- TODO uvesti dodatni pregled mrtvih puteva
    for y = 1, #map do
        for x = 1, #map[1] do
            if y >= 7 and y <= 9 and x >= 1 and x <= 3 then
                map[y][x] = -2
            elseif y == 14 and x == 1 then
                map[y][x] = -1

            elseif map[y][x] == -1 then

                if x > 1 and x < #map[1] then
                    if map[y][x-1] > -1 and map[y][x+1] > -1 and map[y][x-1] == map[y][x+1] then
                        map[y][x] = map[y][x-1]
                    end
                end
                if y > 1 and y < #map then
                    if map[y-1][x] > -1 and map[y+1][x] > -1 and map[y-1][x] == map[y+1][x] then
                        map[y][x] = map[y-1][x]
                    end
                end
            end
        end
    end
end

local function reflect_matrix(map)
    local row = #map
    local col = #map[1]

    local re_col = col * 2
    local half = col

    local re_map = {}
    for i = 1, row do
        re_map[i] = {}
        for j = 1, re_col do
            re_map[i][j] = 0
        end
    end

    for i = 1, row do
        for j = 1, col do
            re_map[i][half + j] = map[i][j]
            re_map[i][half + 1 - j] = map[i][j]
        end
    end

    return re_map
end

function Gen_Map(width, height)
    local row = (height + 1) / 2  -- map_expand | height = (height * 2) - 1 | ovo je f^-1 da se dobija unesena visina
    local col = ((width / 2) + 1) / 2 -- map_expand radi isto plus reflect koji duplira | ovo je f^-1 da se dobije unesena sirina

    local map = map_init(col, row)

    tetris_gen(map)
    map = map_expand(map)
    create_roads(map)
    map = reflect_matrix(map)

    return map
end

