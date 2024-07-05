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
    index : u256 , 
    items : u256 , 
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
        if index == 0 {
            break ; 
        }

        let adjustedIndex = index & 0x3F ;  
        let adjustedBoard = U256BitShift::shr(_board , U256BitShift::shl(adjustedIndex,2))  ;
        let piece = adjustedBoard & 0xF ; 
        println!("{}",piece);

    index = U256BitShift::shr(index, 6); 
    
    }

}








fn main()  {
    let vale : u256 = 16 ; 
    let val = U256BitShift::shl(vale, 3); // right shift  division  >>
    let valr =U256BitShift::shr(vale, 3); // left shift  multiply << 
    // println!("{}" , valr );
    // println!("{}" , max_u256);
    //apply move
    // let new_board = applyMove(0x0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF ,0x1A2 ) ; 
    // println!("new12 {}", new_board) ;
    // rotate 
    // let new_board = rotate(0x0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF ) ; 
    // println!("new12 {}", new_board) ;
    generateMoves(0x3256230011111100000000000000000099999900BCDECB000000001) ;
}



#[cfg(test)]
mod tests {
    #[test]
    fn it_works() {
    }
}
