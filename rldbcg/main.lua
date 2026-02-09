-- Card Game - Basic UI with 5 card slots
-- This creates 5 card slots at the bottom of the screen

function love.load()
	-- Screen dimensions
	screenWidth = love.graphics.getWidth()
	screenHeight = love.graphics.getHeight()

	-- Card properties
	cardWidth = 80
	cardHeight = 120
	cardSpacing = 20  -- Space between cards

	-- Calculate total width of all cards plus spacing
	totalCardsWidth = (cardWidth * 5) + (cardSpacing * 4)

	-- Starting X position to center the cards horizontally
	startX = (screenWidth - totalCardsWidth) / 2

    -- Y position (bottom of screen with some margin)
    cardY = screenHeight - cardHeight - 30

    -- Create a table to store our 5 card 
		cards = {}
    	for i = 1, 5 do
        cards[i] = {
            x = startX + (i - 1) * (cardWidth + cardSpacing),
            y = cardY,
            width = cardWidth,
            height = 
				}
		end
end

function love.update(dt)
-- Game update logic will go here later
end

function love.draw()
-- Set background color (dark green felt table)
love.graphics.clear(0.1, 0.3, 0.2)

-- Draw each card slot
for i = 1, 5 do
    -- Card background (white)
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle("fill", cards[i].x, cards[i].y, cards[i].width, cards[i].height, 5, 5)
    
    -- Card border (darker outline)
    love.graphics.setColor(0.2, 0.2, 0.2)
    love.graphics.setLineWidth(3)
    love.graphics.rectangle("line", cards[i].x, cards[i].y, cards[i].width, cards[i].height, 5, 5)
    
    -- Card number (for identification)
    love.graphics.setColor(0, 0, 0)
    love.graphics.print("Card " .. i, cards[i].x + 10, cards[i].y + 10)
end

-- Reset color
love.graphics.setColor(1, 1, 1)

end