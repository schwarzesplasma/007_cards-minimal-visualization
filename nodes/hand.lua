local Hand = {}

function Hand.create()
    return {
        cards = {},

        add = function(self, card)
            table.insert(self.cards, card)
        end,

        -- remove 
        remove = function(self, index)
            if index < 1 or index > #self.cards then
                error("Invalid hand index: " .. tostring(index))
            end

            return table.remove(self.cards, index)
        end,

        count = function(self)
            return #self.cards
        end,

        getLast = function(self)
            if #self.cards == 0 then
                return nil
            end

            return self.cards[#self.cards]
        end,

        indexOf = function(self, targetCard)
            for i, card in ipairs(self.cards) do
                if card == targetCard then
                    return i
                end
            end
            return nil
        end
    }
end

return Hand
