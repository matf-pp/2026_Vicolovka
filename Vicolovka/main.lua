require("mapGen")

Map = Gen_Map(26, 21)

local tileSize = 16;

function love.load()
        love.window.setMode(1600, 900)
        player = {}
        player.x = 8 * tileSize + 20
        player.y = 13 * tileSize + 20
        player.speed = 128
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
                        if tile == -1 then
                                love.graphics.setColor(0.8, 0.8, 0.8)
                        elseif tile == -2 then
                                love.graphics.setColor(0.5, 0.5, 0.5)
                        else
                                love.graphics.setColor(0.2, 0.2, 0.2)
                        end
                        love.graphics.rectangle("fill", (x-1)*tileSize, (y-1)*tileSize, tileSize, tileSize)
                end
        end
        love.graphics.setColor(1, 1, 1)
        love.graphics.circle("fill", player.x, player.y, tileSize / 2)
        love.graphics.setColor(0.2, 0.2, 0.2)
end
