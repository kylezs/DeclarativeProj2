/*
File     : Proj2.pl
Author   : Kyle Zsembery <k.zsembery@student.unimelb.edu.au>
Purpose  : A solver for a magic square maths puzzle game

==========================================================================

Description of the puzzle:
A puzzle is a square grid of integers.
A valid/complete puzzle must adhere to these puzzle rules:
1. Only digits 1 - 9 to be used
2. Each row and each column contains no repeated digits
3. All squares down the top-left to bottom-right diagonal must contain the
same value
4 Puzzle headers contain EITHER 
4.1 the sum of the digits (4.1) in the row/column 
OR 
4.2 The product of the digits in the row/column

NB1: the above rules do not apply to puzzle headers. With upper left corner 
having no meaning)

NB2: These rules are referred to throughout the inline documentation

==========================================================================

Description of this program:
This program solves puzzles of the above type using Prolog's
Constraint Logic Programming (Finite Domain) library capabilities.
It solves puzzles 2x2, 3x3 and 4x4 puzzles.

The above rules are represented as Prolog constraints and solutions are
generated from those constraints.

puzzle_solution(Puzzle) is the main method

==========================================================================
*/

% Constraint Logic Programming (Finite Domain) Library
:- ensure_loaded(library(clpfd)).

/*
Input: The Puzzle as a List of Lists (of integers), row by row.
e.g. For a 3x3
[[-, H, H, H],
 [H, V, V, V],
 [H, V, V, V],
 [H, V, V, V]]
where H = a Header entry and V = a puzzle Value
The header entries are always bound.
The puzzle values may be bound or unbound. If unbound, 
they will (if possible) be bound to satisfy the puzzle constraints,
solving the puzzle.
Holds if the Puzzle satisfies all Puzzle rules
*/
puzzle_solution(Puzzle) :-
    % do first to drastically reduce solution space
    diagonals_same(Puzzle),

    % Just make sure of the puzzle shape (should be square)
    maplist(same_length(Puzzle), Puzzle),

    % Validate the rows
    valid_rows_rem_header(Puzzle),

    % Now validate the columns
    transpose(Puzzle, T),
    valid_rows_rem_header(T),

    % list of lists -> list of vars (for use in `labeling`)
    append(Puzzle, Vars),

    % using the above constraints, generate a solution (if it exists)
    % ffc option (from docs)
    % https://swish.swi-prolog.org/pldoc/man?predicate=labeling/2: 
    % Of the variables with smallest domains, the leftmost one participating 
    % in most constraints is labeled next.
    labeling([ffc], Vars).

/*
Input: Puzzle (2x2, 3x3, 4x4)
Constrain the the diagonal values to all be the same value (rule 3)
*/
diagonals_same([[_, _, _],
                [_, X, _], 
                [_, _, X]]
                ).
diagonals_same([[_, _, _, _],
                [_, X, _, _], 
                [_, _, X, _], 
                [_, _, _, X]]
                ).
diagonals_same([[_, _, _, _, _],
                [_, X, _, _, _],
                [_, _, X, _, _],
                [_, _, _, X, _],
                [_, _, _, _, X]]
                ).

/* 
Input: Puzzle (or transposed puzzle for columns)
Holds if the Puzzle has valid rows

The first row of the puzzle (or column) is always just headers
and so it can be removed
*/
valid_rows_rem_header([_|X]) :-
    valid_rows(X).

/*
Input: Puzzle rows (or columns) - minus first header row 
Holds if all Puzzle rows are valid
*/
valid_rows([]).
valid_rows([Row|Rest]) :-
    valid_row(Row),
    valid_rows(Rest).

/* 
Input: A single row, consisting of a header followed by the puzzle row
Holds if Puzzle rules 1, 2 and 4 hold

NB: Only ONE of 4.1 and 4.2 need to hold, thus OR and not AND
*/
valid_row(Row) :-
    (   
        distinct_1to9(Row),
        (valid_sum(Row)
    ;   valid_product(Row)
        )
    ).

/* 
Input: A single row, consisting of a header followed by the puzzle row
Holds if Puzzle rules 1 and 2 hold
*/
distinct_1to9([_|Row]) :-
    % constraint for rule 2
    all_distinct(Row),

    % Contraint for rule 1
    Row ins 1..9.
    

/*
Input: A single row, consisting of a header followed by the puzzle row
Holds if the header is equal to the sum of the row values (rule 4.1)
*/
valid_sum([Ans|Rest]) :-
    % From clpfd
    sum(Rest, #=, Ans).

/*
Input: A single row, consisting of a header followed by the puzzle row
Holds if the header is equal to the product of the row values (rule 4.2)
*/
valid_product([Ans|Rest]) :-
    prod_list(Rest, Ans).

/*
Input: List of integers, L, a Product, P
Holds if the product of the ints in L are equal to P
*/
prod_list([], 1).
prod_list([H|T], Product) :-
    prod_list(T, Rest),
    Product #= H*Rest.
