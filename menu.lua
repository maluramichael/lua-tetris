Gamestate = require "libs.hump.gamestate"

game = require "game"

local menu = {}

function menu:init()
    imagefont = love.graphics.newImageFont("assets/tristarf.png", '!"%`{} -./0123456789:;=?ABCDEFGHIJKLMNOPQRSTUVWXYZ')
    header = love.graphics.newText(imagefont, "TETRIS")
    instructions = love.graphics.newText(imagefont, "PRESS SPACE TO START")
end

function menu:keypressed(key)
    if key == "space" then
        Gamestate.switch(game)
    end

    if key == "escape" then
        love.event.quit()
    end
end

function menu:update(dt)
end

function menu:draw()
    love.graphics.draw(header, 100, 100, 0, 3, 3)
    love.graphics.draw(instructions, 100, 300, 0, 2, 2)
end

return menu
