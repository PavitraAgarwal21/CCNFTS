// mod NFTContract ;
pub mod ChessLogic;
// pub mod ERC721Contract;
// pub mod BoardNFT ;
// pub mod  BoardNFT ;
mod erc20;
// pub mod NFTContract ;
mod CCNFTS;


use ChessLogic::{rotate, applyMove};

fn main() {
    println!("Hello, world!");
    let mut _board = 0x3256230010000100001000009199D00009009000BC0ECB000000001;
    let new_board = applyMove(_board, 1373);
    println!("new board : {}", new_board);
}
