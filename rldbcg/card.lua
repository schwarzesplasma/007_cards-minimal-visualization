Card = {}

function Card.createDeck()
	local deck = {}
	local suits = {}
	local suitColors = {
		Hearts = {1, 0, 0},
		Diamonds ={1, 0, 0},
		Clubs = {0, 0, 0},
		Spades = {0, 0, 0}
		}

function Card.draw(card, index)
	-- Draw card background (white)
	love.graphics.setColor(1, 1, 1)
	love.graphics.rectangle("fill", card.x, card.y, card.width, 	card.height, 5, 5)
	
	-- Draw card border (darker outline)
	love.graphics.setColor(0.2, 0.2, 0.2)
	love.graphics.setLineWidth(3)
	love.graphics.rectangle("line", card.x, card.y, card.width, card.height, 5, 5)
	
	-- Draw card number (for identification)
	love.graphics.setColor(0, 0, 0)
	love.graphics.print("Card " .. index, card.x + 10, card.y + 10)
	end
	
return Card