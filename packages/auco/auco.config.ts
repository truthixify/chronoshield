import { IndexerConfig } from "auco";

type AucoServerGlobalConfig = {
  network: "devnet" | "sepolia" | "mainnet";
  indexerConfig?: Partial<IndexerConfig>;
};

const globalConfig: AucoServerGlobalConfig = {
  // network type (devnet, sepolia, mainnet)
  network: "devnet",

  // override config for indexer
  indexerConfig: {
    startingBlockNumber: "latest",
  },
} as const;

export default globalConfig;
