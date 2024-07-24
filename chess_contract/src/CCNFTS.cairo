
use starknet::ContractAddress; 
use starknet::ClassHash;
use starknet::account::Call;
#[starknet::interface]
pub trait IBoardNFT<TContractState> {
    fn getname(self: @TContractState) -> felt252;
    fn getsymbol(self: @TContractState) -> felt252;
    fn hardness_Depth(self: @TContractState, token_id: u256) -> u256;
    fn board_minted_state(self: @TContractState, token_id: u256) -> u256;

    fn board_current_state(self: @TContractState, token_id: u256) -> u256;
    fn update_board_current_state(ref self: TContractState, token_id: u256, new_state_board: u256);
    fn get_minted_token_amount( self : @TContractState , token_id : u256 ) -> u256 ; 
    fn get_token_Id(self: @TContractState, caller: ContractAddress) -> u256 ; 
    fn _play_move_chess(ref self : TContractState ,  _board: u256, _move: u256, _depth: u256 , tokenId : u256  ) -> (u256 , u256) ; 
        fn playmove(ref self: TContractState, _move: u256  )  ; 
    fn getUpdatedBoardStatepublic(self: @TContractState,  tokenboundaccount : ContractAddress ) -> u256 ; 
    fn checkWinngstatus(self: @TContractState, token_id: u256) -> u8 ; 
    fn makePuzzle(ref self: TContractState, _board: u256, _depth: u256 , _amount : u256) ; 
}


#[starknet::interface]
pub trait IERC20<TContractState> {
    fn get_name(self: @TContractState) -> felt252;
    fn get_symbol(self: @TContractState) -> felt252;
    fn get_decimals(self: @TContractState) -> u8;
    fn get_total_supply(self: @TContractState) -> felt252;
    fn balance_of(self: @TContractState, account: ContractAddress) -> felt252;
    fn allowance(
        self: @TContractState, owner: ContractAddress, spender: ContractAddress
    ) -> felt252;
    fn transfer(ref self: TContractState, recipient: ContractAddress, amount: felt252);
    fn transfer_from(
        ref self: TContractState,
        sender: ContractAddress,
        recipient: ContractAddress,
        amount: felt252
    );
    fn approve(ref self: TContractState, spender: ContractAddress, amount: felt252);
    fn increase_allowance(ref self: TContractState, spender: ContractAddress, added_value: felt252);
    fn decrease_allowance(
        ref self: TContractState, spender: ContractAddress, subtracted_value: felt252
    ); 
    
}


#[starknet::interface]
trait IAccount<TContractState> {
    fn is_valid_signature(
        self: @TContractState, hash: felt252, signature: Span<felt252>
    ) -> felt252;
    fn is_valid_signer(self: @TContractState, signer: ContractAddress) -> felt252;
    fn __validate__(ref self: TContractState, calls: Array<Call>) -> felt252;
    fn __validate_declare__(self: @TContractState, class_hash: felt252) -> felt252;
    fn __validate_deploy__(
        self: @TContractState, class_hash: felt252, contract_address_salt: felt252
    ) -> felt252;
    fn __execute__(ref self: TContractState, calls: Array<Call>) -> Array<Span<felt252>>;
    fn token(self: @TContractState) -> (ContractAddress, u256);
    fn owner(self: @TContractState) -> ContractAddress;
    fn lock(ref self: TContractState, duration: u64);
    fn is_locked(self: @TContractState) -> (bool, u64);
    fn supports_interface(self: @TContractState, interface_id: felt252) -> bool;
}

// #[starknet::interface]
// pub trait IERC721<TContractState> {
//     fn name(self: @TContractState) -> felt252;
//     fn symbol(self: @TContractState) -> felt252;
//     fn token_uri(self: @TContractState, token_id: u256) -> felt252;
//     fn balance_of(self: @TContractState, account: ContractAddress) -> u256;
//     fn owner_of(self: @TContractState, token_id: u256) -> ContractAddress;
//     fn get_approved(self: @TContractState, token_id: u256) -> ContractAddress;
//     fn is_approved_for_all(
//         self: @TContractState, owner: ContractAddress, operator: ContractAddress
//     ) -> bool;
//     fn approve(ref self: TContractState, to: ContractAddress, token_id: u256);
//     fn set_approval_for_all(ref self: TContractState, operator: ContractAddress, approved: bool);
//     fn transfer_from(
//         ref self: TContractState, from: ContractAddress, to: ContractAddress, token_id: u256
//     );

// ////////
//     fn mint(ref self: TContractState, to: ContractAddress, token_id: u256);
//     fn mintboard (ref self: TContractState, to: ContractAddress, _board : u256 , _depth : u256  ) ; 
//         fn get_encode_tokenId( self : @TContractState , board_id : u256 , move_id : u256) -> u256 ;
//     fn  mintmove (ref self: TContractState, to: ContractAddress, board_id : u256 , _board : u256 , encoded_move : u256  ) ; 


// }


/// only avlailable for the  
/// 


#[starknet::contract]
mod CCNFTS {
    ////////////////////////////////
    // library imports
    ////////////////////////////////
    ///  use starknet::ContractAddress;
    use starknet::get_contract_address;
    use core::array::ArrayTrait;
    use core::nullable::match_nullable;
    use core::zeroable::Zeroable;
    use core::traits::Into;
    use starknet::{ContractAddress, get_caller_address};
    use super::IAccountDispatcher;
    use super::IAccountDispatcherTrait;
    use ccnfts::chess_test::{searchMove, isLegalMove, applyMove, Move , encodeTokenId , calculate_move_enoded };
    use super::IBoardNFT;
    use super::{IERC20Dispatcher, IERC20DispatcherTrait}; 
    const NAME: felt252 = 0x546573744e4654;
    const SYMBOL: felt252 = 0x544e4654;

    const BASE_URI_PART_1: felt252 = 0x697066733a2f2f516d505a6e336f5967486f676343643835;
    const BASE_URI_PART_2: felt252 = 0x697251685033794d61446139387878683654653550426e53;
    const BASE_URI_PART_3: felt252 = 0x61626859722f;
    const ADMIN_ADDRESS: felt252 =
    0x004835541Fd87cdDBc3B48Ad08e53FfA1E4D55aB21a46900A969DF326C9276326;
    const VERSION_CODE: u256 = 202311150001001; /// YYYYMMDD000NONCE

    const MAX_SUPPLY: u256 = 10000;
    const INTERFACE_ERC165: felt252 = 0x01ffc9a7;
    const INTERFACE_ERC721: felt252 = 0x80ac58cd;
    const INTERFACE_ERC721_METADATA: felt252 = 0x5b5e139f;
    const INTERFACE_ERC721_RECEIVER: felt252 = 0x150b7a02;
    ////////////////////////////////
    // storage variables
    ////////////////////////////////
    #[storage]
    struct Storage {
        name: felt252,
        symbol: felt252,
        owners: LegacyMap::<u256, ContractAddress>,
        balances: LegacyMap::<ContractAddress, u256>,
        count: u256, //Total number of NFTs minted
        token_approvals: LegacyMap::<u256, ContractAddress>,
        operator_approvals: LegacyMap::<(ContractAddress, ContractAddress), bool>,
        ai_hard: LegacyMap::<u256, u256>,
        board_mintedstate: LegacyMap::<u256, u256>,
        //this may or may not be usefull but now keep it there 
        board_currentstate: LegacyMap::<u256, u256>,
        MintedAddress: ContractAddress,
        board_amt : LegacyMap::<u256, u256> , 
        status : LegacyMap::<u256, u8> , //  loss 1 - win 2 - match is going on -0 
        //// which tokenId is the puzzle 
        puzzle_allowed_to_play : LegacyMap::<u256, bool > , // tokenid => true // allowed to play 
        board_to_moves : LegacyMap::<u256, u256> ,
        tokenid_to_uriData : LegacyMap::<u256, (u256, u256 )> ,
        erc20_token: ContractAddress,  
        board_puzzle_supply : u256 , 

    }

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        PlayMoveEvent : PlayMoveEvent ,
        Approval: Approval,
        Transfer: Transfer,
        ApprovalForAll: ApprovalForAll
    }



    #[derive(Drop, starknet::Event)]
    struct PlayMoveEvent {
        caller: ContractAddress,
        currentBoardState : u256 ,
        newBoardState : u256 , 
        token_id_move: u256,
        token_id_board: u256,
    }

    ////////////////////////////////
    // Approval event emitted on token approval
    ////////////////////////////////
    #[derive(Drop, starknet::Event)]
    struct Approval {
        owner: ContractAddress,
        to: ContractAddress,
        token_id: u256
    }

    ////////////////////////////////
    // Transfer event emitted on token transfer
    ////////////////////////////////
    #[derive(Drop, starknet::Event)]
    struct Transfer {
        from: ContractAddress,
        to: ContractAddress,
        token_id: u256
    }

    ////////////////////////////////
    // ApprovalForAll event emitted on approval for operators
    ////////////////////////////////
    #[derive(Drop, starknet::Event)]
    struct ApprovalForAll {
        owner: ContractAddress,
        operator: ContractAddress,
        approved: bool
    }


    ////////////////////////////////
    // Constructor - initialized on deployment
    ////////////////////////////////
    
    #[constructor]
    fn constructor(ref self: ContractState, _minted_Address : ContractAddress  , erc20_token : ContractAddress ) {
        self.MintedAddress.write(_minted_Address);
        self.erc20_token.write(erc20_token);
    }

    #[generate_trait]
    impl ConfigImpl of ConfigTrait {
        fn initConfig(
            ref self: ContractState
        ) { //Configure the contract based on parameters when deploying the contract if needed
            // i think this is the best place to mint the 10 nft as soon as it has been contract ; 
            // so mint the board nft 
            // self.makePuzzle( 0x3256230011111100000000000000000099999900BCDECB000000001 , 3 , 3000);
            // self.makePuzzle( 0x3256230011111100000000000000000099999900BCDECB000000001 , 4 , 4000);
            // self.makePuzzle( 0x3256230011111100000000000000000099999900BCDECB000000001 , 4 , 4000);
            // self.makePuzzle(0x3256230010000100001000009199D00009009000BC0ECB000000001, 4 , 4000);
            // self.makePuzzle(0x3256230010000100001000009199D00009009000BC0ECB000000001, 5 , 5000);
            // self.makePuzzle(0x3256230010000100001000009199D00009009000BC0ECB000000001, 4 , 4000);
            // self.makePuzzle(0x3256230010100100000000009199100009009000BCDECB000000001, 5 , 5000);
            // self.makePuzzle(0x3256230010000100001000009199D00009009000BC0ECB000000001, 6 , 6000);
            // self.makePuzzle(0x32502300100061000010000091990000090D9000BC0ECB000000001, 7 , 7000);
            // self.makePuzzle(0x325023001006010000100D009199000009009000BC0ECB000000001, 6,   6000);
            // self.makePuzzle(0x305023001006010000100D0091992000090C9000B00ECB000000001, 8  , 8000  );
            // self.makePuzzle(0x3256230011111100000000000000000099999900BCDECB000000001, 9 , 9000);
        }
    }


    #[abi(embed_v0)]

    impl IBNFT of IBoardNFT<ContractState> {

        fn getname(self: @ContractState) -> felt252 {
            'CCNFTS'
        }

        // get_symbol function returns NFT's token symbol
        fn getsymbol(self: @ContractState) -> felt252 {
            'CCNFTS'
        }
        fn hardness_Depth(self: @ContractState, token_id: u256) -> u256 {
            self.ai_hard.read(token_id)
        }
        fn board_minted_state(self: @ContractState, token_id: u256) -> u256 {
            self.board_mintedstate.read(token_id)
        }
        fn board_current_state(self: @ContractState, token_id: u256) -> u256 {
            self.board_currentstate.read(token_id)
        }
        fn update_board_current_state(
            ref self: ContractState, token_id: u256, new_state_board: u256
        ) {
            self.board_currentstate.write(token_id, new_state_board);
        }
        fn get_minted_token_amount( self : @ContractState , token_id : u256 ) -> u256 {
            self.board_amt.read(token_id)

        }

        /// token bound account address so then we get the token id 
        fn get_token_Id(self: @ContractState, caller: ContractAddress) -> u256 {
            let account = IAccountDispatcher { contract_address: caller };
            let (_token_contract, token_id) = account.token();
            token_id
        }

        // iwant to make this happen that will be happen so lets do it ok 
        // no other so 

        //called by the system 
    fn _play_move_chess(ref self : ContractState ,  _board: u256, _move: u256, _depth: u256 , tokenId : u256  ) -> (u256 , u256) {
            // first we have to check the move is leagal or not 

            if !isLegalMove(_board, _move) || self.status.read(tokenId) != 0 {
            assert!(false, "illegal move");
            }
            // then we have to apply the move  
            let mut board = applyMove(_board, _move);
            ///// we have to take care of the ai move 
            let (bestMove, isWhiteCheckmated) = searchMove(board, 1 );
            /// if he does not  
            if (bestMove == 0) {
                /// reset the board 
                /// means player has won   
                /// 
                ///  you won minted some large no of token to it ok 
                // 0 -loss 
                // 1 - win 
                // 2 - match is going on
                /// so the owner of the token can able to get the token 
                /// import the erc20 token 
             self.status.write(tokenId, 1) ;
                /// minted winner nft to him              

            } 
            else {
                // ai move  
                board = applyMove(board, bestMove);
        
                if (isWhiteCheckmated) {
                    // player have lost 
                 self.status.write(tokenId, 2) ;
                    /// block him so that he cannot able to play the game 
                }
            }
           ( board , bestMove )
        }




        fn playmove(ref self: ContractState, _move: u256  ) {
            // let _board = 0x3256230010000100001000009199D00009009000BC0ECB000000001;
            let caller = get_caller_address() ; //  callerfrom ; 
            // through the caller we get the token id 
            let tokenId =  self.get_token_Id(caller);
            // through the tokenid we found the current board state ; 
            let current_board_state = self.board_current_state(tokenId);
            let depth = self.hardness_Depth(tokenId) ;
            /// now it is ready for the chess moves and let do the usefull chessstuff 
            let (new_chess_board_after_ai , bestMove ) = self._play_move_chess(current_board_state, _move, depth , tokenId ) ;
            //// now what we have to do is to update the current board state     
            self.update_board_current_state(tokenId, new_chess_board_after_ai);
            // let mut current_all_board  : Array<u256> = self.tba_tokenId_to_move_tokenId.read(tokenId) ;
            //   current_all_board.append(tokenId) ;
            // now we have to save the whole the old board state and the move and the new board state

            // board nft start from o t 63 
            // move nft start from 1 to 63 

            assert!(self.puzzle_allowed_to_play.read(tokenId) , "Puzzle is not allowed to play") ;
            //// let start working with the tokenIds ok which will contain the board and move made during this ok 
            
            // for the first it is zero 
            let encoded_move = calculate_move_enoded(1 , _move , bestMove) ;
            self.mintmove(caller, tokenId  ,  new_chess_board_after_ai , encoded_move ); 

            // safe the board to the token id respectaviely 

            if self.checkWinngstatus(tokenId) ==1  {
                // if the player has won then he can able to withdraw the token
                let erc20_dispatcher = IERC20Dispatcher { contract_address: self.erc20_token.read() }; 
                erc20_dispatcher.transfer_from(self.MintedAddress.read(), caller , self.board_amt.read(tokenId).try_into().unwrap());
            }

            self
                .emit(
                    PlayMoveEvent {
                        caller: caller, 
                        currentBoardState: current_board_state,
                        newBoardState: new_chess_board_after_ai,
                        token_id_move: self.board_to_moves.read(tokenId),
                        token_id_board: tokenId
                    }
                );
        // i also want to create the mapping between the token id and the current board state and move it make it means just before , after and the move by him 
        //token_id_to_board_state : LegacyMap::<u256, BoardState> ,
        }

        fn getUpdatedBoardStatepublic(self: @ContractState,  tokenboundaccount : ContractAddress ) -> u256 {
            let tokenId =  self.get_token_Id(tokenboundaccount);
            let current_board_state = self.board_current_state(tokenId);
            return current_board_state ;
        }

        fn checkWinngstatus(self: @ContractState, token_id: u256) -> u8 {
            self.status.read(token_id)
        }

        /// simple there would be 10 nft with their token id then we goes from there ok 





        fn makePuzzle(ref self: ContractState, _board: u256, _depth: u256 , _amount : u256) -> u256 {
            // want to min this board 
            // setting the depth also means what hard it would be 
            // if the player won then the token which is present in this nft will be gaven to the player  ; 
            // token is transfered to the tokenbound account 
            // mint nft 
            // deploy the token bound account 
            // transfer the chess token to the token bound account
            // make sure when the chess state is of check mate by the player then only he can able to withdraw the token 

            // tokenid =>  board 

            //// minted the token address to the contract address only ok and then we transfer 
           /// this would be increase the counter and do the necessary stuff like this 
           /// 
           
           let caller = get_caller_address() ;
           let board_supply = self.board_puzzle_supply.read(); 
           self.mintboard(caller, _board , _depth  ) ;
        //    let token_id = 2 ; 
        //    // let token_id = self.count.read();
        //     self.ai_hard.write(token_id, _depth);
        //     self.tokenid_to_uriData.write(token_id , (_board, 0) ) ;
        //     self.board_mintedstate.write(token_id, _board);
        //     self.board_currentstate.write(token_id, _board);
        //     self._mint(self.MintedAddress.read(), token_id);
        //     // self.count.write(token_id + 1);
        //     self.board_amt.write(token_id, _amount);


        // want to deploy the contract i know ok what i want is the token id  

        return board_supply ; 
        } 


        
    }


    #[external(v0)]
    #[generate_trait]
    impl IERC721Impl of IERC721Trait {
        ////#### Read Functions ###////
    
        // EPI-721 https://eips.ethereum.org/EIPS/eip-721
        //***** ERC721 Metadata *****//
    
        // get_name function returns NFT's name
        fn name(self: @ContractState) -> felt252 {
            NAME
        }
    
        // get_symbol function returns NFT's token symbol
        fn symbol(self: @ContractState) -> felt252 {
            SYMBOL
        }
    
    
        //
    
    
        // so i think we have to make the mapping of the tokenid and their current board state 
        // and if the current board state is of checkmate and that token id is of the player then he can able to withdraw the token
    
        // how we check that the the token id is from what 
        // the caller id would then be what 
    
    
    
    
        // mint nft 
        // create the tba account 
        // transfer the token to the tba account
    
        // what information does it hold about the nft 
    
        // get tokenURI link to json file metadata
        // jsonMetaFile = BaseURI + TOKEN_ID + .json
    
        fn tokenURI(self: @ContractState, token_id: u256) -> Array<felt252> {
           
                assert(self._exists(token_id), 'ERC721: invalid token ID');
    
                let mut link = ArrayTrait::new();
                let (board , encodemove)  =  self.tokenid_to_uriData.read(token_id) ; 
    
                let board_felt : felt252 = board.try_into().unwrap(); 
                let move_felt : felt252 = encodemove.try_into().unwrap();
    
                if encodemove != 0 {
                    link.append(board_felt);
                    link.append(move_felt);
                }
                link.append(board_felt);
    
              return link ; 
            
        }
        // Compatibility
        fn token_uri(self: @ContractState, token_id: u256) -> Array<felt252> {
            self.tokenURI(token_id)
        }
    
        // Contract-level metadata - https://docs.opensea.io/docs/contract-level-metadata
        // NFT marketplaces use contractURI json file to get information about your collection
        fn contractURI(self: @ContractState) -> Array<felt252> {
            //In this example we use the json file of the first NFT in the collection, but you should customize it to return the correct file
            self.tokenURI(1)
        }
        // Compatibility
        fn contract_uri(self: @ContractState) -> Array<felt252> {
            self.contractURI()
        }
    
        // get maxSupply
        fn maxSupply(self: @ContractState) -> u256 {
            MAX_SUPPLY
        }
    
        //***** ERC721 Enumerable *****//
    
        // get current total nfts minted
        fn totalSupply(self: @ContractState) -> u256 {
            self.count.read()
        }
        // Compatibility
        fn total_supply(self: @ContractState) -> u256 {
            self.totalSupply()
        }
    
        //*****  ERC-2981 EIP165 - NFT Royalty Standard *****//
    
        // get - check supportsInterface
        fn supportsInterface(self: @ContractState, interfaceID: felt252) -> bool {
            interfaceID == INTERFACE_ERC165
                || interfaceID == INTERFACE_ERC721
                || interfaceID == INTERFACE_ERC721_METADATA
        }
        // Compatibility
        fn supports_interface(self: @ContractState, interfaceID: felt252) -> bool {
            self.supportsInterface(interfaceID)
        }
    
        //***** ERC721 *****//
    
        // get balance_of function returns token balance
        fn balanceOf(self: @ContractState, account: ContractAddress) -> u256 {
            assert(account.is_non_zero(), 'ERC721: address zero');
            self.balances.read(account)
        }
        // Compatibility
        fn balance_of(self: @ContractState, account: ContractAddress) -> u256 {
            self.balanceOf(account)
        }
    
        fn mintboard (ref self: ContractState, to: ContractAddress, _board : u256 , _depth : u256  ) {
            // here the tokenID would be the boardSupply 
            let board_supply = self.board_puzzle_supply.read();
            assert!(board_supply < 64 , "Board supply is full");
            let total_supply = self.count.read() ;
                let token_id  = encodeTokenId(board_supply , 0 ) ;
                self._safe_mint(to, token_id);
                self.puzzle_allowed_to_play.write(token_id ,true ) ;
                let board : felt252 =  _board.try_into().unwrap(); 
                self.tokenid_to_uriData.write(token_id, ( _board , 0 ) ) ;
                // self._set_token_uri(token_id, board );
                self.ai_hard.write(token_id, _depth);
                self.board_mintedstate.write(token_id, _board);
                self.board_currentstate.write(token_id, _board);
                self.board_puzzle_supply.write(board_supply + 1) ;
                self.count.write(total_supply + 1) ;
            }
            fn get_encode_tokenId(self : @ContractState , board_id : u256 , move_id : u256) -> u256 {
                encodeTokenId(board_id, move_id)
            }
            /// new board and moves 
            fn  mintmove (ref self: ContractState, to: ContractAddress, board_id : u256 , _board : u256 , encoded_move : u256  ) {
                // here the tokenid would be the board id and the token id would be the move id 
                // encode the boardid and moveid ok 
                let total_supply = self.count.read() ;
                let move_id_supply = self.board_to_moves.read(board_id) + 1 ;
                assert!(move_id_supply  < 64 , "not more move is possible");
                let token_id_encode = encodeTokenId(board_id, move_id_supply) ; 
                self._safe_mint(to, token_id_encode);
                let board : felt252 =  _board.try_into().unwrap(); 
                // self._set_token_uri(token_id_encode , board ) ; 
                // update the move supply 
                self.board_to_moves.write(board_id, move_id_supply) ;   
                // write the token tokenid_uri data       
                self.tokenid_to_uriData.write(token_id_encode, ( _board , encoded_move ) ) ;
                self.count.write(total_supply + 1) ;
            }


    
        
    
    
        // get owner_of function returns owner of token_id
        fn ownerOf(self: @ContractState, token_id: u256) -> ContractAddress {
            let owner = self.owners.read(token_id);
            assert(owner.is_non_zero(), 'ERC721: invalid token ID');
            owner
        }
        // Compatibility
        fn owner_of(self: @ContractState, token_id: u256) -> ContractAddress {
            self.ownerOf(token_id)
        }
    
        // get_approved function returns approved address for a token
        fn getApproved(self: @ContractState, token_id: u256) -> ContractAddress {
            assert(self._exists(token_id), 'ERC721: invalid token ID');
            self.token_approvals.read(token_id)
        }
        // Compatibility
        fn get_approved(self: @ContractState, token_id: u256) -> ContractAddress {
            self.getApproved(token_id)
        }
    
        // get is_approved_for_all function returns approved operator for a token
        fn isApprovedForAll(
            self: @ContractState, owner: ContractAddress, operator: ContractAddress
        ) -> bool {
            self.operator_approvals.read((owner, operator))
        }
        // Compatibility
        fn is_approved_for_all(
            self: @ContractState, owner: ContractAddress, operator: ContractAddress
        ) -> bool {
            self.isApprovedForAll(owner, operator)
        }
    
        ////#### Write Functions ###////
    
        // set approve function approves an address to spend a token
        ////////////////////////////////
        fn approve(ref self: ContractState, to: ContractAddress, token_id: u256) {
            let owner = self.ownerOf(token_id);
            assert(to != owner, 'Approval to current owner');
            assert(
                get_caller_address() == owner || self.isApprovedForAll(owner, get_caller_address()),
                'Not token owner'
            );
            self.token_approvals.write(token_id, to);
            self.emit(Approval { owner: self.ownerOf(token_id), to: to, token_id: token_id });
        }
    
        // set_approval_for_all function approves an operator to spend all tokens 
        fn setApprovalForAll(ref self: ContractState, operator: ContractAddress, approved: bool) {
            let owner = get_caller_address();
            assert(owner != operator, 'ERC721: approve to caller');
            self.operator_approvals.write((owner, operator), approved);
            self.emit(ApprovalForAll { owner: owner, operator: operator, approved: approved });
        }
        // Compatibility
        fn set_approval_for_all(
            ref self: ContractState, operator: ContractAddress, approved: bool
        ) {
            self.setApprovalForAll(operator, approved)
        }
    
        // set transfer_from function is used to transfer a token
        fn transferFrom(
            ref self: ContractState, from: ContractAddress, to: ContractAddress, token_id: u256
        ) {
            assert(
                self._is_approved_or_owner(get_caller_address(), token_id),
                'neither owner nor approved'
            );
            self._transfer(from, to, token_id);
        }
    
        // safe transfer an NFT
        fn safeTransferFrom(
            ref self: ContractState,
            from: ContractAddress,
            to: ContractAddress,
            token_id: u256,
            data: Span<felt252>
        ) {
            // #Todo - Check that the receiving address is a contract address and that it supports INTERFACE_ERC721_RECEIVER
            self.transferFrom(from, to, token_id)
        }
        // Compatibility
        fn safe_transfer_from(
            ref self: ContractState,
            from: ContractAddress,
            to: ContractAddress,
            token_id: u256,
            data: Span<felt252>
        ) {
            self.safeTransferFrom(from, to, token_id, data)
        }
    // ab agayaga na mmaja bedu :-)
    // ok lets go writh into it :-(
    
    }
    
    // #################### ADMIN CONTROL FUNCTIONS #################### //
    #[external(v0)]
    #[generate_trait]
    impl ERC721AdminImpl of ERC721AdminTrait {
        // Airdrop
        fn airdrop(ref self: ContractState, to: ContractAddress, amount: u256) {
            // self._assert_admin();
            let limit: u256 = 500;
            assert(to.is_non_zero(), 'TO_IS_ZERO_ADDRESS');
            assert(amount <= limit, 'Amount is too much');
            self._assert_mintable(self.count.read() + amount);
            let startID: u256 = self.count.read();
            let mut i: u256 = 1;
            loop {
                if i > amount {
                    break;
                }
                self._safe_mint(to, startID + i);
                i += 1;
            };
            // Increase receiver balance
            let receiver_balance = self.balances.read(to);
            self.balances.write(to, receiver_balance + amount.into());
    
            // Increase total nft
            self.count.write(startID + amount.into());
        }
        // Batch Airdrop - Airdrop to multiple receiving addresses, each receiving 1 NFT
        fn batchAirdrop(ref self: ContractState, addressArr: Array<ContractAddress>) {
            // self._assert_admin();
            let totalAmount: u32 = addressArr.len();
            let limit: u32 = 200;
            assert(totalAmount <= limit, 'Input is too long');
            self._assert_mintable(self.count.read() + totalAmount.into());
            //Airdrop
            let startID: u256 = self.count.read();
            let mut i: u32 = 0;
            let mut doneCount: u256 = 0;
            loop {
                if i > (totalAmount - 1) {
                    break;
                }
                let toAddress: ContractAddress = *addressArr.at(i);
                if (toAddress.is_non_zero()) {
                    self._safe_mint(toAddress, startID + doneCount + 1);
                    //update user balance
                    let receiver_balance: u256 = self.balances.read(toAddress);
                    self.balances.write(toAddress, receiver_balance + 1);
                    //update done count
                    doneCount = doneCount + 1;
                }
                i = i + 1;
            };
            // Increase total nft
            self.count.write(startID + doneCount);
        }
    }
    
    // #################### PRIVATE Helper FUNCTION #################### //
    #[external(v0)]
    #[generate_trait]
    impl ERC721HelperImpl of ERC721HelperTrait {
        fn svgimage(self: @ContractState, _tokenId: u256) -> Array<felt252> {
            let mut svg = ArrayTrait::<felt252>::new();
            let _tokenId: felt252 = _tokenId.try_into().unwrap();
            svg.append('<svg height="40" ');
            svg.append('width="30" xmlns="http://');
            svg.append('www.w3.org/2000/svg">');
            svg.append('<text x="5" y="30" fill="none" ');
            svg.append('stroke="red" font-size="35">');
            svg.append(_tokenId);
            svg.append('</text> </svg>');
    
            svg
        }
    
    
        //assert
        // check admin permission 
        fn _assert_admin(self: @ContractState) {
            assert(
                get_caller_address() == self._felt252ToAddress(ADMIN_ADDRESS), 'Caller not admin'
            )
        }
        // check mintable
        fn _assert_mintable(self: @ContractState, max_token_id: u256) {
            assert(max_token_id <= MAX_SUPPLY, 'Out of collection size');
        }
    
        ////////////////////////////////
        // internal function to check if a token exists
        ////////////////////////////////
        fn _exists(self: @ContractState, token_id: u256) -> bool {
            // check that owner of token is not zero
            self.ownerOf(token_id).is_non_zero()
        }
    
        ////////////////////////////////
        // _is_approved_or_owner checks if an address is an approved spender or owner
        ////////////////////////////////
        fn _is_approved_or_owner(
            self: @ContractState, spender: ContractAddress, token_id: u256
        ) -> bool {
            let owner = self.owners.read(token_id);
            spender == owner
                || self.isApprovedForAll(owner, spender)
                || self.getApproved(token_id) == spender
        }
    
        ////////////////////////////////
        // internal function that performs the transfer logic
        ////////////////////////////////
        fn _transfer(
            ref self: ContractState, from: ContractAddress, to: ContractAddress, token_id: u256
        ) {
            // check that from address is equal to owner of token
            assert(from == self.ownerOf(token_id), 'ERC721: Caller is not owner');
            // check that to address is not zero
            assert(to.is_non_zero(), 'ERC721: transfer to 0 address');
    
            // remove previously made approvals
            self.token_approvals.write(token_id, Zeroable::zero());
    
            // increase balance of to address, decrease balance of from address
            self.balances.write(from, self.balances.read(from) - 1);
            self.balances.write(to, self.balances.read(to) + 1);
    
            // update token_id owner
            self.owners.write(token_id, to);
    
            // emit the Transfer event
            self.emit(Transfer { from: from, to: to, token_id: token_id });
        }
    
        // safe mint - Optimize airdrop fees
        fn _safe_mint(ref self: ContractState, to: ContractAddress, token_id: u256) {
            // Update token_id owner
            self.owners.write(token_id, to);
    
            // emit Transfer event
            self.emit(Transfer { from: Zeroable::zero(), to: to, token_id: token_id });
        }
    
        // get baseURI()
        fn _getBaseURI(self: @ContractState) -> Array<felt252> {
            let mut baseLinkArr = ArrayTrait::new();
            baseLinkArr.append(BASE_URI_PART_1);
            baseLinkArr.append(BASE_URI_PART_2);
            baseLinkArr.append(BASE_URI_PART_3);
            baseLinkArr
        }
    }
    
    // #################### Base Helper FUNCTION #################### //
    #[generate_trait]
    impl BaseHelperImpl of BaseHelperTrait {
        // convert int short string .  eg: 1 -> 0x31 
        fn _intToChar(self: @ContractState, input: u256) -> felt252 {
            if input == 0 {
                return 0x30;
            } else if input == 1 {
                return 0x31;
            } else if input == 2 {
                return 0x32;
            } else if input == 3 {
                return 0x33;
            } else if input == 4 {
                return 0x34;
            } else if input == 5 {
                return 0x35;
            } else if input == 6 {
                return 0x36;
            } else if input == 7 {
                return 0x37;
            } else if input == 8 {
                return 0x38;
            } else if input == 9 {
                return 0x39;
            }
            0x0
        }
    
        // convert felt252 hex address to Address type
        fn _felt252ToAddress(self: @ContractState, input: felt252) -> ContractAddress {
            input.try_into().unwrap()
        }
    }
    
    // #################### ADMIN CONTROL FUNCTION #################### //
    #[external(v0)]
    #[generate_trait]
    impl ContractImpl of ContractTrait {
        // return version code of contract
        fn versionCode(self: @ContractState) -> u256 {
            VERSION_CODE
        }
    }


    }

        


//     #[external(v0)]
//     #[generate_trait]
//     impl IERC721Impl of IERC721Trait {
//         ////////////////////////////////
//         // get_name function returns token name
//         ////////////////////////////////
        
        

        
        
//         fn name(self: @ContractState) -> felt252 {
//             'CCNFTS'
//         }



//         ////////////////////////////////
//         // get_symbol function returns token symbol
//         ////////////////////////////////
//         fn symbol(self: @ContractState) -> felt252 {
//             'CCNFTS'
//         }

//         ////////////////////////////////
//         // token_uri returns the token uri
//         ////////////////////////////////
//         fn token_uri(self: @ContractState, token_id: u256) -> Array<felt252> {
//             assert(self._exists(token_id), 'ERC721: invalid token ID');

//             let mut link = ArrayTrait::new();
//             let (board , encodemove)  =  self.tokenid_to_uriData.read(token_id) ; 

//             let board_felt : felt252 = board.try_into().unwrap(); 
//             let move_felt : felt252 = encodemove.try_into().unwrap();

//             if encodemove != 0 {
//                 link.append(board_felt);
//                 link.append(move_felt);
//             }
//             link.append(board_felt);

//           return link ; 
//         }

//         /////////////////////////
//         /// 
//         /// 
//         fn contract_uri(self: @ContractState) -> Array<felt252> {
//             self.token_uri(0)
//         }
//         /// 
//         /// ///////
//         // balance_of function returns token balance
//         ////////////////////////////////
//         fn balance_of(self: @ContractState, account: ContractAddress) -> u256 {
//             assert(account.is_non_zero(), 'ERC721: address zero');
//             self.balances.read(account)
//         }

//         fn maxSupply(self: @ContractState) -> u256 {
//             MAX_SUPPLY
//         }

//         fn total_supply(self: @ContractState) -> u256 {
//            self.count.read()
//         }
//         ////////////////////////////////
//         // owner_of function returns owner of token_id
//         ////////////////////////////////
//         fn owner_of(self: @ContractState, token_id: u256) -> ContractAddress {
//             let owner = self.owners.read(token_id);
//             owner
//         }

//         ////////////////////////////////
//         // get_approved function returns approved address for a token
//         ////////////////////////////////
//         fn get_approved(self: @ContractState, token_id: u256) -> ContractAddress {
//             assert(self._exists(token_id), 'ERC721: invalid token ID');
//             self.token_approvals.read(token_id)
//         }

//         ////////////////////////////////
//         // is_approved_for_all function returns approved operator for a token
//         ////////////////////////////////
//         fn is_approved_for_all(
//             self: @ContractState, owner: ContractAddress, operator: ContractAddress
//         ) -> bool {
//             self.operator_approvals.read((owner, operator))
//         }

//         fn supportsInterface(self: @ContractState, interfaceID: felt252) -> bool {
//             interfaceID == INTERFACE_ERC165
//                 || interfaceID == INTERFACE_ERC721
//                 || interfaceID == INTERFACE_ERC721_METADATA
//         }
//         // Compatibility
//         fn supports_interface(self: @ContractState, interfaceID: felt252) -> bool {
//             self.supportsInterface(interfaceID)
//         }

//         ////////////////////////////////
//         // approve function approves an address to spend a token
//         ////////////////////////////////
//         fn approve(ref self: ContractState, to: ContractAddress, token_id: u256) {
//             let owner = self.owner_of(token_id);
//             assert(to != owner, 'Approval to current owner');
//             assert(
//                 get_caller_address() == owner
//                     || self.is_approved_for_all(owner, get_caller_address()),
//                 'Not token owner'
//             );
//             self.token_approvals.write(token_id, to);
//             self.emit(Approval { owner: self.owner_of(token_id), to: to, token_id: token_id });
//         }

//         ////////////////////////////////
//         // set_approval_for_all function approves an operator to spend all tokens 
//         ////////////////////////////////
//         fn set_approval_for_all(
//             ref self: ContractState, operator: ContractAddress, approved: bool
//         ) {
//             let owner = get_caller_address();
//             assert(owner != operator, 'ERC721: approve to caller');
//             self.operator_approvals.write((owner, operator), approved);
//             self.emit(ApprovalForAll { owner: owner, operator: operator, approved: approved });
//         }


//         ////////////////////////////////
//         // transfer_from function is used to transfer a token
//         ////////////////////////////////
        
//         fn transferFrom(
//             ref self: ContractState, from: ContractAddress, to: ContractAddress, token_id: u256
//         ) {
//             assert(
//                 self._is_approved_or_owner(get_caller_address(), token_id),
//                 'neither owner nor approved'
//             );
//             self.transfer_from(from, to, token_id);
//         } 

//         fn transfer_from(
//             ref self: ContractState, from: ContractAddress, to: ContractAddress, token_id: u256
//         ) {
//             assert(
//                 self._is_approved_or_owner(get_caller_address(), token_id),
//                 'neither owner nor approved'
//             );
//             self._transfer(from, to, token_id);
//         }
//         fn safeTransferFrom(
//             ref self: ContractState,
//             from: ContractAddress,
//             to: ContractAddress,
//             token_id: u256,
//             data: Span<felt252>
//         ) {
//             // #Todo - Check that the receiving address is a contract address and that it supports INTERFACE_ERC721_RECEIVER
//             self.transfer_from(from, to, token_id)
//         }
//         fn safe_transfer_from(
//             ref self: ContractState,
//             from: ContractAddress,
//             to: ContractAddress,
//             token_id: u256,
//             data: Span<felt252>
//         ) {
//             self.safeTransferFrom(from, to, token_id, data)
//         }

//         fn mintboard (ref self: ContractState, to: ContractAddress, _board : u256 , _depth : u256  ) {
//         // here the tokenID would be the boardSupply 
//         let board_supply = self.board_puzzle_supply.read();
//         assert!(board_supply < 64 , "Board supply is full");
//         let total_supply = self.count.read() ;
//             let token_id  = encodeTokenId(board_supply , 0 ) ;
//             self._mint(to, token_id);
//             self.puzzle_allowed_to_play.write(token_id ,true ) ;
//             let board : felt252 =  _board.try_into().unwrap(); 
//             self.tokenid_to_uriData.write(token_id, ( _board , 0 ) ) ;
//             // self._set_token_uri(token_id, board );
//             self.ai_hard.write(token_id, _depth);
//             self.board_mintedstate.write(token_id, _board);
//             self.board_currentstate.write(token_id, _board);
//             self.board_puzzle_supply.write(board_supply + 1) ;
//             self.count.write(total_supply + 1) ;
//         }
//         fn get_encode_tokenId(self : @ContractState , board_id : u256 , move_id : u256) -> u256 {
//             encodeTokenId(board_id, move_id)
//         }
//         /// new board and moves 
//         fn  mintmove (ref self: ContractState, to: ContractAddress, board_id : u256 , _board : u256 , encoded_move : u256  ) {
//             // here the tokenid would be the board id and the token id would be the move id 
//             // encode the boardid and moveid ok 
//             let total_supply = self.count.read() ;
//             let move_id_supply = self.board_to_moves.read(board_id) + 1 ;
//             assert!(move_id_supply  < 64 , "not more move is possible");
//             let token_id_encode = encodeTokenId(board_id, move_id_supply) ; 
//             self._mint(to, token_id_encode);
//             let board : felt252 =  _board.try_into().unwrap(); 
//             // self._set_token_uri(token_id_encode , board ) ; 
//             // update the move supply 
//             self.board_to_moves.write(board_id, move_id_supply) ;   
//             // write the token tokenid_uri data       
//             self.tokenid_to_uriData.write(token_id_encode, ( _board , encoded_move ) ) ;
//             self.count.write(total_supply + 1) ;
//         }

//         fn mint(ref self: ContractState, to: ContractAddress, token_id: u256) {
//             self._mint(to, token_id);
//         }

//     }

//     #[generate_trait]
//     impl ERC721HelperImpl of ERC721HelperTrait {
//         ////////////////////////////////
//         // internal function to check if a token exists
//         ////////////////////////////////
//         fn _exists(self: @ContractState, token_id: u256) -> bool {
//             // check that owner of token is not zero
//             self.owner_of(token_id).is_non_zero()
//         }

//         ////////////////////////////////
//         // _is_approved_or_owner checks if an address is an approved spender or owner
//         ////////////////////////////////
//         fn _is_approved_or_owner(
//             self: @ContractState, spender: ContractAddress, token_id: u256
//         ) -> bool {
//             let owner = self.owners.read(token_id);
//             spender == owner
//                 || self.is_approved_for_all(owner, spender)
//                 || self.get_approved(token_id) == spender
//         }

//         ////////////////////////////////
//         // internal function that sets the token uri
//         ////////////////////////////////

//         ////////////////////////////////
//         // internal function that performs the transfer logic
//         ////////////////////////////////
//         fn _transfer(
//             ref self: ContractState, from: ContractAddress, to: ContractAddress, token_id: u256
//         ) {
//             // check that from address is equal to owner of token
//             assert(from == self.owner_of(token_id), 'ERC721: Caller is not owner');
//             // check that to address is not zero
//             assert(to.is_non_zero(), 'ERC721: transfer to 0 address');

//             // remove previously made approvals
//             self.token_approvals.write(token_id, Zero::zero());

//             // increase balance of to address, decrease balance of from address
//             self.balances.write(from, self.balances.read(from) - 1.into());
//             self.balances.write(to, self.balances.read(to) + 1.into());

//             // update token_id owner
//             self.owners.write(token_id, to);

//             // emit the Transfer event
//             self.emit(Transfer { from: from, to: to, token_id: token_id });
//         }

//         ////////////////////////////////
//         // _mint function mints a new token to the to address
//         ////////////////////////////////
//         fn _mint(ref self: ContractState, to: ContractAddress, token_id: u256) {
//             assert(to.is_non_zero(), 'TO_IS_ZERO_ADDRESS');

//             // Ensures token_id is unique
//             assert(!self.owner_of(token_id).is_non_zero(), 'ERC721: Token already minted');

//             // Increase receiver balance
//             let receiver_balance = self.balances.read(to);
//             self.balances.write(to, receiver_balance + 1.into());

//             // Update token_id owner
//             self.owners.write(token_id, to);

//             // emit Transfer event
//             self.emit(Transfer { from: Zero::zero(), to: to, token_id: token_id });
//         }

//         ////////////////////////////////
//         // _burn function burns token from owner's account
//         ////////////////////////////////
//         fn _burn(ref self: ContractState, token_id: u256) {
//             let owner = self.owner_of(token_id);

//             // Clear approvals
//             self.token_approvals.write(token_id, Zero::zero());

//             // Decrease owner balance
//             let owner_balance = self.balances.read(owner);
//             self.balances.write(owner, owner_balance - 1.into());

//             // Delete owner
//             self.owners.write(token_id, Zero::zero());
//             // emit the Transfer event
//             self.emit(Transfer { from: owner, to: Zero::zero(), token_id: token_id });
//         }
//     }
// }    





