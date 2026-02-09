Card = require("card")

function love.load()
	-- Screen dimensions
	screenWidth = love.graphics.getWidth()
	screenHeight = love.graphics.getHeight()
	
	-- Card properties
	cardWidth = 80
	cardHeight = 120
	cardSpacing = 20  -- Space between cards
	
	totalCardsWidth = (cardWidth * 5) + (cardSpacing * 4) -- Calculate total width of all cards plus spacing
	startX = (screenWidth - totalCardsWidth) / 2 -- Starting X position to center the cards horizontally
	cardY = screenHeight - cardHeight - 30	-- Y position (bottom of screen with some margin)
	
	-- Create a table to store our 5 card slots
	cards = {}
	for i = 1, 5 do
		cards[i] = {
			x = startX + (i - 1) * (cardWidth + cardSpacing),
			y = cardY,
			width = cardWidth,
			height = cardHeight
		}
	end
end

function love.update(dt)
-- Game update logic will go here later
end

function love.draw()
	love.graphics.clear(0.1, 0.3, 0.2) -- Set background color (dark green felt table)
	
	for i = 1, 5 do
		Card.draw(cards[i], i)
	end
	
	love.graphics.setColor(1, 1, 1) -- Reset color
end