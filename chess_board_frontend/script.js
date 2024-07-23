const board = document.getElementById('chessboard');
const capturedWhiteContainer = document.getElementById('captured-white-pieces');
const capturedBlackContainer = document.getElementById('captured-black-pieces');
const boardSize = 6;

const initialBoard = [
    ['♗', '♘', '♕', '♔', '♘', '♗'],
    ['♙', '♙', '♙', '♙', '♙', '♙'],
    ['·', '·', '·', '·', '·', '·'],
    ['·', '·', '·', '·', '·', '·'],
    ['♟', '♟', '♟', '♟', '♟', '♟'],
    ['♜', '♝', '♛', '♚', '♝', '♜']
];

let selectedPiece = null;
let boardState = initialBoard.map(row => row.slice());

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
        const capturedPiece = boardState[row][col];

        if (boardState[row][col] === '·' || capturedPiece !== '·') {
            if (capturedPiece !== '·') {
                capturePiece(capturedPiece);
            }

            boardState[row][col] = selectedPiece.piece;
            boardState[fromRow][fromCol] = '·';
            selectedPiece = null;
            renderBoard();
        }
    } else {
        if (boardState[row][col] !== '·') {
            selectedPiece = { piece: boardState[row][col], row, col };
        }
    }
};

const capturePiece = (piece) => {
    if ('♙♘♗♕♔♜'.includes(piece)) {
        capturedWhiteContainer.innerHTML += `<div>${piece}</div>`;
    } else {
        capturedBlackContainer.innerHTML += `<div>${piece}</div>`;
    }
};

renderBoard();