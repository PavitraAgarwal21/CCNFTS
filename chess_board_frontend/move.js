

// Mapping from 6x6 board to 8x8 board
const sixToEightMapping = [
    35, 34, 33, 32, 31, 30, // 0-5
    29, 28, 27, 26, 25, 24, // 6-11
    23, 22, 21, 20, 19, 18, // 12-17
    17, 16, 15, 14, 13, 12, // 18-23
    11, 10, 9, 8, 7, 6, // 24-29
    5, 4, 3, 2, 1, 0  // 30-35
];

// this is mapped with upper so wheneever the move is from the let say 11 to 17 
// then we called it 22 to 30 
// ok 

// board size is 6*6 so let say 
const boardSize = 6; 
const Mapping = [
    54 , 53 , 52 ,  51 ,  50 ,  49 ,
    46 , 45  , 44 , 43 ,  42 ,  41 ,
    38 , 37 ,  36 , 35 , 34,  33 ,
    30 , 29 , 28 ,  27,  26 , 25 , 
    22 , 21 , 20,  19,  18 , 17 ,
    14 , 13 , 12,  11 , 10 , 9
]


const calculateMove = (fromRow, fromCol, toRow, toCol) => {
    // Convert the 6x6 indices to 8x8 indices
    const fromIndex8x8 = Mapping[fromRow * boardSize + fromCol];
    const toIndex8x8 = Mapping[toRow * boardSize + toCol];
    
    // Encode the move (source index << 6) | destination index
    const move = (fromIndex8x8 << 6) | toIndex8x8;
    return move;
};

// Example usage
const fromRow = 4;  // Example source row on the 6x6 board
const fromCol = 1;  // Example source column on the 6x6 board
const toRow = 3;    // Example destination row on the 6x6 board
const toCol = 1;    // Example destination column on the 6x6 board

const move = calculateMove(fromRow, fromCol, toRow, toCol);
console.log('Move:', move);  // Display the calculated move

function hexToBoard(hexStr) {
    // Define piece mapping
    const pieceMap = {
        '0': '·',  // Empty
        '1': '♙',  // White Pawn
        '2': '♘',  // White Knight
        '3': '♗',  // White Bishop
        '4': '♖',  // White Rook
        '5': '♕',  // White Queen
        '6': '♔',  // White King
        '9': '♟',  // Black Pawn
        'B': '♜',  // Black Rook
        'C': '♝',  // Black Bishop
        'D': '♛',  // Black Queen
        'E': '♚',  // Black King
    };

    // Remove '0x' prefix if present
    if (hexStr.startsWith('0x')) {
        hexStr = hexStr.slice(2);
    }

    // Convert hex string to a binary string
    let binaryStr = BigInt('0x' + hexStr).toString(2).padStart(256, '0');

    // Create the 8x8 board as a list of lists
    let board = [];
    for (let row = 0; row < 8; row++) {
        let boardRow = [];
        for (let col = 0; col < 8; col++) {
            // Calculate the bit index (4 bits per piece)
            let bitIndex = (row * 8 + col) * 4;
            // Extract 4-bit segment from the binary string
            let hexDigit = parseInt(binaryStr.slice(bitIndex, bitIndex + 4), 2).toString(16).toUpperCase();
            // Get the piece from the map
            let piece = pieceMap[hexDigit] || '·';
            boardRow.push(piece);
        }
        board.push(boardRow);
    }

    // Convert the 8x8 board to 6x6 by removing one row and one column from each side
    const trimmedBoard = board.slice(1, 7).map(row => row.slice(1, 7));

    // Reverse the order of the rows to have black pieces on top and white pieces on the bottom
    trimmedBoard.reverse();

    return trimmedBoard;
}

function hexToDecimal(hexStr) {
    // Remove '0x' prefix if present
    if (hexStr.startsWith('0x')) {
        hexStr = hexStr.slice(2);
    }

    // Convert the hex string to a decimal number
    let decimalNumber = BigInt('0x' + hexStr);

    return decimalNumber;
}
console.log(hexToDecimal('0x3256230011111100000000000000000099999900BCDECB000000001'));
// Example usage
const number = 331315573416267984596543414422294546879883252852981354553476644865n; // Use BigInt for large numbers
const hexValue =  number.toString(16).toUpperCase().padStart(64, '0'); ; //' ; //
console.log(hexToBoard(hexValue));
