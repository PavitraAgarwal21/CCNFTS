export const JSON_RPC:string = "https://starknet-sepolia.public.blastapi.io/rpc/v0_7"
export const IMPLEMENTATION_HASH:string = "0x45d67b8590561c9b54e14dd309c9f38c4e2c554dd59414021f9d079811621bd"
export const REGISTRY_ADDRESS:string = "0x4101d3fa033024654083dd982273a300cb019b8cb96dd829267a4daf59f7b7e"
export  const TOKEN_CONTRACT:string = "0x2e3460eadecd9e00d9cf1c9c26fac4c45ba767b150cc697399ece5e54927411"
export const TOKEN_ID:string = "1"

export const shortenAddress = (address: string) => {
    if (!address) return null;
    return `${address.substr(0, 6)}...${address.substr(
      address.length - 4,
      address.length
    )}`;
  };