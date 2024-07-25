import React from 'react';
import ReactDOM from 'react-dom/client';
import './index.css';
import styles from './component/Chessboard.module.css';
// import Dapp from './App';
import reportWebVitals from './reportWebVitals';
// import Chessboard from './component/Chessboard';
// import BuyChessBoard from './component/BuyChessBoard'; 
// import ShowChessNFT  from './component/ShowChessNFT';  
// import Header from './component/header';
import APP from './App';

const root = ReactDOM.createRoot(
  document.getElementById('root') as HTMLElement
);
root.render(
  <React.StrictMode>
<APP/>
  </React.StrictMode>
);

reportWebVitals();
