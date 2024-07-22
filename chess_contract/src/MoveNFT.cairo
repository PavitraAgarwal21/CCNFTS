// creating the two nft project 
// create the board nft  , with depth 
// create it token bound account 
// connect it with the this nft contract and execute the call on this contract 
// only the person who has the token nft can able to withdraw the token 
// using the predefined contract and the ai can only able to mint the token 

// token  starting state connect lete h  state1 -> playmove(move) -> state2
// token id -> state h 
/// 100 mint 
/// current state mint 
/// current state token Moves - board and moves 
/// internal id 1 = 1 ; 0 = 0 

// first of all this contract has been called by the

// defining the trait for the boardNFT which i want to use 

use starknet::ContractAddress;
use starknet::ClassHash;
use starknet::account::Call;


// token bound account 
// when we connecvt to the account what  does it mean by it is connected 
// w have been minted the nft to the connceted wallet which is the token boun account 

// leta assume i have the board nft 
// not assume that i have been deployed the tokenbound account for that nft 
// i have connceted that token bound account to this nft contract and call with the help of the execute function 

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


#[starknet::interface]
pub trait IBoardNFT<TContractState> {
    fn getname(self: @TContractState) -> felt252;
    fn getsymbol(self: @TContractState) -> felt252;
    fn hardness_Depth(self: @TContractState, token_id: u256) -> u256;
    fn board_minted_state(self: @TContractState, token_id: u256) -> u256;
    fn board_current_state(self: @TContractState, token_id: u256) -> u256;
    fn update_board_current_state(ref self: TContractState, token_id: u256, new_state_board: u256);
    fn get_minted_token_amount( self : @TContractState , token_id : u256 ) -> u256 ; 

}


#[starknet::contract]
mod MoveNFT {
    use starknet::ContractAddress;
    use starknet::get_caller_address;
    use starknet::get_contract_address;
    use core::array::ArrayTrait;
    use core::nullable::match_nullable;
    use core::zeroable::Zeroable;
    use core::traits::Into;
    use ccnfts::chess_test::{searchMove, isLegalMove, applyMove, Move };


    use super::IBoardNFTDispatcher;
    use super::IBoardNFTDispatcherTrait;
    use super::IAccountDispatcher;
    use super::IAccountDispatcherTrait;


    #[storage(Drop, Serde, Copy, starknet::store)]
    struct Storage {
        owners: LegacyMap::<u256, ContractAddress>,
        balances: LegacyMap::<ContractAddress, u256>,
        token_approvals: LegacyMap::<u256, ContractAddress>,
        operator_approvals: LegacyMap::<(ContractAddress, ContractAddress), bool>,
        count: u256, //Total number of NFTs minted
        boardNFT: IBoardNFTDispatcher,
        // making the mapping of the tokenbound account to the token id ;
        
        token_bound_account_to_tokenId: LegacyMap::<ContractAddress, u256>,
        

        token_id_to_move_state: LegacyMap::<u256, (u256, u256, u256)>,
   

        token_id_to_board : LegacyMap::<u256, u256> ,  


        board_to_total_nft_move : LegacyMap::<u256, u256> , 
        win_lose : LegacyMap::<u256, bool> , 


    }





    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        Approval: Approval,
        Transfer: Transfer,
        ApprovalForAll: ApprovalForAll,
        PlayMoveEvent : PlayMoveEvent ,
    }


    #[derive(Drop, starknet::Event)]
    struct PlayMoveEvent {
        caller: ContractAddress,
        currentBoardState : u256 ,
        newBoardState : u256 , 
        move : u256 ,
        token_id_move: u256,
        token_id_board: u256,
    }


    #[constructor]
    fn constructor(ref self: ContractState, _boardNFTAddress: ContractAddress) {
        self.initConfig(_boardNFTAddress);
    }

    #[generate_trait]
    impl ConfigImpl of ConfigTrait {
        fn initConfig(ref self: ContractState, _boardNFTAddress: ContractAddress) {
            let boardNFT = IBoardNFTDispatcher { contract_address: _boardNFTAddress };
            self.boardNFT.write(boardNFT);
        }
    }


    // we have also been working with the token bound account . 
    // trate the token bound account connect the token bound account 
    // execute the transaction 

    // we also have to design the design that we can use the deploued contract from that 
    // const BoardNFTContract : ContractAddress = 0x26087b21ffe0510269e562487d0f75f603718f5bc6646cac3ae02d187823d89 ; 

    #[external(v0)]
    #[generate_trait]
    impl IBoardHelpfull of IBoardHelpfullTrait {
        fn boardNFTgetname(self: @ContractState) -> felt252 {
            let boardNFT = self.boardNFT.read();
            boardNFT.getname()
        }
        fn boardNFTgetsymbol(self: @ContractState) -> felt252 {
            let boardNFT = self.boardNFT.read();
            boardNFT.getsymbol()
        }
        fn boardNFThardness(self: @ContractState, token_id: u256) -> u256 {
            let boardNFT = self.boardNFT.read();
            boardNFT.hardness_Depth(token_id)
        }
        fn boardNFTboard_minted_state(self: @ContractState, token_id: u256) -> u256 {
            let boardNFT = self.boardNFT.read();
            boardNFT.board_minted_state(token_id)
        }
        fn boardNFTboard_current_state(self: @ContractState, token_id: u256) -> u256 {
            let boardNFT = self.boardNFT.read();
            boardNFT.board_current_state(token_id)
        }
        fn boardNFTupdate_board_current_state(
            ref self: ContractState, token_id: u256, new_state_board: u256
        ) {
            let boardNFT = self.boardNFT.read();
            boardNFT.update_board_current_state(token_id, new_state_board)
        }
        ///private
        fn get_token_Id(self: @ContractState, caller: ContractAddress) -> u256 {
            let account = IAccountDispatcher { contract_address: caller };
            let (_token_contract, token_id) = account.token();
            token_id
        }
        fn get_amt_mint(self : @ContractState , token_id : u256 ) -> u256 {
            let boardNFT = self.boardNFT.read();
            boardNFT.get_minted_token_amount(token_id)
        }
       
    }

    #[external(v0)]
    #[generate_trait]
    impl IMoveImpl of ImoveTrait {

     fn _play_move_chess(ref self : ContractState ,  _board: u256, _move: u256, _depth: u256) -> u256 {
            // first we have to check the move is leagal or not 
            if !isLegalMove(_board, _move) {
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
                ///  you won minted some large no of token to it ok 
                
                /// import the erc20 token 
                
                self.win_lose.write(_board, true) ;
                /// minted winner nft to him 
                
            } else {
                // ai move  
                board = applyMove(board, bestMove);
        
                if (isWhiteCheckmated) {
                    // player have lost 
                    self.win_lose.write(_board, false) ;
                    /// block him so that he cannot able to play the game 
                  
                }
            }
            board
        }


fn playmove(ref self: ContractState, _move: u256 , callerfrom : ContractAddress ) {
            // let _board = 0x3256230010000100001000009199D00009009000BC0ECB000000001;
            let caller = callerfrom ; 
            // through the caller we get the token id 
            let tokenId =  self.get_token_Id(caller);
            // through the tokenid we found the current board state ; 
            let current_board_state = self.boardNFTboard_current_state(tokenId);
            let depth = self.boardNFThardness(tokenId) ;
            /// now it is ready for the chess moves and let do the usefull chessstuff 
            
            let new_chess_board_after_ai = self._play_move_chess(current_board_state, _move, depth);
            //// now what we have to do is to update the current board state     
            self.boardNFTupdate_board_current_state(tokenId, new_chess_board_after_ai);
            // let mut current_all_board  : Array<u256> = self.tba_tokenId_to_move_tokenId.read(tokenId) ;
            //   current_all_board.append(tokenId) ;
            // now we have to save the whole the old board state and the move and the new board state

            let nft_move_token_id = self.board_to_total_nft_move.read(tokenId) ; 
            
            self._safe_mint(caller, nft_move_token_id ); 

            if self.win_lose.read(tokenId) {
                // mint_token(caller, self.get_amt_mint(tokenId)) ;
                // exit game 
            } 

        
// gasless token cleaner 

            self.token_id_to_board.write(nft_move_token_id, new_chess_board_after_ai);

            self
                .token_id_to_move_state
                .write(nft_move_token_id, (current_board_state, _move, new_chess_board_after_ai));

                self.board_to_total_nft_move.write(tokenId, nft_move_token_id + 1 ) ;

            // want to map the tokenId = to the array of the token_id_move  

            //// mint the nft to the token bound account 
           
            //// emiting 
            /// new chess board 
            /// move 

            self
                .emit(
                    PlayMoveEvent {
                        caller: caller, 
                        currentBoardState: current_board_state,
                        newBoardState: new_chess_board_after_ai,
                        move: _move,
                        token_id_move: nft_move_token_id,
                        token_id_board: tokenId
                    }
                );
        // i also want to create the mapping between the token id and the current board state and move it make it means just before , after and the move by him 
        //token_id_to_board_state : LegacyMap::<u256, BoardState> ,

        }
    // fn mintMove(ref self: ContractState, _move: u256, _depth: u256) {
    //     assert!(_depth >= 3 && _depth <= 10, "depth should be greater then 3 and less then 10");
    //     // self.playmove(_depth);
    //     self._safe_mint(get_caller_address(), 2);
    // //after each times the nft is minted from the move it is transfered to the nft token bound account 
    // }
    // so i think we have to make the mapping of the tokenid and their current board state 
    // and if the current board state is of checkmate and that token id is of the player then he can able to withdraw the token

    // how we check that the the token id is from what 
    // the caller id would then be what 

    // fn withdrawToken(
    //     ref self: ContractState
    // ) { // check if the current board state is of check mate 
    // // if the current board state is of check mate then the player can able to withdraw the token 
    // // if the player is able to withdraw the token then the token is transfered to the token bound account 
    // // if the player is not able to withdraw the token then the token is transfered to the contract account

    // }

    // fn makePuzzle(
    //     ref self: ContractState, _board: u256, _depth: u256, _amount: u256
    // ) { // want to min this board 
    // // setting the depth also means what hard it would be 
    // // if the player won then the token which is present in this nft will be gaven to the player  ; 
    // // token is transfered to the tokenbound account 
    // // mint nft 
    // // deploy the token bound account 
    // // transfer the chess token to the token bound account
    // // make sure when the chess state is of check mate by the player then only he can able to withdraw the token 

    // }

    // mint nft 
    // create the tba account 
    // transfer the token to the tba account

    // what information does it hold about the nft 

    // fn can_onlymodify_their_tokenid(
    //     self: @ContractState, caller: ContractAddress, _tokenid: u256
    // ) {
    //     let account = IAccountDispatcher { contract_address: caller };

    //     let (token_contract_address, tokenid_from_tba) = account.token();

    //     // now i want to check which token id the are manipulating 
    //     assert!(tokenid_from_tba == _tokenid, "You can only modify your token id");
    // }

    // fn tokenboundmodifier(self: @ContractState, caller: ContractAddress) -> bool {
    //     // so first we have to figure out what are the things we have to check 

    //     // get the token id 
    //     let account = IAccountDispatcher { contract_address: caller };
    //     let (_token_contract, token_id) = account.token();

    //     // token_bound_account == token_id
    //     true
    // }
    }


    ////// should one for the erc20 token contract 

    ////// this must contain only about the token bound account details only //////// 

    #[external(v0)]
    #[generate_trait]
    impl IAccountImpl of IAccountImplTrait {
        //what would be the caller of this address 
        // contain the nft token  

        fn gettingTokenId(ref self: ContractState) -> u256 {
            let caller = get_caller_address();
            self.token_bound_account_to_tokenId.read(caller)
        }


        /// getting the caller address 
        /// //. then initiate the account from it 
        /// then call the token function 
        /// which gave the tokenid , token contract address 

        fn settokenId(ref self: ContractState) {
            let caller = get_caller_address();

            let account = IAccountDispatcher { contract_address: caller };
            let (_token_contract, token_id) = account.token();

            self.token_bound_account_to_tokenId.write(caller, token_id);
        }
    }


    ////// this must containonly the nft related only ok  ////////
    /// 
    /// 
    /// 

    const NAME: felt252 = 'Each Move NFT';
    const SYMBOL: felt252 = 'EMNFT';
    const BASE_URI_PART_1: felt252 = 0x697066733a2f2f516d505a6e336f5967486f676343643835;
    const BASE_URI_PART_2: felt252 = 0x697251685033794d61446139387878683654653550426e53;
    const BASE_URI_PART_3: felt252 = 0x61626859722f;

    // Total number of NFTs that can be minted
    const MAX_SUPPLY: u256 = 50
        * 10; // maximum each chess has 50 moves so 50*10 = 500 nft can be minted 
    const ADMIN_ADDRESS: felt252 =
        0x004835541Fd87cdDBc3B48Ad08e53FfA1E4D55aB21a46900A969DF326C9276326;
    const VERSION_CODE: u256 = 202311150001001; /// YYYYMMDD000NONCE
    const INTERFACE_ERC165: felt252 = 0x01ffc9a7;
    const INTERFACE_ERC721: felt252 = 0x80ac58cd;
    const INTERFACE_ERC721_METADATA: felt252 = 0x5b5e139f;
    const INTERFACE_ERC721_RECEIVER: felt252 = 0x150b7a02;


    #[derive(Drop, starknet::Event)]
    struct Approval {
        owner: ContractAddress,
        to: ContractAddress,
        token_id: u256
    }

    #[derive(Drop, starknet::Event)]
    struct Transfer {
        from: ContractAddress,
        to: ContractAddress,
        token_id: u256
    }


    #[derive(Drop, starknet::Event)]
    struct ApprovalForAll {
        owner: ContractAddress,
        operator: ContractAddress,
        approved: bool
    }
    #[external(v0)]
    #[generate_trait]
    impl IERC721Impl of IERC721Trait {
        fn name(self: @ContractState) -> felt252 {
            NAME
        }

        fn symbol(self: @ContractState) -> felt252 {
            SYMBOL
        }

        fn token_uri(self: @ContractState, token_id: u256) -> Array<felt252> {
            self.tokenURI(token_id)
        }


        fn contract_uri(self: @ContractState) -> Array<felt252> {
            self.contractURI()
        }


        fn maxSupply(self: @ContractState) -> u256 {
            MAX_SUPPLY
        }


        fn total_supply(self: @ContractState) -> u256 {
            self.totalSupply()
        }


        // Compatibility
        fn supports_interface(self: @ContractState, interfaceID: felt252) -> bool {
            self.supportsInterface(interfaceID)
        }

        // Compatibility
        fn balance_of(self: @ContractState, account: ContractAddress) -> u256 {
            self.balanceOf(account)
        }


        // Compatibility
        fn owner_of(self: @ContractState, token_id: u256) -> ContractAddress {
            self.ownerOf(token_id)
        }


        // Compatibility
        fn get_approved(self: @ContractState, token_id: u256) -> ContractAddress {
            self.getApproved(token_id)
        }

        // get is_approved_for_all function returns approved operator for a token

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


        // Compatibility
        fn set_approval_for_all(
            ref self: ContractState, operator: ContractAddress, approved: bool
        ) {
            self.setApprovalForAll(operator, approved)
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
        fn supportsInterface(self: @ContractState, interfaceID: felt252) -> bool {
            interfaceID == INTERFACE_ERC165
                || interfaceID == INTERFACE_ERC721
                || interfaceID == INTERFACE_ERC721_METADATA
        }
        // get owner_of function returns owner of token_id
        fn ownerOf(self: @ContractState, token_id: u256) -> ContractAddress {
            let owner = self.owners.read(token_id);
            assert(owner.is_non_zero(), 'ERC721: invalid token ID');
            owner
        }
        // set_approval_for_all function approves an operator to spend all tokens 
        fn setApprovalForAll(ref self: ContractState, operator: ContractAddress, approved: bool) {
            let owner = get_caller_address();
            assert(owner != operator, 'ERC721: approve to caller');
            self.operator_approvals.write((owner, operator), approved);
            self.emit(ApprovalForAll { owner: owner, operator: operator, approved: approved });
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
        fn isApprovedForAll(
            self: @ContractState, owner: ContractAddress, operator: ContractAddress
        ) -> bool {
            self.operator_approvals.read((owner, operator))
        }
        // get_approved function returns approved address for a token
        fn getApproved(self: @ContractState, token_id: u256) -> ContractAddress {
            assert(self._exists(token_id), 'ERC721: invalid token ID');
            self.token_approvals.read(token_id)
        }

        fn totalSupply(self: @ContractState) -> u256 {
            self.count.read()
        }

        /////// useful
        fn tokenURI(self: @ContractState, token_id: u256) -> Array<felt252> {
            let boardState =  self.token_id_to_board.read(token_id) ; 
            let boardStateFelt  : felt252 = boardState.try_into().unwrap(); 
            let mut uri = ArrayTrait::<felt252>::new(); 
            uri.append(boardStateFelt);
            uri 
        }
        fn balanceOf(self: @ContractState, account: ContractAddress) -> u256 {
            assert(account.is_non_zero(), 'ERC721: address zero');
            self.balances.read(account)
        }
        fn contractURI(self: @ContractState) -> Array<felt252> {
            //In this example we use the json file of the first NFT in the collection, but you should customize it to return the correct file
            self.tokenURI(1)
        }


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

    //  #################### Base Helper FUNCTION #################### //
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

        fn versionCode(self: @ContractState) -> u256 {
            VERSION_CODE
        }
    }
}

