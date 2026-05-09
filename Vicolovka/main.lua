Map = {
        {1, 0, 1, 1, 1, 1, 0, 1},
        {0, 0, 0, 0, 0, 0, 0, 0},
        {1, 1, 0, 1, 1, 0, 1, 1},
        {1, 1, 0, 1, 1, 0, 1, 1},
        {0, 0, 0, 0, 0, 0, 0, 0},
        {1, 0, 1, 1, 1, 1, 0, 1},
}

local tileSize = 32;


function love.load()
        love.window.setMode(800, 600)
end

function love.update(dt)

end


function love.draw()
        love.graphics.print("Hello World!", 400 , 300)
end;
