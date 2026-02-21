local Animation = {}

function Animation.create()
    return {
        animations = {},

        add = function(self, card, fromX, fromY, toX, toY, duration)
            table.insert(self.animations, {
                card = card,
                fromX = fromX,
                fromY = fromY,
                toX = toX,
                toY = toY,
                duration = duration,
                elapsed = 0
            })
        end,

        update = function(self, dt)
            for i = #self.animations, 1, -1 do
                local anim = self.animations[i]

                anim.elapsed = anim.elapsed + dt

                if anim.elapsed >= anim.duration then
                    table.remove(self.animations, i)
                end
            end
        end,

        isAnimating = function(self, card)
            for _, anim in ipairs(self.animations) do
                if anim.card == card then
                    return true
                end
            end
            return false
        end,

        getPosition = function(self, card)
            for _, anim in ipairs(self.animations) do
                if anim.card == card then

                    local progress = anim.elapsed / anim.duration
                    if progress > 1 then
                        progress = 1
                    end

                    local currentX = anim.fromX + (anim.toX - anim.fromX) * progress
                    local currentY = anim.fromY + (anim.toY - anim.fromY) * progress

                    return {
                        x = currentX,
                        y = currentY
                    }
                end
            end
            return nil
        end,

        draw = function(self)
            -- We will implement this next
        end
    }
end

return Animation