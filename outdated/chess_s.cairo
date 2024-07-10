// use starknet::ContractAddress;
// use core::poseidon::PoseidonTrait;

// #[starknet::contract]
// mod chess_s  {
//     use starknet::{
//         ContractAddress, get_caller_address, get_contract_address,
//         storage_access::StorageBaseAddress
//     };
//     use core::poseidon::PoseidonTrait;
//     use core::hash::{HashStateTrait, HashStateExTrait};

//     #[storage]
//     struct Storage {
//        pub ctx : Context , 
//        lastPieceInd : PieceID ,
//        Pieces : LegacyMap::< PieceID, GamePiece> ,

//     }

//     #[derive(Drop, Serde, starknet::Store)]
//    pub struct GamePiece {
//         pid : PieceID ,
//         ptype : PieceType,
//         r : u8 , 
//         c : u8 ,
//         alive : bool ,
//         moves : u256 , 
//     }

//     #[derive(Drop, Serde, starknet::Store)]
// pub struct Player {
//     player_address : ContractAddress ,
//     state : PlayerState ,
//     bet : u256 ,
// }

// #[derive(Drop,Serde,starknet::Store)]
// pub struct Context {
//     PlayerOne : ContractAddress ,
//     PlayerTwo : ContractAddress ,
//     fee : u256 , 
//     playerturn : u8 ,

// }

//     #[derive(Drop,Serde,starknet::Store)] 
//     enum PieceType{
//         king, rook, bishop, queen, knight, pawn
//     }
//     #[derive(Drop,Serde,Copy,starknet::Store)]
//     enum PieceID {
//         p1_king, p1_queen, p1_rookl, p1_rookr, p1_bishopl, p1_bishopr, p1_knightl, p1_knightr, p1_pawn1, p1_pawn2, p1_pawn3, p1_pawn4, p1_pawn5, p1_pawn6, p1_pawn7, p1_pawn8,
//         p2_king, p2_queen, p2_rookl, p2_rookr, p2_bishopl, p2_bishopr, p2_knightl, p2_knightr, p2_pawn1, p2_pawn2, p2_pawn3, p2_pawn4, p2_pawn5, p2_pawn6, p2_pawn7, p2_pawn8,
//         Nil
//     }
//     #[derive(Drop, Serde, starknet::Store)]
//     enum SpecCommand {
//         Null, Withdraw, Pass, Castle, PromoteToQueen, PromoteToRook, PromoteToBishop, PromoteToKnight
//     }
//     #[derive(Drop, Serde, starknet::Store)]
//     enum PlayerState {
//         Normal,
//         Withdraw,
//         Pass
//     }

// }


