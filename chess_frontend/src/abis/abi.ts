export const ABI = [
  {
    "name": "IBNFT",
    "type": "impl",
    "interface_name": "ccnfts::MIX::IBoardNFT"
  },
  {
    "name": "core::integer::u256",
    "type": "struct",
    "members": [
      {
        "name": "low",
        "type": "core::integer::u128"
      },
      {
        "name": "high",
        "type": "core::integer::u128"
      }
    ]
  },
  {
    "name": "ccnfts::MIX::IBoardNFT",
    "type": "interface",
    "items": [
      {
        "name": "getname",
        "type": "function",
        "inputs": [],
        "outputs": [
          {
            "type": "core::felt252"
          }
        ],
        "state_mutability": "view"
      },
      {
        "name": "getsymbol",
        "type": "function",
        "inputs": [],
        "outputs": [
          {
            "type": "core::felt252"
          }
        ],
        "state_mutability": "view"
      },
      {
        "name": "hardness_Depth",
        "type": "function",
        "inputs": [
          {
            "name": "token_id",
            "type": "core::integer::u256"
          }
        ],
        "outputs": [
          {
            "type": "core::integer::u256"
          }
        ],
        "state_mutability": "view"
      },
      {
        "name": "board_minted_state",
        "type": "function",
        "inputs": [
          {
            "name": "token_id",
            "type": "core::integer::u256"
          }
        ],
        "outputs": [
          {
            "type": "core::integer::u256"
          }
        ],
        "state_mutability": "view"
      },
      {
        "name": "board_current_state",
        "type": "function",
        "inputs": [
          {
            "name": "token_id",
            "type": "core::integer::u256"
          }
        ],
        "outputs": [
          {
            "type": "core::integer::u256"
          }
        ],
        "state_mutability": "view"
      },
      {
        "name": "update_board_current_state",
        "type": "function",
        "inputs": [
          {
            "name": "token_id",
            "type": "core::integer::u256"
          },
          {
            "name": "new_state_board",
            "type": "core::integer::u256"
          }
        ],
        "outputs": [],
        "state_mutability": "external"
      },
      {
        "name": "get_minted_token_amount",
        "type": "function",
        "inputs": [
          {
            "name": "token_id",
            "type": "core::integer::u256"
          }
        ],
        "outputs": [
          {
            "type": "core::integer::u256"
          }
        ],
        "state_mutability": "view"
      },
      {
        "name": "get_token_Id",
        "type": "function",
        "inputs": [
          {
            "name": "caller",
            "type": "core::starknet::contract_address::ContractAddress"
          }
        ],
        "outputs": [
          {
            "type": "core::integer::u256"
          }
        ],
        "state_mutability": "view"
      },
      {
        "name": "_play_move_chess",
        "type": "function",
        "inputs": [
          {
            "name": "_board",
            "type": "core::integer::u256"
          },
          {
            "name": "_move",
            "type": "core::integer::u256"
          },
          {
            "name": "_depth",
            "type": "core::integer::u256"
          },
          {
            "name": "tokenId",
            "type": "core::integer::u256"
          }
        ],
        "outputs": [
          {
            "type": "(core::integer::u256, core::integer::u256)"
          }
        ],
        "state_mutability": "external"
      },
      {
        "name": "playmove",
        "type": "function",
        "inputs": [
          {
            "name": "_move",
            "type": "core::integer::u256"
          }
        ],
        "outputs": [],
        "state_mutability": "external"
      },
      {
        "name": "getUpdatedBoardStatepublic",
        "type": "function",
        "inputs": [
          {
            "name": "tokenboundaccount",
            "type": "core::starknet::contract_address::ContractAddress"
          }
        ],
        "outputs": [
          {
            "type": "core::integer::u256"
          }
        ],
        "state_mutability": "view"
      },
      {
        "name": "checkWinngstatus",
        "type": "function",
        "inputs": [
          {
            "name": "token_id",
            "type": "core::integer::u256"
          }
        ],
        "outputs": [
          {
            "type": "core::integer::u8"
          }
        ],
        "state_mutability": "view"
      },
      {
        "name": "makePuzzle",
        "type": "function",
        "inputs": [
          {
            "name": "_board",
            "type": "core::integer::u256"
          },
          {
            "name": "_depth",
            "type": "core::integer::u256"
          },
          {
            "name": "_amount",
            "type": "core::integer::u256"
          }
        ],
        "outputs": [],
        "state_mutability": "external"
      }
    ]
  },
  {
    "name": "name",
    "type": "function",
    "inputs": [],
    "outputs": [
      {
        "type": "core::felt252"
      }
    ],
    "state_mutability": "view"
  },
  {
    "name": "symbol",
    "type": "function",
    "inputs": [],
    "outputs": [
      {
        "type": "core::felt252"
      }
    ],
    "state_mutability": "view"
  },
  {
    "name": "tokenURI",
    "type": "function",
    "inputs": [
      {
        "name": "token_id",
        "type": "core::integer::u256"
      }
    ],
    "outputs": [
      {
        "type": "core::array::Array::<core::felt252>"
      }
    ],
    "state_mutability": "view"
  },
  {
    "name": "token_uri",
    "type": "function",
    "inputs": [
      {
        "name": "token_id",
        "type": "core::integer::u256"
      }
    ],
    "outputs": [
      {
        "type": "core::array::Array::<core::felt252>"
      }
    ],
    "state_mutability": "view"
  },
  {
    "name": "contractURI",
    "type": "function",
    "inputs": [],
    "outputs": [
      {
        "type": "core::array::Array::<core::felt252>"
      }
    ],
    "state_mutability": "view"
  },
  {
    "name": "contract_uri",
    "type": "function",
    "inputs": [],
    "outputs": [
      {
        "type": "core::array::Array::<core::felt252>"
      }
    ],
    "state_mutability": "view"
  },
  {
    "name": "maxSupply",
    "type": "function",
    "inputs": [],
    "outputs": [
      {
        "type": "core::integer::u256"
      }
    ],
    "state_mutability": "view"
  },
  {
    "name": "totalSupply",
    "type": "function",
    "inputs": [],
    "outputs": [
      {
        "type": "core::integer::u256"
      }
    ],
    "state_mutability": "view"
  },
  {
    "name": "total_supply",
    "type": "function",
    "inputs": [],
    "outputs": [
      {
        "type": "core::integer::u256"
      }
    ],
    "state_mutability": "view"
  },
  {
    "name": "core::bool",
    "type": "enum",
    "variants": [
      {
        "name": "False",
        "type": "()"
      },
      {
        "name": "True",
        "type": "()"
      }
    ]
  },
  {
    "name": "supportsInterface",
    "type": "function",
    "inputs": [
      {
        "name": "interfaceID",
        "type": "core::felt252"
      }
    ],
    "outputs": [
      {
        "type": "core::bool"
      }
    ],
    "state_mutability": "view"
  },
  {
    "name": "supports_interface",
    "type": "function",
    "inputs": [
      {
        "name": "interfaceID",
        "type": "core::felt252"
      }
    ],
    "outputs": [
      {
        "type": "core::bool"
      }
    ],
    "state_mutability": "view"
  },
  {
    "name": "balanceOf",
    "type": "function",
    "inputs": [
      {
        "name": "account",
        "type": "core::starknet::contract_address::ContractAddress"
      }
    ],
    "outputs": [
      {
        "type": "core::integer::u256"
      }
    ],
    "state_mutability": "view"
  },
  {
    "name": "balance_of",
    "type": "function",
    "inputs": [
      {
        "name": "account",
        "type": "core::starknet::contract_address::ContractAddress"
      }
    ],
    "outputs": [
      {
        "type": "core::integer::u256"
      }
    ],
    "state_mutability": "view"
  },
  {
    "name": "mintboard",
    "type": "function",
    "inputs": [
      {
        "name": "to",
        "type": "core::starknet::contract_address::ContractAddress"
      },
      {
        "name": "_board",
        "type": "core::integer::u256"
      },
      {
        "name": "_depth",
        "type": "core::integer::u256"
      }
    ],
    "outputs": [],
    "state_mutability": "external"
  },
  {
    "name": "get_encode_tokenId",
    "type": "function",
    "inputs": [
      {
        "name": "board_id",
        "type": "core::integer::u256"
      },
      {
        "name": "move_id",
        "type": "core::integer::u256"
      }
    ],
    "outputs": [
      {
        "type": "core::integer::u256"
      }
    ],
    "state_mutability": "view"
  },
  {
    "name": "mintmove",
    "type": "function",
    "inputs": [
      {
        "name": "to",
        "type": "core::starknet::contract_address::ContractAddress"
      },
      {
        "name": "board_id",
        "type": "core::integer::u256"
      },
      {
        "name": "_board",
        "type": "core::integer::u256"
      },
      {
        "name": "encoded_move",
        "type": "core::integer::u256"
      }
    ],
    "outputs": [],
    "state_mutability": "external"
  },
  {
    "name": "ownerOf",
    "type": "function",
    "inputs": [
      {
        "name": "token_id",
        "type": "core::integer::u256"
      }
    ],
    "outputs": [
      {
        "type": "core::starknet::contract_address::ContractAddress"
      }
    ],
    "state_mutability": "view"
  },
  {
    "name": "owner_of",
    "type": "function",
    "inputs": [
      {
        "name": "token_id",
        "type": "core::integer::u256"
      }
    ],
    "outputs": [
      {
        "type": "core::starknet::contract_address::ContractAddress"
      }
    ],
    "state_mutability": "view"
  },
  {
    "name": "getApproved",
    "type": "function",
    "inputs": [
      {
        "name": "token_id",
        "type": "core::integer::u256"
      }
    ],
    "outputs": [
      {
        "type": "core::starknet::contract_address::ContractAddress"
      }
    ],
    "state_mutability": "view"
  },
  {
    "name": "get_approved",
    "type": "function",
    "inputs": [
      {
        "name": "token_id",
        "type": "core::integer::u256"
      }
    ],
    "outputs": [
      {
        "type": "core::starknet::contract_address::ContractAddress"
      }
    ],
    "state_mutability": "view"
  },
  {
    "name": "isApprovedForAll",
    "type": "function",
    "inputs": [
      {
        "name": "owner",
        "type": "core::starknet::contract_address::ContractAddress"
      },
      {
        "name": "operator",
        "type": "core::starknet::contract_address::ContractAddress"
      }
    ],
    "outputs": [
      {
        "type": "core::bool"
      }
    ],
    "state_mutability": "view"
  },
  {
    "name": "is_approved_for_all",
    "type": "function",
    "inputs": [
      {
        "name": "owner",
        "type": "core::starknet::contract_address::ContractAddress"
      },
      {
        "name": "operator",
        "type": "core::starknet::contract_address::ContractAddress"
      }
    ],
    "outputs": [
      {
        "type": "core::bool"
      }
    ],
    "state_mutability": "view"
  },
  {
    "name": "approve",
    "type": "function",
    "inputs": [
      {
        "name": "to",
        "type": "core::starknet::contract_address::ContractAddress"
      },
      {
        "name": "token_id",
        "type": "core::integer::u256"
      }
    ],
    "outputs": [],
    "state_mutability": "external"
  },
  {
    "name": "setApprovalForAll",
    "type": "function",
    "inputs": [
      {
        "name": "operator",
        "type": "core::starknet::contract_address::ContractAddress"
      },
      {
        "name": "approved",
        "type": "core::bool"
      }
    ],
    "outputs": [],
    "state_mutability": "external"
  },
  {
    "name": "set_approval_for_all",
    "type": "function",
    "inputs": [
      {
        "name": "operator",
        "type": "core::starknet::contract_address::ContractAddress"
      },
      {
        "name": "approved",
        "type": "core::bool"
      }
    ],
    "outputs": [],
    "state_mutability": "external"
  },
  {
    "name": "transferFrom",
    "type": "function",
    "inputs": [
      {
        "name": "from",
        "type": "core::starknet::contract_address::ContractAddress"
      },
      {
        "name": "to",
        "type": "core::starknet::contract_address::ContractAddress"
      },
      {
        "name": "token_id",
        "type": "core::integer::u256"
      }
    ],
    "outputs": [],
    "state_mutability": "external"
  },
  {
    "name": "core::array::Span::<core::felt252>",
    "type": "struct",
    "members": [
      {
        "name": "snapshot",
        "type": "@core::array::Array::<core::felt252>"
      }
    ]
  },
  {
    "name": "safeTransferFrom",
    "type": "function",
    "inputs": [
      {
        "name": "from",
        "type": "core::starknet::contract_address::ContractAddress"
      },
      {
        "name": "to",
        "type": "core::starknet::contract_address::ContractAddress"
      },
      {
        "name": "token_id",
        "type": "core::integer::u256"
      },
      {
        "name": "data",
        "type": "core::array::Span::<core::felt252>"
      }
    ],
    "outputs": [],
    "state_mutability": "external"
  },
  {
    "name": "safe_transfer_from",
    "type": "function",
    "inputs": [
      {
        "name": "from",
        "type": "core::starknet::contract_address::ContractAddress"
      },
      {
        "name": "to",
        "type": "core::starknet::contract_address::ContractAddress"
      },
      {
        "name": "token_id",
        "type": "core::integer::u256"
      },
      {
        "name": "data",
        "type": "core::array::Span::<core::felt252>"
      }
    ],
    "outputs": [],
    "state_mutability": "external"
  },
  {
    "name": "airdrop",
    "type": "function",
    "inputs": [
      {
        "name": "to",
        "type": "core::starknet::contract_address::ContractAddress"
      },
      {
        "name": "amount",
        "type": "core::integer::u256"
      }
    ],
    "outputs": [],
    "state_mutability": "external"
  },
  {
    "name": "batchAirdrop",
    "type": "function",
    "inputs": [
      {
        "name": "addressArr",
        "type": "core::array::Array::<core::starknet::contract_address::ContractAddress>"
      }
    ],
    "outputs": [],
    "state_mutability": "external"
  },
  {
    "name": "svgimage",
    "type": "function",
    "inputs": [
      {
        "name": "_tokenId",
        "type": "core::integer::u256"
      }
    ],
    "outputs": [
      {
        "type": "core::array::Array::<core::felt252>"
      }
    ],
    "state_mutability": "view"
  },
  {
    "name": "_assert_admin",
    "type": "function",
    "inputs": [],
    "outputs": [],
    "state_mutability": "view"
  },
  {
    "name": "_assert_mintable",
    "type": "function",
    "inputs": [
      {
        "name": "max_token_id",
        "type": "core::integer::u256"
      }
    ],
    "outputs": [],
    "state_mutability": "view"
  },
  {
    "name": "_exists",
    "type": "function",
    "inputs": [
      {
        "name": "token_id",
        "type": "core::integer::u256"
      }
    ],
    "outputs": [
      {
        "type": "core::bool"
      }
    ],
    "state_mutability": "view"
  },
  {
    "name": "_is_approved_or_owner",
    "type": "function",
    "inputs": [
      {
        "name": "spender",
        "type": "core::starknet::contract_address::ContractAddress"
      },
      {
        "name": "token_id",
        "type": "core::integer::u256"
      }
    ],
    "outputs": [
      {
        "type": "core::bool"
      }
    ],
    "state_mutability": "view"
  },
  {
    "name": "_transfer",
    "type": "function",
    "inputs": [
      {
        "name": "from",
        "type": "core::starknet::contract_address::ContractAddress"
      },
      {
        "name": "to",
        "type": "core::starknet::contract_address::ContractAddress"
      },
      {
        "name": "token_id",
        "type": "core::integer::u256"
      }
    ],
    "outputs": [],
    "state_mutability": "external"
  },
  {
    "name": "_safe_mint",
    "type": "function",
    "inputs": [
      {
        "name": "to",
        "type": "core::starknet::contract_address::ContractAddress"
      },
      {
        "name": "token_id",
        "type": "core::integer::u256"
      }
    ],
    "outputs": [],
    "state_mutability": "external"
  },
  {
    "name": "_getBaseURI",
    "type": "function",
    "inputs": [],
    "outputs": [
      {
        "type": "core::array::Array::<core::felt252>"
      }
    ],
    "state_mutability": "view"
  },
  {
    "name": "versionCode",
    "type": "function",
    "inputs": [],
    "outputs": [
      {
        "type": "core::integer::u256"
      }
    ],
    "state_mutability": "view"
  },
  {
    "name": "constructor",
    "type": "constructor",
    "inputs": [
      {
        "name": "_minted_Address",
        "type": "core::starknet::contract_address::ContractAddress"
      },
      {
        "name": "erc20_token",
        "type": "core::starknet::contract_address::ContractAddress"
      }
    ]
  },
  {
    "kind": "struct",
    "name": "ccnfts::MIX::MIX::PlayMoveEvent",
    "type": "event",
    "members": [
      {
        "kind": "data",
        "name": "caller",
        "type": "core::starknet::contract_address::ContractAddress"
      },
      {
        "kind": "data",
        "name": "currentBoardState",
        "type": "core::integer::u256"
      },
      {
        "kind": "data",
        "name": "newBoardState",
        "type": "core::integer::u256"
      },
      {
        "kind": "data",
        "name": "token_id_move",
        "type": "core::integer::u256"
      },
      {
        "kind": "data",
        "name": "token_id_board",
        "type": "core::integer::u256"
      }
    ]
  },
  {
    "kind": "struct",
    "name": "ccnfts::MIX::MIX::Approval",
    "type": "event",
    "members": [
      {
        "kind": "data",
        "name": "owner",
        "type": "core::starknet::contract_address::ContractAddress"
      },
      {
        "kind": "data",
        "name": "to",
        "type": "core::starknet::contract_address::ContractAddress"
      },
      {
        "kind": "data",
        "name": "token_id",
        "type": "core::integer::u256"
      }
    ]
  },
  {
    "kind": "struct",
    "name": "ccnfts::MIX::MIX::Transfer",
    "type": "event",
    "members": [
      {
        "kind": "data",
        "name": "from",
        "type": "core::starknet::contract_address::ContractAddress"
      },
      {
        "kind": "data",
        "name": "to",
        "type": "core::starknet::contract_address::ContractAddress"
      },
      {
        "kind": "data",
        "name": "token_id",
        "type": "core::integer::u256"
      }
    ]
  },
  {
    "kind": "struct",
    "name": "ccnfts::MIX::MIX::ApprovalForAll",
    "type": "event",
    "members": [
      {
        "kind": "data",
        "name": "owner",
        "type": "core::starknet::contract_address::ContractAddress"
      },
      {
        "kind": "data",
        "name": "operator",
        "type": "core::starknet::contract_address::ContractAddress"
      },
      {
        "kind": "data",
        "name": "approved",
        "type": "core::bool"
      }
    ]
  },
  {
    "kind": "enum",
    "name": "ccnfts::MIX::MIX::Event",
    "type": "event",
    "variants": [
      {
        "kind": "nested",
        "name": "PlayMoveEvent",
        "type": "ccnfts::MIX::MIX::PlayMoveEvent"
      },
      {
        "kind": "nested",
        "name": "Approval",
        "type": "ccnfts::MIX::MIX::Approval"
      },
      {
        "kind": "nested",
        "name": "Transfer",
        "type": "ccnfts::MIX::MIX::Transfer"
      },
      {
        "kind": "nested",
        "name": "ApprovalForAll",
        "type": "ccnfts::MIX::MIX::ApprovalForAll"
      }
    ]
  }
] as const ; 