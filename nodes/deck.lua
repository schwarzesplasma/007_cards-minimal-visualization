local Card = require("nodes.card")
local Deck = {}

function Deck.create()
    return {
        cards = {},

        generateStandard52 = function(self)
            local suits = { "hearts", "diamonds", "clubs", "spades" }

            for _, suit in ipairs(suits) do
                for rank = 1, 13 do
                    table.insert(self.cards, Card.create(rank, suit))
                end
            end
        end,

        shuffle = function(self)
            for i = #self.cards, 2, -1 do
                local j = love.math.random(i)
                self.cards[i], self.cards[j] = self.cards[j], self.cards[i]
            end
        end,

        collect = function(self)
            return table.remove(self.cards)
        end,

        count = function(self)
            return #self.cards
        end
    }
end

return Deck
