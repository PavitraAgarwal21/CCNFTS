// App.js
import React from 'react';
import Chessboard from "./component/Chessboard";
import BuyChessBoard from "./component/BuyChessBoard";
import ShowChessNFT from "./component/ShowChessNFT";
import styles from './App.module.css'; // Import your CSS module

function App() {
  return (
    <div className={styles.container}>
      <header className={styles.header}>
        <h1>Chess-on-Blockchain</h1>
        <p>Explore and buy chessboards, view NFTs, and play chess!</p>
      </header>

      <section className={`${styles.section} ${styles.playChess}`}>
        <h2>Play Chess</h2>
        <p>This is a 6x6 chessboard that is exciting and challenging to play on. Test your skills and enjoy the game!</p>
        <Chessboard />
      </section>

      <section className={`${styles.section} ${styles.yourNFTs}`}>
        <h2>Your Chess NFTs</h2>
        <p>View your collection of chessboard NFTs. Each piece in your collection is a unique digital asset that you can showcase.</p>
        <ShowChessNFT />
      </section>

      <section className={`${styles.section} ${styles.buyChessBoards}`}>
        <h2>Chess NFT Market Place </h2>
        <p>Purchase exclusive and beautifully crafted chessboards. Each board is unique and represents a piece of digital art on the blockchain.</p>
        <BuyChessBoard />
      </section>
    </div>
  );
}

export default App;