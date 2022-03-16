% Triwizard Game

:- dynamic i_am_at/1, at/2, holding/1, energy/1, alive/1 ,inventory_items/1, passage/2 ,unconceal/1.
% :- retractall(at(_, _)), retractall(i_am_at(_)), retractall(alive(_)).

i_am_at(l1-1).

path(l1-1, s, l1-3).
path(l1-1, e, l1-2).
path(l1-2, w, l1-1).
path(l1-2, s, l1-4).
path(l1-4, n, l1-2).
path(l1-3, n, l1-1).
path(l1-3, e, l1-4).
path(l1-4, w, l1-3).
path(l1-4, e, l2-3) :- passage(l1-4, l2-3).

path(l2-1, s, l2-3).
path(l2-1, e, l2-2).
path(l2-2, w, l2-1).
path(l2-2, s, l2-4).
path(l2-4, n, l2-2).
path(l2-3, n, l2-1).
path(l2-3, e, l2-4).
path(l2-4, w, l2-3).
path(l2-4, e, l3-3) :- passage(l2-4, l3-3).

path(l3-1, s, l3-3).
path(l3-1, e, l3-2).
path(l3-2, w, l3-1).
path(l3-2, s, l3-4).
path(l3-4, n, l3-2).
path(l3-3, n, l3-1).
path(l3-3, e, l3-4).
path(l3-4, w, l3-3).
path(l3-2, n, win) :- passage(l3-2, win).

energy(3).

alive(1).
% path()
at(food, l1-3).
at(food, l2-1).
at(food, l3-1).

at(key, l1-2).
at(concealed, l2-2).
at(elderwand, l3-4).

% at(potion, l2-2) :- unconceal(concealed).

inventory_items(['wand']).

inventory :-
  inventory_items(X),
  write(X).


cast(X) :-
        alive(1),
        holding(wand),
        ((X == revelio, at(concealed, l2-2), retract(at(concealed, l2-2)), retract(holding(wand)), assert(at(potion, l2-2)), write('Object Revealed. Press the Observe Environment button or type look to see the object.'), nl); true),
        ((X == geminio, at(elderwand, l3-4), retract(at(elderwand, l3-4)), retract(holding(wand)), assert(at(staff, l3-4)), write('Wands merged. Staff has been forged. Press the Observe Environment button or type look to see the object.'), nl); true),
        !, nl.

cast(_) :-
        write('Can''t cast the spell without a wand in the hand. Type wand and click Use or type use(wand) to use the wand.'),
        nl.

use(X) :-
        alive(1),
        ((X == wand, write('You are ready to cast a spell! Beware, wand is both a weapon for good and destruction! Click Observe Environment for further instructions!'), assert(holding(X)), nl); true),
        holding(X),
        inventory_items(I),
        delete(I, X, New),
        retract(inventory_items(I)),
        assert(inventory_items(New)),
        retract(holding(X)),
        i_am_at(Loc),
        ((X == key, assert(passage(l1-4, l2-3)), write('You have unlocked the door.'), nl, go(e), nl); true),
        ((X == potion, assert(passage(l2-4, l3-3)), write('You have unlocked the door.'), nl, go(e), nl); true),
        ((X == staff, assert(passage(l3-2, win)), write('You have won.'), nl, go(n), nl); true),
        ((X == wand, append([X], New, New_with_wand), retract(inventory_items(New)), assert(inventory_items(New_with_wand)), assert(holding(X)), nl); true),
        ((X == wand, at(elderwand, Loc), delete(New_with_wand, X, New_Without_Wand), retract(inventory_items(New_with_wand)), assert(inventory_items(New_Without_Wand)), nl); true),
        !, nl.

use(_) :-
        write('Can''t find the object in the inventory.'),
        nl.

take(X) :-
        holding(X),
        write('You''re already holding it!'),
        !, nl.

take(X) :-
        i_am_at(Place),
        ((\+ X == concealed)),
        ((\+ X == elderwand)),
        alive(1),
        at(X, Place),
        retract(at(X, Place)),
        assert(holding(X)),
        inventory_items(I),
        append([X], I, New),
        retract(inventory_items(I)),
        assert(inventory_items(New)),
        ((X == food, energy(E), E1 is E + 4, retract(energy(E)), assert(energy(E1)), retract(holding(X)), delete(New, X, New_Without_Food), retract(inventory_items(New)), assert(inventory_items(New_Without_Food)), writeln('Food consumed and energy replenished by 4.')) ; true),
        write('OK.'),
        !, nl.

take(_) :-
        write('I don''t see it here.'),
        nl.

/* These rules describe how to put down an object. */

drop(X) :-
        holding(X),
        alive(1),
        i_am_at(Place),
        retract(holding(X)),
        assert(at(X, Place)),
        write('OK.'),
        !, nl.

drop(_) :-
        write('You aren''t holding it!'),
        nl.


/* These rules define the direction letters as calls to go/1. */

n :- go(n).

s :- go(s).

e :- go(e).

w :- go(w).


/* This rule tells how to move in a given direction. */

go(Direction) :-
        i_am_at(Here),
        alive(1),
        path(Here, Direction, There),
        energy(X),
        decrease_energy,
        ((X =< 0, retract(alive(1)), writeln('Energy Finished. You are Dead Now.'), die); true),
        ((X =< 2, \+ There == win,writeln('Get some food fast!')); true),
        alive(1),
        retract(i_am_at(Here)),
        assert(i_am_at(There)),
        !, look.

go(_) :-
        alive(1),
        write('You can''t go that way.'),
        !.

decrease_energy :-
        energy(X),
        Y is X - 1,
        retract(energy(X)),
        assert(energy(Y)),
        !.


/* This rule tells how to look about you. */

look :-
        % alive(1),
        i_am_at(Place),
        describe(Place),
        nl,
        notice_objects_at(Place),
        nl.


/* These rules set up a loop to mention all the objects
   in your vicinity. */

notice_objects_at(Place) :-
        at(X, Place),
        write('There is a '), write(X), write(' object here.'), nl,
        fail.

notice_objects_at(_).


/* This rule tells how to die. */

die :-
        retract(alive(1)),
        finish.


/* Under UNIX, the "halt." command quits Prolog but does not
   remove the output window. On a PC, however, the window
   disappears before the final output can be seen. Hence this
   routine requests the user to perform the final "halt." */

finish :-
        nl,
        write('The game is over. Please enter the "halt." command.'),
        nl, !.


/* This rule just writes out game instructions. */

instructions :-
        nl,
        write('Enter commands using standard Prolog syntax or play game using UI.'), nl,
        write('Available commands are:'), nl,
        write('start.             -- to start the game.'), nl,
        write('n.  s.  e.  w.     -- to go in that direction.'), nl,
        write('take(Object).      -- to pick up an object.'), nl,
        write('drop(Object).      -- to put down an object.'), nl,
        write('use(Object).       -- to use an object.'), nl,
        write('cast(Spell).       -- cast spell to perform an action'), nl,
        write('look.              -- to look around you again.'), nl,
        write('inventory.         -- to see the inventory of items.'), nl,
        write('instructions.      -- to see this message again.'), nl,
        write('halt.              -- to end the game and quit.'), nl,
        write('There are 3 levels to this game. Clear all of them to win.'), nl,
        nl.


/* This rule prints out instructions and tells where you are. */

start :-
        alive(1),
        instructions,
        look.


/* These rules describe the various rooms.  Depending on
   circumstances, a room may have more than one description. */

describe(l1-1) :-
        write('Welcome to Level 1 of the Triwizard tournament! You are in a maze, with a door to the east and a table of food to the south.'), nl, nl,
        energy(X),
        write('Current energy level is: '),write(X), nl,
        write('You are at L1-1.'), nl.

describe(l1-2) :-
        \+ holding(key),
        write('There are snitches flying in the room. But wait...'), nl,
        write('The snitches are actually keys!!! Grab a key by typing key and clicking Pick or typing take(key) if using CLI.'), nl, nl,
        energy(X),
        write('Current energy level is: '),write(X), nl,
        write('You are at L1-2.'), nl.

describe(l1-2) :-
        holding(key),
        write('Go to the door and unlock it with the key.'), nl, nl,
        energy(X),
        write('Current energy level is: '),write(X), nl,
        write('You are at L1-2.'), nl.

describe(l1-3) :-
        at(food, l1-3),
        write('There is a table with some food on it. Grab some food by typing food and clicking Pick or typing take(food) if using CLI.'), nl, nl,
        write('PS. Food gives you energy. Without food, you will die!'), nl, nl,
        energy(X),
        write('Current energy level is: '),write(X), nl,
        write('You are at L1-3.'), nl.

describe(l1-3) :-
        \+ at(food, l1-3),
        write('No more food on the table. Go to level 2 to get more food!!'), nl, nl,
        write('PS. Food gives you energy. Without food, you will die!'), nl, nl,
        energy(X),
        write('Current energy level is: '),write(X), nl,
        write('You are at L1-3.'), nl.

describe(l1-4) :-
        \+ holding(key),
        write('You need a key to open the door and enter level 2 of the maze'), nl, nl,
        energy(X),
        write('Current energy level is: '),write(X), nl,
        write('You are at L1-4.'), nl.

describe(l1-4) :-
        holding(key),
        write('Grab the key from the inventory by typing key and clicking Use or typing use(key) if using CLI.'), nl, nl,
        energy(X),
        write('Current energy level is: '),write(X), nl,
        write('You are at L1-4.'), nl.

describe(l2-1) :-
        at(food, l2-1),
        write('There is a table with some food on it. Grab some food by typing food and clicking Pick or typing take(food) if using CLI.'), nl, nl,
        write('PS. Food gives you energy. Without food, you will die!'), nl, nl,
        energy(X),
        write('Current energy level is: '),write(X), nl,
        write('You are at L2-1.'), nl.

describe(l2-1) :-
        \+ at(food, l2-3),
        write('No more food on the table. Go to level 3 to get more food!!'), nl, nl,
        write('PS. Food gives you energy. Without food, you will die!'), nl, nl,
        energy(X),
        write('Current energy level is: '),write(X), nl,
        write('You are at L2-1.'), nl.

describe(l2-2) :-
        \+ holding(wand),
        \+ at(potion, l2-2),
        \+ holding(potion),
        write('There is a concealed object that might help you beat the spihnx. Type wand and click Use or type use(wand) to use the wand and cast a spell to reveal the object.'), nl, nl,
        energy(X),
        write('Current energy level is: '),write(X), nl,
        write('You are at L2-2.'), nl.

describe(l2-2) :-
        holding(wand),
        \+ at(potion, l2-2),
        write('Cast a spell to reveal the concealed object by typing the spell and clicking Cast or typing cast(Spell) if using CLI.'), nl, nl,
        write('Hint: The spell is revelio.'), nl, nl,
        energy(X),
        write('Current energy level is: '),write(X), nl,
        write('You are at L2-2.'), nl.

describe(l2-2) :-
        at(potion, l2-2),
        \+ holding(potion),
        write('You need the potion to beat the sphinx. Pick up the potion by typing potion and clicking Pick or typing take(potion) if using CLI.'), nl, nl,
        energy(X),
        write('Current energy level is: '),write(X), nl,
        write('You are at L2-2.'), nl.

describe(l2-2) :-
        holding(potion),
        write('Go to the sphinx and beat it with the potion!'), nl, nl,
        energy(X),
        write('Current energy level is: '),write(X), nl,
        write('You are at L2-2.'), nl.

describe(l2-3) :-
        write('Welcome to level 2 of the Triwizard tournament! You are in the outer maze, with a spihnx to the east and a table of food to the north.'), nl, nl,
        energy(X),
        write('Current energy level is: '),write(X), nl,
        write('You are at L2-3.'), nl.

describe(l2-4) :-
        \+ holding(potion),
        write('You need a potion to beat the sphinx and enter level 3 of the maze'), nl, nl,
        write('Hint: The potion might be hidden.'), nl, nl,
        energy(X),
        write('Current energy level is: '),write(X), nl,
        write('You are at L2-4.'), nl.

describe(l2-4) :-
        holding(potion),
        write('Grab the potion for beating sphinx from the inventory by typing potion and clicking Use or typing use(potion) if using CLI.'), nl, nl,
        energy(X),
        write('Current energy level is: '),write(X), nl,
        write('You are at L2-4.'), nl.

describe(l3-1) :-
        energy(X),
        write('Current energy level is: '),write(X), nl,
        write('You are at L3-1.'), nl.

describe(l3-2) :-
        holding(staff),
        write('Grab the staff for beating the dark lord from the inventory by typing staff and clicking Use or typing use(staff) if using CLI.'), nl, nl,
        energy(X),
        write('Current energy level is: '),write(X), nl,
        write('You are at L3-2.'), nl.

describe(l3-2) :-
        \+ holding(staff),
        write('You need a staff to beat the dark lord and win the Triwizard tournament.'), nl, nl,
        energy(X),
        write('Current energy level is: '),write(X), nl,
        write('You are at L3-2.'), nl.

describe(l3-3) :-
        write('Welcome to level 3 of the Triwizard tournament! You are in the inner maze, with a treasure chest to the east and a table of food to the north.'), nl, nl,
        energy(X),
        write('Current energy level is: '),write(X), nl,
        write('You are at L3-3.'), nl.

describe(l3-4) :-
        \+ holding(wand),
        \+ at(staff, l3-4),
        \+ holding(staff),
        write('The treasure chest has an elder wand inside. Use the wand in your inventory by typing wand and clicking Use or typing use(wand) if using CLI, to combine the two wands and create a staff.'), nl,
        write('Hint: You need to use a spell to merge the two wands.'), nl, nl,
        energy(X),
        write('Current energy level is: '),write(X), nl,
        write('You are at L3-4.'), nl.

describe(l3-4) :-
        holding(wand),
        \+ at(staff, l3-4),
        \+ holding(staff),
        write('Cast a spell to combine the two wands and create a staff.'), nl, nl,
        write('Hint: The spell is geminio.'), nl, nl,
        energy(X),
        write('Current energy level is: '),write(X), nl,
        write('You are at L3-4.'), nl.

describe(l3-4) :-
        at(staff, l3-4),
        \+ holding(staff),
        write('You need the staff to beat the dark lord. Pick up the staff by typing staff and clicking Pick or typing take(staff) if using CLI.'), nl, nl,
        energy(X),
        write('Current energy level is: '),write(X), nl,
        write('You are at L3-4.'), nl.

describe(l3-4) :-
        holding(staff),
        write('Go to the dark lord and beat it with the staff!'), nl, nl,
        energy(X),
        write('Current energy level is: '),write(X), nl,
        write('You are at L3-4.'), nl.

describe(win) :-
        write('Dark Lord has been defeated. You won the Triwizard Tournament Harry!'), nl,
        write('You are now at Hogwarts.'), nl.
