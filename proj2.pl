/*
File     : Proj2.pl
Author   : Kyle Zsembery <k.zsembery@student.unimelb.edu.au>
Purpose  : A solver for a magic square maths puzzle game

Description of the puzzle:
A puzzle is a square grid of integers.
A valid/complete puzzle must adhere to these rules:
- Only digits 1 - 9 to be used
- Each row and each column contains no repeated digits
- All squares down the top-left to bottom-right diaganol must contain the
same value
- Puzzle headers contain EITHER the sum of the digits in the row/column 
OR the product of the digits in the row/column (NB: the above rules do
    not apply to puzzle headers. With upper left corner having no meaning)

==========================================================================
Description of this program:
This program solves puzzles of the above type using Prolog's
Constraint Logic Programming (Finite Domain) library capabilities.
It solves puzzles 2x2, 3x3 and 4x4 puzzles.

The above rules are represented as Prolog constraints and solutions are
generated from those constraints.

puzzle_solution(Puzzle) is the main method

`Puzzle` is input as a List of Lists, row by row, 
e.g. For a 3x3
[[_, H, H, H], [H, V, V, V], [H, V, V, V], [H, V, V, V]]
where H = a header values and V = a puzzle value
The values, Vs, may be bound or unbound. If unbound, 
they will (if possible) be bound to satisfy the puzzle constraints,
solving the puzzle.
*/

% Constraint Logic Programming (Finite Domain) Library
:- ensure_loaded(library(clpfd)).



puzzle_solution(Puzzle) :-
    diagonals_same(Puzzle),
    maplist(same_length(Puzzle), Puzzle),
    % Validate the rows
    valid_rows_rem_header(Puzzle),
    % Now validate the columns
    transpose(Puzzle, T),
    valid_rows_rem_header(T),
    append(Puzzle, Vars),
    labeling([ffc], Vars).

% Can use some sort of labeling, here. NB: labeling method has ffc and ff options that will make it more efficient

/*
Constrain the the diaganol values to all be the same value for 2x2, 3x3
and 4x4 puzzles */
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
    (   
        distinct_1to9(Row),
        (valid_sum(Row)
    ;   valid_product(Row)
        )
    ).

distinct_1to9([_|Row]) :-
    all_distinct(Row),
    Row ins 1..9.
    

% this may fail the other way, when we need this as a constraint, e.g. A + B + 3 = 7.
valid_sum([Ans|Rest]) :-
    sum(Rest, #=, Ans).


valid_product([Ans|Rest]) :-
    prod_list(Rest, Ans).

prod_list([], 1).
prod_list([H|T], Product) :-
    prod_list(T, Rest),
    Product #= H*Rest.


/* Test puzzles
Valid 2
[[0, 8, 7], [7, 7, 1], [7, 1, 7]]
Invalid 2
1. [[1,1,3], [1,1,1], [1,1,1]]

2. [[0, 13, 12], [12, 6, 2], [42, 7, 6]]
solve
[[0, 13, 12], [12, _,_], [42, _,_]] (gets 2 solutions, we will never be given puzzles that give 2 solutions, but code can do it)


Valid 3
1. [[0, 14, 10, 35], [14, 7, 2, 1], [15, 3, 7, 5], [28, 4, 1, 7]]
Solve:
[[0, 14, 10, 35], [14, A, B, C], [15, D, E, F], [28, G, 1, I]]

From Grok
2. [[0,14,18,48],[20,_,_,_],[9,_,_,_],[126,_,_,_]]
[[0,14,18,48],[20,A,B,C],[9,D,E,F],[126,G,H,I]]
[[0,14,18,48],[20,3,9,8],[9,4,3,2],[126,7,6,3]]

3. [[0,24,13,126], [84, 6, 2, 7], [10, 1, 6, 3], [120, 4, 5, 6]]
Solve
[[0,24,13,126], [84, _,_,_], [10, _,_,_], [120, _,_,_]]

Invalid 3
1. [[0, 14, 10, 35], [14, 7, 2, 1], [15, 3, 8, 5], [28, 4, 1, 7]]

Valid 4
1. [[0, 17, 10, 54, 420], [42, 2, 1, 3, 7], [108, 1, 2, 9, 6], [16, 6, 3, 2, 5], [15, 8, 4, 1, 2]]
Solve:
[[0, 17, 10, 54, 420], [42, 2, 1, 3, 7], [108, 1, _, 9, 6], [16, _, 3, 2, 5], [15, _, _, _, 2]]
[[0, 17, 10, 54, 420], [42, _, _, _, _], [108, 1, _, 9, 6], [16, _, 3, 2, _], [15, _, _, _, 2]]

2. [[0, 15, 630, 24, 168], [576, 2, 9, 8, 4], [15, 1, 2, 5, 7], [120, 4, 5, 2, 3], [26, 8, 7, 9, 2]]
Solve
[[0, 15, 630, 24, 168], [576, _, _, _, _], [15, _, _, _, _], [120, _, _, _, _], [26, _, _, _, _]]

3. [[0, 20, 384, 384, 20], [384, 2, 4, 8, 6], [20, 8, 2, 6, 4], [20, 4, 6, 2, 8], [384, 6, 8, 4, 2]]
Solve
[[0, 20, 384, 384, 20], [384, _, _, _, _], [20, _, _, _, _], [20, _, _, _, _], [384, _, _, _, _]] (very many solutions)
[[0, 20, 384, 384, 20], [384, _, 4, _, _], [20, 8, _, _, 4], [20, _, _, 2, _], [384, _, _, _, _]] (one solution)

3. 
Invalid 4 (83 instead of 84)
1. [[0, 14, 20, 83, 48], [13, 1, 2, 7, 3], [72, 3, 1, 6, 4], [252, 7, 9, 1, 4], [48, 3, 8, 2, 1]] (83 instead of 84)
2. [[1,1,1,1,2], [1,1,1,1,1], [1,1,1,1,1], [1,1,1,1,1], [1,1,1,1,1]]

Invalid 4
*/