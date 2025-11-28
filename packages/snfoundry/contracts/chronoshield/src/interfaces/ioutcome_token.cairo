use starknet::ContractAddress;

#[starknet::interface]
pub trait IOutcomeToken<TContractState> {
    // Admin Functions

    fn authorize_market(ref self: TContractState, market: ContractAddress, authorized: bool);
    fn register_market(ref self: TContractState, market_id: u256, collateral: ContractAddress);
    fn set_winning_outcome(ref self: TContractState, market_id: u256, outcome_id: u256);

    // Market Functions
    fn mint_outcome(
        ref self: TContractState,
        market_id: u256,
        outcome_id: u256,
        to: ContractAddress,
        amount: u256,
    );

    fn burn_outcome(
        ref self: TContractState,
        market_id: u256,
        outcome_id: u256,
        from: ContractAddress,
        amount: u256,
    );

    // Read functions
    fn balance_of_outcome(
        self: @TContractState, user: ContractAddress, market_id: u256, outcome_id: u256,
    ) -> u256;
    fn is_resolved(self: @TContractState, market_id: u256) -> bool;
}
