use starknet::ContractAddress;
use starknet::account::Call;
#[starknet::interface]
pub trait IBoardNFT<TContractState> {
    fn getname(self: @TContractState) -> felt252;
    fn getsymbol(self: @TContractState) -> felt252;
    fn hardness_Depth(self: @TContractState, token_id: u256) -> u256;
    fn board_minted_state(self: @TContractState, token_id: u256) -> u256;
    fn get_move_total_supply(self: @TContractState, token_id: u256) -> u256;
    fn board_current_state(self: @TContractState, token_id: u256) -> u256;
    fn update_board_current_state(ref self: TContractState, token_id: u256, new_state_board: u256);
    fn get_minted_token_amount(self: @TContractState, token_id: u256) -> u256;
    fn get_token_Id(self: @TContractState, caller: ContractAddress) -> u256;
    fn _play_move_chess(
        ref self: TContractState, _board: u256, _move: u256, _depth: u256, tokenId: u256
    ) -> (u256, u256);
    fn playmove(ref self: TContractState, _move: u256);
    fn getUpdatedBoardStatepublic(
        self: @TContractState, tokenboundaccount: ContractAddress
    ) -> u256;
    fn checkWinngstatus(self: @TContractState, token_id: u256) -> u8;
    fn makePuzzle(ref self: TContractState, _board: u256, _depth: u256, _amount: u256);
    fn mintmove(
        ref self: TContractState,
        to: ContractAddress,
        board_id: u256,
        _board: u256,
        encoded_move: u256
    );
    fn mintboard(ref self: TContractState, to: ContractAddress, _board: u256, _depth: u256);
    fn get_encode_tokenId(self: @TContractState, board_id: u256, move_id: u256) -> u256;
    fn get_total_puzzle_supply(self: @TContractState) -> u256;
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


#[starknet::contract]
mod CCNFTS {
    ////////////////////////////////
    // library imports
    ////////////////////////////////
    use core::array::ArrayTrait;
    use core::num::traits::zero::Zero;
    use core::traits::Into;
    use super::IAccountDispatcher;
    use super::IAccountDispatcherTrait;
    use ccnfts::ChessLogic::{
        searchMove, isLegalMove, applyMove, encodeTokenId, calculate_move_enoded
    };
    use starknet::{ContractAddress, get_caller_address, storage::Map};

    use super::IBoardNFT;
    use super::{IERC20Dispatcher, IERC20DispatcherTrait};
    const NAME: felt252 = 0x43434e465453;
    const SYMBOL: felt252 = 0x43434e465453;


    const ADMIN_ADDRESS: felt252 =
        0x004835541Fd87cdDBc3B48Ad08e53FfA1E4D55aB21a46900A969DF326C9276326;
    const VERSION_CODE: u256 = 202311150001001;
    const MAX_SUPPLY: u256 = 100000;
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
        owners: Map::<u256, ContractAddress>,
        balances: Map::<ContractAddress, u256>,
        count: u256, //Total number of NFTs minted
        token_approvals: Map::<u256, ContractAddress>,
        operator_approvals: Map::<(ContractAddress, ContractAddress), bool>,
        ai_hard: Map::<u256, u256>,
        board_mintedstate: Map::<u256, u256>,
        board_currentstate: Map::<u256, u256>,
        MintedAddress: ContractAddress,
        board_amt: Map::<u256, u256>,
        status: Map::<u256, u8>,
        puzzle_allowed_to_play: Map::<u256, bool>,
        board_to_moves: Map::<u256, u256>,
        tokenid_to_uriData: Map::<u256, (u256, u256)>,
        erc20_token: ContractAddress,
        board_puzzle_supply: u256,
        board_creator: Map::<u256, ContractAddress>,
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        PlayMoveEvent: PlayMoveEvent,
        Approval: Approval,
        Transfer: Transfer,
        ApprovalForAll: ApprovalForAll,
        MintBoard: MintBoard
    }

    #[derive(Drop, starknet::Event)]
    struct MintBoard {
        caller: ContractAddress,
        token_id: u256,
    }

    #[derive(Drop, starknet::Event)]
    struct PlayMoveEvent {
        caller: ContractAddress,
        currentBoardState: u256,
        newBoardState: u256,
        token_id_move: u256,
        token_id_board: u256,
    }


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
    fn constructor(
        ref self: ContractState, _minted_Address: ContractAddress, erc20_token: ContractAddress
    ) {
        self.MintedAddress.write(_minted_Address);
        self.erc20_token.write(erc20_token);
    }

    #[generate_trait]
    impl ConfigImpl of ConfigTrait {
        fn initConfig(ref self: ContractState) {}
    }


    #[abi(embed_v0)]
    impl IBNFT of IBoardNFT<ContractState> {
        fn getname(self: @ContractState) -> felt252 {
            'CCNFTS'
        }
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
        fn get_minted_token_amount(self: @ContractState, token_id: u256) -> u256 {
            self.board_amt.read(token_id)
        }

        /// token bound account address so then we get the token id
        fn get_token_Id(self: @ContractState, caller: ContractAddress) -> u256 {
            let account = IAccountDispatcher { contract_address: caller };
            let (_token_contract, token_id) = account.token();
            token_id
        }

        fn get_move_total_supply(self: @ContractState, token_id: u256) -> u256 {
            self.board_to_moves.read(token_id)
        }

        ///@notice Plays a move in the chess game by the user and
        /// responds with an AI move.
        /// The function checks for move legality, applies the player's move,
        /// then determines and applies the AI's move.
        /// @params `_board`: The current state of the chess board represented as a `u256` value.
        /// @params `_move`: The player's move, encoded as a `u256` value.
        /// @params `_depth`: The search depth for AI move calculation (not used directly here but
        /// passed for potential AI move logic).
        /// @params- `tokenId`: A unique identifier for the player's game.
        /// A tuple containing ( u256 , u256 ):
        /// @return The updated chess board state after both the player and AI moves.
        /// @return The best move calculated for the AI.

        fn _play_move_chess(
            ref self: ContractState, _board: u256, _move: u256, _depth: u256, tokenId: u256
        ) -> (u256, u256) {
            // Check if the move is legal and ensure the game status allows for a move.
            // If the move is illegal or the game is not in progress (status != 0), raise an
            // assertion failure.
            if !isLegalMove(_board, _move) || self.status.read(tokenId) != 0 {
                assert!(false, "illegal move");
            }
            // then we have to apply the move
            let mut board = applyMove(_board, _move);
            // After the player's move, determine the AI's best move by calling `searchMove`.
            // The `searchMove` function returns:
            // - `bestMove`: The AI's calculated best move.
            // - `isWhiteCheckmated`: A flag indicating if white is checkmated.
            let (bestMove, isWhiteCheckmated) = searchMove(board, 1);

            // If the AI could not find a move (`bestMove == 0`), the game ends in a draw or the
            // player wins.
            // Update the game status to 1, indicating the game is over.
            if (bestMove == 0) {
                self.status.write(tokenId, 1);
            } else {
                // If the AI found a valid move, apply the AI's move to the board.
                board = applyMove(board, bestMove);

                // Check if the AI has checkmated the player.
                // If white is checkmated, the player has lost, and we update the status to 2 (game
                // over, player lost).
                // This also blocks further moves by the player.
                if (isWhiteCheckmated) {
                    // player have lost
                    self.status.write(tokenId, 2);
                    /// block him so that he cannot able to play the game
                }
            }
            (board, bestMove)
        }
        /// @notice Executes a move in the chess game, updates the board state, and handles token
        /// transfers based on the game outcome.
        /// This function is invoked by a player when they make a move, and it also handles the AI's
        /// response.
        /// @return
        /// - `self`: A reference to the contract state.
        /// - `_move`: The player's move encoded as a `u256` value.
        fn playmove(ref self: ContractState, _move: u256) {
            let caller = get_caller_address(); //  callerfrom ; 
            // through the caller we get the token id
            let tokenId = self.get_token_Id(caller);
            // through the tokenid we found the current board state ;
            let current_board_state = self.board_current_state(tokenId);
            let depth = self.hardness_Depth(tokenId);
            // Perform the player's move and calculate the AI's response by calling
            // `_play_move_chess`.
            // This returns the new board state after the AI's move and the best move made by the
            // AI.
            let (new_chess_board_after_ai, bestMove) = self
                ._play_move_chess(current_board_state, _move, depth, tokenId);

            self.update_board_current_state(tokenId, new_chess_board_after_ai);
            // Ensure that the puzzle (game) is still allowed to be played.
            assert!(self.puzzle_allowed_to_play.read(tokenId), "Puzzle is not allowed to play");
            // Encode the move made by the player and the AI's move into a single encoded value.

            let encoded_move = calculate_move_enoded(1, _move, bestMove);
            // Mint a move token for the caller with the updated chess board state and the encoded
            // move.

            self.mintmove(caller, tokenId, new_chess_board_after_ai, encoded_move);

            // If the player has won the game, they are allowed to withdraw the ERC20 tokens.

            if self.checkWinngstatus(tokenId) == 1 {
                let erc20_dispatcher = IERC20Dispatcher {
                    contract_address: self.erc20_token.read()
                };
                // Transfer the ERC20 token from the minted address to the caller (the winner).

                erc20_dispatcher
                    .transfer_from(
                        self.MintedAddress.read(),
                        caller,
                        self.board_amt.read(tokenId).try_into().unwrap()
                    );
            } // If the AI has won, the minted ERC20 tokens are transferred to the board creator.
            else if self.checkWinngstatus(tokenId) == 2 {
                // Retrieve the board creator's address for the current token ID.
                let board_creator = self.board_creator.read(tokenId);
                let erc20_dispatcher = IERC20Dispatcher {
                    contract_address: self.erc20_token.read()
                };
                erc20_dispatcher
                    .transfer_from(
                        self.MintedAddress.read(),
                        board_creator,
                        self.board_amt.read(tokenId).try_into().unwrap()
                    );
            }
            // Emit an event after the move, logging important game details.
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
        }

        fn getUpdatedBoardStatepublic(
            self: @ContractState, tokenboundaccount: ContractAddress
        ) -> u256 {
            let tokenId = self.get_token_Id(tokenboundaccount);
            let current_board_state = self.board_current_state(tokenId);
            return current_board_state;
        }

        fn checkWinngstatus(self: @ContractState, token_id: u256) -> u8 {
            self.status.read(token_id)
        }

        fn makePuzzle(ref self: ContractState, _board: u256, _depth: u256, _amount: u256) {
            let caller = get_caller_address();
            self.mintboard(caller, _board, _depth);
        }

        fn get_total_puzzle_supply(self: @ContractState) -> u256 {
            self.board_puzzle_supply.read()
        }
        /// Mints a new chess board and assigns it to a user.
        /// This function also initializes the board state, sets AI difficulty, and allows the game
        /// to be played.
        ///
        /// @params:
        /// - `self`: A reference to the contract state.
        /// - `to`: The address of the user who will receive the minted board.
        /// - `_board`: The initial board state represented as a `u256` value.
        /// - `_depth`: The AI difficulty level (search depth) for this board.

        fn mintboard(ref self: ContractState, to: ContractAddress, _board: u256, _depth: u256) {
            // here the tokenID would be the boardSupply
            let board_supply = self.board_puzzle_supply.read();
            // Ensure the number of minted boards doesn't exceed 64. If it does, the minting process
            // is halted.
            assert!(board_supply < 64, "Board supply is full");
            let total_supply = self.count.read();
            // Generate a unique token ID using the board supply value (board number) and initialize
            // the move count to 0.
            let token_id = encodeTokenId(board_supply, 0);
            // Safely mint the token and assign ownership to the recipient (specified by `to`).
            self._safe_mint(to, token_id);
            // Set the creator of the board (the `to` address) for this specific token ID.
            self.board_creator.write(token_id, to);
            // Allow the puzzle (game) to be played by setting the respective flag to `true`.
            self.puzzle_allowed_to_play.write(token_id, true);
            // Store the initial board state and move number in the `tokenid_to_uriData` mapping.
            // The move number is initialized to 0 (indicating no moves have been made yet).
            self.tokenid_to_uriData.write(token_id, (_board, 0));
            // Write the AI difficulty (search depth) for the token ID (board).
            self.ai_hard.write(token_id, _depth);
            // Store the minted board's state in the `board_mintedstate` mapping, associating it
            // with the token ID.
            self.board_mintedstate.write(token_id, _board);
            // Set the current board state (same as the initial board state) in the
            // `board_currentstate` mapping.
            self.board_currentstate.write(token_id, _board);
            // Increment the board supply counter by 1 to account for the newly minted board.
            self.board_puzzle_supply.write(board_supply + 1);
            self.count.write(total_supply + 1);
            // Emit a `MintBoard` event, logging the caller and the token ID for the newly minted
            // board.
            self.emit(MintBoard { caller: to, token_id: token_id });
        }
        fn get_encode_tokenId(self: @ContractState, board_id: u256, move_id: u256) -> u256 {
            encodeTokenId(board_id, move_id)
        }

        /// Mints a new move for an existing chess board.
        /// This function assigns a unique token ID to the move and updates the board's state
        /// accordingly.
        ///
        /// @params :
        /// - `self`: A reference to the contract state.
        /// - `to`: The address of the player or recipient who made the move.
        /// - `board_id`: The ID of the chess board to which the move is applied.
        /// - `_board`: The updated board state after the move.
        /// - `encoded_move`: The move encoded as a `u256` value.
        fn mintmove(
            ref self: ContractState,
            to: ContractAddress,
            board_id: u256,
            _board: u256,
            encoded_move: u256
        ) {
            let total_supply = self.count.read();
            let move_id_supply = self.board_to_moves.read(board_id) + 1;
            // Ensure that no more than 64 moves can be made for any given board.
            assert!(move_id_supply < 64, "not more move is possible");
            let token_id_encode = encodeTokenId(board_id, move_id_supply);
            self._safe_mint(to, token_id_encode);
            // (Optional step, currently commented out): Set the token URI for the newly minted move
            // token.
            // The URI can represent the board state after the move, which would be stored
            // off-chain.
            // let board: felt252 = _board.try_into().unwrap();
            // self._set_token_uri(token_id_encode , board );
            // Update the move supply for the board by writing the new move count to
            // `board_to_moves`.
            self.board_to_moves.write(board_id, move_id_supply);
            // Store the new board state and the encoded move in `tokenid_to_uriData` for the newly
            // minted move token.
            self.tokenid_to_uriData.write(token_id_encode, (_board, encoded_move));
            // Increment the total token supply by 1 to reflect the newly minted move token.
            self.count.write(total_supply + 1);
        }
    }


    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    #[abi(per_item)]
    #[generate_trait]
    impl IERC721Impl of IERC721Trait {
        fn name(self: @ContractState) -> felt252 {
            NAME
        }
        fn symbol(self: @ContractState) -> felt252 {
            SYMBOL
        }
        fn tokenURI(self: @ContractState, token_id: u256) -> Array<felt252> {
            assert(self._exists(token_id), 'ERC721: invalid token ID');

            let mut link = ArrayTrait::new();
            let (board, encodemove) = self.tokenid_to_uriData.read(token_id);

            let board_felt: felt252 = board.try_into().unwrap();
            let move_felt: felt252 = encodemove.try_into().unwrap();

            if encodemove != 0 {
                link.append(board_felt);
                link.append(move_felt);
            }
            link.append(board_felt);

            return link;
        }
        fn token_uri(self: @ContractState, token_id: u256) -> Array<felt252> {
            self.tokenURI(token_id)
        }
        // Contract-level metadata - https://docs.opensea.io/docs/contract-level-metadata
        // NFT marketplaces use contractURI json file to get information about your collection
        fn contractURI(self: @ContractState) -> Array<felt252> {
            //In this example we use the json file of the first NFT in the collection, but you
            //should customize it to return the correct file
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
            // #Todo - Check that the receiving address is a contract address and that it supports
            // INTERFACE_ERC721_RECEIVER
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
    }


    #[abi(per_item)]
    #[generate_trait]
    impl ERC721HelperImpl of ERC721HelperTrait {
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

            // todo zero address error
            // let addressZero: ContractAddress = zero();
            // // remove previously made approvals
            // self.token_approvals.write(token_id, from);

            // increase balance of to address, decrease balance of from address
            self.balances.write(from, self.balances.read(from) - 1);
            self.balances.write(to, self.balances.read(to) + 1);
            self.owners.write(token_id, to);
            self.emit(Transfer { from: from, to: to, token_id: token_id });
        }

        fn _safe_mint(ref self: ContractState, to: ContractAddress, token_id: u256) {
            self.owners.write(token_id, to);
            // todo zero address error .
        // let addressZero: ContractAddress = zero();
        // self.emit(Transfer { from: addressZero, to: to, token_id: token_id });
        }
    }

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

        fn _felt252ToAddress(self: @ContractState, input: felt252) -> ContractAddress {
            input.try_into().unwrap()
        }
    }
}
