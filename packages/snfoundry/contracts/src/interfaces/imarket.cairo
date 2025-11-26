use crate::types::{MarketInfo, MarketType};
use starknet::ContractAddress;

#[starknet::interface]
pub trait IMarket<T> {
    fn get_market_type(self: @T) -> MarketType;
    fn get_market_info(self: @T) -> MarketInfo;
    // fn buy(ref self: T, outcome_id: u8, collateral_in: u256, min_tokens_out: u256) -> u256;
    fn buy(ref self: T, outcome_id: u256, collateral_in: u256, min_tokens_out: u256) -> u256;
    fn sell(ref self: T, outcome_id: u256, tokens_in: u256, min_collateral_out: u256) -> u256;
    // fn sell(ref self: T, outcome_id: u8, tokens_in: u256, min_collateral_out: u256) -> u256;
    fn add_liquidity(ref self: T, amount: u256);
    fn remove_liquidity(ref self: T, tokens: u256);
    fn get_price(self: @T, outcome_id: u256) -> u256;
    fn getQuoteBuy(self: @T, outcome_id: u256, collateral_in: u256, user: ContractAddress) -> (u256, u256);
    fn getQuoteSell(self: @T, outcome_id: u256, tokens_in: u256, user: ContractAddress) -> (u256, u256);
    fn get_reserves(self: @T) -> (u256, u256);
    fn fund_redemptions(ref self: T);
}
