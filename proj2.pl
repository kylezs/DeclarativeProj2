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
[[0, 8, 7], [7, 7, 1], [7, 1, 7]]
Invalid 2
1. [[1,1,3], [1,1,1], [1,1,1]]


Valid 3
1. [[0, 14, 10, 35], [14, 7, 2, 1], [15, 3, 7, 5], [28, 4, 1, 7]]
Solve:
[[0, 14, 10, 35], [14, A, B, C], [15, D, E, F], [28, G, 1, I]]

From Grok
2. [[0,14,18,48],[20,_,_,_],[9,_,_,_],[126,_,_,_]]
[[0,14,18,48],[20,A,B,C],[9,D,E,F],[126,G,H,I]]
[[0,14,18,48],[20,3,9,8],[9,4,3,2],[126,7,6,3]]

3. [[0,24,17,126], [84, 6, 2, 7], [10, 1, 6, 3], [120, 4, 5, 6]]

Invalid 3
1. [[0, 14, 10, 35], [14, 7, 2, 1], [15, 3, 8, 5], [28, 4, 1, 7]]

Valid 4
1. [[0, 17, 10, 54, 420], [42, 2, 1, 3, 7], [108, 1, 2, 9, 6], [16, 6, 3, 2, 5], [15, 8, 4, 1, 2]]
Solve:
[[0, 17, 10, 54, 420], [42, 2, 1, 3, 7], [108, 1, _, 9, 6], [16, _, 3, 2, 5], [15, _, _, _, 2]]
[[0, 17, 10, 54, 420], [42, _, _, _, _], [108, 1, _, 9, 6], [16, _, 3, 2, _], [15, _, _, _, 2]]



Invalid 4 (83 instead of 84)
1. [[0, 14, 20, 83, 48], [13, 1, 2, 7, 3], [72, 3, 1, 6, 4], [252, 7, 9, 1, 4], [48, 3, 8, 2, 1]] (83 instead of 84)
2. [[1,1,1,1,2], [1,1,1,1,1], [1,1,1,1,1], [1,1,1,1,1], [1,1,1,1,1]]

Invalid 4
*/

% Need to construct the puzzle first.

% Used to write the puzzle immediately after getting to see the test

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
