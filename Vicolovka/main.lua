Map = {
        {1, 0, 1, 1, 1, 1, 0, 1, 1, 0, 1, 1, 1, 1, 0, 1},
        {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
        {1, 1, 0, 1, 1, 0, 1, 1, 1, 1, 0, 1, 1, 0, 1, 1},
        {1, 1, 0, 1, 1, 0, 1, 1, 1, 1, 0, 1, 1, 0, 1, 1},
        {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
        {1, 0, 1, 1, 1, 1, 0, 1, 1, 0, 1, 1, 1, 1, 0, 1},
        {1, 0, 1, 1, 1, 1, 0, 1, 1, 0, 1, 1, 1, 1, 0, 1},
        {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
        {1, 1, 0, 1, 1, 0, 1, 1, 1, 1, 0, 1, 1, 0, 1, 1},
        {1, 1, 0, 1, 1, 0, 1, 1, 1, 1, 0, 1, 1, 0, 1, 1},
        {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
        {1, 0, 1, 1, 1, 1, 0, 1, 1, 0, 1, 1, 1, 1, 0, 1},
}

local tileSize = 50;

function love.load()
        love.window.setMode(800, 600)
        player = {}
        player.x = 1 * tileSize + 20
        player.y = 0 * tileSize + 20
        player.speed = 64
end

function love.update(dt)
        if love.keyboard.isDown("right") then
                player.x = player.x + player.speed * dt
        end
        if love.keyboard.isDown("left") then
                player.x = player.x - player.speed * dt
        end
        if love.keyboard.isDown("up") then
                player.y = player.y - player.speed * dt
        end
        if love.keyboard.isDown("down") then
                player.y = player.y + player.speed * dt
        end

end


function love.draw()
        for y, row in ipairs(Map) do
                for x, tile in ipairs(row) do
                        if tile == 1 then
                                love.graphics.setColor(0.2, 0.2, 0.2)
                        else
                                love.graphics.setColor(0.8, 0.8, 0.8)
                        end
                        love.graphics.rectangle("fill", (x-1)*tileSize, (y-1)*tileSize, tileSize, tileSize)
                end
        end
        love.graphics.circle("fill", player.x, player.y, 20)
end
