# CCNFTs 

## CCNFTs: A Revolutionary Approach to Blockchain Gaming

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

- **Bit-Shifts and Masks**: Each piece is 4 bits, and the board positions are accessed via bit shifts and masks instead of array indices.
- **Boundary Rows/Columns**: The top/bottom rows and left/right columns are used as sentinel values for efficient boundary validation. These rows and columns do not contain pieces but are used to determine the player's turn (0 for black, 1 for white).
### Move Representation

Each move is encoded using 12 bits:

- **First 6 bits**: The index from which the piece is moving
- **Last 6 bits**: The index to which the piece is moving

**Example**: A move encoded as `1243` represents a move from index 19 to 27 (binary representation `1243 = (19 << 6) | 27`).