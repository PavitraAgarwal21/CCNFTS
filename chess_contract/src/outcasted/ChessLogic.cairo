#[starknet::contract]
mod ChessLogic {
    use core::option::OptionTrait;
    use alexandria_data_structures::array_ext::ArrayTraitExt;
    use core::array::ArrayTrait;
    use alexandria_math::{U128BitShift, U256BitShift};
    use alexandria_data_structures::vec::{Felt252Vec, VecTrait};
    use core::traits::TryInto;

    const max_u256: u256 = 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;


    #[storage]
    struct Storage {
        board: u256,
    }

    #[constructor]
    fn constructor(ref self: ContractState) {
        self.board.write(0x3256230011111100000000000000000099999900BCDECB000000001);
    }


    // define the custom vector for myself 

    #[derive(Drop, Serde, starknet::store)]
    pub struct ArrayStack {
        main_stack: Array<u256>,
        aux_stack: Array<u256>,
        size: usize,
    }
    #[derive(Drop, Serde)]
    pub struct Move {
        board: u256,
        metadata: u256,
    }
    #[derive(Drop, Serde)]
    struct MoveArray {
        index: u32,
        items: ArrayStack,
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

    fn isLegalMove(_board: u256, _move: u256) -> bool {
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

    fn searchRay(_board: u256, _fromIndex: u256, _toIndex: u256, _directionVector: u256) -> bool {
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
            if (isValid(_board, rayStart)) {
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


    fn isCapture(_board: u256, _indexAdjustedBoard: u256) -> bool {
        /// exp the square you want to caputure is not empty and the piece is not the same as the current player
        return ((_indexAdjustedBoard & 0xF != 0)
            && (U256BitShift::shr(_indexAdjustedBoard & 0xF, 3) != _board & 1));
    }


    fn isValid(_board: u256, _toIndex: u256) -> bool {
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


    ///////// logic of the game ok 
    #[external(v0)]
    #[generate_trait]
    impl IChessLogicImp of IChessLogicTrait {
        fn applyMove(self: @ContractState, mut _board: u256, _move: u256) -> u256 {
            // u256 piece = (_board >> ((_move >> 6) << 2)) & 0xF;
            let piece: u256 = U256BitShift::shr(
                _board, U256BitShift::shl(U256BitShift::shr(_move, 6), 2)
            )
                & 0xF;
            _board = _board
                & (max_u256
                    ^ (U256BitShift::shl(0xF, U256BitShift::shl(U256BitShift::shr(_move, 6), 2))));
            _board = _board
                & (max_u256 ^ (U256BitShift::shl(0xF, U256BitShift::shl(_move & 0x3F, 2))));
            _board = _board | U256BitShift::shl(piece, U256BitShift::shl(_move & 0x3F, 2));

            return self.rotate(_board);
        }

        fn rotate(self: @ContractState, mut _board: u256) -> u256 {
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


        fn searchMove(self: @ContractState, _board: u256, _depth: u256) -> (u256, bool) {
            let mut moves = self.generateMoves(_board);
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
                    currentScore = self.evaluateMove(_board, movePartition & 0xFFF)
                        + self.negMax(self.applyMove(_board, movePartition & 0xFFF), _depth - 1);

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


        fn negMax(self: @ContractState, _board: u256, _depth: u256) -> i128 {
            if (_depth == 0) {
                return 0;
            }
            // println!(" board {} depth {}", _board, _depth);
            let mut moves = self.generateMoves(_board);
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
                    currentScore = self.evaluateMove(_board, movePartition & 0xFFF);
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
                return bestScore + self.negMax(self.applyMove(_board, bestMove), _depth - 1);
            } else {
                return -bestScore + self.negMax(self.applyMove(_board, bestMove), _depth - 1);
            }
        }


        fn evaluateMove(self: @ContractState, _board: u256, _move: u256) -> i128 {
            let fromIndex: u256 = 6 * (U256BitShift::shr(_move, 9))
                + ((U256BitShift::shr(_move, 6)) & 7)
                - 7;

            let toIndex: u256 = 6 * ((U256BitShift::shr(_move & 0x3F, 3)))
                + ((_move & 0x3F) & 7)
                - 7;

            // println!("nnnnsgdv {}" , U256BitShift::shl(U256BitShift::shr(_move , 6 ),2));
            // println!("wefvcrs {} " , U256BitShift::shr(_board ,(U256BitShift::shl(U256BitShift::shr(_move , 6 ),2)))&7);
            let pieceAtFromIndex: u256 = U256BitShift::shr(
                _board, (U256BitShift::shl(U256BitShift::shr(_move, 6), 2))
            )
                & 7;

            let pieceAtToIndex: u256 = (U256BitShift::shr(
                _board, (U256BitShift::shl(_move & 0x3F, 2))
            )
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
                            self.getPst(pieceAtToIndex),
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
                            self.getPst(pieceAtToIndex),
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
                            self.getPstTwo(pieceAtToIndex),
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
                        self.getPst(pieceAtFromIndex),
                        if ((7 * (0x23 - fromIndex)) < 255) {
                            (7 * (0x23 - fromIndex))
                        } else {
                            255
                        }
                    )
                    & 0x7F;
                newPst =
                    U256BitShift::shr(
                        self.getPst(pieceAtFromIndex),
                        if ((7 * toIndex) < 255) {
                            (7 * toIndex)
                        } else {
                            255
                        }
                    )
                    & 0x7F;
            } else if (fromIndex < 0x12) {
                oldPst =
                    U256BitShift::shr(
                        self.getPstTwo(pieceAtFromIndex),
                        (if ((0xC * fromIndex) < 255) {
                            (0xC * fromIndex)
                        } else {
                            255
                        })
                    )
                    & 0xFFF;
                newPst =
                    U256BitShift::shr(
                        self.getPstTwo(pieceAtFromIndex),
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
                            self.getPst(pieceAtFromIndex),
                            (if ((0xC * (fromIndex - 0x12)) < 255) {
                                0xC * (fromIndex - 0x12)
                            } else {
                                255
                            })
                        )
                        & 0xFFF;
                    newPst =
                        U256BitShift::shr(
                            self.getPst(pieceAtFromIndex),
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

        fn getPst(self: @ContractState, _type: u256) -> u256 {
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

        fn getPstTwo(self: @ContractState, _type: u256) -> u256 {
            if (_type == 5) {
                return 0xB30B50B50B50B40B30B20B40B50B40B40B20B00B20B30B30B20B0;
            } else {
                return 0xF9EF9CF9CF9CF9CF9EFA1FA1FA0FA0FA1FA1FA4FA6FA2FA2FA6FA4;
            }
        }
        fn generateMoves(self: @ContractState, _board: u256) -> ArrayStack { // done and checked 
            let mut movesArray = MoveArray { index: 0, items: newAS(), };
            append(ref movesArray.items, 0);
            append(ref movesArray.items, 0);
            append(ref movesArray.items, 0);
            append(ref movesArray.items, 0);
            append(ref movesArray.items, 0);
            let mut move: u256 = 0;
            let mut moveTo: u256 = 0;
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
                        self.appendTo(ref movesArray, adjustedIndex, adjustedIndex + 8);

                        /// move the pawn to the 2 row head 
                        /// means it is in his 2 row starting point and can move 2 steps and that place is empty 
                        if ((U256BitShift::shr(adjustedIndex, 3) == 2)
                            && (U256BitShift::shr(adjustedBoard, 0x40) & 0xF == 0)) {
                            self.appendTo(ref movesArray, adjustedIndex, adjustedIndex + 0x10);
                        }
                    }
                    /// capture the piece to the left diagonal of it  
                    if (isCapture(_board, U256BitShift::shr(adjustedBoard, 0x1C))) {
                        ///append to the moves 
                        self.appendTo(ref movesArray, adjustedIndex, adjustedIndex + 7);
                    }
                    //// capture the piece to the right diagonal of it 
                    if (isCapture(_board, U256BitShift::shr(adjustedBoard, 0x24))) {
                        ///append to the moves 
                        self.appendTo(ref movesArray, adjustedIndex, adjustedIndex + 9);
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
                            self
                                .appendTo(
                                    ref movesArray, adjustedIndex, adjustedIndex + (move & 0xFF)
                                );
                        }
                        if (move <= adjustedIndex
                            && isValid(_board, adjustedIndex - (move & 0xFF))) {
                            self
                                .appendTo(
                                    ref movesArray, adjustedIndex, adjustedIndex - (move & 0xFF)
                                );
                        }
                        move = U256BitShift::shr(move, 8);
                    }
                } else {
                    if (piece != 2) {
                        move = adjustedIndex + 1; // 10 
                        while isValid(_board, move) {
                            self.appendTo(ref movesArray, adjustedIndex, move);
                            if (isCapture(
                                _board, U256BitShift::shr(_board, U256BitShift::shl(move, 2))
                            )) {
                                break;
                            }
                            move = move + 1;
                        };
                        move = adjustedIndex - 1; // move - 8 
                        while isValid(_board, move) {
                            self.appendTo(ref movesArray, adjustedIndex, move);

                            if (isCapture(
                                _board, U256BitShift::shr(_board, U256BitShift::shl(move, 2))
                            )) {
                                break;
                            }

                            move = move - 1;
                        };

                        move = adjustedIndex + 8;
                        while isValid(_board, move) {
                            self.appendTo(ref movesArray, adjustedIndex, move);
                            if (isCapture(
                                _board, U256BitShift::shr(_board, U256BitShift::shl(move, 2))
                            )) {
                                break;
                            }
                            move = move + 8;
                        };
                        move = adjustedIndex - 8;
                        while isValid(_board, move) {
                            self.appendTo(ref movesArray, adjustedIndex, move);
                            if (isCapture(
                                _board, U256BitShift::shr(_board, U256BitShift::shl(move, 2))
                            )) {
                                break;
                            }
                            move = move - 8;
                        };
                    }
                    if (piece != 3) {
                        move = adjustedIndex + 7;
                        while isValid(_board, move) {
                            self.appendTo(ref movesArray, adjustedIndex, move);
                            if (isCapture(
                                _board, U256BitShift::shr(_board, U256BitShift::shl(move, 2))
                            )) {
                                break;
                            }
                            move = move + 7;
                        };
                        move = adjustedIndex - 7;
                        while isValid(_board, move) {
                            self.appendTo(ref movesArray, adjustedIndex, move);
                            if (isCapture(
                                _board, U256BitShift::shr(_board, U256BitShift::shl(move, 2))
                            )) {
                                break;
                            }
                            move = move - 7;
                        };
                        move = adjustedIndex + 9;
                        while isValid(_board, move) {
                            self.appendTo(ref movesArray, adjustedIndex, move);
                            if (isCapture(
                                _board, U256BitShift::shr(_board, U256BitShift::shl(move, 2))
                            )) {
                                break;
                            }
                            move = move + 9;
                        };

                        move = adjustedIndex - 9;
                        while isValid(_board, move) {
                            if (move == 0) {
                                break;
                            }
                            self.appendTo(ref movesArray, adjustedIndex, move);
                            if (isCapture(
                                _board, U256BitShift::shr(_board, U256BitShift::shl(move, 2))
                            )) {
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


        // here append to index is changed to and tested more  
        fn appendTo(
            self: @ContractState,
            ref _moveArray: MoveArray,
            _fromMoveIndex: u256,
            _toMoveIndex: u256
        ) -> bool {
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


        fn _play_move_chess(
            ref self: ContractState, _board: u256, _move: u256, _depth: u256, ai: bool
        ) {
            // first we have to check the move is leagal or not 
            isLegalMove(_board, _move);
            // then we have to apply the move  
            let mut board = self.applyMove(_board, _move);

            if ai {
                let (bestMove, isWhiteCheckmated) = self.searchMove(board, _depth);
                /// if he does not  
                if (bestMove == 0) {
                    /// reset the board 
                    /// means player has won  
                    ///  you won minted some large no of token to it ok 
                    /// minted winner nft to him 

                    board = 0;
                } else {
                    // ai move  
                    board = self.applyMove(board, bestMove);

                    if (isWhiteCheckmated) {
                        // player have lost 
                        /// block him so that he cannot able to play the game 
                        board = 0;
                    }
                }
            }
            ///// we have to take care of the ai move 

            self.board.write(board);
        }
    }
}
