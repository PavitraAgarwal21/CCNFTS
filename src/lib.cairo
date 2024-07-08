pub mod chess_test ; 
use chess_test::{generateMoves , searchMove , negMax};



fn main()  {
    // let vale : u256 = 16 ; 
    // let val = U256BitShift::shl(vale, 3); // right shift  division  >>
    // let valr =U256BitShift::shr(vale, 3); // left shift  multiply << 
    /// working with the array 

    // let mut vec = Felt252Vec::<u128>::new(); 
//  working_with_array() ;
    // println!("{}" , valr );
    // println!("{}" , max_u256);
    //apply move
    // let new_board = applyMove(0x0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF ,0x1A2 ) ; 
    // println!("new12 {}", new_board) ;
    // rotate 
    // let new_board = rotate(0x0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF ) ; 
    // println!("new12 {}", new_board) ;
    // Chprinting() ; 
    // negMax(0x3256230011111100000000000000000099999900BCDECB000000001 , 1 ); 
    // searchMove(0x3256230011111100000000000000000099999900BCDECB000000001, 0x1A2) ; 
    generateMoves(0x3256230011111100000000000000000099999900BCDECB000000001);
    //  let vec = Felt252Vec::<u128>::new() ; 
}



#[cfg(test)]
mod tests {
    #[test]
    fn it_works() {
    }
}
