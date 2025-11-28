use starknet::ContractAddress;
use crate::types::ProposedOutcome;

#[starknet::interface]
pub trait IAiOracleAdapter<TContractState> {
    fn propose_ai(
        ref self: TContractState,
        proposal: ProposedOutcome,
        signature_r: felt252,
        signature_s: felt252,
        bond_amount: u256,
        evidence_uris: Array<felt252>,
        nonce: felt252,
    );
    fn add_signer(ref self: TContractState, signer: ContractAddress);
    fn remove_signer(ref self: TContractState, signer: ContractAddress);
}
