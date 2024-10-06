use core::option::OptionTrait;
use alexandria_data_structures::array_ext::ArrayTraitExt;
use core::array::ArrayTrait;
use alexandria_math::{U128BitShift, U256BitShift, U16BitShift};

use core::traits::TryInto;
// let val = U256BitShift::shl(vale, 3); // right shift  multiply << 128
// let valr =U256BitShift::shr(vale, 3); // left shift  divison >>  2
const max_u256: u256 = 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;

pub fn encodeTokenId(num1: u256, num2: u256) -> u256 {
    (U256BitShift::shl(num1, 8) | num2)
}


pub fn calculate_move_enoded(_depth: u256, _move: u256, _bestMove: u256) -> u256 {
    U256BitShift::shl(_depth, 24) | U256BitShift::shl(_move, 12) | _bestMove
}

//////////////////////////////////////////////////
//                                              //
//  Library: ArrayStack                         //
//  Description:                                //
//  - Implemented ArrayStack library methods    //
//    with proper trait implementations.        //
//                                              //
//////////////////////////////////////////////////
#[derive(Drop, Debug)]
pub struct ArrayStack {
    main_stack: Array<u256>,
    aux_stack: Array<u256>,
    size: usize,
}
#[derive(Drop)]
pub struct Move {
    board: u256,
    metadata: u256,
}
#[derive(Drop)]
pub struct MoveArray {
    pub index: u32,
    pub items: ArrayStack,
}

fn insert(ref arrst: ArrayStack, index: usize, value: u256) {
    if (index >= arrst.size) { // println!("Array out of bound");
    }
    // println!("{:?}", arrst.main_stack); //
    let mut i = 0;
    while i < index {
        let val = arrst.main_stack.pop_front().unwrap();
        arrst.aux_stack.append(val);
        i += 1;
    };
    arrst.main_stack.pop_front(); // Remove the old value
    arrst.aux_stack.append(value); // Set the new value
    arrst.aux_stack.append_all(ref arrst.main_stack); // Append the old value back
    arrst.main_stack = arrst.aux_stack; // Reverse the stack
    arrst.aux_stack = ArrayTrait::<u256>::new();
}
fn append(ref arrst: ArrayStack, value: u256) {
    arrst.main_stack.append(value);
    arrst.size += 1;
}
fn get(arrst: @ArrayStack, index: usize) -> u256 {
    return arrst.main_stack.at(index).clone();
}
fn len(arrst: @ArrayStack) -> usize {
    return arrst.size.clone();
}
fn newAS() -> ArrayStack {
    ArrayStack {
        main_stack: ArrayTrait::<u256>::new(), aux_stack: ArrayTrait::<u256>::new(), size: 0,
    }
}

//////////////////////////////////////////////////
//                                              //
//  Chess AI Implementation                     //
//  Description:                                //
//  - Implemented basic chess AI functionalities//
//    such as move generation and evaluation.   //
//                                              //
//////////////////////////////////////////////////

/// @notice Searches for the ``best'' move.
/// @dev The ply depth must be at least 3 because game ending scenarios are determined lazily.
/// This is because {generateMoves} generates pseudolegal moves. Consider the following:
///     1. In the case of white checkmates black, depth 2 is necessary:
///         * Depth 1: This is the move black plays after considering depth 2.
///         * Depth 2: Check whether white captures black's king within 1 turn for every such
///           move. If so, white has checkmated black.
///     2. In the case of black checkmates white, depth 3 is necessary:
///         * Depth 1: This is the move black plays after considering depths 2 and 3.
///         * Depth 2: Generate all pseudolegal moves for white in response to black's move.
///         * Depth 3: Check whether black captures white's king within 1 turn for every such
///         * move. If so, black has checkmated white.
/// The minimum depth required to cover all the cases above is 3. For simplicity, stalemates
/// are treated as checkmates.
///
/// The function returns 0 if the game is over after white's move (no collision with any
/// potentially real moves because 0 is not a valid index), and returns true if the game is over
/// after black's move.
/// @param _board The board position to analyze.
/// @param _depth The ply depth to analyze to. Must be at least 3.
/// @return The best move for the player (denoted by the last bit in `_board`).
/// @return Whether white is checkmated or not.
pub fn searchMove(_board: u256, _depth: u256) -> (u256, bool) {
    let mut moves = generateMoves(_board);
    if (get(@moves, 0) == 0) {
        return (0, false);
    }
    let mut bestScore: i128 = -4_196;
    let mut currentScore: i128 = 0;
    let mut bestMove: u256 = 0;

    let mut i: u32 = 0;
    while get(@moves, i) != 0 {
        let mut movePartition = get(@moves, i);
        while movePartition != 0 {
            currentScore = evaluateMove(_board, movePartition & 0xFFF)
                + negMax(applyMove(_board, movePartition & 0xFFF), _depth - 1);

            if (currentScore > bestScore) {
                bestScore = currentScore;
                bestMove = movePartition & 0xFFF;
            }
            movePartition = U256BitShift::shr(movePartition, 0xC);
        };
        i = i + 1;
    };

    if (bestScore < -1_260) {
        return (0, false);
    };
    return (bestMove, bestScore > 1_260);
}

/// @notice Searches and evaluates moves using a variant of the negamax search algorithm.
/// @dev For efficiency, the function evaluates how good moves are and sums them up, rather than
/// evaluating entire board positions. Thus, the only pruning the algorithm performs is when a
/// king is captured. If a king is captured, it always returns -4,000, which is the king's value
/// because there is nothing more to consider.
/// @param _board The board position to analyze.
/// @param _depth The ply depth to analyze to.
/// @return The cumulative score searched to a ply depth of `_depth`, assuming each side picks
/// their best moves.
pub fn negMax(_board: u256, _depth: u256) -> i128 {
    if (_depth == 0) {
        return 0;
    }
    let mut moves = generateMoves(_board);
    if (get(@moves, 0) == 0) {
        return 0;
    }
    let mut bestScore: i128 = -4_196;
    let mut currentScore: i128 = 0;
    let mut bestMove: u256 = 0;
    let mut i: u32 = 0;
    while get(@moves, i) != 0 {
        let mut movePartition = get(@moves, i);
        while movePartition != 0 {
            currentScore = evaluateMove(_board, movePartition & 0xFFF);
            if (currentScore > bestScore) {
                bestScore = currentScore;
                bestMove = movePartition & 0xFFF;
            }
            movePartition = U256BitShift::shr(movePartition, 0xC);
        };
        i = i + 1;
    };
    if (((U256BitShift::shr(_board, U256BitShift::shl((bestMove & 0x3F), 2))) & 7) == 6) {
        return -4_000;
    }
    if (_board & 1 == 0) {
        return bestScore + negMax(applyMove(_board, bestMove), _depth - 1);
    } else {
        return -bestScore + negMax(applyMove(_board, bestMove), _depth - 1);
    }
}

/// @notice Uses piece-square tables (PSTs) to evaluate how ``good'' a move is.
/// @dev The PSTs were selected semi-arbitrarily with chess strategies in mind (e.g. pawns are
/// good in the center). Updating them changes the way the engine ``thinks.'' Each piece's PST
/// is bitpacked into as few uint256s as possible for efficiency .
///          Pawn                Bishop               Knight                   Rook
///    20 20 20 20 20 20    62 64 64 64 64 62    54 56 54 54 56 58    100 100 100 100 100 100
///    30 30 30 30 30 30    64 66 66 66 66 64    56 60 64 64 60 56    101 102 102 102 102 101
///    20 22 24 24 22 20    64 67 68 68 67 64    58 64 68 68 64 58     99 100 100 100 100  99
///    21 20 26 26 20 21    64 68 68 68 68 64    58 65 68 68 65 58     99 100 100 100 100  99
///    21 30 16 16 30 21    64 67 66 66 67 64    56 60 65 65 60 56     99 100 100 100 100  99
///    20 20 20 20 20 20    62 64 64 64 64 62    54 56 58 58 56 54    100 100 101 101 100 100
///                            Queen                         King
///                   176 178 179 179 178 176    3994 3992 3990 3990 3992 3994
///                   178 180 180 180 180 178    3994 3992 3990 3990 3992 3994
///                   179 180 181 181 180 179    3996 3994 3992 3992 3994 3995
///                   179 181 181 181 180 179    3998 3996 3996 3996 3996 3998
///                   178 180 181 180 180 178    4001 4001 4000 4000 4001 4001
///                   176 178 179 179 178 176    4004 4006 4002 4002 4006 4004
/// All entries in the figure above are in decimal representation.
///
/// Each entry in the pawn's, bishop's, knight's, and rook's PSTs uses 7 bits, and each entry in
/// the queen's and king's PSTs uses 12 bits. Additionally, each piece is valued as following:
///                                      | Type   | Value |
///                                      | ------ | ----- |
///                                      | Pawn   | 20    |
///                                      | Bishop | 66    |
///                                      | Knight | 64    |
///                                      | Rook   | 100   |
///                                      | Queen  | 180   |
///                                      | King   | 4000  |
/// The king's value just has to be sufficiently larger than 180 * 7 = 1260 (i.e. equivalent to
/// 7 queens) because check/checkmates are detected lazily .
///
/// The evaluation of a move is given by
///                Δ(PST value of the moved piece) + (PST value of any captured pieces).
/// @param _board The board to apply the move to.
/// @param _move The move to evaluate.
/// @return The evaluation of the move applied to the given position.
fn evaluateMove(_board: u256, _move: u256) -> i128 {
    let fromIndex: u256 = 6 * (U256BitShift::shr(_move, 9))
        + ((U256BitShift::shr(_move, 6)) & 7)
        - 7;

    let toIndex: u256 = 6 * ((U256BitShift::shr(_move & 0x3F, 3))) + ((_move & 0x3F) & 7) - 7;
    let pieceAtFromIndex: u256 = U256BitShift::shr(
        _board, (U256BitShift::shl(U256BitShift::shr(_move, 6), 2))
    )
        & 7;

    let pieceAtToIndex: u256 = (U256BitShift::shr(_board, (U256BitShift::shl(_move & 0x3F, 2)))
        & 7);

    let mut oldPst: u256 = 0;
    let mut newPst: u256 = 0;
    let mut captureValue: u256 = 0;
    if (pieceAtToIndex != 0) {
        if (pieceAtToIndex < 5) { // piece is not a queen or king 
            captureValue =
                U256BitShift::shr(
                    getPst(pieceAtToIndex),
                    if ((7 * (0x23 - toIndex)) < 255) {
                        (7 * (0x23 - toIndex))
                    } else {
                        255
                    }
                )
                & 0x7F;
        } else if (toIndex < 0x12) {
            captureValue =
                U256BitShift::shr(
                    getPst(pieceAtToIndex),
                    if ((0xC * (0x11 - toIndex)) < 255) {
                        (0xC * (0x11 - toIndex))
                    } else {
                        255
                    }
                )
                & 0xFFF;
        } else {
            captureValue =
                U256BitShift::shr(
                    getPstTwo(pieceAtToIndex),
                    if ((0xC * (0x23 - toIndex)) < 255) {
                        (0xC * (0x23 - toIndex))
                    } else {
                        255
                    }
                )
                & 0xFFF;
        }
    }
    if (pieceAtFromIndex < 5) { // if piece is not the queen or king
        oldPst =
            U256BitShift::shr(
                getPst(pieceAtFromIndex),
                if ((7 * (0x23 - fromIndex)) < 255) {
                    (7 * (0x23 - fromIndex))
                } else {
                    255
                }
            )
            & 0x7F;
        newPst =
            U256BitShift::shr(
                getPst(pieceAtFromIndex), if ((7 * toIndex) < 255) {
                    (7 * toIndex)
                } else {
                    255
                }
            )
            & 0x7F;
    } else if (fromIndex < 0x12) {
        oldPst =
            U256BitShift::shr(
                getPstTwo(pieceAtFromIndex),
                (if ((0xC * fromIndex) < 255) {
                    (0xC * fromIndex)
                } else {
                    255
                })
            )
            & 0xFFF;
        newPst =
            U256BitShift::shr(
                getPstTwo(pieceAtFromIndex),
                (if ((0xC * toIndex) < 255) {
                    0xC * toIndex
                } else {
                    255
                })
            )
            & 0xFFF;
    } else {
        if (fromIndex >= 0x12 && toIndex >= 0x12) {
            oldPst =
                U256BitShift::shr(
                    getPst(pieceAtFromIndex),
                    (if ((0xC * (fromIndex - 0x12)) < 255) {
                        0xC * (fromIndex - 0x12)
                    } else {
                        255
                    })
                )
                & 0xFFF;
            newPst =
                U256BitShift::shr(
                    getPst(pieceAtFromIndex),
                    (if ((0xC * (toIndex - 0x12)) < 255) {
                        (0xC * (toIndex - 0x12))
                    } else {
                        255
                    })
                )
                & 0xFFF;
        }
    }
    let capture_felt: felt252 = captureValue.try_into().unwrap();
    let captureValueI: i128 = capture_felt.try_into().unwrap();
    let oldPst_felt: felt252 = oldPst.try_into().unwrap();
    let oldPstI: i128 = oldPst_felt.try_into().unwrap();
    let newPst_felt: felt252 = newPst.try_into().unwrap();
    let newPstI: i128 = newPst_felt.try_into().unwrap();
    let computed_i128: i128 = captureValueI + newPstI - oldPstI;
    return computed_i128;
}
/// @notice Maps a given piece type to its PST (see {Engine-evaluateMove} for details on the
/// PSTs and {Chess} for piece representation).
/// @dev The queen's and king's PSTs do not fit in 1 uint256, so their PSTs are split into 2
/// uint256s each. {Chess-getPst} contains the first half, and {Chess-getPstTwo} contains the
/// second half.
/// @param _type A piece type defined in {Chess}.
/// @return The PST corresponding to `_type`.
fn getPst(_type: u256) -> u256 {
    if (_type == 1) {
        return 0x2850A142850F1E3C78F1E2858C182C50A943468A152A788103C54A142850A14;
    }
    if (_type == 2) {
        return 0x7D0204080FA042850A140810E24487020448912240810E1428701F40810203E;
    }
    if (_type == 3) {
        return 0xC993264C9932E6CD9B365C793264C98F1E4C993263C793264C98F264CB97264;
    }
    if (_type == 4) {
        return 0x6CE1B3670E9C3C8101E38750224480E9D4189120BA70F20C178E1B3874E9C36;
    }
    if (_type == 5) {
        return 0xB00B20B30B30B20B00B20B40B40B40B40B20B30B40B50B50B40B3;
    }
    return 0xF9AF98F96F96F98F9AF9AF98F96F96F98F9AF9CF9AF98F98F9AF9B;
}
/// @notice Maps a queen or king to the second half of its PST (see {Engine-getPst}).
/// @param _type A piece type defined in {Chess}. Must be a queen or a king .
/// @return The PST corresponding to `_type`.
fn getPstTwo(_type: u256) -> u256 {
    if (_type == 5) {
        return 0xB30B50B50B50B40B30B20B40B50B40B40B20B00B20B30B30B20B0;
    } else {
        return 0xF9EF9CF9CF9CF9CF9EFA1FA1FA0FA0FA1FA1FA4FA6FA2FA2FA6FA4;
    }
}

//////////////////////////////////////////////////
//                                              //
//  Chess Validation and Application            //
//  Description:                                //
//  - Implemented chess move validation         //
//    and application logic for a chess game.   //
//                                              //
//////////////////////////////////////////////////

/// ======================================Piece Representation======================================
/// Each chess piece is defined with 4 bits as follows:
///     * The first bit denotes the color (0 means black; 1 means white).
///     * The last 3 bits denote the type:
///         | Bits | # | Type   |
///         | ---- | - | ------ |
///         | 000  | 0 | Empty  |
///         | 001  | 1 | Pawn   |
///         | 010  | 2 | Bishop |
///         | 011  | 3 | Rook   |
///         | 100  | 4 | Knight |
///         | 101  | 5 | Queen  |
///         | 110  | 6 | King   |
/// ======================================Board Representation======================================
/// The board is an 8x8 representation of a 6x6 chess board. For efficiency, all information is
/// bitpacked into a single u256. Thus, unlike typical implementations, board positions are
/// accessed via bit shifts and bit masks, as opposed to array accesses. Since each piece is 4 bits,
/// there are 64 ``indices'' to access:
///                                     63 62 61 60 59 58 57 56
///                                     55 54 53 52 51 50 49 48
///                                     47 46 45 44 43 42 41 40
///                                     39 38 37 36 35 34 33 32
///                                     31 30 29 28 27 26 25 24
///                                     23 22 21 20 19 18 17 16
///                                     15 14 13 12 11 10 09 08
///                                     07 06 05 04 03 02 01 00
/// All numbers in the figure above are in decimal representation.
/// For example, the piece at index 27 is accessed with ``(board >> (27 << 2)) & 0xF''.
///
/// The top/bottom rows and left/right columns are treated as sentinel rows/columns for efficient
/// boundary validation  i.e., (63, ..., 56),
/// (07, ..., 00), (63, ..., 07), and (56, ..., 00) never contain pieces. Every bit in those rows
/// and columns should be ignored, except for the last bit. The last bit denotes whose turn it is to
/// play (0 means black's turn; 1 means white's turn). e.g. a potential starting position:
///                                Black
///                       00 00 00 00 00 00 00 00                    Black
///                       00 03 02 05 06 02 03 00                 ♜ ♝ ♛ ♚ ♝ ♜
///                       00 01 01 01 01 01 01 00                 ♟ ♟ ♟ ♟ ♟ ♟
///                       00 00 00 00 00 00 00 00     denotes
///                       00 00 00 00 00 00 00 00    the board
///                       00 09 09 09 09 09 09 00                 ♙ ♙ ♙ ♙ ♙ ♙
///                       00 11 12 13 14 12 11 00                 ♖ ♘ ♕ ♔ ♘ ♖
///                       00 00 00 00 00 00 00 01                    White
///                                White
/// All numbers in the example above are in decimal representation.
/// ======================================Move Representation=======================================
/// Each move is allocated 12 bits. The first 6 bits are the index the piece is moving from, and the
/// last 6 bits are the index the piece is moving to. Since the index representing a square is at
/// most 54, 6 bits sufficiently represents any index (0b111111 = 63 > 54). e.g. 1243 denotes a move
/// from index 19 to 27 (1243 = (19 << 6) | 27).
///
/// Since the board is represented by a u256, consider including ``using Chess for u256''.

/// @notice Takes in a board position, and applies the move `_move` to it.
/// @dev After applying the move, the board's perspective is updated (so that NEXT PLAYER CAN PLAY
/// THEIR MOVE ). Thus, @param _board The board to apply the move to.
/// @param _move The move to apply.
/// @return The reversed board after applying `_move` to `_board`.
pub fn applyMove(mut _board: u256, _move: u256) -> u256 {
    let piece: u256 = U256BitShift::shr(_board, U256BitShift::shl(U256BitShift::shr(_move, 6), 2))
        & 0xF;
    _board = _board
        & (max_u256 ^ (U256BitShift::shl(0xF, U256BitShift::shl(U256BitShift::shr(_move, 6), 2))));

    _board = _board
        & (max_u256
            ^ (U256BitShift::shl(
                0xF, U256BitShift::shl(_move & 0x3F, 2)
            ))); // thus creating the system much more 
    // place the piece at the to index
    _board = _board | U256BitShift::shl(piece, U256BitShift::shl(_move & 0x3F, 2));

    return rotate(_board);
}

/// @notice Flips the view of the game board by reversing its 4-bit sections.
/// For example, `1100-0011` becomes `0011-1100`.
/// @dev  Since the last bit exchanges positions with the 4th bit, changes the player .
/// @param _board The board  to reverse .
/// @return _board reversed.
pub fn rotate(mut _board: u256) -> u256 {
    let mut rotatedBoard: u256 = 0;
    let mut i: u256 = 0;
    loop {
        if i >= 64 {
            break;
        }
        rotatedBoard = (U256BitShift::shl(rotatedBoard, 4)) | (_board & 0xF);
        _board = U256BitShift::shr(_board, 4);
        i = i + 1;
    };
    rotatedBoard
}

/// Maps an index relative to the 6x6 board to the index relative to the 8x8
/// representation.
/// The indices are mapped as follows:
///                           35 34 33 32 31 30              54 53 52 51 50 49
///                           29 28 27 26 25 24              46 45 44 43 42 41
///                           23 22 21 20 19 18    mapped    38 37 36 35 34 33
///                           17 16 15 14 13 12      to      30 29 28 27 26 25
///                           11 10 09 08 07 06              22 21 20 19 18 17
///                           05 04 03 02 01 00              14 13 12 11 10 09
/// All numbers in the figure above are in decimal representation. The bits are bitpacked into a
/// uint256 (i.e. ``0xDB5D33CB1BADB2BAA99A59238A179D71B69959551349138D30B289 = 54 << (6 * 35) |
/// ... | 9 << (6 * 0)'') for efficiency.
/// Index relative to the 6x6 board.
/// Index relative to the 8x8 representation.
/// Appends a move to a {Chess-MovesArray} object.
/// Since each uint256 fits at most 21 moves
/// bitpacks 21 moves per uint256 before moving on to the next uint256.

/// @notice Generates all possible  moves for a given position and color.
/// @dev The last bit denotes which color to generate the moves for .
///  All moves are expressed in code as shifts respective to the board's 8x8 representation .
/// @param _board The board position to generate moves for.
/// @return ArrayStack of all possible moves. not more then the 105 moves as 105 * 12 bits = 1260
/// and  256 bits * 5 = 1280
pub fn generateMoves(_board: u256) -> ArrayStack { // done and checked 
    let mut movesArray = MoveArray { index: 0, items: newAS(), };
    append(ref movesArray.items, 0);
    append(ref movesArray.items, 0);
    append(ref movesArray.items, 0);
    append(ref movesArray.items, 0);
    append(ref movesArray.items, 0);
    let mut move: u256 = 0;
    // `0xDB5D33CB1BADB2BAA99A59238A179D71B69959551349138D30B289` is a mapping of indices
    // relative to the 6x6 board to indices relative to the 8x8 representation
    let mut index: u256 = 0xDB5D33CB1BADB2BAA99A59238A179D71B69959551349138D30B289;
    loop {
        if index == 0 {
            break;
        }
        let mut adjustedIndex: u256 = (index & 0x3F);
        let mut adjustedBoard: u256 = U256BitShift::shr(
            _board, U256BitShift::shl(adjustedIndex, 2)
        );
        let mut piece = adjustedBoard & 0xF;
        // Skip if square is empty or not the color of the board the function call is analyzing.
        if (piece == 0 || U256BitShift::shr(piece, 3) != _board & 1) {
            index = U256BitShift::shr(index, 6);
            continue;
        }
        // remove the player bit  0111 &
        piece = piece & 0x7;
        // means it is pawn
        if (piece == 1) {
            /// if the front row is empty or not
            if (U256BitShift::shr(adjustedBoard, 0x20) & 0xF == 0) {
                appendTo(ref movesArray, adjustedIndex, adjustedIndex + 8);

                /// move the pawn to the 2 row head
                /// means it is in his 2 row starting point and can move 2 steps and that place is
                /// empty
                if ((U256BitShift::shr(adjustedIndex, 3) == 2)
                    && (U256BitShift::shr(adjustedBoard, 0x40) & 0xF == 0)) {
                    appendTo(ref movesArray, adjustedIndex, adjustedIndex + 0x10);
                }
            }
            /// capture the piece to the left diagonal of it
            if (isCapture(_board, U256BitShift::shr(adjustedBoard, 0x1C))) {
                ///append to the moves
                appendTo(ref movesArray, adjustedIndex, adjustedIndex + 7);
            }
            //// capture the piece to the right diagonal of it
            if (isCapture(_board, U256BitShift::shr(adjustedBoard, 0x24))) {
                ///append to the moves
                appendTo(ref movesArray, adjustedIndex, adjustedIndex + 9);
            }
        } /// if piece is knight(horse) or king 
        else if (piece & 0x7 == 4 || piece & 0x7 == 6) {
            let mut move = if piece == 4 {
                0x060A0F11
            } else {
                0x01070809
            };

            while (move != 0) {
                if (isValid(_board, adjustedIndex + (move & 0xFF))) {
                    appendTo(ref movesArray, adjustedIndex, adjustedIndex + (move & 0xFF));
                }
                if (move <= adjustedIndex && isValid(_board, adjustedIndex - (move & 0xFF))) {
                    appendTo(ref movesArray, adjustedIndex, adjustedIndex - (move & 0xFF));
                }
                move = U256BitShift::shr(move, 8);
            }
        } else {
            if (piece != 2) {
                move = adjustedIndex + 1; // 10 
                while isValid(_board, move) {
                    appendTo(ref movesArray, adjustedIndex, move);
                    if (isCapture(_board, U256BitShift::shr(_board, U256BitShift::shl(move, 2)))) {
                        break;
                    }
                    move = move + 1;
                };
                move = adjustedIndex - 1; // move - 8 
                while isValid(_board, move) {
                    appendTo(ref movesArray, adjustedIndex, move);

                    if (isCapture(_board, U256BitShift::shr(_board, U256BitShift::shl(move, 2)))) {
                        break;
                    }

                    move = move - 1;
                };

                move = adjustedIndex + 8;
                while isValid(_board, move) {
                    appendTo(ref movesArray, adjustedIndex, move);
                    if (isCapture(_board, U256BitShift::shr(_board, U256BitShift::shl(move, 2)))) {
                        break;
                    }
                    move = move + 8;
                };
                move = adjustedIndex - 8;
                while isValid(_board, move) {
                    appendTo(ref movesArray, adjustedIndex, move);
                    if (isCapture(_board, U256BitShift::shr(_board, U256BitShift::shl(move, 2)))) {
                        break;
                    }
                    move = move - 8;
                };
            }
            if (piece != 3) {
                move = adjustedIndex + 7;
                while isValid(_board, move) {
                    appendTo(ref movesArray, adjustedIndex, move);
                    if (isCapture(_board, U256BitShift::shr(_board, U256BitShift::shl(move, 2)))) {
                        break;
                    }
                    move = move + 7;
                };
                move = adjustedIndex - 7;
                while isValid(_board, move) {
                    appendTo(ref movesArray, adjustedIndex, move);
                    if (isCapture(_board, U256BitShift::shr(_board, U256BitShift::shl(move, 2)))) {
                        break;
                    }
                    move = move - 7;
                };
                move = adjustedIndex + 9;
                while isValid(_board, move) {
                    appendTo(ref movesArray, adjustedIndex, move);
                    if (isCapture(_board, U256BitShift::shr(_board, U256BitShift::shl(move, 2)))) {
                        break;
                    }
                    move = move + 9;
                };

                move = adjustedIndex - 9;
                while isValid(_board, move) {
                    if (move == 0) {
                        break;
                    }
                    appendTo(ref movesArray, adjustedIndex, move);
                    if (isCapture(_board, U256BitShift::shr(_board, U256BitShift::shl(move, 2)))) {
                        break;
                    }
                    move = move - 9;
                };
            }
        }
        /// outerloop
        index = U256BitShift::shr(index, 6);
    };
    // println!("{:?}", movesArray.items.main_stack);
    return movesArray.items;
}

/// @notice Determines whether a move is a legal move or not (includes checking whether king is
/// checked or not after the move).
/// @param _board The board to analyze.
/// @param _move The move to check.
/// @return Whether the move is legal or not.
pub fn isLegalMove(_board: u256, _move: u256) -> bool {
    let fromIndex: u256 = U256BitShift::shr(_move, 6);
    let toIndex: u256 = _move & 0x3F;

    if ((U256BitShift::shr(0x7E7E7E7E7E7E00, fromIndex) & 1) == 0) {
        return false;
    }

    if ((U256BitShift::shr(0x7E7E7E7E7E7E00, toIndex) & 1) == 0) {
        return false;
    }

    let mut pieceAtFromIndex: u256 = U256BitShift::shr(_board, U256BitShift::shl(fromIndex, 2))
        & 0xF;
    if (pieceAtFromIndex == 0) {
        return false;
    }
    if (U256BitShift::shr(pieceAtFromIndex, 3) != _board & 1) {
        return false;
    }
    pieceAtFromIndex = pieceAtFromIndex & 0x7;

    let adjustedBoard = U256BitShift::shr(_board, U256BitShift::shl(toIndex, 2));
    let mut indexChange: u256 = if toIndex < fromIndex {
        fromIndex - toIndex
    } else {
        toIndex - fromIndex
    };
    if (pieceAtFromIndex == 1) {
        if (toIndex <= fromIndex) {
            return false;
        }
        indexChange = toIndex - fromIndex;
        if (indexChange == 7 || indexChange == 9) {
            if (!isCapture(_board, adjustedBoard)) {
                return false;
            }
        } else if (indexChange == 8) {
            if (!isValid(_board, toIndex)) {
                return false;
            }
        } else if (indexChange == 0x10) {
            if (!isValid(_board, toIndex - 8) || !isValid(_board, toIndex)) {
                return false;
            }
        } else {
            return false;
        }
    } else if (pieceAtFromIndex == 4 || pieceAtFromIndex == 6) {
        if (U256BitShift::shr(if pieceAtFromIndex == 4 {
            0x28440
        } else {
            0x382
        }, indexChange)
            & 1 == 0) {
            return false;
        }
        if (!isValid(_board, toIndex)) {
            return false;
        }
    } else {
        let mut rayFound: bool = false;
        if (pieceAtFromIndex != 2) {
            if (pieceAtFromIndex != 2) {
                rayFound = searchRay(_board, fromIndex, toIndex, 1)
                    || searchRay(_board, fromIndex, toIndex, 8);
            }
        }
        if (pieceAtFromIndex != 3) {
            rayFound = rayFound
                || searchRay(_board, fromIndex, toIndex, 7)
                || searchRay(_board, fromIndex, toIndex, 9);
        }
        if (!rayFound) {
            return false;
        }
    }
    if (negMax(applyMove(_board, _move), 1) < -1_260) {
        return false;
    }
    return true;
}

/// @notice Determines whether there is a clear path along a direction vector from one index to
/// another index on the board.
/// @dev The board's representation essentially flattens it from 2D to 1D, so `_directionVector`
/// should be the change in index that represents the direction vector.
/// @param _board The board to analyze.
/// @param _fromIndex The index of the starting piece.
/// @param _toIndex The index of the ending piece.
/// @param _directionVector The direction vector of the ray.
/// @return Whether there is a clear path between `_fromIndex` and `_toIndex` or not.
pub fn searchRay(_board: u256, _fromIndex: u256, _toIndex: u256, _directionVector: u256) -> bool {
    let mut indexChange: u256 = 0;
    let mut rayStart: u256 = 0;
    let mut rayEnd: u256 = 0;
    if (_fromIndex < _toIndex) {
        indexChange = _toIndex - _fromIndex;
        rayStart = _fromIndex + _directionVector;
        rayEnd = _toIndex;
    } else {
        indexChange = _fromIndex - _toIndex;
        rayStart = _toIndex;
        rayEnd = _fromIndex - _directionVector;
    }
    if (indexChange % _directionVector != 0) {
        return false;
    }

    let mut rayStart = rayStart;
    let mut flag: bool = false;

    loop {
        if (rayStart >= rayEnd) {
            break;
        }
        if (!isValid(_board, rayStart)) {
            flag = true;
            break;
        }
        if (isCapture(_board, U256BitShift::shr(_board, U256BitShift::shl(rayStart, 2)))) {
            flag = true;
            break;
        }
        rayStart = rayStart + _directionVector;
    };
    if flag {
        return false;
    }

    return rayStart == rayEnd;
}

/// @notice Determines whether a move results in a capture or not.
/// @param _board The board prior to the potential capture.
/// @param _indexAdjustedBoard The board bitshifted to the to index to consider.
/// @return Whether the move is a capture or not.
pub fn isCapture(_board: u256, _indexAdjustedBoard: u256) -> bool {
    /// exp the square you want to caputure is not empty and the piece is not the same as the
    /// current player
    return ((_indexAdjustedBoard & 0xF != 0)
        && (U256BitShift::shr(_indexAdjustedBoard & 0xF, 3) != _board & 1));
}

/// @notice Determines whether a move is valid or not (i.e. within bounds and not capturing
/// same colored piece).
/// @dev As mentioned above, the board representation has 2 sentinel rows and columns for
/// efficient boundary validation as follows:
///                                           0 0 0 0 0 0 0 0
///                                           0 1 1 1 1 1 1 0
///                                           0 1 1 1 1 1 1 0
///                                           0 1 1 1 1 1 1 0
///                                           0 1 1 1 1 1 1 0
///                                           0 1 1 1 1 1 1 0
///                                           0 1 1 1 1 1 1 0
///                                           0 0 0 0 0 0 0 0,
/// where 1 means a piece is within the board, and 0 means the piece is out of bounds. The bits
/// are bitpacked into a uint256 (i.e. ``0x7E7E7E7E7E7E00 = 0 << 63 | ... | 0 << 0'') for
/// efficiency.
///
/// Moves that overflow the uint256 are computed correctly because bitshifting more than bits
/// available results in 0. However, moves that underflow the uint256 (i.e. applying the move
/// results in a negative index) must be checked beforehand.
/// @param _board The board on which to consider whether the move is valid.
/// @param _toIndex The to index of the move.
/// @return Whether the move is valid or not.
pub fn isValid(_board: u256, _toIndex: u256) -> bool {
    return (((U256BitShift::shr(0x7E7E7E7E7E7E00, _toIndex)
        & 1) == 1) // move must be with in the bounds 
        && ((U256BitShift::shr(_board, U256BitShift::shl(_toIndex, 2))
            & 0xF) == 0 // the to index must be empty
            || U256BitShift::shr(
                U256BitShift::shr(_board, U256BitShift::shl(_toIndex, 2)) & 0xF, 3
            ) != _board
                & 1 ///piece is the opposite contester 
                ));
}


/// @param _movesArray {Chess-MovesArray} object to append the new move to.
/// @param _fromMoveIndex Index the piece moves from.
/// @param _toMoveIndex Index the piece moves to.

pub fn appendTo(ref _moveArray: MoveArray, _fromMoveIndex: u256, _toMoveIndex: u256) -> bool {
    let mut currentIndex = _moveArray.index;
    let mut currentPartition = get(@_moveArray.items, currentIndex);
    if (currentPartition > U256BitShift::shl(1, 0xF6)) {
        _moveArray.index += 1;
        insert(
            ref _moveArray.items,
            _moveArray.index,
            U256BitShift::shl(_fromMoveIndex, 6) | _toMoveIndex
        );
    } else {
        insert(
            ref _moveArray.items,
            currentIndex,
            U256BitShift::shl(currentPartition, 0xC)
                | U256BitShift::shl(_fromMoveIndex, 6)
                | _toMoveIndex
        )
    }
    return true;
}


#[cfg(test)]
mod tests {
    // apply move test
    use super::{rotate, applyMove};

    #[test]
    fn test_rotate() {
        let mut _board = 0x3256230010000100001000009199D00009009000BC0ECB000000001;
        let rotated_board = rotate(_board);

        let rotate_as = 0x100000000BCE0CB00090090000D9919000001000010000100326523000000000;
        assert(rotated_board == rotate_as, 'not rotated properly ');
    }

    #[test]
    fn test_apply_move() {
        let mut _board = 0x3256230010000100001000009199D00009009000BC0ECB000000001;
        let new_board = applyMove(_board, 1373);
        let new_board_as = 0x100000000BCE0CB00090000000D9999000001000010000100326523000000000;
        assert(new_board == new_board_as, 'not applied properly');
    }
    #[test]
    fn test_generateMoves() {
        let mut _board = 0x3256230010000100001000009199D00009009000BC0ECB000000001;
    }
}
