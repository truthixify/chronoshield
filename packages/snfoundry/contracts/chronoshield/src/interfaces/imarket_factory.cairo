use crate::types::MarketParams;

#[starknet::interface]
pub trait IMarketFactory<TContractState> {
    fn create_market(ref self: TContractState, market_params: MarketParams) -> u256;

}
