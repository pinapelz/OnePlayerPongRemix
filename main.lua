--[[
    GD50 2018
    Pong Remake

    -- Main Program --

    Author: Colton Ogden
    cogden@cs50.harvard.edu

    Originally programmed by Atari in 1972. Features two
    paddles, controlled by players, with the goal of getting
    the ball past your opponent's edge. First to 10 points wins.

    This version is built to more closely resemble the NES than
    the original Pong machines or the Atari 2600 in terms of
    resolution, though in widescreen (16:9) so it looks nicer on 
    modern systems.
]]

-- push is a library that will allow us to draw our game at a virtual
-- resolution, instead of however large our window is; used to provide
-- a more retro aesthetic
--
-- https://github.com/Ulydev/push
push = require 'push'

-- the "Class" library we're using will allow us to represent anything in
-- our game as code, rather than keeping track of many disparate variables and
-- methods
--
-- https://github.com/vrld/hump/blob/master/class.lua
Class = require 'class'
require 'OtherPaddle'
-- our Paddle class, which stores position and dimensions for each Paddle
-- and the logic for rendering them
require 'Paddle'

-- our Ball class, which isn't much different than a Paddle structure-wise
-- but which will mechanically function very differently
require 'Ball'

-- size of our actual window
WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

-- size we're trying to emulate with push
VIRTUAL_WIDTH = 432
VIRTUAL_HEIGHT = 243
bonus  = false
-- paddle movement speed
PADDLE_SPEED = 200

--[[
    Called just once at the beginning of the game; used to set up
    game objects, variables, etc. and prepare the game world.
]]
function love.load()
    -- set love's default filter to "nearest-neighbor", which essentially
    -- means there will be no filtering of pixels (blurriness), which is
    -- important for a nice crisp, 2D look
    love.graphics.setDefaultFilter('nearest', 'nearest')

    -- set the title of our application window
    love.window.setTitle('Pong')

    -- seed the RNG so that calls to random are always random
    math.randomseed(os.time())

    -- initialize our nice-looking retro text fonts
    smallFont = love.graphics.newFont('font.ttf', 8)
    largeFont = love.graphics.newFont('font.ttf', 16)
    scoreFont = love.graphics.newFont('font.ttf', 32)
    love.graphics.setFont(smallFont)

    -- set up our sound effects; later, we can just index this table and
    -- call each entry's `play` method
    sounds = {
        ['paddle_hit'] = love.audio.newSource('sounds/paddle_hit.wav', 'static'),
        ['score'] = love.audio.newSource('sounds/score.wav', 'static'),
        ['wall_hit'] = love.audio.newSource('sounds/wall_hit.wav', 'static')
    }
    
    -- initialize our virtual resolution, which will be rendered within our
    -- actual window no matter its dimensions
    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = false,
        resizable = true,
        vsync = true,
        canvas = false
    })


    player1 = Paddle(7, 30, 5, 20)
    player2 = Paddle(VIRTUAL_WIDTH-10,30, 5, 20)
	player3 = OtherPaddle(VIRTUAL_WIDTH/2-6,3,20,5)
	player4= OtherPaddle(VIRTUAL_WIDTH/2-6,VIRTUAL_HEIGHT-7,20,5)
	player4= OtherPaddle(VIRTUAL_WIDTH/2-6,VIRTUAL_HEIGHT-7,20,5)


    -- place a ball in the middle of the screen
    ball = Ball(VIRTUAL_WIDTH / 2 - 2, VIRTUAL_HEIGHT / 2 - 2, 4, 4)

    player1Score = 0
    player2Score = 0
	playerScore = 0
    servingPlayer = 1

    winningPlayer = 0

    gameState = 'start'
end


function love.resize(w, h)
    push:resize(w, h)
end


function love.update(dt)
    if gameState == 'serve' then
        -- before switching to play, initialize ball's velocity based
        -- on player who last scored
        ball.dy = math.random(-50, 50)
        if servingPlayer == 1 then
            ball.dx = math.random(140, 200)
        else
            ball.dx = -math.random(140, 200)
        end
    elseif gameState == 'play' then
        if ball:collides(player1) then
		bonus = true
            ball.dx = -ball.dx * 1.03
            ball.x = player1.x + 5
			playerScore = playerScore+1
            -- keep velocity going in the same direction, but randomize it
            if ball.dy < 0 then
                ball.dy = -math.random(10, 150)
            else
                ball.dy = math.random(10, 150)
            end

            sounds['paddle_hit']:play()
        end
        if ball:collides(player2) then
		bonus = true
            ball.dx = -ball.dx * 1.03
            ball.x = player2.x - 4
		playerScore = playerScore+1
            -- keep velocity going in the same direction, but randomize it
            if ball.dy < 0 then
                ball.dy = -math.random(10, 150)
            else
                ball.dy = math.random(10, 150)
            end

            sounds['paddle_hit']:play()
        end
     if ball:collides(player3) then
		if bonus then
		
	
		playerScore = playerScore+4
            -- keep velocity going in the same direction, but randomize it
       
            sounds['paddle_hit']:play()
			bonus = false
		end
    end
		if ball:collides(player4) then
		if bonus then
		playerScore = playerScore+4
            -- keep velocity going in the same direction, but randomize it
       
            sounds['paddle_hit']:play()
			bonus = false
			end
        end
        if ball.y <= 0 then
            ball.y = 0
            ball.dy = -ball.dy
            sounds['wall_hit']:play()
        end

        -- -4 to account for the ball's size
        if ball.y >= VIRTUAL_HEIGHT - 4 then
            ball.y = VIRTUAL_HEIGHT - 4
            ball.dy = -ball.dy
            sounds['wall_hit']:play()
        end

        if ball.x < 0 then
            servingPlayer = 1
            player2Score = player2Score + 1
			
            sounds['score']:play()

            if player2Score == 10 then
                
            else
                gameState = 'serve'

                ball:reset()
            end
        end

        if ball.x > VIRTUAL_WIDTH then
            servingPlayer = 2

            sounds['score']:play()

            if player1Score == 10 then
              
            else
                gameState = 'serve'
                ball:reset()
            end
        end
    end


    if love.keyboard.isDown('w') then
        player1.dy = -PADDLE_SPEED
		      player2.dy = -PADDLE_SPEED
    elseif love.keyboard.isDown('s') then
        player1.dy = PADDLE_SPEED
		   player2.dy = PADDLE_SPEED
    else
        player2.dy = 0
		 player1.dy = 0
    end

    if love.keyboard.isDown('up') then
           player1.dy = -PADDLE_SPEED
		      player2.dy = -PADDLE_SPEED
    elseif love.keyboard.isDown('down') then
          player1.dy = PADDLE_SPEED
		   player2.dy = PADDLE_SPEED
    else
        player2.dy = 0
		 player1.dy = 0
    end
	 
	    if love.keyboard.isDown('a') then
           player3.dx = -PADDLE_SPEED
		   
    elseif love.keyboard.isDown('d') then
          player3.dx = PADDLE_SPEED
		 
    else
        player3.dx = 0
	end
		    if love.keyboard.isDown('left') then
           player3.dx = -PADDLE_SPEED
		    player4.dx = -PADDLE_SPEED
		   
    elseif love.keyboard.isDown('right') then
          player3.dx = PADDLE_SPEED
		   player4.dx = PADDLE_SPEED
		 
    else
        player3.dx = 0
    player4.dx = 0
    end
	
	

    -- update our ball based on its DX and DY only if we're in play state;
    -- scale the velocity by dt so movement is framerate-independent
    if gameState == 'play' then
        ball:update(dt)
    end

    player1:update(dt)
    player2:update(dt)
	player3:update(dt)
	player4:update(dt)
end


function love.keypressed(key)
    -- `key` will be whatever key this callback detected as pressed
    if key == 'escape' then
        -- the function LÖVE2D uses to quit the application
        love.event.quit()
    -- if we press enter during either the start or serve phase, it should
    -- transition to the next appropriate state
    elseif key == 'enter' or key == 'return' then
        if gameState == 'start' then
            gameState = 'serve'
        elseif gameState == 'serve' then
		playerScore = 0
            gameState = 'play'
        elseif gameState == 'done' then
            -- game is simply in a restart phase here, but will set the serving
            -- player to the opponent of whomever won for fairness!
            gameState = 'serve'

            ball:reset()

            -- reset scores to 0
            player1Score = 0
            player2Score = 0

            -- decide serving player as the opposite of who won
            if winningPlayer == 1 then
                servingPlayer = 2
            else
                servingPlayer = 1
            end
        end
    end
end

--[[
    Called each frame after update; is responsible simply for
    drawing all of our game objects and more to the screen.
]]
function love.draw()
    -- begin drawing with push, in our virtual resolution
    push:start()

    
    -- render different things depending on which part of the game we're in
    if gameState == 'start' then
    elseif gameState == 'serve' then
        love.graphics.setFont(smallFont)
  
    elseif gameState == 'play' then
    elseif gameState == 'done' then
        love.graphics.setFont(largeFont)
        love.graphics.printf('Player ' .. tostring(winningPlayer) .. ' wins!',
            0, 10, VIRTUAL_WIDTH, 'center')
        love.graphics.setFont(smallFont)
        love.graphics.printf('Press Enter to restart!', 0, 30, VIRTUAL_WIDTH, 'center')
    end

    displayScore()
    
    player1:render()
    player2:render()
	player3:render()
	player4:render()
    ball:render()

    -- display FPS for debugging; simply comment out to remove
    displayFPS()

    -- end our drawing to push
    push:finish()
end

--[[
    Simple function for rendering the scores.
]]
function displayScore()
    -- score display
    love.graphics.setFont(scoreFont)
    love.graphics.printf(tostring(playerScore), 0, VIRTUAL_HEIGHT / 2 -70, VIRTUAL_WIDTH+3, 'center')
     
  
end

--[[
    Renders the current FPS.
]]
function displayFPS()
    -- simple FPS display across all states
    love.graphics.setFont(smallFont)
    love.graphics.setColor(0, 255, 0, 255)
    love.graphics.print('FPS: ' .. tostring(love.timer.getFPS()), 10, 10)
    love.graphics.setColor(255, 255, 255, 255)
end
