/*
File     : Proj2.pl
Author   : Kyle Zsembery <k.zsembery@student.unimelb.edu.au>
Purpose  : A solver for a magic square maths puzzle game

Description of the game:

*/
% For transposing
:- ensure_loaded(library(clpfd)).

/* Test puzzles
Valid 2
1. 
Invalid 2
1. 


Valid 3
1. [[0, 14, 10, 35], [14, 7, 2, 1], [15, 3, 7, 5], [28, 4, 1, 7]]

Invalid 3
1. [[0, 14, 10, 35], [14, 7, 2, 1], [15, 3, 8, 5], [28, 4, 1, 7]]

Valid 4
1. [[0, 14, 20, 84, 48], [13, 1, 2, 7, 3], [72, 3, 1, 6, 4], [252, 7, 9, 1, 4], [48, 3, 8, 2, 1]]

Invalid 4
*/
puzzle_solution(Puzzle) :-
    diagonals_same(Puzzle),
    valid_rows_rem_header(Puzzle).

% 2, 3, 4 square cases- MAYBE USE IF STATEMENT TO CHECK LENGTH AND THEN DECIDE WHICH TO USE, TO STOP CHECKPOINTS
diagonals_same([[_, _, _], [_, X, _], [_, _, X]]).
diagonals_same([[_, _, _, _], [_, X, _, _], [_, _, X, _], [_, _, _, X]]).
diagonals_same([[_, _, _, _, _], [_, X, _, _, _], [_, _, X, _, _], [_, _, _, X, _], [_, _, _, _, X]]).

% The first row is the row of headers, can discard it. 
valid_rows_rem_header([_|X]) :-
    valid_rows(X).

valid_rows([]).
valid_rows([Row|Rest]) :-
    valid_row(Row),
    valid_rows(Rest).

valid_row(Row) :-
    (   valid_sum(Row)
    ;   valid_product(Row)
    ).

% this may fail the other way, when we need this as a constraint, e.g. A + B + 3 = 7.
valid_sum([Ans|Rest]) :-
    sumlist(Rest, Ans).

valid_product([Ans|Rest]) :-
    prod_list(Rest, Ans).

prod_list([], 1).
prod_list([H|T], Product) :-
    prod_list(T, Rest),
    Product is H*Rest.

% !!!!!!!!!! next, transpose to validate columns