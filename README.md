# CCNFTs 


## CCNFTs - Revolutionizing ERC20 and ERC721 TokenoEconomics by AI Blockchain Gaming with NFT-Embedded Chess

CCNFTs is revolutionizing the gaming world on the blockchain with a thrilling vision for the future. Imagine starting with classic games and earning NFTs, then transitioning to ON-NFT games where your entire gaming experience is encapsulated within an NFT. Dive into the world of challenging chess, where you can play against AI at the difficulty level you want. Each move you make not only impacts the game but mints a new chessboard with your classic move in the TBA account, ensuring every move is meticulously verified and recorded. Witness the excitement of every move. Winning a game earns you prestigious Chess Tokens, while losing results in minting tokens for the challenge creator. This groundbreaking approach intertwines ERC20 and ERC721 tokens, creating a dynamic and interconnected economy that boosts demand and value for both, opening doors to an exhilarating new tokenomics landscape.


## Features

**CCNFTs** is set to transform the blockchain gaming landscape with its groundbreaking approach. Here’s what makes it exceptional:

1. **Innovative Gaming Experience**: Begin with classic games and earn NFTs, then move to on-chain games where the entire experience is encapsulated in NFTs. This creates a seamless integration of gaming and blockchain technology.

2. **Dynamic Chess with AI**: Engage in a challenging chess game where you can adjust the AI difficulty to suit your skill level. Every move you make has a direct impact on the game and is meticulously recorded.

3. **On-Chain Move Tracking**: Each move you make mints a new chessboard in the TBA account, ensuring that every move is verified and recorded transparently. This creates a unique, verifiable history of your gameplay.

4. **Token Rewards System**: Winning a game earns you prestigious Chess Tokens, while losing results in minting tokens for the challenge creator. This creates a dynamic tokenomics model where ERC20 and ERC721 tokens are intricately linked, boosting demand and value for both.

## Chess : Technical Details

### Piece Representation

Each chess piece is represented using 4 bits:

- **First bit**: Denotes the color (0 for black, 1 for white)
- **Last 3 bits**: Denotes the type of piece

| Bits | # | Type   |
|------|---|--------|
| 000  | 0 | Empty  |
| 001  | 1 | Pawn   |
| 010  | 2 | Bishop |
| 011  | 3 | Rook   |
| 100  | 4 | Knight |
| 101  | 5 | Queen  |
| 110  | 6 | King   |

### Board Representation

The chessboard is a 6x6 grid bit-packed into a single `uint256`. To manage the board efficiently: 
```board : u256 = 0x3256230011111100000000000000000099999900BCDECB000000001 ```

```0 0 0 0 0 0 0 0 
0 3 2 5 6 2 3 0
0 1 1 1 1 1 1 0
0 0 0 0 0 0 0 0
0 0 0 0 0 0 0 0
0 9 9 9 9 9 9 0 
0 B C D E C B 0
0 0 0 0 0 0 0 1 

Binary Representation:

0000 0000 0000 0000 0000 0000 0000 0000
0000 0011 0010 0101 0110 0010 0011 0000
0000 0001 0001 0001 0001 0001 0001 0000
0000 0000 0000 0000 0000 0000 0000 0000
0000 0000 0000 0000 0000 0000 0000 0000
0000 1001 1001 1001 1001 1001 1001 0000
0000 1011 1100 1101 1110 1100 1011 0000
0000 0000 0000 0000 0000 0000 0000 0001

Decimal Representation:

0 0 0 0 0 0 0 0
0 ♜ ♝ ♛ ♚ ♝ ♜ 0
0 ♟ ♟ ♟ ♟ ♟ ♟ 0
0 · · · · · · 0
0 · · · · · · 0
0 ♙ ♙ ♙ ♙ ♙ ♙ 0
0 ♖ ♘ ♕ ♔ ♘ ♖ 0
0 0 0 0 0 0 0 0
```

### Player Turn Logic

The current player is determined using the following logic:
- `BOARD & 1 == 1`: It is your turn to play (the player).
- `BOARD & 1 == 0`: It is the AI's turn to play.


- **Bit-Shifts and Masks**: Each piece is 4 bits, and the board positions are accessed via bit shifts and masks instead of array indices.
- **Boundary Rows/Columns**: The top/bottom rows and left/right columns are used as sentinel values for efficient boundary validation. These rows and columns do not contain pieces but are used to determine the player's turn (0 for black, 1 for white).
### Move Representation
Each move is encoded using 12 bits:
- **First 6 bits**: The index from which the piece is moving
- **Last 6 bits**: The index to which the piece is moving
**Example**: A move encoded as `1243` represents a move from index 19 to 27 (binary representation `1243 = (19 << 6) | 27`).


### AI Implementation

We use the Negamax algorithm for the AI implementation.

## Limitations and Challenges

1. Some libraries are not yet implemented for `uint256`.
2. AI implementation is somewhat challenging.
3. The difficulty of the AI depends on the depth; due to the limitation of the number of computational steps on StarkNet, increasing the depth may exceed the gas limit.
4. Fully on-chain NFTs, such as base64-encoded SVG token URLs, can have very long lengths, making it difficult for Argent/Brave wallets to display your NFTs correctly.

## How I Overcame the Challenges

1. I have created some libraries for our own use and will soon make them well-tested and release them.
2. I focused on understanding the algorithm and implementing a minimal but effective approach.
3. We have currently set the depth to 1 to keep the number of computations within limits.
4. For now, I have created a personal dashboard where anyone can see their NFT holdings.

## Files and Structure

- **chess_test.cairo**: This file contains the implementation of the chess logic and AI. It handles the rules of chess, validates moves, and includes AI to play against users.  
  [View File](https://github.com/PavitraAgarwal21/CCNFTS/blob/main/chess_contract/src/chess_test.cairo)

- **CCNFTS.cairo**: This file outlines the token economics and the main functionalities for handling NFTs. It includes the logic for creating, transferring, and managing chess piece NFTs.  
  [View File](https://github.com/PavitraAgarwal21/CCNFTS/blob/main/chess_contract/src/CCNFTS.cairo)

## Project Links

- **Project Link**: [CCNFTs Website](https://ccnfts.vercel.app/)
- **Project Codebase**: [GitHub Repository](https://github.com/PavitraAgarwal21/CCNFTS)
- **Project Video**: [Watch on YouTube](https://youtu.be/a_gTtDXRvBM)