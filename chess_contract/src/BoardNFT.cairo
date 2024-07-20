// create the board nft  , with depth 
// create it token bound account . 
// connect it with the this nft contract and execute the call on this contract 
// only the person who has the token nft can able to withdraw the token . 
// using the predefined contract and the ai can only able to mint the token .  

#[starknet::interface]
pub trait IBoardNFT<TContractState> {
    fn getname(self: @TContractState) -> felt252;
    fn getsymbol(self: @TContractState) -> felt252;
    fn hardness_Depth(self: @TContractState, token_id: u256) -> u256;
    fn board_minted_state(self: @TContractState, token_id: u256) -> u256;

    fn board_current_state(self: @TContractState, token_id: u256) -> u256;
    fn update_board_current_state(ref self: TContractState, token_id: u256, new_state_board: u256);
}


#[starknet::contract]
mod BoardNFT {
    ////////////////////////////////
    // library imports
    ////////////////////////////////
    use starknet::ContractAddress;
    use starknet::get_caller_address;
    use starknet::get_contract_address;
    use core::array::ArrayTrait;
    use core::nullable::match_nullable;
    use core::zeroable::Zeroable;
    use core::traits::Into;
    use super::IBoardNFT;


    const NAME: felt252 = 'BoardNFT';


    // Your NFT's Token Symbol as Bytes. eg: "MDN" -> 0x4d444e
    const SYMBOL: felt252 = 'BNFT';

    const BASE_URI_PART_1: felt252 = 0x697066733a2f2f516d505a6e336f5967486f676343643835;
    const BASE_URI_PART_2: felt252 = 0x697251685033794d61446139387878683654653550426e53;
    const BASE_URI_PART_3: felt252 = 0x61626859722f;


    const MAX_SUPPLY: u256 = 10;
    // only 10 board initially 

    // this is import in this 
    const ADMIN_ADDRESS: felt252 =
        0x004835541Fd87cdDBc3B48Ad08e53FfA1E4D55aB21a46900A969DF326C9276326;

    const VERSION_CODE: u256 = 202311150001001; /// YYYYMMDD000NONCE
    //# Const Default Init End #

    // ERC 165 interface codes
    const INTERFACE_ERC165: felt252 = 0x01ffc9a7;
    const INTERFACE_ERC721: felt252 = 0x80ac58cd;
    const INTERFACE_ERC721_METADATA: felt252 = 0x5b5e139f;
    const INTERFACE_ERC721_RECEIVER: felt252 = 0x150b7a02;

    ////////////////////////////////
    // storage variables
    ////////////////////////////////
    #[storage]
    struct Storage {
        owners: LegacyMap::<u256, ContractAddress>,
        balances: LegacyMap::<ContractAddress, u256>,
        token_approvals: LegacyMap::<u256, ContractAddress>,
        operator_approvals: LegacyMap::<(ContractAddress, ContractAddress), bool>,
        count: u256, //Total number of NFTs minted
        ////////////////for the chess 

        //we have to make the tokenID = > u256 mapping 
        ai_hard: LegacyMap::<u256, u256>,
        board_mintedstate: LegacyMap::<u256, u256>,
        //this may or may not be usefull but now keep it there 
        board_currentstate: LegacyMap::<u256, u256>,
        // just for the now 
        // this is the amount of token locked in this contract
        amountlocked: LegacyMap::<u256, u256>,
        MintedAddress: ContractAddress,
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        Approval: Approval,
        Transfer: Transfer,
        ApprovalForAll: ApprovalForAll
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


    #[derive(Drop, starknet::Event)]
    struct ApprovalForAll {
        owner: ContractAddress,
        operator: ContractAddress,
        approved: bool
    }


    #[constructor]
    fn constructor(ref self: ContractState, _minted_Address: ContractAddress) {
        self.MintedAddress.write(_minted_Address);
        self.count.write(0);
        self.initConfig();
    }

    #[generate_trait]
    impl ConfigImpl of ConfigTrait {
        fn initConfig(
            ref self: ContractState
        ) { //Configure the contract based on parameters when deploying the contract if needed
            // i think this is the best place to mint the 10 nft as soon as it has been contract ; 
            // so mint the board nft 

            self.makePuzzle(0x3256230011111100000000000000000099999900BCDECB000000001, 3);
            self.makePuzzle(0x3256230010111100000000000190000099099900BCDECB000000001, 4);
            self.makePuzzle(0x3256230010101100000100009190000009099900BCDECB000000001, 5);
            self.makePuzzle(0x3256230010100100000100009199100009009900BCDECB000000001, 4);
            self.makePuzzle(0x3256230010100100000000009199100009009000BCDECB000000001, 5);
            self.makePuzzle(0x3256230010000100001000009199D00009009000BC0ECB000000001, 6);
            self.makePuzzle(0x32502300100061000010000091990000090D9000BC0ECB000000001, 7);
            self.makePuzzle(0x325023001006010000100D009199000009009000BC0ECB000000001, 6);
            self.makePuzzle(0x305023001006010000100D0091992000090C9000B00ECB000000001, 8);
            self.makePuzzle(0x3256230011111100000000000000000099999900BCDECB000000001, 9);
        }
    }


    #[abi(embed_v0)]
    impl IBNFT of IBoardNFT<ContractState> {
        // get_name function returns NFT's name
        fn getname(self: @ContractState) -> felt252 {
            NAME
        }

        // get_symbol function returns NFT's token symbol
        fn getsymbol(self: @ContractState) -> felt252 {
            SYMBOL
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
    }


    #[external(v0)]
    #[generate_trait]
    impl IERC721Impl of IERC721Trait {
        // get_name function returns NFT's name
        fn name(self: @ContractState) -> felt252 {
            NAME
        }

        // get_symbol function returns NFT's token symbol
        fn symbol(self: @ContractState) -> felt252 {
            SYMBOL
        }

        // they to submit the some of the stark token and get chess token locked in this contract 
        // let take some hold the token deposition scene ok ;

        fn makePuzzle(ref self: ContractState, _board: u256, _depth: u256) {
            // want to min this board 
            // setting the depth also means what hard it would be 
            // if the player won then the token which is present in this nft will be gaven to the player  ; 
            // token is transfered to the tokenbound account 
            // mint nft 
            // deploy the token bound account 
            // transfer the chess token to the token bound account
            // make sure when the chess state is of check mate by the player then only he can able to withdraw the token 

            let token_id = self.count.read();
            let _amount = 20;
            self.amountlocked.write(token_id, _amount);
            self.ai_hard.write(token_id, _depth);
            self.board_mintedstate.write(token_id, _board);
            self.board_currentstate.write(token_id, _board);
            self._safe_mint(self.MintedAddress.read(), token_id);
            self.count.write(token_id + 1);
        }


        fn tokenURI(self: @ContractState, token_id: u256) -> Array<felt252> {
            let tokenFile: felt252 = token_id.try_into().unwrap();
            let mut link = self._getBaseURI(); //BaseURI
            //# Convert int id into Cairo ShortString(bytes) #
            // revert number   12345 -> 54321, 1000 -> 0001
            let mut revNumber: u256 = 0;
            let mut currentInt: u256 = token_id * 10 + 1;
            loop {
                revNumber = revNumber * 10 + currentInt % 10;
                currentInt = currentInt / 10_u256;
                if currentInt < 1 {
                    break;
                };
            };
            //split chart
            loop {
                let lastChar: u256 = revNumber % 10_u256;
                link.append(self._intToChar(lastChar)); // BaseURI + TOKEN_ID
                revNumber = revNumber / 10_u256;
                if revNumber < 2 { //~ = 1
                    break;
                };
            };
            link.append(0x2e6a736f6e); // BaseURI + TOKEN_ID + .json
            link
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

