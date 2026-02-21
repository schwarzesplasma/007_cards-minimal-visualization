local Discard = {}

function Discard.create()
    return {
        cards = {},

        add = function(self, card)
            table.insert(self.cards, card)
        end,

        count = function(self)
            return #self.cards
        end,

        getLast = function(self)
            if #self.cards == 0 then
                return nil
            end

            return self.cards[#self.cards]
        end 
    }
end

return Discard