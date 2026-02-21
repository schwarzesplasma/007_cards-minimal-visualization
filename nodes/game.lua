local Deck      = require("nodes.deck")
local Hand      = require("nodes.hand")
local Discard   = require("nodes.discard")
local Layout    = require("config.layout")

local Game = {}

function Game.create()
    return {
        deck = nil,
        hand = nil,
        maxHandSize = 5,
        activeCard = nil,
        hoveredCard = nil,
        discard = nil,
        debug = true,

        drawButton = {
            x       = Layout.buttons.collect.xPosition,
            y       = Layout.buttons.collect.yPosition,
            width   = Layout.buttons.collect.width,
            height  = Layout.buttons.collect.height,
            text    = Layout.buttons.collect.text,
        },


        load = function(self)
            love.window.setMode(1000, 600)

            self.deck = Deck.create()
            self.deck:generateStandard52()
            self.deck:shuffle()

            self.hand = Hand.create()

            self.discard = Discard.create()

            -- draw whatever number is the maxium size of hand
            for i = 1, self.maxHandSize do
                local card = self.deck:collect()
                if card then
                    self.hand:add(card)
                end
            end

            if self.hand:count() > 0 then
                self.activeCard = self.hand.cards[1]
            end
        end,

        update = function(self, dt)
            self:updateHover()
        end,

        draw = function(self)
            self:drawHand()
            self:drawDiscard()
            self:drawDeck()
            self:drawUI()

            if self.debug then
                self:drawDebug()
            end
        end,

        drawHand = function(self)
            local startX    = Layout.hand.startX
            local spacing   = Layout.hand.spacing
            local y         = Layout.hand.startY

        --[[if self.hand:count() == 0 then
                return
            end]]--

            for i = 1, self.maxHandSize do
                local x     = startX + (i - 1) * spacing
                local card  = self.hand.cards[i]

                if card then
                    -- Hover background
                    if card == self.hoveredCard then
                        love.graphics.setColor(1, 0.95, 0.8)
                    else
                        love.graphics.setColor(1, 1, 1)
                    end

                    love.graphics.rectangle("fill", x, y, 100, 150)

                    love.graphics.setColor(0, 0, 0)
                    love.graphics.rectangle("line", x, y, 100, 150)

                    love.graphics.print(
                        card.rank .. " of " .. card.suit,
                        x + 10,
                        y + 10
                    )

                    -- Selection border
                    if card == self.activeCard then
                        love.graphics.setColor(1, 0, 0)
                        love.graphics.rectangle("line", x - 3, y - 3, 106, 156)
                    end

                    -- Hover border
                    if card == self.hoveredCard then
                        love.graphics.setColor(0, 1, 0)
                        love.graphics.rectangle("line", x - 6, y - 6, 112, 162)
                    end

                else
                    -- Empty slot
                    love.graphics.setColor(0.85, 0.85, 0.85)
                    love.graphics.rectangle("fill", x, y, 100, 150)

                    love.graphics.setColor(0, 0, 0)
                    love.graphics.rectangle("line", x, y, 100, 150)
                end
            end
        end,

        drawDiscard = function(self)
            local x = Layout.discard.xPosition
            local y = Layout.discard.yPosition
            local width = Layout.card.width
            local height = Layout.card.height

            love.graphics.setColor(0.3, 0.3, 0.3)
            love.graphics.rectangle("fill", x, y, width, height)

            love.graphics.setColor(1, 1, 1)
            love.graphics.rectangle("line", x, y, width, height)

            local top = self.discard:getLast()

            if top then
                love.graphics.print(
                    top.rank .. " of " .. top.suit,
                    x + 10,
                    y + 10
                )
            else
                love.graphics.print("Discard", x + 10, y + 10)
            end
        end,

        drawDeck = function(self)
            local x         = Layout.deck.xPosition
            local y         = Layout.deck.yPosition
            local width     = Layout.card.width
            local height    = Layout.card.height

            love.graphics.setColor(0.2, 0.2, 0.2) -- dark grey
            love.graphics.rectangle("fill", x, y, width, height)

            love.graphics.setColor(1, 1, 1)
            love.graphics.rectangle("line", x, y, width, height)

            love.graphics.print(
                "Deck\n(" .. self.deck:count() .. ")",
                x + 15,
                y + 10
            )
        end,

        drawUI = function(self)
            local b = self.drawButton

            love.graphics.setColor(0.2, 0.2, 0.2)
            love.graphics.rectangle("fill", b.x, b.y, b.width, b.height)

            love.graphics.setColor(1, 1, 1)
            love.graphics.rectangle("line", b.x, b.y, b.width, b.height)

            love.graphics.print(
                b.text,
                b.x + 20,
                b.y + 15
            )
        end,

        collectFromDeck = function(self)
            if self.hand:count() >= self.maxHandSize then
                return
            end

            local card = self.deck:collect()

            if card then
                self.hand:add(card)

                if not self.activeCard then
                    self.activeCard = card
                end
            end
        end,



        drawDebug = function(self)
            love.graphics.setColor(1, 1, 0)

            local x = 200
            local y = 20
            local lineHeight = 20

            local mouseX, mouseY = love.mouse.getPosition()

            love.graphics.print("DEBUG", x, y)                                                                              y = y + lineHeight
            love.graphics.print("Mouse position: " .. "x " .. mouseX .. ", y " .. mouseY , x, y)                            y = y + lineHeight
            love.graphics.print("Deck count: " .. self.deck:count(), x, y)                                                  y = y + lineHeight
            love.graphics.print("Hand count: " .. self.hand:count(), x, y)                                                  y = y + lineHeight

            if self.hoveredCard then
                love.graphics.print("Hovered card: " .. self.hoveredCard.rank .. " of " .. self.hoveredCard.suit, x, y)     y = y + lineHeight
            else
                love.graphics.print("No card hovered", x, y)                                                                y = y + lineHeight
            end

            if self.activeCard then
                love.graphics.print("Selected card: " .. self.activeCard.rank .. " of " .. self.activeCard.suit, x, y)      y = y + lineHeight
            else
                love.graphics.print("No card selected", x, y)                                                               y = y + lineHeight
            end

            if self.hand:count() > 0 then                                           -- IMPORTANT safety check: only do this if the index is an integer greater than 0
                local first = self.hand.cards[1]                                    -- Otherwise it would index nil, which is not allowed
                love.graphics.print("First card of hand: " .. first.rank .. " of " .. first.suit, x, y)                     y = y + lineHeight
            end

            local last = self.hand:getLast()

            if last then
                love.graphics.print("Last card of hand: " .. last.rank .. " of " .. last.suit, x, y)                        y = y + lineHeight
            end

        end,


        keypressed = function(self, key)
            if key == "right" then
                local currentIndex = self.hand:indexOf(self.activeCard)
                if currentIndex and currentIndex < self.hand:count() then
                    self.activeCard = self.hand.cards[currentIndex + 1]
                end
            end

            if key == "left" then
                local currentIndex = self.hand:indexOf(self.activeCard)
                if currentIndex and currentIndex > 1 then
                    self.activeCard = self.hand.cards[currentIndex - 1]
                end
            end

        if key == "space" then
            if self.activeCard then
                local index = self.hand:indexOf(self.activeCard)
                local removed = self.hand:remove(index)
                self.discard:add(removed)

                print("\nRemoved: " .. removed.rank .. " of " .. removed.suit)

                -- Set new selection
                if self.hand:count() > 0 then
                    if index > self.hand:count() then
                        self.activeCard = self.hand.cards[self.hand:count()]
                    else
                        self.activeCard = self.hand.cards[index]
                    end
                else
                    self.activeCard = nil
                end
            end
        end
            
            if key == "d" then
                self.debug = not self.debug
            end
        end,

        mousepressed = function(self, x, y, button)
            local b = self.drawButton

            if 
                x >= b.x and x <= b.x + b.width 
                and
                y >= b.y and y <= b.y + b.height 
                then

                self:collectFromDeck()
                return
            end

            if button ~= 1 then
                return
            end

            local startX = 200
            local spacing = 120
            local cardY = 400
            local width = 100
            local height = 150

            for i, card in ipairs(self.hand.cards) do
                local cardX = startX + (i - 1) * spacing

                if x >= cardX and x <= cardX + width
                and y >= cardY and y <= cardY + height then

                    self.activeCard = card
                    break
                end
            end
        end,

        updateHover = function(self)
            local mouseX, mouseY = love.mouse.getPosition()

            self.hoveredCard = nil

            local startX    = 200
            local spacing   = 120
            local cardY     = 400
            local width     = Layout.card.width
            local height    = Layout.card.height

            for i, card in ipairs(self.hand.cards) do
                local cardX = startX + (i - 1) * spacing

                if  mouseX >= cardX and mouseX <= cardX + width
                and mouseY >= cardY and mouseY <= cardY + height
                then

                    self.hoveredCard = card
                end
            end
        end,

    }
end

return Game