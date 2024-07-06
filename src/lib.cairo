use core::array::ArrayTrait;
use alexandria_math::{U128BitShift, U256BitShift}; 

// let val = U256BitShift::shl(vale, 3); // right shift  multiply << 128 
// let valr =U256BitShift::shr(vale, 3); // left shift  divison >>  2
#[derive(Drop)] 
struct Move {
    board : u256 , 
    metadata : u256 ,
}
#[derive(Drop)] 
struct MoveArray {
    index : u32 ,
     items :  Array<u256>,  
}
const max_u256 : u256 = 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF; 



fn applyMove ( mut _board :  u256 , _move : u256 ) -> u256 {

    // u256 piece = (_board >> ((_move >> 6) << 2)) & 0xF;
    let piece : u256 =  U256BitShift::shr(_board,U256BitShift::shl(U256BitShift::shr(_move, 6),2)) & 0xF; // to convert the four bit 
    //_board &= type(uint256).max ^ (0xF << ((_move >> 6) << 2));
    // println!("befre {}" , _board); 
    _board = _board & max_u256^(U256BitShift::shl(0xF,U256BitShift::shl(U256BitShift::shr(_move, 6),2))) ; 
    // println!("after {}" , _board); 
    // println!("{} " , piece) ;
    // _board &= type(uint256).max ^ (0xF << ((_move & 0x3F) << 2));
    _board = _board & max_u256^(U256BitShift::shl(0xF,U256BitShift::shl(_move&0x3F ,2))) ; 
    // println!("afte2 {}" , _board); 

    // place the piece at the to index 
    // _board |= (piece << ((_move & 0x3F) << 2));

    _board = _board |  U256BitShift::shl(piece , U256BitShift::shl(_move & 0x3F,2)) ; 
    // println!("afte3 {}" , _board) ;
    return _board  ; 
//123456789ABCDEF0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF
//123456789ABCDEF0123456789ABCDEF0123456789ABCDEF0123456786ABCDEF
//123456789ABCDEF0123456789ABC2EF0123456789ABCDEF0123456786ABCDEF
//123456789ABCDEF0123456789ABCBEF0123456789ABCDEF0123456786ABCDEF
}


// let now we have to working on the rotate the board 
fn rotate(mut _board : u256 ) -> u256 {
let mut rotatedBoard : u256 =0 ;   
let mut i : u256 = 0 ;
loop {
    if i >= 64 {
        break ;
    }
    rotatedBoard = (U256BitShift::shl(rotatedBoard,4)) | (_board & 0xF) ;
    _board = U256BitShift::shr(_board , 4) ; 
    i = i + 1 ;
} ; 
rotatedBoard 
}

fn generateMoves(_board : u256 )  {

    let mut move : u256  = 0 ; 
    let mut moveTo : u256 = 0 ; 
    let mut index : u256 = 0xDB5D33CB1BADB2BAA99A59238A179D71B69959551349138D30B289 ;
    loop {
        if index == 0 {break ;}
        let mut adjustedIndex = index & 0x3F ;  
        let mut adjustedBoard = U256BitShift::shr(_board , U256BitShift::shl(adjustedIndex,2))  ;
        let mut piece = adjustedBoard & 0xF ; 
    // println!("piece {}" , piece);
    //    println!("last bit of the board {}",U256BitShift::shr(piece,3));
    //    println!("last {} ", _board& 1);
        // if the piece is empty or the piece is not the same as the current player
        if (piece == 0 ||   U256BitShift::shr(piece,3) != _board & 1)   {
            index = U256BitShift::shr(index, 6); 
            continue;
        }  
        /// remove the player bit  0111 & 
         piece = piece & 0x7 ; 
         ///// means it is pawn 
        if (piece == 1) { 
            /// if the front row is empty or not 
            if (U256BitShift::shr(adjustedBoard,0x20)&0xF == 0 ) {
                // println!("adjusted board {}" , U256BitShift::shr(adjustedBoard , 0x20)&0xf );
                // println!("pawn front empty {}" , piece)  ;
                // println!("pawn from{}",adjustedIndex  ) ;
                // println!("pawn to {}",adjustedIndex + 8 ) ; 
                /// move the pawn to the 2 row head 
                /// means it is in his 2 row starting point and can move 2 steps and that place is empty 
                if ( (U256BitShift::shr(adjustedIndex , 3) == 2) && (U256BitShift::shr(adjustedBoard,0x40)&0xF == 0) ) {
                    // println!("pawn from{}",adjustedIndex  ) ;
                    // println!("pawn to {}",adjustedIndex + 0x10 ) ; 
                }  
            }
            /// capture the piece to the left diagonal of it  
                if (isCapture(_board , U256BitShift::shr(adjustedBoard,0x1C))) {
                ///append to the moves 
                println!("pawn from{}",adjustedIndex  ) ;
                println!("pawn to {}",adjustedIndex + 7  ) ;
            }
            //// capture the piece to the right diagonal of it 
            if (isCapture(_board , U256BitShift::shr(adjustedBoard,0x24))) {
                ///append to the moves 
                println!("pawn from{}",adjustedIndex  ) ;
                println!("pawn to {}",adjustedIndex + 9  ) ;
            }

        } 

        /// if piece is knight(horse) or king 
        else if (piece&0x7 == 4 || piece&0x7 == 6) {
            let mut piece = adjustedBoard & 0xF ;  
            println!("piece {}" , piece) ;
            println!("adjusted board {}" , adjustedIndex ) ;

        }




        index = U256BitShift::shr(index, 6); 
    }

}









fn isCapture(_board : u256 , _indexAdjustedBoard : u256 ) -> bool {
  /// exp the square you want to caputure is not empty and the piece is not the same as the current player
    return (
       (_indexAdjustedBoard & 0xf != 0) && ( U256BitShift::shr(_indexAdjustedBoard & 0xf, 3) != _board&1 )
    ) ; 
}


fn isValid(_toIndex : u256  , _board : u256 ) -> bool { 
    return (
        U256BitShift::shr(0x7E7E7E7E7E7E00 , _toIndex) & 1 == 1 // move must be with in the bounds 
        && (U256BitShift::shr(_board , U256BitShift::shl(_toIndex ,2 ))) == 0 // the to index must be empty
        ||   U256BitShift::shr(U256BitShift::shr(_board , U256BitShift::shl(_toIndex , 2)) & 0xf , 3) != _board &1    ///piece is the opposite contester 
    ) ; 
}
fn appendTo(mut _moveArray : MoveArray , _fromMoveIndex : u256 , _toMoveIndex : u256 ) -> bool {

    let mut currentIndex   = _moveArray.index ; 
    let currentPartition : u256  = *_moveArray.items.at(currentIndex); 
    let val : u256 = U256BitShift::shl(1,0xF6)  ; 
    if (currentPartition > val ) {
        let val  : u256 = U256BitShift::shr(_fromMoveIndex , 6) | _toMoveIndex ; 
        
        
        // _moveArray.*items.at(++_moveArray.index) = currentIndex + 1 ;

    } else {

    }

    return true ;
}
#[derive(Drop)]
struct mmm { 
    a : u256 , 
    b : Array<u256>, 
} 
fn working_with_array () 
{ 
    let mut mm = mmm {
        a : 12 , 
        b : ArrayTrait::<u256>::new() , 
    };
    mm.b.append(12);
    println!("{:?}" , mm.b);
}



fn main()  {
    let vale : u256 = 16 ; 
    let val = U256BitShift::shl(vale, 3); // right shift  division  >>
    let valr =U256BitShift::shr(vale, 3); // left shift  multiply << 
    /// working with the array 
    working_with_array() ;
    // println!("{}" , valr );
    // println!("{}" , max_u256);
    //apply move
    // let new_board = applyMove(0x0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF ,0x1A2 ) ; 
    // println!("new12 {}", new_board) ;
    // rotate 
    // let new_board = rotate(0x0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF ) ; 
    // println!("new12 {}", new_board) ;
    // generateMoves(0x3256230011111100000000000000000099999900BCDECB000000001) ;
}



#[cfg(test)]
mod tests {
    #[test]
    fn it_works() {
    }
}
