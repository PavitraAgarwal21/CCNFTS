// components/Chessboard.js
import React, { useEffect, useRef, useState } from 'react';
import styles from './Chessboard.module.css';
import { Contract, RpcProvider } from "starknet";
import { ConnectedStarknetWindowObject } from "get-starknet-core";
import { TokenboundConnector, TokenBoundModal, useTokenBoundModal } from "tokenbound-connector";
import { ABI } from "../abis/abi";
const contractAddress = "0x2a6d064d39cd39d2e34bb4705655e445d093a66f4fdc2a5e756336eacaeed9e"; 
const sleep = (ms: number) => new Promise(resolve => setTimeout(resolve, ms));

const Chessboard = () => {
  const provider = new RpcProvider({
    nodeUrl: "https://starknet-sepolia.public.blastapi.io/rpc/v0_7",
  });
  const [connection, setConnection] = useState<ConnectedStarknetWindowObject>();
  const [account, setAccount] = useState();
  const [address, setAddress] = useState("");
  const [retrievedValue, setRetrievedValue] = useState("");
  const [boardState, setBoardState] = useState<string[][]>([]);
  const [selectedPiece, setSelectedPiece] = useState<{ piece: string, row: number, col: number } | null>(null);
  const [currentPlayer, setCurrentPlayer] = useState('white');
  const moveRef = useRef<number>(0);

  const {
    isOpen,
    openModal,
    closeModal,
    value,
    selectedOption,
    handleChange,
    handleChangeInput,
    resetInputValues,
  } = useTokenBoundModal();

  const tokenbound = new TokenboundConnector({
    tokenboundAddress: value,
    parentAccountId: selectedOption,
  });

  const connectTBA = async () => {
    const connection = await tokenbound.connect();
    closeModal();
    resetInputValues();

    if (connection && connection.isConnected) {
      setConnection(connection);
      setAccount(connection.account);
      setAddress(connection.selectedAddress);
    }
  };

  const disconnectTBA = async () => {
    await tokenbound.disconnect();
    setConnection(undefined);
    setAccount(undefined);
    setAddress("");
  };

  const playChess = async () => {
    try {
      const contract = new Contract(ABI, contractAddress, account).typedv2(ABI);
      let move = playMove();
      let val = await contract.playmove(move); 
      console.log(val);
      await sleep(15000); // Wait for 5 seconds
      refresh() ; 
    } catch (error) {
      console.log(error);
    }
  };

  const refresh = async () => {
    try {
      sleep(2000); // Wait for 5 seconds
      const contract = new Contract(ABI, contractAddress, provider).typedv2(ABI);
      let new_board_state = await contract.getUpdatedBoardStatepublic(address);
      console.log(new_board_state); 
      const hexValue = new_board_state.toString(16).toUpperCase().padStart(64, '0');
      const initialBoard = hexToBoard(hexValue);
      setBoardState(initialBoard);
      setSelectedPiece(null);
      setCurrentPlayer('white');
      moveRef.current = 0;
    } catch (error) {
      console.log("Error in getUpdatedState");
      console.log(error);
    }
  };

  useEffect(() => {
    refresh();
    resetBoard();
  }, []);

  const resetBoard = () => {
    const number = BigInt('331315573416267984596543414422294546879883252852981354553476644865');
    const hexValue = number.toString(16).toUpperCase().padStart(64, '0');
    const initialBoard = hexToBoard(hexValue);
    setBoardState(initialBoard);
    setSelectedPiece(null);
    setCurrentPlayer('white');
    moveRef.current = 0;
  };

  const hexToBoard = (hexStr: string) => {

    const pieceMap: { [key: string]: string } = {
   '0': '·',  
      '1': '♟',  
      '2': '♝', 
      '3': '♜', 
      '4': '.',  
      '5': '♛',  
      '6': '♚',  
      '9': '♙',  
      'B': '♖', 
      'C': '♘',  
      'D': '♕', 
      'E': '♔',  
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

  const handleSquareClick = (row: number, col: number) => {
    if (selectedPiece) {
      const { piece, row: fromRow, col: fromCol } = selectedPiece;
      if (boardState[row][col] === '·' || isOpponentPiece(boardState[row][col])) {
        const newBoardState = boardState.map(row => row.slice());
        newBoardState[row][col] = piece;
        newBoardState[fromRow][fromCol] = '·';
        setBoardState(newBoardState);

        const newMove = calculateMove(fromRow, fromCol, row, col);
        moveRef.current = newMove;

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
    return ('♙♘♗♕♔♖'.includes(piece) && currentPlayer === 'white') ||
           ('♟♝♞♛♚♜'.includes(piece) && currentPlayer === 'black');
  };

  const isOpponentPiece = (piece: string) => {
    return ('♙♘♗♕♔♖'.includes(piece) && currentPlayer === 'black') ||
           ('♟♝♞♛♚♜'.includes(piece) && currentPlayer === 'white');
  };

  const playMove = () => {
    console.log(`Encoded Move: ${moveRef.current}`);
    return moveRef.current; 
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
          <button onClick={resetBoard}>Reset Board</button>
          <div>         
             <button onClick={playChess}>Play Chess</button>
          </div>
          <button onClick={refresh}>Get Updated State</button>
        </div>
      </div>
      {!connection ? (
        <button className="button" onClick={openModal}>
          Connect Wallet
        </button>
      ) : (
        <button onClick={  disconnectTBA}>Disconnect Wallet</button>
      )}
    <TokenBoundModal
          isOpen={isOpen}
          closeModal={closeModal}
          value={value}
          selectedOption={selectedOption}
          handleChange={handleChange}
          handleChangeInput={handleChangeInput}
          onConnect={connectTBA}
        />
    </div>
  );
};

export default Chessboard;