use starknet::ContractAddress;
use crate::types::{Market, MarketParams};

#[starknet::interface]
pub trait IMarketFactory<TContractState> {
    fn create_market(ref self: TContractState, market_params: MarketParams, salt: felt252) -> u256;
    fn refund_creator_stake(ref self: TContractState, market_id: u256);
    fn update_market_status(ref self: TContractState, market_id: u256);
    fn set_min_creator_stake(ref self: TContractState, new_min_stake: u256);
    fn get_market_count(self: @TContractState) -> u256;
    fn get_market(self: @TContractState, market_id: u256) -> Market;
    fn get_all_market_ids(self: @TContractState) -> Array<u256>;
    fn get_market_ids_by_category(self: @TContractState, category: felt252) -> Array<u256>;
    fn get_market_ids_by_creator(self: @TContractState, creator: ContractAddress) -> Array<u256>;
    fn get_markets(self: @TContractState, offset: u256, limit: u256) -> Array<Market>;
    fn get_active_markets(self: @TContractState, offset: u256, limit: u256) -> Array<Market>;
    fn market_exists(self: @TContractState, market_id: u256) -> bool;
}
