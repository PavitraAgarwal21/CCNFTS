export default function Home() {
    return (
      <main className="flex min-h-screen flex-col items-center justify-between py-24 md:p-24">
       
        <div className="mb-32 grid md:grid-cols-2 md:text-start text-center  lg:w-full lg:mb-0 lg:grid-cols-4 lg:text-left lg:max-w-5xl">
          <a
            href="/Chessboard"
            className="group rounded-lg border border-transparent px-5 py-4 transition-colors hover:border-gray-300 hover:bg-gray-100 hover:dark:border-neutral-700 hover:dark:bg-neutral-800/30"
            target="_blank"
            rel="noopener noreferrer"
          >
            <h2 className={`mb-3 text-2xl font-semibold`}>
              Scaffold Deployer{" "}
              <span className="inline-block transition-transform group-hover:translate-x-1 motion-reduce:transform-none">
                -&gt;
              </span>
            </h2>
            <p className={`m-0 max-w-[30ch] text-sm opacity-50`}>
              A simple tool for seamlessly deploying smart contracts to Starknet
              testnet and mainnet <br />
              <br />
            </p>
          </a>
          <a
            href="https://starknet-faucet.vercel.app"
            className="group rounded-lg border border-transparent px-5 py-4 transition-colors hover:border-gray-300 hover:bg-gray-100 hover:dark:border-neutral-700 hover:dark:bg-neutral-800/30"
            target="_blank"
            rel="noopener noreferrer"
          >
            <h2 className={`mb-3 text-2xl font-semibold`}>
              Sepolia Faucet{" "}
              <span className="inline-block transition-transform group-hover:translate-x-1 motion-reduce:transform-none">
                -&gt;
              </span>
            </h2>
            <p className={`m-0 max-w-[30ch] text-sm opacity-50`}>
              A sepETH/sepSTRK faucet for claiming ETH/STRK sepolia testnet tokens{" "}
            </p>
          </a>
        </div>
      </main>
    );
  }