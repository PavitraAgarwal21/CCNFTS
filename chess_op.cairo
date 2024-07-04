use core::integer::u512 ; 

    ///  @dev making the 8 * 8  chess board 


    /// @dev   
    /// every piece in the chess is represented as the 4 bits 
    /// 1 bit for the color 
    /// 3 bits for the piece 
    
    /// 000 -> empty -> 0
    /// 001 -> pawn ->  1
    /// 010 -> bishop -> 2 
    /// 011 -> rook  -> 3 
    /// 100 -> knight -> 4 
    /// 101 -> queen -> 5 
    /// 110 -> king -> 6 

    /// for each color specifically 
    /// white pawn -> 1001 -> 9  diff 8 
    /// black pawn -> 0001 -> 1
    /// white bishop -> 1010 -> a 
    /// black bishop -> 0010 -> 2 
    /// white rook ->  1011 -> b
    /// black rook -> 0011 -> 3 
    /// white knight -> 1100 -> c
    /// black knight -> 0100 -> 4 
    /// white queen -> 1101 -> d
    /// black queen -> 0101 -> 5 
    /// white king -> 1110 -> e
    /// black king -> 0110 -> 6


/// @board 
/// 8 * 8 board
/// 64 cells
/// 1 cell -> 4 bits 
/// 64*4 bits -> 256 bits -> 32 bytes -> 64 hex characters 
/// 64 hex character == chess board state 
/// consider 10*10 board for the 1 row and column each side to provide padding for invlaid move 
/// so then to represent the board we have to represent in 10*10*4 = 400 bits > 256 bits 
/// so we require 512 bits  - 4*128 bits type 
/// padding/invalid cell can be represent in f or 1111


/// @moves 
/// every move is represented as 12 bits 
/// first six bits is from where 
/// second six bits is move to 
/// 6 bits = 2^6 = 64 = 8*8  so every position is represented in 6bits
/// but in the 10*10 board every move can be represented as 2^7 = 128 > 100 but we take u8 and so every move is represented as u16 - 2*u8 one from and anther to 
/// 
 


// fn main () {
//      let board =  u512 {
//         limb0: 0x6871ca8d3c208c16d87cfd47,
//         limb1: 0xb85045b68181585d97816a91,
//         limb2: 0x30644e72e131a029,
//         limb3: 0x0
//     } ; 
//     println!("{}",board);
// }
