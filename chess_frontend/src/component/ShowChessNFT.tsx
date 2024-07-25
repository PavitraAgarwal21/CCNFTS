import React, { useEffect, useRef, useState } from 'react';
import {
  type ConnectOptions,
  type DisconnectOptions,
  connect,
  disconnect,
} from "get-starknet";

import { ABI } from "../abis/abi";
import styles from './ShowChessBoard.module.css';
import { Contract, RpcProvider } from "starknet";
import { ConnectedStarknetWindowObject } from "get-starknet-core";
import { TokenboundConnector, TokenBoundModal, useTokenBoundModal } from "tokenbound-connector";

const contractAddress = "0x397de13e4b1982fa6d69ce9d441f762acd3e93b8cc9d08fc162d5938975c506";

function ShowChessNFT() {
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

  const hexToBoard = (hexStr: string): string[][] => {
  
    const pieceMap: { [key: string]: string } = {
        '0': '·', 
           '1': '♟', 
           '2': '♝',  
           '3': '♜',  
           '4': '.',  
           '5': '♛' ,
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
    let board: string[][] = [];
    
    for (let row = 0; row < 8 ; row++) {
      let boardRow: string[] = [];
      for (let col = 0; col < 8 ; col++) {
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

  async function getTokenId(address: string): Promise<string> {
    const contract = new Contract(ABI, contractAddress, provider).typedv2(ABI);
  
    const tokenId = await contract.get_token_Id(address);
    return tokenId.toString();
  }
  
  async function getTotalMoves(tokenId: string | number | bigint): Promise<number> {
    const contract = new Contract(ABI, contractAddress, provider);
  
    const tokenIdStr = tokenId.toString();
  
    const totalMoves = 3 ; // await contract.get_total_moves(tokenIdStr);
  
    console.log(totalMoves);
    return totalMoves;
  }
  
  interface Puzzle {
    boardHex: string;
    tokenId: number;
    moves: number;
  }

  function bigintToHex(value: bigint): string {
    return '0x' + value.toString(16);
  }

  const initialPuzzles: Puzzle[] = [] ; 
  async function getAllTokenIDs() {
    try {
      const userAddress = '0xYourAddress'; // Replace with the actual address
      const tokenId = await getTokenId(address);
      console.log('Token ID:', tokenId);
      const contract = new Contract(ABI, contractAddress, provider).typedv2(ABI);

      const totalMoves = await getTotalMoves(tokenId);
      console.log('Total Moves:', totalMoves);
  
      for (let i = 1; i <= totalMoves; i++) {
        const _token_id = (BigInt(tokenId) << BigInt(8)) + BigInt(i);
        let board = await contract.token_uri(_token_id);
        initialPuzzles.push({boardHex: bigintToHex(BigInt(board[0])) , tokenId: Number(_token_id), moves: Number(board[1])});
      }
      console.log(initialPuzzles);
    } catch (error) {
      console.error('Error in getAllTokenIDs:', error);
    }
  }

  const [puzzleList, setPuzzleList] = useState<Puzzle[]>(initialPuzzles);

  const handleButtonClick = async (event: React.MouseEvent<HTMLButtonElement, MouseEvent>) => {
    const { id } = event.currentTarget;

    if (id === "getNFTs") {
      await getAllTokenIDs();
      setPuzzleList([...initialPuzzles]);
    } else if (id === "disconnect") {
      disconnectTBA();
    }
  };

return (
    <div className={styles.showApp}>
    <div className={styles.showCard}>
      <h1 className={styles.title}>Chess NFT Showcase</h1>
      <div className={styles.buttonGroup}>
        <button className={styles.showButton} id="getNFTs" onClick={handleButtonClick}>
          Show Chess NFTs
        </button>
        {!connection ? (
          <button className={styles.showButton} onClick={openModal}>
            Connect Wallet
          </button>
        ) : (
          <button className={styles.showButton} onClick={disconnectTBA}>
            Disconnect Wallet
          </button>
        )}
      </div>
      <TokenBoundModal
        isOpen={isOpen}
        closeModal={closeModal}
        value={value}
        selectedOption={selectedOption}
        handleChange={handleChange}
        handleChangeInput={handleChangeInput}
        onConnect={connectTBA}
      />
      <div className={styles.showBoardContainer}>
        {puzzleList.map((puzzle, index) => (
          <div key={index} className={styles.showBoardWrapper}>
            <div className={styles.showChessboard}>
              {hexToBoard(puzzle.boardHex).map((row, rowIndex) => (
                <div key={rowIndex} className={styles.showRow}>
                  {row.map((square, colIndex) => (
                    <div
                      key={colIndex}
                      className={`${styles.showSquare} ${((rowIndex + colIndex) % 2 === 0) ? styles.showLight : styles.showDark}`}
                    >
                      {square}
                    </div>
                  ))}
                </div>
              ))}
            </div>
            <div className={styles.showBoardActions}>
              <p>Token ID: {puzzle.tokenId}</p>
              <p>Moves: {puzzle.moves}</p>
            </div>
          </div>
        ))}
      </div>
    </div>
  </div>
  );
}

export default ShowChessNFT;