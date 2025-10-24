card(_{id: 1,
       name: "Mana of Power I",
       description: "Add 1 to your Mana Count"}).
card(_{id: 2,
       name: "Mana of Power II",
       description: "Add 2 to your Mana Count"}).
card(_{id: 3,
       name: "Mana of Power III",
       description: "Add 3 to your Mana Count"}).
card(_{id: 4,
       name: "Mana of Power IV",
       description: "Add 4 to your Mana Count"}).
card(_{id: 5,
       name: "Mana of Power V",
       description: "Add 5 to your Mana Count"}).


weights(player1, [1-4, 2-3, 3-2, 4-1, 5-1]).
weights(player2, [1-4, 2-3, 3-3, 4-2, 5-1]).


% Main predicate to pick a number according to weights
weighted_choice(Player, Picked) :-
    weights(Player, Choices),
    maplist(arg(2), Choices, Ws),
    sum_list(Ws, Total),
    random_between(1, Total, R),
    pick_weighted(Choices, R, Picked).

% Walk through the weighted choices to select the item
pick_weighted([Num-W|_], R, Num) :-
    R =< W, !.
pick_weighted([_-W|Rest], R, Picked) :-
    R > W,
    R1 is R - W,
    pick_weighted(Rest, R1, Picked).


% Generate a list of N weighted random picks
weighted_choices(_, 0, []) :- !.
weighted_choices(Player, N, [X|Xs]) :-
    weighted_choice(Player, X),
    N1 is N - 1,
    weighted_choices(Player, N1, Xs).


id_card(ID, Card) :- card(Card), Card.id = ID.


ressert(Term, NewTerm) :-
    retractall(Term),
    assert(NewTerm).

new_deck(Player) :-
    weighted_choices(Player, 30, Ids),
    maplist(id_card, Ids, Deck), !,
    ressert(deck(Player, _), deck(Player, Deck)),
    ressert(hand(Player, _), hand(Player, [])),
    ressert(mana_count(Player,_), mana_count(Player, 0)),
    ressert(discard(Player,_), discard(Player, [])).

draw(Player) :-
    deck(Player, [TopCard|Deck]),
    hand(Player, Hand),
    ressert(deck(Player,_), deck(Player, Deck)),
    ressert(hand(Player,_), hand(Player,[TopCard|Hand])).

% remove_nth(+N, +List, -Result)
remove_nth(1, [_|T], T) :- !.
remove_nth(N, [H|T], [H|R]) :-
    N > 1,
    N1 is N - 1,
    remove_nth(N1, T, R).

play_card(Player, NCard) :-
    % player state
    hand(Player, Hand),
    mana_count(Player, MC),
    discard(Player, Discard),
    % pick and remove nth card; add card mana count
    nth1(NCard, Hand, Card),
    remove_nth(NCard, Hand, NewHand),
    NewMC is Card.id + MC,
    % update database with new state
    ressert(hand(Player,_),       hand(Player,NewHand)),
    ressert(mana_count(Player,_), mana_count(Player, NewMC)),
    ressert(discard(Player,_),    discard(Player, [Card|Discard])),

    format('~w played "~w"', [Player, Card.name]),
    display_state(Player).


display_state(Player) :-
    hand(Player, Hand),
    mana_count(Player, MC),
    %% discard(Player, Discard),
    format('~n~n=== Player ~w State ===~n', [Player]),
    format('Mana Count: ~w~n', [MC]),
    format('Hand:~n'),
    display_card_list(Hand),!.
    % format('Discard Pile:~n'),!.
    % display_card_list(Discard),!.


% Helper to display a list of cards (shows index and card name/desc)
display_card_list([]) :-
    format('  (Empty)~n').
display_card_list(Cards) :-
    display_card_list(Cards, 1).

display_card_list([], _).
display_card_list([Card|Rest], N) :-
    format('  [~w] ~w: ~w~n', [N, Card.name, Card.description]),
    N1 is N + 1,
    display_card_list(Rest, N1).



% Draw N cards for a player
draw_n(_, 0) :- !.
draw_n(Player, N) :-
    draw(Player), N1 is N-1, draw_n(Player, N1).


% play game
next_player(player1, player2).
next_player(player2, player1).

% Main game loop: CurrentPlayer, IsFirstTurn for current player
turn(CurrentPlayer, IsFirstTurn) :-
    (  game_over(Winner)
    -> format("~nGAME OVER! Winner: ~w~n", [Winner]),
       display_state(Winner)
    ;  (IsFirstTurn == true ->
            true  % player1 does not draw at start of first turn
       ;
       draw(CurrentPlayer)),  % everyone else draws on their turn
       format("~n~w's turn:~n", [CurrentPlayer]),
       play_highest(CurrentPlayer),
       next_player(CurrentPlayer, NextPlayer),
       turn(NextPlayer, false)
    ).


% Find the index of the highest value card in Hand
highest_card_index(Hand, Index) :-
    maplist(arg(1), Hand, Ids),
    max_member(MaxId, Ids),
    nth1(Index, Ids, MaxId).

% Play the highest card in hand
play_highest(Player) :-
    hand(Player, Hand),
    highest_card_index(Hand, N),
    play_card(Player, N).

% Check if any player has >= 20 mana
game_over(Player) :-
    mana_count(Player, MC),
    MC >= 20, !.

% Setup initial decks, hands, and mana for both players
setup_game :-
    new_deck(player1),
    new_deck(player2),
    draw_n(player1, 3),
    draw_n(player2, 3).

% Play game entrypoint
play_game :-
    setup_game,
    turn(player1, true),!.
