use starknet::ContractAddress;

#[derive(Copy, Drop, Serde, starknet::Store)]
pub enum MarketType {
    #[default]
    BINARY,
    MULTICHOICE,
    LIMITORDER,
    POOLEDlIQUIDITY,
}

#[derive(Copy, Drop, Serde, starknet::Store)]
pub struct MarketInfo {
    pub market_id: u256,
    pub market_type: MarketType,
    pub close_time: u64,
    pub outcome_count: u256,
    pub is_resolved: bool,
    pub is_paused: bool,
    pub collateral_token: ContractAddress,
}

