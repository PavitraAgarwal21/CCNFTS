const board = document.getElementById('chessboard');
const lastMoveDisplay = document.getElementById('last-move');
const boardSize = 6;

const initialBoard = [
    ['♜', '♝', '♛', '♚', '♝', '♜'],
    ['♟', '♟', '♟', '♟', '♟', '♟'],
    ['·', '·', '·', '·', '·', '·'],
    ['·', '·', '·', '·', '·', '·'],
    ['♙', '♙', '♙', '♙', '♙', '♙'],
    ['♗', '♘', '♕', '♔', '♘', '♗']
];

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

        if (boardState[row][col] === '·' || isOpponentPiece(boardState[row][col])) {
            boardState[row][col] = selectedPiece.piece;
            boardState[fromRow][fromCol] = '·';

            const move = (fromRow * boardSize + fromCol) << 6 | (row * boardSize + col);
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