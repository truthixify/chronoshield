import { useReadContract, useSendTransaction, useContract } from "@starknet-react/core";
import { marketAbi } from "@/lib/abis";
import { useMemo } from "react";
import { shortString } from "starknet";

export function useMarketData(marketAddress: string) {
  const { data: marketInfo, isLoading: isLoadingInfo } = useReadContract({
    abi: marketAbi,
    address: marketAddress,
    functionName: "get_market_info",
    args: [],
  });

  const { data: reserves, isLoading: isLoadingReserves } = useReadContract({
    abi: marketAbi,
    address: marketAddress,
    functionName: "get_reserves",
    args: [],
    refetchInterval: 5000, // Refresh every 5 seconds
  });

  return {
    marketInfo,
    reserves,
    isLoading: isLoadingInfo || isLoadingReserves,
  };
}

export function useMarketActions(marketAddress: string) {
  const { contract } = useContract({
    abi: marketAbi,
    address: marketAddress,
  });

  const { send: buy, isPending: isBuying } = useSendTransaction({
    calls: undefined,
  });

  const handleBuy = (outcomeId: number, amount: string) => {
      // This requires constructing the Call object manually if not using useContractWrite bound to a function
      // But typically useSendTransaction takes an array of calls.
      // Ideally we use useContractWrite if available for single function.
      
      // Simplified for now - the integration in page will handle the call construction
      // or we return the contract instance.
      return { buy, isBuying };
  };

  return { contract };
}

