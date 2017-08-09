Gamestate = require "libs.hump.gamestate"
menu = require "menu"
game = require "game"

function love.load()
    Gamestate.registerEvents()
    Gamestate.switch(menu)
end

function love.draw(dt)
end
