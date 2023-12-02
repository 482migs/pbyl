function CheckCollision(x1,y1,w1,h1,x2,y2,w2,h2)
    return x1 < x2+w2 and
            x2 < x1+w1 and
            y1 < y2+h2 and
            y2 < y1+h1
end

function love.load()
    love.filesystem.setIdentity("assets")

    font = love.graphics.newFont("assets/fonts/rainyhearts.ttf", 100)
    font2 = love.graphics.newFont("assets/fonts/rainyhearts.ttf", 100)
    font3 = love.graphics.newFont("assets/fonts/rainyhearts.ttf", 35)
    font4 = love.graphics.newFont("assets/fonts/rainyhearts.ttf", 20)

    bg = love.graphics.newImage("assets/images/bg.png")
    ball = love.graphics.newImage("assets/images/balls.png")
    paddle = love.graphics.newImage("assets/images/paddle.png")
    logo = love.graphics.newImage("assets/images/logo.png")

    boom = love.audio.newSource("assets/sfx/explosion.wav", "static")
    blip1 = love.audio.newSource("assets/sfx/blip1.wav", "static")
    blip2 = love.audio.newSource("assets/sfx/blip2.wav", "static")


    paddle_x = 350
    
    ball_x = 400
    ball_y = 200

    ball_vx = 1.5
    ball_vy = 2.5

    momentum = 0

    angle = 0

    playing = false

    counter = 0

    score = 0

    love.window.setTitle("Pong but you're lonely")

    started = false

    splash = true
end

function love.update(dt)

    if love.keyboard.isDown("q") then love.event.quit(0) end
    if love.keyboard.isDown("s") then love.filesystem.write("data.sav", "0") end

    counter = counter + 0.01

    if momentum == 0.2 then momentum = 0 end
    if momentum >= 0 then momentum = momentum - 0.2 end
    if momentum <= 0 then momentum = momentum + 0.2 end

    if love.keyboard.isDown("space") and splash == false and playing == false then 
        playing = true
        score = 0
    end
     
    if playing == true then
        if CheckCollision(ball_x, ball_y, 45, 45, paddle_x, 500, 225, 45) then
            angle = 1 - 2 * (ball_x - paddle_x) / 100
            ball_vx = angle * 3
            ball_vy = -ball_vy
            blip1:play()
        end

        


        if love.keyboard.isDown("left") or love.keyboard.isDown("a") then
            momentum = -4
        end

        if love.keyboard.isDown("right") or love.keyboard.isDown("d") then
            momentum = 4
        end

        paddle_x = paddle_x + momentum

        ball_x = ball_x + ball_vx
        ball_y = ball_y + ball_vy

        if paddle_x <= 0 then paddle_x = 5 end
        if paddle_x >= 800-150 then paddle_x = 800-150 end

        if ball_x <= 10 then 
            ball_vx = -ball_vx 
            score = score + 1
            blip2:play()
        end
        if ball_x >= 800-45 then 
            ball_vx = -ball_vx
            score = score + 1
            blip2:play()
        end
        if ball_y == 0 then 
            ball_vy = -ball_vy 
            score = score + 1
            blip1:play()
        end
    end

    if ball_y >= 650 or love.keyboard.isDown("r") then
        boom:play()
        playing = false 
        ball_x = 400
        ball_y = 200
        ball_vx = 1.5
        ball_vy = 2.5
        if score > highscore then
            success, message = love.filesystem.write("data.sav", tostring(score))
        end
    end


end

function love.draw()
    -- love.filesystem.write("data.sav", "0")
    love.graphics.draw(bg, 0, 0, 0, 1, 1)

    if love.timer.getTime() > 2 then 
        splash = false 
        menu = true
    end

    if splash == false then

        if playing == true then
            started = true
            love.graphics.draw(paddle, math.floor(paddle_x), 500, 0, 1/5, 1/5)
            love.graphics.draw(ball, math.floor(ball_x), math.floor(ball_y), 0, 1/5)
            love.graphics.setColor(0,0,0)
            love.graphics.print(score, font, (375 + 35)- (string.len(tostring(score)) * 30), 0, 0)
            love.graphics.print("press \"q\" to quit", font4, 10, 10)
            highscore = tonumber((love.filesystem.read("data.sav"))) or 0
            love.graphics.print("highscore: " .. tostring(highscore), font4, 350, 100, 0)
            love.graphics.reset()
        else
            love.graphics.setColor(0,0,0)
            if started == false then
                love.graphics.print("pong", font, 320, 120)
                love.graphics.print("(but you're lonely)", font4, 340, 250)
                love.graphics.print("press \"q\" to quit", font4, 10, 10)
                love.graphics.print("press space to play", font3, 275, 550 + (math.sin(counter) * 7))
            else
                love.graphics.print("game over :(", font, 170, 100)
                love.graphics.print("your score: " .. score, font3, 300, 200)
                if score > highscore then
                    love.graphics.print("! new high score !", font3, 270, 250 + (math.cos(counter) * 5))
                end
                love.graphics.print("press space to start again", font3, 210, 300)
            end
            love.graphics.reset()
        end
    

    else
        love.graphics.draw(logo, 300, 100, 0, 0.5)
        love.graphics.setColor(0,0,0)
        love.graphics.printf("cakethought games \npresents...", font2, -100, 300, 1000, "center")
        love.graphics.reset()
    end

    love.graphics.setBackgroundColor(1,1,1)
end