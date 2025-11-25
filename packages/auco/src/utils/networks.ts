export const getPublicRpcFromNetwork = (
  network: "devnet" | "sepolia" | "mainnet",
) => {
  switch (network) {
    case "devnet":
      return "http://127.0.0.1:5050";
    case "sepolia":
      return "https://starknet-sepolia.blastapi.io/64168c77-3fa5-4e1e-9fe4-41675d212522/rpc/v0_8";
    case "mainnet":
      return "https://starknet-mainnet.blastapi.io/64168c77-3fa5-4e1e-9fe4-41675d212522/rpc/v0_8";
    default:
      throw new Error(`Unsupported network: ${network}`);
  }
};

export const getPublicWsFromNetwork = (
  network: "devnet" | "sepolia" | "mainnet",
) => {
  switch (network) {
    case "devnet":
      return "ws://127.0.0.1:5050/ws";
    case "sepolia":
      return "wss://starknet-sepolia.blastapi.io/64168c77-3fa5-4e1e-9fe4-41675d212522/rpc/v0_8";
    case "mainnet":
      return "wss://starknet-mainnet.blastapi.io/64168c77-3fa5-4e1e-9fe4-41675d212522/rpc/v0_8";
    default:
      throw new Error(`Unsupported network: ${network}`);
  }
};
