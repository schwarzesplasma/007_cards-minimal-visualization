local Card = {}

function Card.create(rank, suit)
    return {
        rank = rank,
        suit = suit
    }
end

return Card
