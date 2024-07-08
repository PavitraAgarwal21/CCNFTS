use core::fmt::Debug;
use core::traits::IndexView;
use core::array::ArrayTrait;
use alexandria_math::{U128BitShift, U256BitShift}; 
use alexandria_data_structures::vec::{Felt252Vec , VecTrait} ;
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

pub fn searchMove(_board : u256 , _depth : u256 ) -> (u256 , bool ) {
    // let mut moves = Felt252Vec::<u256>::new() ;
    let mut vec  : Felt252Vec<u128> = Felt252Vec::<u128>{ items: Default::default(), len:  0 } ; 
    // let
    // let mut balances: Felt252Dict<u128> = Default::default();
    let mut counter : felt252  = 0 ; 
    let mut balances: Felt252Dict<u128> = Default::default();
    balances.insert(counter, 100);
    counter +=1 ; 
    balances.insert(counter, 200);
    counter += 1 ; 
    println!("{}" , counter ) ;
    let alex_balance = balances.get(1);
    println!("{}" , alex_balance) ;
    let maria_balance = balances.get(2);
    assert!(maria_balance == 200, "Balance is not 200");
    // generateMoves(_board) ;
    
    println!("from the engine ") ;
        negMax(_board , _depth) ; 
    return (12,true) ; 
    
    }
    
    pub fn negMax(_board : u256 , _depth : u256 ) -> i128  {
    
    if(_depth == 0 ) {return 0 ; }  
    let mut moves : Felt252Vec<u128> = Felt252Vec::<u128>{ items: Default::default(), len:  0 } ;
    generateMoves(_board) ; 
    if (moves.at(0) == 0 ) {return 0 ; } 
    let mut bestScore : i128 = -4_196 ; 
    let mut currentScore : i128 = 0 ;  
    let mut bestMove : u256 = 0 ; 
    let mut i : u32 = 0 ; 
    while moves.at(i) != 0  { 
        let mut movePartition = moves.at(i) ;  
        while movePartition != 0 {
        } ; 
        // generateMoves(_board) ; 
    
    
     i = i + 1 ; 
    } ; 
        return 0 ;  
    }

pub fn applyMove ( mut _board :  u256 , _move : u256 ) -> u256 {

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

pub fn generateMoves(_board : u256 )  {

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


pub fn isLegalMove(_board : u256  , _move : u256 ) -> bool {

let fromIndex :u256 = U256BitShift::shr(_move, 6) ;
let toIndex : u256 = _move & 0x3F ;
if (U256BitShift::shr(0x7E7E7E7E7E7E00,fromIndex)&1==0) {return false ;}
if (U256BitShift::shr(0x7E7E7E7E7E7E00,toIndex)&1==1) {return false ;}

let mut pieceAtFromIndex : u256 = U256BitShift::shr(_board, U256BitShift::shl(fromIndex,2)) & 0xF ;
if (pieceAtFromIndex == 0) {return false ;}
if (U256BitShift::shr(pieceAtFromIndex,3) != _board & 1) {return false ;} 
pieceAtFromIndex = pieceAtFromIndex & 0x7 ;

let adjustedBoard = U256BitShift::shr(_board, U256BitShift::shl(toIndex,2)) ;
let mut indexChange : u256 = if toIndex < fromIndex { fromIndex - toIndex  } else {  toIndex - fromIndex };
if (pieceAtFromIndex == 1) {
    if(toIndex <= fromIndex) {return false ;}
    indexChange = toIndex - fromIndex ;
    if (indexChange == 7 || indexChange == 9 ) {
        if (!isCapture(_board, adjustedBoard)) {return false ;}
    } else if(indexChange == 8) { 
        if (!isValid(_board , toIndex)) { return false ;}
    } else if (indexChange == 0x10) {
        if (!isValid(_board ,  toIndex -8  ) || !isValid(_board , toIndex )) { return false ;}
    } else {
        return false ; 
    }
} else  if  (pieceAtFromIndex == 4 || pieceAtFromIndex == 6 ) {
    if (  U256BitShift::shr(if pieceAtFromIndex == 4 {0x28440 } else {0x382} , indexChange)&1 == 0  ) {return false ; }
if (!isValid(_board , toIndex )) {return false ; }  
} else {
    let mut rayFound : bool = false ;
    if (pieceAtFromIndex != 2 ) {
        if (pieceAtFromIndex != 2 ) {
            rayFound = searchRay(_board , fromIndex , toIndex , 1 ) || searchRay(_board , fromIndex , toIndex , 8 ) ; 
        } 
    }
        if (pieceAtFromIndex != 3 ) {
            rayFound = rayFound || searchRay(_board , fromIndex  , toIndex , 7 ) 
            || searchRay(_board , fromIndex , toIndex , 9 ) ;
        }
        if (!rayFound ) {return false ; }  
    } 

   // if (Engine.negaMax(_board.applyMove(_move), 1) < -1_260) return false;

return true ;

}



pub fn searchRay (_board : u256 , _fromIndex : u256 , _toIndex : u256 , _directionVector  : u256 ) -> bool { 
    let mut indexChange : u256 = 0 ; 
    let mut rayStart : u256 = 0 ; 
    let mut rayEnd : u256 = 0  ;  
    if (_fromIndex < _toIndex ) {
        indexChange = _toIndex - _fromIndex ; 
        rayStart = _fromIndex + _directionVector; 
        rayEnd = _toIndex ; 
    } else {
        indexChange = _fromIndex - _toIndex ; 
        rayStart = _toIndex ; 
        rayEnd = _fromIndex  - _directionVector;  
    } 
    if (indexChange % _directionVector != 0 ) {return false ;}   

    let mut rayStart = rayStart ; 
    let mut flag : bool = false ;  

    loop {
        if (rayStart >=  rayEnd) {break ;}
if (!isValid(_board , rayStart)) {
    flag = true; 
    break ; 
} 
if (isCapture(_board , U256BitShift::shr(_board , U256BitShift::shl(rayStart , 2)))) {
    flag = true ; 
    break ; 
}
rayStart = rayStart + _directionVector  ; 

    };
    if flag {return false ;} 

return rayStart == rayEnd ; 
}







pub fn isCapture(_board : u256 , _indexAdjustedBoard : u256 ) -> bool {
  /// exp the square you want to caputure is not empty and the piece is not the same as the current player
    return (
       (_indexAdjustedBoard & 0xf != 0) && ( U256BitShift::shr(_indexAdjustedBoard & 0xf, 3) != _board&1 )
    ) ; 
}


pub fn isValid(_toIndex : u256  , _board : u256 ) -> bool { 
    return (
        U256BitShift::shr(0x7E7E7E7E7E7E00 , _toIndex) & 1 == 1 // move must be with in the bounds 
        && (U256BitShift::shr(_board , U256BitShift::shl(_toIndex ,2 ))) == 0 // the to index must be empty
        ||   U256BitShift::shr(U256BitShift::shr(_board , U256BitShift::shl(_toIndex , 2)) & 0xf , 3) != _board &1    ///piece is the opposite contester 
    ) ; 
}
pub fn appendTo(mut _moveArray : MoveArray , _fromMoveIndex : u256 , _toMoveIndex : u256 ) -> bool {

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

pub fn working_with_array () 
{ 


    // let mut vec = Felt252Vec::<u128>::new() ;

    // let mut arr =  ArrayTrait::<u256>::new() ;
    // arr.append(23);
    // arr.append(123);
    // arr.append(1123);
    // arr.append(11123);
    // arr.append(111123);
    // arr.append(1111123);
    // arr.get(2) ;
    //println!("{:?}" , arr.get(2)  );
  
}