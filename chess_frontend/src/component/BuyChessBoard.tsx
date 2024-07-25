import React, { useState } from "react";
import {
  type ConnectOptions,
  type DisconnectOptions,
  connect,
  disconnect,
} from "get-starknet";
import { TokenboundClient , TokenboundClientOptions } from "starknet-tokenbound-sdk";
import { IMPLEMENTATION_HASH, REGISTRY_ADDRESS  , JSON_RPC } from "./constants" ; 
import { ABI } from "../abis/abi";
import styles from './BuyChessBoard.module.css';
import { Contract, RpcProvider } from "starknet";
import { stringify } from "querystring";
import { a } from "@starknet-react/core/dist/index-79NvzQC9";
import { stat } from "fs";
import { copyToClipboard  } from './utils';
const contractAddress = "0x1b3f391b295753980d169452cf1ad25170ca7005724714bda80efac638a5435";
const sleep = (ms: number) => new Promise(resolve => setTimeout(resolve, ms));


function BuyChessBoard() {

  const [walletName, setWalletName] = useState("");
  const [account, setAccount] = useState();
  const [tbaAccount, setTbaAccount] = useState<string | null>(null);

  const provider = new RpcProvider({
    nodeUrl: "https://starknet-sepolia.public.blastapi.io/rpc/v0_7",
  });
  function handleConnect(options?: ConnectOptions) {
    return async () => {
      const res = await connect(options);
      // console.log(res?.account);
      setWalletName(res?.name || "");
      setAccount(res?.account);
    }
  }
  function handleDisconnect(options?: DisconnectOptions) {
    return async () => {
      await disconnect(options);
      setWalletName("");
    }
  }

  interface Puzzle {
    boardHex: string;
    depth: number;
    score: number;
  }


 const hexToBoard = (hexStr: string): string[][] => {
    const pieceMap: { [key: string]: string } = {
      '0': '·',  '1': '♟',  '2': '♝',  '3': '♜',
      '4': '.',  '5': '♛',  '6': '♚',  '9': '♙',
      'A': '♘',  'B': '♖',  'C': '♗',  'D': '♕',
      'E': '♔',
    };

    if (hexStr.startsWith('0x')) {
      hexStr = hexStr.slice(2);
    }

    let binaryStr = BigInt('0x' + hexStr).toString(2).padStart(256, '0');
    let board: string[][] = [];
    for (let row = 0; row < 8; row++) {
      let boardRow: string[] = [];
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


   const initialPuzzles: Puzzle[] = [
    { boardHex: '0x3256230011111100000000000000000099999900BCDECB000000001', depth: 3, score: 3000 },
    { boardHex: '0x3256230011111100000000000000000099999900BCDECB000000001', depth: 4, score: 4000 },
    { boardHex: '0x3256230010000100001000009199D00009009000BC0ECB000000001', depth: 4, score: 4000 },
    { boardHex: '0x3256230010000100001000009199D00009009000BC0ECB000000001', depth: 5, score: 5000 },
    { boardHex: '0x3256230010100100000000009199100009009000BCDECB000000001', depth: 5, score: 5000 },
    { boardHex: '0x3256230011111100000000000000000099999900BCDECB000000001', depth: 3, score: 3000 },
    { boardHex: '0x3256230011111100000000000000000099999900BCDECB000000001', depth: 4, score: 4000 },
    { boardHex: '0x3256230010000100001000009199D00009009000BC0ECB000000001', depth: 4, score: 4000 },
    { boardHex: '0x3256230010000100001000009199D00009009000BC0ECB000000001', depth: 5, score: 5000 },
    { boardHex: '0x3256230010100100000000009199100009009000BCDECB000000001', depth: 5, score: 5000 },
    { boardHex: '0x3256230010000100001000009199D00009009000BC0ECB000000001', depth: 6, score: 6000 },
    { boardHex: '0x32502300100061000010000091990000090D9000BC0ECB000000001', depth: 7, score: 7000 },
    { boardHex: '0x305023001006010000100D009199000009009000BC0ECB000000001', depth: 8, score: 8000 },
    { boardHex: '0x3256230011111100000000000000000099999900BCDECB000000001', depth: 9, score: 9000 },
  ];

  const [puzzleList, setPuzzleList] = useState<Puzzle[]>(initialPuzzles);
  const [indexToRemove, setIndexToRemove] = useState<number | null>(null);

  const storePuzzle = (puzzle: Puzzle): void => {
    puzzleList.push(puzzle);
  };

  const popPuzzle = (index: number) => {
    setPuzzleList(prevPuzzles => {
      if (index >= 0 && index < prevPuzzles.length) {
        const newPuzzles = prevPuzzles.filter((_, i) => i !== index);
        return newPuzzles;
      }
      return prevPuzzles;
    });
  };

  const handleBuy = (puzzle: Puzzle) => {
    buychess(puzzle);
    // Add your 'Buy' logic here
  };

  // 1 deploy ment logic and when it deployed 
  // then we have to get the 
// i think mint and deployed both at the same time it would be then one of the best think 


  const handleDeploy = (puzzle: Puzzle) => {
    console.log("Deploy Puzzle Info: ", puzzle);
    // Add your 'Deploy' logic here

    // now i want to discuss how the tba deployemnt of the contract will be good and and gave him the tba account 
    
    // all this done so that our work is simple ok 

    // what we want is the token id 
    // we know the contract id 
    // we want to get the 
    // mint will contain the token id 
    // read from that ok 

  };





interface TokenID{
  creator: string;
  tokenId: number;
}

// contract address t0 

const [token_id, set_token_id] = useState<string>(""); 

async function buychess(puzzle: Puzzle) {
  const contract = new Contract(ABI, contractAddress, account).typedv2(ABI);
  const board = BigInt(puzzle.boardHex);
  const depth = puzzle.depth;
  const amt = puzzle.score;
  try {

    
let tx = await contract.makePuzzle(board, depth, amt); 
    console.log(tx);
    let contract_read = new Contract(ABI, contractAddress, provider).typedv2(ABI); 
    let board_supply  = await contract_read.get_total_puzzle_supply();
    let board_token_id = (Number(board_supply) << 8).toString(); // Shift left by 8 bits and convert to string
    console.log(board_token_id);
    
     await sleep(15000); // Wait for 5 seconds
    let val = await deployTBA(board_token_id);
    let status = await checkTBAdeployment(board_token_id);
    console.log(status);
    while (!status) {
   status = await checkTBAdeployment(board_token_id);
   await sleep(2000);
    }
      let tbaaccount = await getTBA(board_token_id);
      console.log(tbaaccount);
     
    }
   catch (error) {
    console.error(error);
  }
  
}



  const options: TokenboundClientOptions = {
    account : account , 
    registryAddress : REGISTRY_ADDRESS ,
    implementationAddress : IMPLEMENTATION_HASH , 
    jsonRPC : JSON_RPC , 
  }
  let tokenbound : any ; 
  if (account){
     tokenbound = new TokenboundClient(options);
  } 


  const deployTBA = async (token_id : string) => {
   await  sleep(5000);

    try {
      const status = await tokenbound.createAccount( {
        tokenContract : contractAddress , 
        tokenId : token_id, 
      }
      ); 
    } catch(err) {
      console.log(err)
    }
  };
  const checkTBAdeployment = async (token_id : string) => {
  
    const status = await tokenbound.checkAccountDeployment( {
      tokenContract : contractAddress , 
      tokenId : token_id, 
    }
    ); 
    return status.deployed;
  }
  // now i have to deploy the contract and then get the token id from that ok
  const getTBA = async (token_id : string) => {  
      const tbaaccount = await tokenbound.getAccount( {
        tokenContract : contractAddress , 
        tokenId : token_id, 
      }
      ); 
      setTbaAccount(tbaaccount);
      console.log(tbaaccount)
      alert("copy the address from the clipboard");
  }

  const handleCopy = () => {
    if (tbaAccount) {
      copyToClipboard(tbaAccount);
      alert("TBA account address copied to clipboard!");
    }
  };

  // create the token id for this ok now i am all ready to go with that ok 


  // let tokenbound : any  = new TokenboundClient(options);



  return (
    <div className={styles.buyApp}>
      <div className={styles.buyCard}>
        <button className={styles.buyButton} onClick={handleConnect()}>Connect</button>
        <button className={styles.buyButton} onClick={handleDisconnect()}>Disconnect</button>

      </div>
      <div>
        <h1>Chess Puzzle Management</h1>
        <div className={styles.buyBoardContainer}>
          {puzzleList.map((puzzle, index) => (
            <div key={index} className={styles.buyBoardWrapper}>
              <h3>Puzzle {index + 1}</h3>
              <div className={styles.buyChessboard}>
                {hexToBoard(puzzle.boardHex).map((row, rowIndex) => (
                  <React.Fragment key={rowIndex}>
                    {row.map((piece, colIndex) => (
                      <div
                        key={colIndex}
                        className={`${styles.buySquare} ${((rowIndex + colIndex) % 2 === 1) ? styles.buyDark : styles.buyLight}`}
                      >
                        {piece}
                      </div>
                    ))}
                  </React.Fragment>
                ))}
              </div>
              <div>
              <p>Depth: {puzzle.depth}</p>
                <p>Score: {puzzle.score}</p>
                <div className={styles.buyBoardActions}>
                  <button
                    className={`${styles.buyButton} ${styles.buy1Button}`}
                    onClick={() => handleBuy(puzzle)}
                  >
                    Buy
                  </button>
                  <button className={styles.copyButton} onClick={handleCopy}>Copy Address</button>

                </div>
              </div>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}



/// puzzle mint is complete what i want now is to make the simple thing so lets do it  

export default BuyChessBoard;