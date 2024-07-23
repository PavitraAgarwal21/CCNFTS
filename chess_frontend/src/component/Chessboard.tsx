// components/Chessboard.js
import React, { useEffect, useState } from 'react';
import styles from './Chessboard.module.css';

const Chessboard = () => {
  const [boardState, setBoardState] = useState<string[][]>([]);
  const [selectedPiece, setSelectedPiece] = useState<{ piece: string, row: number, col: number } | null>(null);
  const [currentPlayer, setCurrentPlayer] = useState('white');
  const [lastMove, setLastMove] = useState('');

  useEffect(() => {
    const number = BigInt('331315573416267984596543414422294546879883252852981354553476644865');
    const hexValue = number.toString(16).toUpperCase().padStart(64, '0');
    const initialBoard = hexToBoard(hexValue);
    setBoardState(initialBoard);
  }, []);

  const hexToBoard = (hexStr : string) => {
    const pieceMap: { [key: string]: string } = {
      '0': '·',
      '1': '♙',
      '2': '♘',
      '3': '♗',
      '4': '♖',
      '5': '♕',
      '6': '♔',
      '9': '♟',
      'B': '♜',
      'C': '♝',
      'D': '♛',
      'E': '♚',
    };

    if (hexStr.startsWith('0x')) {
      hexStr = hexStr.slice(2);
    }

    let binaryStr = BigInt('0x' + hexStr).toString(2).padStart(256, '0');

    let board = [];
    for (let row = 0; row < 8; row++) {
      let boardRow = [];
      for (let col = 0; col < 8; col++) {
        let bitIndex = (row * 8 + col) * 4;
        let hexDigit = parseInt(binaryStr.slice(bitIndex, bitIndex + 4), 2).toString(16).toUpperCase();
        let piece = pieceMap[hexDigit] || '·';
        boardRow.push(piece);
      }
      board.push(boardRow);
    }

    const trimmedBoard = board.slice(1, 7).map(row => row.slice(1, 7));
    trimmedBoard.reverse();
    return trimmedBoard;
  };

  const calculateMove = (fromRow: number, fromCol: number, toRow: number, toCol: number) => {
    const Mapping = [
      54, 53, 52, 51, 50, 49,
      46, 45, 44, 43, 42, 41,
      38, 37, 36, 35, 34, 33,
      30, 29, 28, 27, 26, 25,
      22, 21, 20, 19, 18, 17,
      14, 13, 12, 11, 10, 9
    ];

    const fromIndex8x8 = Mapping[fromRow * 6 + fromCol];
    const toIndex8x8 = Mapping[toRow * 6 + toCol];
    const move = (fromIndex8x8 << 6) | toIndex8x8;
    return move;
  };

  const decodeMove = (move: number) => {
    const toIndex8x8 = move & 0x3F;
    const fromIndex8x8 = (move >> 6) & 0x3F;
    const Mapping = [
      54, 53, 52, 51, 50, 49,
      46, 45, 44, 43, 42, 41,
      38, 37, 36, 35, 34, 33,
      30, 29, 28, 27, 26, 25,
      22, 21, 20, 19, 18, 17,
      14, 13, 12, 11, 10, 9
    ];

    const fromRow = Math.floor(Mapping.indexOf(fromIndex8x8) / 6);
    const fromCol = Mapping.indexOf(fromIndex8x8) % 6;
    const toRow = Math.floor(Mapping.indexOf(toIndex8x8) / 6);
    const toCol = Mapping.indexOf(toIndex8x8) % 6;

    return `(${fromRow}, ${fromCol}) -> (${toRow}, ${toCol})`;
  };

  const handleSquareClick = (row: number, col: number) => {
    if (selectedPiece) {
      const { piece, row: fromRow, col: fromCol } = selectedPiece;
      if (boardState[row][col] === '·' || isOpponentPiece(boardState[row][col])) {
        const newBoardState = boardState.map(row => row.slice());
        newBoardState[row][col] = piece;
        newBoardState[fromRow][fromCol] = '·';
        setBoardState(newBoardState);

        const move = calculateMove(fromRow, fromCol, row, col);
        setLastMove(`Move: ${move} | Decoded: ${decodeMove(move)}`);

        setSelectedPiece(null);
        setCurrentPlayer(currentPlayer === 'white' ? 'black' : 'white');
      }
    } else {
      if (boardState[row][col] !== '·' && isPieceOfCurrentPlayer(boardState[row][col])) {
        setSelectedPiece({ piece: boardState[row][col], row, col });
      }
    }
  };

  const isPieceOfCurrentPlayer = (piece: string) => {
    return ('♙♘♗♕♔♜'.includes(piece) && currentPlayer === 'white') ||
           ('♟♝♞♛♚♜'.includes(piece) && currentPlayer === 'black');
  };

  const isOpponentPiece = (piece : string ) => {
    return ('♙♘♗♕♔♜'.includes(piece) && currentPlayer === 'black') ||
           ('♟♝♞♛♚♜'.includes(piece) && currentPlayer === 'white');
  };

  return (
    <div className={styles.container}>
      <div className={styles.boardWrapper}>
        <div className={styles.chessboard}>
          {boardState.map((row, rowIndex) =>
            row.map((piece, colIndex) => (
              <div
                key={`${rowIndex}-${colIndex}`}
                className={`${styles.square} ${(rowIndex + colIndex) % 2 === 1 ? styles.dark : ''}`}
                onClick={() => handleSquareClick(rowIndex, colIndex)}
              >
                {piece}
              </div>
            ))
          )}
        </div>
        <div className={styles.moveContainer}>
          <h3>Last Move: <span id="last-move">{lastMove}</span></h3>
        </div>
      </div>
    </div>
  );
};

export default Chessboard;