import React from 'react';
import ReactDOM from 'react-dom/client';
import './index.css';
import styles from './component/Chessboard.module.css';
// import Dapp from './App';
import reportWebVitals from './reportWebVitals';
import Chessboard from './component/Chessboard';
const root = ReactDOM.createRoot(
  document.getElementById('root') as HTMLElement
);

root.render(
  <React.StrictMode>
     



        <Chessboard/>
     
  </React.StrictMode>
);

reportWebVitals();
