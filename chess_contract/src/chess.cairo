use alexandria_math::{U128BitShift, U256BitShift};
#[starknet::interface]
pub trait IGetChess<TContractState> {
    fn applyMove(self: @TContractState, _board: u256, _move: u256) -> u256;
}

#[starknet::contract]
mod Chess {
    use super::IGetChess;
    use alexandria_math::{U128BitShift, U256BitShift};

    #[storage]
    struct Storage {
        val: u32,
    }

    #[derive(Drop, Serde, starknet::Store)]
    pub struct Move {
        board: u256,
        metadata: u256,
    }
    #[derive(Drop, Serde, starknet::Store)]
    pub struct MoveArray {
        index: u256,
        items: u256, // taking the five items 
    }


    #[abi(embed_v0)]
    impl Chess of IGetChess<ContractState> {
        fn applyMove(self: @ContractState, _board: u256, _move: u256) -> u256 {
            let piece: u256 = _board;
            let x = U256BitShift::shl(_move, 6);
            println!("{}", x);
            return piece;
        }
    }
}

