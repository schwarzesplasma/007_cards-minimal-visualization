# 007 Cards - Minimal Visualization

Minimal card game visualization built with LÖVE2D.

## Overview
This project renders a simple card-table prototype with:
- a shuffled 52-card deck
- a player hand with selectable cards
- a discard pile
- basic input handling (mouse + keyboard)
- optional debug overlay

It is designed as a learning project for structuring a small LÖVE codebase into reusable modules.

## Requirements
- LÖVE2D (11.x recommended)

## Run
From the project root:

```powershell
love .
```

If `love` is not in your PATH, launch the project by opening the folder with the LÖVE executable.

## Controls
- `Left Arrow`: select previous card in hand
- `Right Arrow`: select next card in hand
- `Space`: discard selected card
- `D`: toggle debug overlay
- `Left Click` on a card: select that card
- `Left Click` on **Draw Card** button: draw one card from deck (if hand is not full)

## Current Game Flow
1. Window opens at `1000x600`.
2. Deck is generated (52 cards) and shuffled.
3. The initial hand is filled up to `maxHandSize` (currently 5).
4. First card in hand becomes selected.
5. During play, cards can be selected and discarded, and additional cards can be drawn while there is free hand space.

## Project Structure
- `main.lua`: LÖVE callbacks and game bootstrap
- `nodes/game.lua`: main game state, input logic, and rendering orchestration
- `nodes/deck.lua`: deck creation, shuffle, collect, count
- `nodes/hand.lua`: hand management (add/remove/index/count)
- `nodes/discard.lua`: discard pile management
- `nodes/card.lua`: card model (`rank`, `suit`)
- `nodes/animation.lua`: animation manager scaffold (update/isAnimating/getPosition)
- `config/layout.lua`: UI layout constants (positions, sizes)
- `utils/dump.lua`: table debug dump helper

## Notes
- `nodes/animation.lua` is present and updated each frame, but animated rendering is not fully integrated yet.
- `config/config.lua` exists but is currently not wired into active rendering logic.

## Development
Common Git workflow:

```powershell
git status
git add .
git commit -m "docs: add project README"
git push
```

## License
No license file is currently included.
