import { useState } from "react";
import "./App.css";
import { Contract, RpcProvider } from "starknet";
import { ConnectedStarknetWindowObject } from "get-starknet-core";
import { TokenboundConnector, TokenBoundModal, useTokenBoundModal } from "tokenbound-connector";

import { ABI } from "./abis/abi";
const contractAddress =
  "0x4fe0e3eb26e38cc45e6898697109a3ca09237a198d5a9e415b3c030a8c43a64";

function Dapp() {
  const [connection, setConnection] = useState<ConnectedStarknetWindowObject>();
  const [account, setAccount] = useState();
  const [address, setAddress] = useState("");
  const [retrievedValue, setRetrievedValue] = useState("");
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

  const increaseCounter = async () => {
    try {
      const contract = new Contract(ABI, contractAddress, account).typedv2(ABI);
      let val = await contract.playmove(1373); 
      console.log(val); 

      alert("you successfully increased the counter");
    } catch (error) {
      console.log(error);
    }
  };


  const decreaseCounter = async () => {
    try {
      const contract = new Contract(ABI, contractAddress, account).typedv2(ABI);
      let val = await contract.playmove(1373);
      console.log(val);
      alert("you sucessfully decreased the counter");
    } catch (error) {
      console.log(error);
    }
  };

  const getCounter = async () => {
    const provider = new RpcProvider({
      nodeUrl: "https://starknet-sepolia.public.blastapi.io/rpc/v0_7",
    });
    try {
      const contract = new Contract(ABI, contractAddress,  provider ).typedv2(
        ABI
      );
      const counter = await contract.boardNFTboard_current_state(1);
      console.log(counter.toString());
      setRetrievedValue(counter.toString());
    } catch (error) {
      console.log(error);
    }
  };

  return (
    <div className="">
      <header className="">
        <p><b>Address: {address ? address : ""}</b></p>

        <div className="card">
          <p>Increase/Decrease Counter &rarr;</p>
        
          <div className="cardForm">
            <input
              type="submit"
              className="button"
              value="Increase"
              onClick={increaseCounter}
            />
            <input
              type="submit"
              className="button"
              value="Decrease"
              onClick={decreaseCounter}
            />
          </div>

          <hr />
          <div className="cardForm">
            <input
              type="submit"
              className="button"
              value="Get Counter"
              onClick={getCounter}
            />
            <p>{retrievedValue}</p>
          </div>
        </div>
      </header>

      {!connection ? (
        <button
          className="button"
          onClick={openModal}
        >
          Connect Wallet
        </button>
      ) : (
        <button className="" onClick={disconnectTBA}>
          Disconnect
        </button>
      )}

      {isOpen && (
        <TokenBoundModal
          isOpen={isOpen}
          closeModal={closeModal}
          value={value}
          selectedOption={selectedOption}
          handleChange={handleChange}
          handleChangeInput={handleChangeInput}
          onConnect={connectTBA}
        />
      )}
    </div>
  );
}

export default Dapp;