use starknet::ContractAddress;
use crate::types::ResolutionState;

#[starknet::interface]
pub trait IResolutionModule<TContractState> {
    fn propose_resolution(
        ref self: TContractState,
        market_id: u256,
        outcome_id: u256,
        bond_amount: u256,
        evidence_uri: felt252,
    );
    fn dispute(ref self: TContractState, market_id: u256, bond_amount: u256, reason: ByteArray);
    fn finalize(ref self: TContractState, market_id: u256);
    fn finalize_disputed(
        ref self: TContractState, market_id: u256, outcome_id: u256, slash_proposer: bool,
    );
    fn set_dispute_window(ref self: TContractState, new_window: u64);
    fn set_min_bond(ref self: TContractState, new_min_bond: u256);
    fn set_arbitrator(ref self: TContractState, new_arbitrator: ContractAddress);
    fn get_resolution_state(self: @TContractState, market_id: u256) -> ResolutionState;
    fn can_dispute(self: @TContractState, market_id: u256) -> bool;
    fn can_finalize(self: @TContractState, market_id: u256) -> bool;
    fn get_dispute_time_remaining(self: @TContractState, market_id: u256) -> u64;
}
