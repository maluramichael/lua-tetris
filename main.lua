function rubber_band(dx, dy)
    local dt = love.timer.getDelta()
    return dx * dt, dy * dt
end

function love.load()
    windowWidth = love.graphics.getWidth()
    windowHeight = love.graphics.getHeight()
    love.keyboard.setKeyRepeat(true)
    love.graphics.setDefaultFilter("nearest", "nearest", 0)
    defaultFont = love.graphics.newFont("assets/defaultFont.ttf", 32)
    image = love.graphics.newImage("assets/blocks.png")
    quad = love.graphics.newQuad(48, 80, 16, 16, image:getWidth(), image:getHeight())

    tilesize = 128

    quadscale = tilesize / 16
    padding = 0
    mapwidth = 8
    mapheight = 10
    map = {}
    for y = 1, mapheight do
        map[y] = {}
        for x = 1, mapwidth do
            map[y][x] = 0
        end
    end

    forms = {}
    forms.L = {{1, 0}, {1, 0}, {1, 1}}
    forms.J = {{0, 1}, {0, 1}, {1, 1}}
    forms.T = {{1, 1, 1}, {0, 1, 0}}
    forms.O = {{1, 1}, {1, 1}}
    forms.S = {{0, 1, 1}, {1, 1, 0}}
    forms.Z = {{1, 1, 0}, {0, 1, 1}}
    forms.I = {{1}, {1}, {1}, {1}}
    forms.TEST = {{1}}

    start = {x=3, y = 0}

    player = {
        x = start.x,
        y = start.y,
        form = forms.T
    }

    fallspeed = 1
    tick = fallspeed

    setform(0, 6)
end

function love.keypressed(key, scancode, isrepeat)
    -- print("key pressed: " .. key)
    if key == "escape" then
        love.event.quit()
    end

    if key == "left" then
        moveform(-1, 0)
    end
    if key == "right" then
        moveform(1, 0)
    end
    if key == "down" then
        moveform(0, 1)
        tick = fallspeed
    end
end

function love.keyreleased(key, scancode)
    -- print("key released: " .. key)
end

function love.update(dt)
    -- tick = tick - dt
    if tick <= 0 then
        moveform(0, 1)
        tick = fallspeed
    end
end

function moveform(dx, dy)
    if formmovable(dx, dy) == true then
        player.x = player.x + dx
        player.y = player.y + dy
    end
end

function formmovable(dx, dy)
    formwidth = #player.form[1]
    formheight = #player.form

    -- form goes down
    if dy == 1 then
        -- +1 because player.x and y starts with 0 and lua tables start with 1
        playerxinmap = player.x + 1
        playeryinmap = player.y + 1

        -- iterate through every block of the form
        for y = 1, #player.form do
            for x = 1, #player.form[y] do
                blockbelowx = playerxinmap + (x - 1)
                blockbelowy = playeryinmap + (y - 1) + 1

                blockbelow = map[blockbelowy][blockbelowx]

                -- check if anything is beneath the block
                if player.form[y][x] == 1 and blockbelow == 1 then
                    setform(player.x, player.y)
                    player.x = start.x
                    player.y = start.y
                    return false
                end
            end
        end

        if (player.y + formheight) < mapheight then
            return true
        end
    end

    if dx == -1 and (player.x) > 0 then
        return true
    end

    if dx == 1 and (player.x + formwidth) < mapwidth then
        return true
    end

    return false
end

function setform(xoffset, yoffset)
    for y = 1, #player.form do
        for x = 1, #player.form[y] do
            tile = player.form[y][x]
            if tile == 1 then
                map[y + yoffset][x + xoffset] = 1
            end
        end
    end
end

function renderform(xoffset, yoffset)
    for y = 1, #player.form do
        for x = 1, #player.form[y] do
            -- love.graphics.rectangle(
            --     "fill",
            --     (x + xoffset) * tilesize,
            --     (y + yoffset) * tilesize,
            --     tilesize - padding,
            --     tilesize - padding
            -- )
            if player.form[y][x] == 1 then
                love.graphics.draw(image, quad, (x + xoffset) * tilesize, (y + yoffset) * tilesize, 0, quadscale)
            end
        end
    end
end

function love.draw(dt)
    for y = 1, #map do
        for x = 1, #map[y] do
            tile = map[y][x]
            love.graphics.setColor(255, 255, 255, 50)
            love.graphics.rectangle("fill", x * tilesize, y * tilesize, tilesize - padding, tilesize - padding, 0)
            if tile == 1 then
                love.graphics.setColor(255, 0, 0, 255)
                love.graphics.draw(image, quad, x * tilesize, y * tilesize, 0, quadscale)
            end
        end
    end

    love.graphics.setColor(255, 255, 255, 255)
    renderform(player.x, player.y)
end
