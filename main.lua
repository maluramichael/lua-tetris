Gamestate = require "libs.hump.gamestate"
game = require "game"

function love.load()
    Gamestate.registerEvents()
    Gamestate.switch(game)
end

function love.draw(dt)
end
