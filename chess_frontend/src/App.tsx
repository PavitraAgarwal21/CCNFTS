import React from 'react';
import Chessboard from "./component/Chessboard";
import BuyChessBoard from "./component/BuyChessBoard";
import ShowChessNFT from "./component/ShowChessNFT";
import styles from './App.module.css'; // Import your CSS module

function APP() {
  return (
    <div className={styles.container}>
      <header className={styles.header}>
        <h1>Chess-on-Blockchain</h1>
        <p>Explore and buy chessboards, view NFTs, and play chess!</p>
      </header>

      <section className={styles.section}>
        <BuyChessBoard />
      </section>


      <div>

  This is the chess board 0f 6*6 which is very cool to play 

      </div>

      <section className={styles.section}>
        <Chessboard />
      </section>

      <section className={styles.section}>
        <ShowChessNFT />
      </section>
    </div>
  );
}

export default APP;