local Layout = {
    card = {
        width = 100,
        height = 150
    },

    hand = {
        startX = 200,
        startY = 400,
        spacing = 120,
        maxSlots = 3
    },

    deck = {
        xPosition = 50,
        yPosition = 250
    },

    discard = {
        xPosition = 50,
        yPosition = 50
    },

    buttons = {
        collect = {
            xPosition   = 800,
            yPosition   = 20,
            width       = 150,
            height      = 50,
            text        = "Draw Card"
        }
    }
}

return Layout