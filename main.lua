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

    tilesize = 64

    quadscale = tilesize / 16
    padding = 5
    mapwidth = 6
    mapheight = 23
    map = {}
    for y = 1, mapheight do
        map[y] = {}
        for x = 1, mapwidth do
            map[y][x] = 0
            -- debug
            if y == mapheight then
                map[y][x] = 1
            end
            if y == mapheight -1 then
                map[y][x] = math.random(0,1)
            end
        end
    end

    forms = {}
    forms["L"] = {
        {
            {1, 0, 0},
            {1, 0, 0},
            {1, 1, 0}
        },
        {
            {0, 0, 0},
            {0, 0, 1},
            {1, 1, 1}
        },
        {
            {0, 1, 1},
            {0, 0, 1},
            {0, 0, 1}
        },
        {
            {1, 1, 1},
            {1, 0, 0},
            {0, 0, 0}
        }
    }

    forms["J"] = {
        {
            {0, 0, 1},
            {0, 0, 1},
            {0, 1, 1}
        },
        {
            {1, 1, 1},
            {0, 0, 1},
            {0, 0, 0}
        },
        {
            {1, 1, 0},
            {1, 0, 0},
            {1, 0, 0}
        },
        {
            {0, 0, 0},
            {1, 0, 0},
            {1, 1, 1}
        }
    }

    forms["T"] = {
        {
            {1, 1, 1},
            {0, 1, 0},
            {0, 0, 0}
        },
        {
            {1, 0, 0},
            {1, 1, 0},
            {1, 0, 0}
        },
        {
            {0, 0, 0},
            {0, 1, 0},
            {1, 1, 1}
        },
        {
            {0, 0, 1},
            {0, 1, 1},
            {0, 0, 1}
        }
    }
    forms["O"] = {
        {
            {1, 1},
            {1, 1}
        }
    }

    forms["S"] = {
        {
            {0, 1, 1},
            {1, 1, 0},
            {0, 0, 0}
        },
        {
            {1, 0, 0},
            {1, 1, 0},
            {0, 1, 0}
        },
        {
            {0, 0, 0},
            {1, 1, 0},
            {0, 1, 1}
        },
        {
            {0, 0, 1},
            {0, 1, 1},
            {0, 1, 0}
        }
    }
    forms["Z"] = {
        {
            {1, 1, 0},
            {0, 1, 1},
            {0, 0, 0}
        },
        {
            {0, 1, 0},
            {1, 1, 0},
            {1, 0, 0}
        },
        {
            {0, 0, 0},
            {1, 1, 0},
            {0, 1, 1}
        },
        {
            {0, 0, 1},
            {0, 1, 1},
            {0, 1, 0}
        }
    }
    forms["I"] = {
        {
            {0, 1, 0, 0},
            {0, 1, 0, 0},
            {0, 1, 0, 0},
            {0, 1, 0, 0}
        },
        {
            {0, 0, 0, 0},
            {1, 1, 1, 1},
            {0, 0, 0, 0},
            {0, 0, 0, 0}
        }
    }

    start = {x = 3, y = 0}

    math.randomseed(os.time())

    player = {
        x = start.x,
        y = start.y,
        form = nil
    }

    resetplayer()

    fallspeed = 1
    tick = fallspeed
end

function rotate()
    local nextrotation = player.formrotation + 1
    if nextrotation > player.formmaxrotations then
        nextrotation = 1
    end
    player.formrotation = nextrotation
    player.form = player.formtype[nextrotation]
end

function randomelement(elements)
    -- iterate over whole table to get all keys
    local keyset = {}
    for k in pairs(elements) do
        table.insert(keyset, k)
    end

    -- now you can reliably return a random key
    return elements[keyset[math.random(#keyset)]]
end

function randomform()
    local randomtype = randomelement(forms)
    local maxrotations = #randomtype
    local randomindex = math.random(maxrotations)
    local randomform = randomtype[randomindex]
    return randomform, randomtype, randomindex, maxrotations
end

function love.keypressed(key, scancode, isrepeat)
    -- print("key pressed: " .. key)
    if key == "escape" then
        love.event.quit()
    end

    if key == "left" then
        moveform(-1, 0)
    end

    if key == "a" then
        rotate()
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
    -- +1 because player.x and y starts with 0 and lua tables start with 1
    playerxinmap = player.x + 1
    playeryinmap = player.y + 1

    -- iterate through every block of the form
    for y = 1, #player.form do
        for x = 1, #player.form[y] do
            if player.form[y][x] == 1 then
                checkx = (playerxinmap - 1) + x + dx
                checky = (playeryinmap - 1) + y + dy

                if checky > mapheight then
                    setform(player.x, player.y)
                    resetplayer()
                    return false
                end

                if checkx <= 0 then
                    return false
                end

                if checkx > mapwidth then
                    return false
                end

                blocktocheck = map[checky][checkx]

                -- check if anything is beneath the block
                if player.form[y][x] == 1 and blocktocheck == 1 then
                    if dy == 1 then
                        setform(player.x, player.y)
                        resetplayer()
                    end
                    return false
                end
            end
        end
    end

    return true
end

function resetplayer()
    player.x = start.x
    player.y = start.y

    if player.form == nil then
        player.form, player.formtype, player.formrotation, player.formmaxrotations = randomform()
    else
        player.form,
            player.formtype,
            player.formrotation,
            player.formmaxrotations = player.next, player.nexttype, player.nextrotation, player.nextmaxrotations
        player.next, player.nexttype, player.nextrotation, player.nextmaxrotations = randomform()
    end

    if player.next == nil then
        player.next, player.nexttype, player.nextrotation, player.nextmaxrotations = randomform()
    else
        player.next, player.nexttype, player.nextrotation, player.nextmaxrotations = randomform()
    end

    -- TODO: add loose condition
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

    checkforlines()
end

function collapsemap(aboveline)
    for y = aboveline, 2, -1 do
        map[y] = map[y - 1]
    end

    -- TODO: add 'addpoints' method
end

function removeline(line)
    for x = 1, #map[line] do
        map[line][x] = 0
    end

    collapsemap(line)
end

function checkforlines()
    for y = 1, #map do
        local activetilesinline = 0
        for x = 1, #map[y] do
            if map[y][x] == 1 then
                activetilesinline = activetilesinline + 1
            end
        end
        print(activetilesinline)
        if activetilesinline == mapwidth then
            removeline(y)
        end
    end
end

function renderform(form, xoffset, yoffset)
    for y = 1, #form do
        for x = 1, #form[y] do
            if form[y][x] == 1 then
                love.graphics.draw(image, quad, (x + xoffset) * tilesize, (y + yoffset) * tilesize, 0, quadscale)
            -- else
            --     love.graphics.rectangle(
            --         "fill",
            --         (x + xoffset) * tilesize,
            --         (y + yoffset) * tilesize,
            --         tilesize - padding,
            --         tilesize - padding
            --     )
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
    renderform(player.form, player.x, player.y)
    renderform(player.next, 11, 0)

    -- for y = 1, #map do
    --     for x = 1, #map[y] do
    --         love.graphics.setColor(255, 255, 255, 255)
    --         love.graphics.print(x .. " " .. y, x * tilesize, y * tilesize, 0, 2)
    --     end
    -- end
end
