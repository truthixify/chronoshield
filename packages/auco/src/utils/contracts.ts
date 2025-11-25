import deployedContracts from "../contracts/deployedContracts";
import globalConfig from "../../auco.config";

// Dynamically extract types from the actual deployedContracts structure
type AvailableNetworks = keyof typeof deployedContracts;
type CurrentNetwork = typeof globalConfig.network extends AvailableNetworks
  ? typeof globalConfig.network
  : AvailableNetworks;
type CurrentNetworkContracts = (typeof deployedContracts)[CurrentNetwork];
type AvailableContracts = keyof CurrentNetworkContracts;

/**
 * Retrieves contract information by name from the deployed contracts configuration
 * for the currently configured network. To be used with auco onEvent or onReorg
 *
 * @param name - The name of the contract to retrieve, must be a valid contract name
 *               for the current network configuration
 * @returns An object containing the contract address and ABI for the specified contract
 *
 * @example
 * ```typescript
 * const { contractAddress, abi } = getContractByName("MyContract");
 * ```
 */
export const getContractByName = <T extends AvailableContracts>(
  name: T,
): {
  contractAddress: CurrentNetworkContracts[T]["address"];
  abi: CurrentNetworkContracts[T]["abi"];
} => {
  return {
    contractAddress:
      deployedContracts[globalConfig.network as CurrentNetwork][name].address,
    abi: deployedContracts[globalConfig.network as CurrentNetwork][name].abi,
  };
};
