const board = document.getElementById('chessboard');
const lastMoveDisplay = document.getElementById('last-move');
const boardSize = 6;
const Mapping = [
    54 , 53 , 52 ,  51 ,  50 ,  49 ,
    46 , 45  , 44 , 43 ,  42 ,  41 ,
    38 , 37 ,  36 , 35 , 34,  33 ,
    30 , 29 , 28 ,  27,  26 , 25 , 
    22 , 21 , 20,  19,  18 , 17 ,
    14 , 13 , 12,  11 , 10 , 9
];



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




const calculateMove = (fromRow, fromCol, toRow, toCol) => {
        // Convert the 6x6 indices to 8x8 indices
        const fromIndex8x8 = Mapping[fromRow * boardSize + fromCol];
        const toIndex8x8 = Mapping[toRow * boardSize + toCol];
        
        // Encode the move (source index << 6) | destination index
        const move = (fromIndex8x8 << 6) | toIndex8x8;
        return move;
    };
function getPieceAt(row, col) 
    {
    
        return boardState[row][col];

    }   

const number = 331315573416261998285838300841264183498209722800608769246624743425n; // Use BigInt for large numbers
const hexValue = number.toString(16).toUpperCase().padStart(64, '0');
const initialBoard = hexToBoard(hexValue)
// [
//     ['♜', '♝', '♛', '♚', '♝', '♜'],
//     ['♟', '♟', '♟', '♟', '♟', '♟'],
//     ['·', '·', '·', '·', '·', '·'],
//     ['·', '·', '·', '·', '·', '·'],
//     ['♙', '♙', '♙', '♙', '♙', '♙'],
//     ['♗', '♘', '♕', '♔', '♘', '♗']
// ];

let selectedPiece = null;
let boardState = initialBoard.map(row => row.slice());
let currentPlayer = 'white';

const renderBoard = () => {
    board.innerHTML = '';
    boardState.forEach((row, rowIndex) => {
        row.forEach((piece, colIndex) => {
            const square = document.createElement('div');
            square.className = 'square';
            if ((rowIndex + colIndex) % 2 === 1) {
                square.classList.add('dark');
            }
            square.innerHTML = piece;
            square.dataset.row = rowIndex;
            square.dataset.col = colIndex;
            square.addEventListener('click', handleSquareClick);
            board.appendChild(square);
        });
    });
};

const handleSquareClick = (event) => {
    const row = Number(event.target.dataset.row);
    const col = Number(event.target.dataset.col);

    if (selectedPiece) {
        const fromRow = selectedPiece.row;
        const fromCol = selectedPiece.col;
        console.log('fromRow:', fromRow, 'fromCol:', fromCol, 'toRow:', row, 'toCol:', col);

        if (boardState[row][col] === '·' || isOpponentPiece(boardState[row][col])) {
            boardState[row][col] = selectedPiece.piece;
            boardState[fromRow][fromCol] = '·';



/// how the move is from where the move is fromROW AND COLUM IS IT CALulcated ok 

            const move = calculateMove(fromRow, fromCol, row, col);
            lastMoveDisplay.textContent = move;


            selectedPiece = null;
            currentPlayer = currentPlayer === 'white' ? 'black' : 'white';
            renderBoard();
        }
    } else {
        if (boardState[row][col] !== '·' && isPieceOfCurrentPlayer(boardState[row][col])) {
            selectedPiece = { piece: boardState[row][col], row, col };
        }
    }
};

const isPieceOfCurrentPlayer = (piece) => {
    return ('♙♘♗♕♔♜'.includes(piece) && currentPlayer === 'white') ||
           ('♟♝♞♛♚♜'.includes(piece) && currentPlayer === 'black');
};

const isOpponentPiece = (piece) => {
    return ('♙♘♗♕♔♜'.includes(piece) && currentPlayer === 'black') ||
           ('♟♝♞♛♚♜'.includes(piece) && currentPlayer === 'white');
};

renderBoard();

