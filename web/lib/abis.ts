export const marketAbi = [
  {
    type: "impl",
    name: "MarketImpl",
    interface_name: "chronoshield::interfaces::imarket::IMarket",
  },
  {
    type: "struct",
    name: "core::integer::u256",
    members: [
      { name: "low", type: "core::integer::u128" },
      { name: "high", type: "core::integer::u128" },
    ],
  },
  {
    type: "enum",
    name: "chronoshield::types::MarketType",
    variants: [
      { name: "BINARY", type: "()" },
      { name: "MULTICHOICE", type: "()" },
      { name: "LIMITORDER", type: "()" },
      { name: "POOLEDlIQUIDITY", type: "()" },
    ],
  },
  {
    type: "struct",
    name: "chronoshield::types::MarketInfo",
    members: [
      { name: "market_id", type: "core::integer::u256" },
      { name: "market_type", type: "chronoshield::types::MarketType" },
      { name: "close_time", type: "core::integer::u64" },
      { name: "outcome_count", type: "core::integer::u256" },
      { name: "is_resolved", type: "core::bool" },
      { name: "is_paused", type: "core::bool" },
      { name: "collateral_token", type: "core::starknet::contract_address::ContractAddress" },
    ],
  },
  {
    type: "interface",
    name: "chronoshield::interfaces::imarket::IMarket",
    items: [
      {
        type: "function",
        name: "get_market_info",
        inputs: [],
        outputs: [{ type: "chronoshield::types::MarketInfo" }],
        state_mutability: "view",
      },
      {
        type: "function",
        name: "get_reserves",
        inputs: [],
        outputs: [
          { type: "core::integer::u256" },
          { type: "core::integer::u256" },
        ],
        state_mutability: "view",
      },
       {
        type: "function",
        name: "buy",
        inputs: [
            { name: "outcome_id", type: "core::integer::u256" },
            { name: "collateral_in", type: "core::integer::u256" },
            { name: "min_tokens_out", type: "core::integer::u256" }
        ],
        outputs: [{ type: "core::integer::u256" }],
        state_mutability: "external",
      },
    ],
  },
] as const;

