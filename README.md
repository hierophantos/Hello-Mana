- [👋🔮 Hello Mana!  Card Game in Prolog](#org627f3b8)
  - [Game Rules](#org73f578f)
  - [Requirements](#org185e5c3)
  - [How to Run](#orgda01000)


<a id="org627f3b8"></a>

# 👋🔮 Hello Mana!  Card Game in Prolog

A simple two-player card game with Prolog, where each player draws and plays cards to accumulate mana. The first to reach 20 mana wins.


<a id="org73f578f"></a>

## Game Rules

-   Each player starts with a shuffled deck of 30 cards (mana values 1–5, weighted distribution).
-   Both players draw 3 cards for their initial hand.
-   On your turn, draw a card, then play a card in your hand.
-   The played card’s mana value is added to your mana count; the card then goes to your discard pile.
-   Players alternate turns. The first turn for player 1 skips the draw step.
-   First player to reach 20 or more mana wins.


<a id="org185e5c3"></a>

## Requirements

-   [SWI-Prolog](https://www.swi-prolog.org/)


<a id="orgda01000"></a>

## How to Run

1.  Run from swipl script
    
    Open a terminal in the game’s directory. change \`play.pl\` to be executable
    
    ```shell
    chmod +x play.pl
    ```
    
    Then run play.pl
    
    ```shell
    ./play.pl
    ```

2.  Or from Prolog's toplevel (REPL)
    
    Start prolog
    
    ```prolog
    swipl
    ```
    
    And run
    
    ```prolog
    ?- [hello_mana].
    ?- play_game.
    ```
