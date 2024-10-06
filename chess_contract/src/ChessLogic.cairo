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
#[derive(Drop)]
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
///
///

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


pub fn negMax(_board: u256, _depth: u256) -> i128 {
    if (_depth == 0) {
        return 0;
    }
    // println!(" board {} depth {}", _board, _depth);
    let mut moves = generateMoves(_board);
    // if (moves(0) == 0) {
    //     return 0;
    // }
    // println!("moves {:?}", get(@moves, 0));
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
            // println!("evaluate is corrected ");
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


fn evaluateMove(_board: u256, _move: u256) -> i128 {
    let fromIndex: u256 = 6 * (U256BitShift::shr(_move, 9))
        + ((U256BitShift::shr(_move, 6)) & 7)
        - 7;

    let toIndex: u256 = 6 * ((U256BitShift::shr(_move & 0x3F, 3))) + ((_move & 0x3F) & 7) - 7;

    // println!("nnnnsgdv {}" , U256BitShift::shl(U256BitShift::shr(_move , 6 ),2));
    // println!("wefvcrs {} " , U256BitShift::shr(_board ,(U256BitShift::shl(U256BitShift::shr(_move
    // , 6 ),2)))&7);
    let pieceAtFromIndex: u256 = U256BitShift::shr(
        _board, (U256BitShift::shl(U256BitShift::shr(_move, 6), 2))
    )
        & 7;

    let pieceAtToIndex: u256 = (U256BitShift::shr(_board, (U256BitShift::shl(_move & 0x3F, 2)))
        & 7);

    // println!(
    //     " move - {} fromIndex - {}  toIndex - {} pieceAtFromIndex - {} pieceAtToIndex - {}  ",
    //     _move,
    //     fromIndex,
    //     toIndex,
    //     pieceAtFromIndex,
    //     pieceAtToIndex
    // );

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

pub fn applyMove(mut _board: u256, _move: u256) -> u256 {
    // u256 piece = (_board >> ((_move >> 6) << 2)) & 0xF;
    let piece: u256 = U256BitShift::shr(_board, U256BitShift::shl(U256BitShift::shr(_move, 6), 2))
        & 0xF;
    // to convert the four bit
    //_board &= type(uint256).max ^ (0xF << ((_move >> 6) << 2));
    // println!("befre {}" , _board);
    // _board &= type(uint256).max ^ (0xF << ((_move >> 6) << 2));
    _board = _board
        & (max_u256 ^ (U256BitShift::shl(0xF, U256BitShift::shl(U256BitShift::shr(_move, 6), 2))));
    // println!("{} " , piece) ;
    // _board &= type(uint256).max ^ (0xF << ((_move & 0x3F) << 2));
    _board = _board & (max_u256 ^ (U256BitShift::shl(0xF, U256BitShift::shl(_move & 0x3F, 2))));

    // place the piece at the to index
    // _board |= (piece << ((_move & 0x3F) << 2));

    _board = _board | U256BitShift::shl(piece, U256BitShift::shl(_move & 0x3F, 2));

    return rotate(_board);
}
// 331315573414633347629270044178747969067042435179612056278544678913
// 331315573414633347629270044179246429565577835510633988326921601025

// let now we have to working on the rotate the board
fn rotate(mut _board: u256) -> u256 {
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

pub fn generateMoves(_board: u256) -> ArrayStack { // done and checked 
    let mut movesArray = MoveArray { index: 0, items: newAS(), };
    append(ref movesArray.items, 0);
    append(ref movesArray.items, 0);
    append(ref movesArray.items, 0);
    append(ref movesArray.items, 0);
    append(ref movesArray.items, 0);
    let mut move: u256 = 0;
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

        //    println!("last bit of the board {}",U256BitShift::shr(piece,3));
        //    println!("last {} ", _board& 1);
        // if the piece is empty or the piece is not the same as the current player
        if (piece == 0 || U256BitShift::shr(piece, 3) != _board & 1) {
            index = U256BitShift::shr(index, 6);
            continue;
        }
        /// remove the player bit  0111 &
        piece = piece & 0x7;
        ///// means it is pawn
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
    // if (negMax(applyMove(_board,_move),1) < -1_260) {
    //     return false;
    // }
    return true;
}


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


pub fn isCapture(_board: u256, _indexAdjustedBoard: u256) -> bool {
    /// exp the square you want to caputure is not empty and the piece is not the same as the
    /// current player
    return ((_indexAdjustedBoard & 0xF != 0)
        && (U256BitShift::shr(_indexAdjustedBoard & 0xF, 3) != _board & 1));
}


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

// here append to index is changed to and tested more
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

// 0x3256230011111100000000000000000099999900BCDECB000000001
// 0x3252562023000111111100000000000000000099999900BCDECB000000001
pub fn working_with_array() {
    let mut _board = 0x3256230010000100001000009199D00009009000BC0ECB000000001;
    // if (isLegalMove(_board, 1373 )) {
//     // println!("Legal Move");
//     // println!("before move {}" , _board) ;
//     let mut new_board = applyMove(_board, 1373);
//     //    println!("after move board {}", new_board) ;
//     // println!("new board   {}", new_board);
//     let (bestmove, iswhitecheckmated) = searchMove(new_board, 3);
//     // println!("best move {} iswhitecheckmated {}", bestmove, iswhitecheckmated);
//     new_board = applyMove(new_board, bestmove);
//     // println!("_board  after ai move  {} ", new_board);
// }
// println!("new board {}", _play_move_chess(_board , 1373 , 3));
}

