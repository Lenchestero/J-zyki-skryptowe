json = require "json"
io.stdout:setvbuf("no")


current_scene = "menu"

GRID_WIDTH = 14
GRID_HEIGHT = 24
BLOCK_SIZE = 40
fallTimer = 0
fallInterval = 0.5
clearedLines = 0
gameOver = false
linesToClear = {}
isAnimating = false
animationVisible = true
animationTimer = 0
animationDuration = 0.5

board = {}

different_blocks = {
    A = {
        {1, 1, 1, 1}
    },
    B = {
        {1, 1},
        {1, 1}
    },
    C = {
        {0, 1, 0},
        {1, 1, 1}
    },
    D = {
        {0, 1, 1},
        {1, 1, 0}
    }
}

sound = {}

function love.load()
    love.window.setTitle("Tetris LOVE")
    love.window.setMode(GRID_WIDTH * BLOCK_SIZE, GRID_HEIGHT * BLOCK_SIZE)
    font = love.graphics.newFont("Savate.ttf", 52)
    math.randomseed(os.time())


    for y = 1, GRID_HEIGHT do
        board[y] = {}
        for x = 1, GRID_WIDTH do
            board[y][x] = nil
        end
    end
    spawnPiece()

    sound.rotate = love.audio.newSource("audio/real-swish_3.mp3", "static")
    sound.clear = love.audio.newSource("audio/arcade-ui-18.mp3", "static")
    sound.loss = love.audio.newSource("audio/arcade-ui-4.mp3", "static")
    sound.placing = love.audio.newSource("audio/epic-object-placing.mp3", "static")
    sound.move = love.audio.newSource("audio/swipe.mp3", "static")
    sound.menu = love.audio.newSource("audio/ui-button-click-5.mp3", "static")
end

function playSoundClone(src)
    local s = src:clone()
    s:play()
end

function colorToString(color)
    return string.format("%.3f,%.3f,%.3f", color[1], color[2], color[3])
end

function spawnPiece()
    local keys = {}
    for k in pairs(different_blocks) do
        table.insert(keys, k)
    end

    local randomKey = keys[math.random(#keys)]
    local shape = different_blocks[randomKey]

    local r = 0.5 + math.random() * 0.5
    local g = 0.5 + math.random() * 0.5
    local b = 0.5 + math.random() * 0.5

    local newPiece = {
        shape = shape,
        x = math.floor(GRID_WIDTH / 2) - math.floor(#shape[1] / 2) + 1,
        y = 1,
        color = {r, g, b}
    }

    if canMove(newPiece, 0, 0) then
        currentPiece = newPiece
    else
        gameOver = true
        sound.loss:play()
    end
end

function drawPiece()
    for y = 1, #currentPiece.shape do
        for x = 1, #currentPiece.shape[y] do
            if currentPiece.shape[y][x] == 1 then
                local drawX = (currentPiece.x + x - 1) * BLOCK_SIZE
                local drawY = (currentPiece.y + y - 1) * BLOCK_SIZE
                love.graphics.setColor(currentPiece.color)
                love.graphics.rectangle("fill", drawX, drawY, BLOCK_SIZE, BLOCK_SIZE)
                love.graphics.setColor(0, 0, 0)
                love.graphics.rectangle("line", drawX, drawY, BLOCK_SIZE, BLOCK_SIZE)
            end
        end
    end
    love.graphics.setColor(1, 1, 1)
end

function canMove(piece, dx, dy)
    for y = 1, #piece.shape do
        for x = 1, #piece.shape[y] do
            if piece.shape[y][x] == 1 then
                local newX = piece.x + x + dx
                local newY = piece.y + y + dy

                if newX < 1 or newX > GRID_WIDTH or newY < 1 or newY > GRID_HEIGHT then
                    return false
                end

                if board[newY][newX] ~= nil then
                    return false
                end
            end
        end
    end
    return true
end

function rotateMatrix(matrix)
    local rotated = {}
    local rows = #matrix
    local cols = #matrix[1]

    for x = 1, cols do
        rotated[x] = {}
        for y = rows, 1, -1 do
            table.insert(rotated[x], matrix[y][x])
        end
    end
    playSoundClone(sound.rotate)
    return rotated
end

function movePieceDown()
    if canMove(currentPiece, 0, 1) then
        currentPiece.y = currentPiece.y + 1
        playSoundClone(sound.move)
    else
        placePiece()
        clearLines()
        spawnPiece()
    end
end

function hardDrop()
    while canMove(currentPiece, 0, 1) do
        currentPiece.y = currentPiece.y + 1
    end
    placePiece()
    clearLines()
    spawnPiece()
end

function placePiece()
    for y = 1, #currentPiece.shape do
        for x = 1, #currentPiece.shape[y] do
            if currentPiece.shape[y][x] == 1 then
                local boardX = currentPiece.x + x
                local boardY = currentPiece.y + y
                if boardY >= 1 and boardY <= GRID_HEIGHT and boardX >= 1 and boardX <= GRID_WIDTH then
                    board[boardY][boardX] = currentPiece.color
                end
            end
        end
    end
    playSoundClone(sound.placing)
    saveBoard()
end

function clearLines()
    linesToClear = {}
    for y = GRID_HEIGHT, 1, -1 do
        local full = true
        for x = 1, GRID_WIDTH do
            if board[y][x] == nil then
                full = false
                break
            end
        end
        if full then
            table.insert(linesToClear, y)
        end
    end

    if #linesToClear > 0 then
        animationTimer = 0
        isAnimating = true
        animationVisible = true
        playSoundClone(sound.clear)
    end
end

function updateLineClear(dt)
    if  isAnimating then
        animationTimer = animationTimer + dt
        if animationTimer >= animationDuration then
            table.sort(linesToClear, function(a, b) return a > b end)
            for _, y in ipairs(linesToClear) do
                table.remove(board, y)
            end

            for i = 1, #linesToClear do
                local newLine = {}
                for x = 1, GRID_WIDTH do
                    newLine[x] = nil
                end
                table.insert(board, 1, newLine)
            end

            clearedLines = clearedLines + #linesToClear
            love.filesystem.write("score_save.txt", tostring(clearedLines))
            saveBoard()

            linesToClear = {}
            isAnimating = false
        else
            animationVisible = math.floor(animationTimer * 10) % 2 == 0
        end
    end
end


function drawBoard()
    for y = 1, GRID_HEIGHT do
        for x = 1, GRID_WIDTH do
            local drawX = (x - 1) * BLOCK_SIZE
            local drawY = (y - 1) * BLOCK_SIZE

           if board[y][x] ~= nil then
            local shouldFlash = false
            for _, clearY in ipairs(linesToClear) do
                if y == clearY then
                    shouldFlash = true
                    break
                end
            end

            if not (shouldFlash and isAnimating and not animationVisible) then
                local color = board[y][x]
                if shouldFlash and  isAnimating then
                    love.graphics.setColor(1, 1, 1)
                else
                    love.graphics.setColor(color[1], color[2], color[3])
                end
                love.graphics.rectangle("fill", drawX, drawY, BLOCK_SIZE, BLOCK_SIZE)
            end

            else
                love.graphics.setColor(0.9, 0.9, 0.9, 0.1)
                love.graphics.rectangle("line", drawX, drawY, BLOCK_SIZE, BLOCK_SIZE)
            end

            love.graphics.setColor(0, 0, 0)
            love.graphics.rectangle("line", drawX, drawY, BLOCK_SIZE, BLOCK_SIZE)
        end
    end
end

function saveBoard()
    local saveData = {}

    for y = 1, GRID_HEIGHT do
        saveData[y] = {}
        for x = 1, GRID_WIDTH do
            if board[y][x] ~= nil then
                saveData[y][x] = colorToString(board[y][x])
            else
                saveData[y][x] = false
            end
        end
    end

    local jsonData = json.encode(saveData)
    love.filesystem.write("board_save.json", jsonData)
end

function resetBoard()
    for y = 1, GRID_HEIGHT do
        board[y] = {}
        for x = 1, GRID_WIDTH do
            board[y][x] = nil
        end
    end
end

function stringToColor(s)
    local r, g, b = s:match("([^,]+),([^,]+),([^,]+)")
    return {tonumber(r), tonumber(g), tonumber(b)}
end

function loadBoard()
    if love.filesystem.getInfo("board_save.json") then
        local data = love.filesystem.read("board_save.json")
        local loaded = json.decode(data)

        for y = 1, GRID_HEIGHT do
            board[y] = {}
            for x = 1, GRID_WIDTH do
                if loaded[y][x] and type(loaded[y][x]) == "string" then
                    board[y][x] = stringToColor(loaded[y][x])
                else
                    board[y][x] = nil
                end
            end
        end
    else
        resetBoard()
    end
    if love.filesystem.getInfo("score_save.txt") then
        local data = love.filesystem.read("score_save.txt")
        clearedLines = tonumber(data) or 0
    else
        clearedLines = 0
    end
end

function love.draw()
    if current_scene == "menu" then
        love.graphics.clear(0,0,0, 1)
        drawMenu()
    elseif current_scene == "game" then
        drawGame()
    end
end

function love.update(dt)
    if gameOver then return end
    if current_scene == "game" then
        updateLineClear(dt)
        if not  isAnimating then
            fallTimer = fallTimer + dt
            if fallTimer >= fallInterval then
                fallTimer = 0
                movePieceDown()
            end
        end
    end
end


function love.keypressed(key)
    if current_scene == "menu" then
        if  key == "return" then
            playSoundClone(sound.menu)
            current_scene = "game"
            return
        elseif key == "space" then
            playSoundClone(sound.menu)
            current_scene = "game"
            loadBoard()
            return
        end
    end

    if current_scene == "game" then
        if key == "left" and canMove(currentPiece, -1, 0) then
            currentPiece.x = currentPiece.x - 1
            playSoundClone(sound.move)
        elseif key == "up" then
            local rotatedShape = rotateMatrix(currentPiece.shape)
            local testPiece = {
                shape = rotatedShape,
                x = currentPiece.x,
                y = currentPiece.y
            }
            if canMove(testPiece, 0, 0) then
                currentPiece.shape = rotatedShape
            end
        elseif key == "right" and canMove(currentPiece, 1, 0) then
            currentPiece.x = currentPiece.x + 1
            playSoundClone(sound.move)
        elseif key == "down" then
            movePieceDown()
            playSoundClone(sound.move)
        elseif key == "space" then
            hardDrop()
        elseif key == "escape" then
            playSoundClone(sound.menu)
            current_scene = "menu"
            gameOver = false
            clearedLines = 0
            resetBoard()
            return 
        end
    end
end

function drawMenu()
    love.graphics.setColor(123/255, 75/255, 148/255, 1)
    local squareSize = 400
    local squareX = (GRID_WIDTH * BLOCK_SIZE - squareSize) / 2
    local squareY = (GRID_HEIGHT * BLOCK_SIZE - squareSize) / 2
    love.graphics.rectangle("fill", squareX, squareY, squareSize, squareSize)

    love.graphics.setColor(196/255, 255/255, 178/255, 1) 
    love.graphics.setFont(font)
    love.graphics.printf("TETRIS", 0, GRID_HEIGHT * BLOCK_SIZE / 3, GRID_WIDTH * BLOCK_SIZE, "center")
    love.graphics.setFont(love.graphics.newFont("Savate.ttf",20))
    love.graphics.printf("Press Enter to start new", 0, GRID_HEIGHT * BLOCK_SIZE / 2, GRID_WIDTH * BLOCK_SIZE, "center")
    love.graphics.printf("Press Space to load from checkpoint", 0, GRID_HEIGHT * BLOCK_SIZE / 2 + 20, GRID_WIDTH * BLOCK_SIZE, "center")

    local controlsFont = love.graphics.newFont("Savate.ttf", 16)
    love.graphics.setFont(controlsFont)

    local startY = GRID_HEIGHT * BLOCK_SIZE / 2 + 40
    local spacing = 22

    love.graphics.printf("← : Move Left", 0, startY, GRID_WIDTH * BLOCK_SIZE, "center")
    love.graphics.printf("→ : Move Right", 0, startY + spacing, GRID_WIDTH * BLOCK_SIZE, "center")
    love.graphics.printf("↑ : Rotate", 0, startY + spacing * 2, GRID_WIDTH * BLOCK_SIZE, "center")
    love.graphics.printf("↓ : Soft Drop", 0, startY + spacing * 3, GRID_WIDTH * BLOCK_SIZE, "center")
    love.graphics.printf("Space : Hard Drop", 0, startY + spacing * 4, GRID_WIDTH * BLOCK_SIZE, "center")
end

function drawGame()
    drawBoard()
    drawPiece()
    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(love.graphics.newFont("Savate.ttf", 20))
    love.graphics.print("Score: " .. tostring(clearedLines), 10, 10)

    if gameOver then

        love.graphics.setColor(123/255, 75/255, 148/255, 0.2)
        local squareSize = 400
        local squareX = (GRID_WIDTH * BLOCK_SIZE - squareSize) / 2
        local squareY = (GRID_HEIGHT * BLOCK_SIZE - squareSize) / 2
        love.graphics.rectangle("fill", squareX, squareY, squareSize, squareSize)

        love.graphics.setColor(1,1,1,1)
        love.graphics.setFont(love.graphics.newFont("Savate.ttf" ,48))
        love.graphics.printf("GAME OVER", 0, GRID_HEIGHT * BLOCK_SIZE / 2 - 24, GRID_WIDTH * BLOCK_SIZE, "center")
        love.graphics.setFont(love.graphics.newFont("Savate.ttf",20))
        love.graphics.printf("Press Esc to get back to menu", 0, GRID_HEIGHT * BLOCK_SIZE / 2 + 100, GRID_WIDTH * BLOCK_SIZE, "center")
    end
end
