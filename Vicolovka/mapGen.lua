require "Object"
require "Entities"

math.randomseed(os.time())



O_shape = {{0,0}}
I_shape = {{0,0}, {0, 1}}
L_shape = {{0,0}, {-1, 0}, {0, 1}}
T_shape = {{0,0}, {0, 1}, {0, 2}, {1, 1}}
X_shape = {{0,0}, {1, 0}, {2, 0}, {1, -1}, {1, 1}}

Shapes = {O_shape, I_shape, L_shape, T_shape, X_shape}

local function grid_init(width, height)
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

local function put_start(grid)
    
    local start
    repeat
        start = math.random(1, #grid)
    until start ~= 4 and start ~= 5

    grid[start][1] = 0

    return start
end

local function check_shape(x, y, shape, grid)

    for i = 1, #shape do
        local dx = shape[i][1]
        local dy = shape[i][2]

        local target_x = x + dx
        local target_y = y + dy

        --dead_end_check[1] = dead_end_check[1] + dx
        --dead_end_check[2] = dead_end_check[2] + dy

        if target_y < 1 or target_y > #grid or target_x < 1 or target_x > #grid[1] then
            return false
        elseif y == 7 and dy == 1 then
            return false
        elseif y == 8 and dy == -1 then
            return false
        elseif grid[target_y][target_x] == -2 then
            return false
        elseif grid[target_y][target_x] > 0 then
            return false
        end
    end 

    return true
end

local function get_valid_shapes(x, y, grid)
    local check_shape_shapes = {}

    for _, shape in ipairs(Shapes) do
        local r_sh = shape
        if shape == O_shape then
            if check_shape(x, y, r_sh, grid) then
                table.insert(check_shape_shapes, r_sh)
            end
        elseif shape == I_shape then
            for i = 1, 2 do
                if check_shape(x, y, r_sh, grid) then
                    table.insert(check_shape_shapes, r_sh)
                end

                r_sh = rotate(r_sh)
            end
        else
           for i = 1, 4 do
                if check_shape(x, y, r_sh, grid) then
                    table.insert(check_shape_shapes, r_sh)
                end

                r_sh = rotate(r_sh)
            end 
        end
    end

    return check_shape_shapes
end

local function next_pos(start_y, grid)
    for y = start_y, #grid do
        if grid[y][1] == -1 then return 1 , y end
    end

    for x = 1, #grid[1] do
        for y = 1, #grid do
            if grid[y][x] == -1 then return x, y end
        end
    end

    return -1, -1
end

local function put_shape(x, y, shape, grid, num)

    for i = 1, #shape do
        local dx = shape[i][1]
        local dy = shape[i][2]

        grid[y + dy][x + dx] = num
    end
    
    num = num + 1
    return num
end

local function tetris_gen(grid)
    local tile_num = 0
    local start = put_start(grid)

    local y = start
    local x = 1 
    local max_steps = #grid * #grid[1]

    for step = 1, max_steps do
        local valid_shapes = get_valid_shapes(x, y, grid)

        if #valid_shapes > 0 then
            local chosen_shape = valid_shapes[math.random(#valid_shapes)]
            tile_num = put_shape(x, y, chosen_shape, grid, tile_num)
        elseif grid[y][x] == -1 then
            grid[y][x] = tile_num
            tile_num = tile_num + 1
        end

        x, y = next_pos(y, grid)
        if x == -1 then break end
    end

end

local function grid_expand(grid)
    local row = #grid
    local col = #grid[1]

    local ex_row = (row * 2) - 1
    local ex_col = (col * 2) - 1
    local ex_grid = {}

    for i = 1, ex_row do
        ex_grid[i] = {}
        for j = 1, ex_col do
            ex_grid[i][j] = -1
        end
    end

    for y = 1, row do
        for x = 1, col do
            local ex = (x * 2) - 1
            local ey = (y * 2) - 1
            ex_grid[ey][ex] = grid[y][x]
        end
    end

    return ex_grid
end

local function create_roads(grid)
    -- TODO uvesti dodatni pregled mrtvih puteva
    for y = 1, #grid do
        for x = 1, #grid[1] do
            if y >= 7 and y <= 9 and x >= 1 and x <= 3 then
                grid[y][x] = -2
            elseif y == 14 and x == 1 then
                grid[y][x] = -1

            elseif grid[y][x] == -1 then

                if x > 1 and x < #grid[1] then
                    if grid[y][x-1] > -1 and grid[y][x+1] > -1 and grid[y][x-1] == grid[y][x+1] then
                        grid[y][x] = grid[y][x-1]
                    end
                end
                if y > 1 and y < #grid then
                    if grid[y-1][x] > -1 and grid[y+1][x] > -1 and grid[y-1][x] == grid[y+1][x] then
                        grid[y][x] = grid[y-1][x]
                    end
                end
            end
        end
    end
end

local function reflect_grid(grid)
    local row = #grid
    local col = #grid[1]

    local re_col = col * 2
    local half = col

    local re_grid = {}
    for i = 1, row do
        re_grid[i] = {}
        for j = 1, re_col do
            re_grid[i][j] = 0
        end
    end

    for i = 1, row do
        for j = 1, col do
            re_grid[i][half + j] = grid[i][j]
            re_grid[i][half + 1 - j] = grid[i][j]
        end
    end

    return re_grid
end

local function dfs(x, y, visited, grid)
    visited[y][x] = 1;

    for i = -1, 1 do
        for j = -1, 1 do
            if(y + i >= 1 and y + i <= #grid and x + j >= 1 and x + j <= #grid[1]) then
                if(visited[y + i][x + j] == 0 and grid[y + i][x + j] == -1) then
                    visited[y + i][x + j] = 1
                    dfs(x + j, y + i, visited, grid)
                end
            end
        end
    end
end

local function clear_dead_ends(grid, start_x, start_y)
    local visited = {}
    for i = 1, #grid do
        visited[i] = {}
        for j = 1, #grid[1] do
            visited[i][j] = 0;
        end
    end


    dfs(start_x, start_y, visited, grid)

    for i = 1, #grid do
        for j = 1, #grid[1] do
            if grid[i][j] == -1 and visited[i][j] == 0 then
                grid[i][j] = 1
            end
        end
    end
end

local function uniform_grid(grid)
    for i = 1, #grid do
        for j = 1, #grid[i] do
            if grid[i][j] > -1 then
                grid[i][j] = 1
            elseif grid[i][j] == -1 then
                grid[i][j] = 0
            end
        end
    end
end

local function get_tileType(x, y, grid)
    if grid[y][x] == -2 then
        return "ghostBox"
    elseif grid[y][x] == 1 then
        return "wall"
    else
        return "path"
    end
end

local function make_map(grid, map, tileSize, world)
    local largeStructY = nil
    local largeStructX = nil

    --ovde pozivam jednom funkciju umesto u petlji svaki put
    local grassTexture = love.graphics.newImage("Assets/Vicolovka_grass.png")
    local pathTexture = love.graphics.newImage("Assets/Vicolovka_path.png")
    local ghostBox = love.graphics.newImage("Assets/Vicolovka_GhostBox_empty.png")

    for y = 1, #grid do
        map[y] = {}
        for x = 1, #grid[y] do
            
            local tileType = get_tileType(x, y, grid)

            local tile
            --podelio sam tile na wall i path i pozvao odvojene konstruktore            
            if tileType == "wall" then
                tile = Object:new(world, (x-1)*tileSize + tileSize/2, (y-1)*tileSize + tileSize/2, tileSize, tileSize, tileSize, tileSize, "static", "wall")
            elseif tileType == "ghostBox" then
                tile = Object:new(world, (x-1)*tileSize + tileSize/2, (y-1)*tileSize + tileSize/2, tileSize, tileSize, tileSize, tileSize, "static", "ghostBox")
            elseif tileType == "path" then
                tile = Object:new(nil, (x-1)*tileSize + tileSize/2, (y-1)*tileSize + tileSize/2, tileSize, tileSize, tileSize, tileSize, "static")
            end
            
            tile.tile_type = tileType
            tile.entity = nil
            
            if tileType == "ghostBox" then
                if not largeStructY then
                    largeStructY = y
                    largeStructX = x
                end

                local x_offset = x - largeStructX
                local y_offset = y - largeStructY

                tile.local_x =  x_offset * tileSize
                tile.local_y =  y_offset * tileSize


                tile.quad = love.graphics.newQuad(tile.local_x, tile.local_y, tileSize, tileSize, ghostBox)
                tile.texture = ghostBox
            elseif tileType == "wall" then

                
                tile.texture = grassTexture
                tile.entity = Entities.create("forest")
            else
                
                tile.texture = pathTexture
                tile.entity = Entities.create("breadCrumb") 
            end

            
            map[y][x] = tile
        end
    end
end

function Gen_Map(width, height, tileSize, world)
    local row = (height + 1) / 2  -- map_expand | height = (height * 2) - 1 | ovo je f^-1 da se dobija unesena visina
    local col = ((width / 2) + 1) / 2 -- map_expand radi isto plus reflect koji duplira | ovo je f^-1 da se dobije unesena sirina

    local grid = grid_init(col, row)

    tetris_gen(grid)
    grid = grid_expand(grid)
    create_roads(grid)
    grid = reflect_grid(grid)
    clear_dead_ends(grid, 14, 9)
    uniform_grid(grid)

    local map = {}

    make_map(grid, map, tileSize, world)

    return map
end
