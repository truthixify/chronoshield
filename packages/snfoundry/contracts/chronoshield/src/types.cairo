use core::hash::{HashStateExTrait, HashStateTrait};
use core::poseidon::PoseidonTrait;
use openzeppelin::utils::snip12::StructHash;
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

#[derive(Copy, Drop, Serde, Default, starknet::Store)]
pub struct FeeConfig {
    pub protocol_basis_points: u256,
    pub creator_basis_points: u256,
}

#[derive(Copy, Drop, Serde, Hash, starknet::Store)]
pub struct ProposedOutcome {
    pub market_id: u256,
    pub outcome_id: u256,
    pub close_time: u64,
    pub evidence_hash: felt252,
    pub not_before: u64,
    pub deadline: u64,
}

// Since there's no u64 type in SNIP-12, we use u128 for `expiry` in the type hash generation.
const STARKNET_DOMAIN_TYPE_HASH: felt252 = selector!(
    "\"StarknetDomain\"(\"name\":\"felt\",\"version\":\"felt\",\"chain_id\":\"felt\",\"revision\":\"felt\")",
);

const PROPOSAL_TYPE_OUTCOME: felt252 = selector!(
    "\"ProposedOutcome\"(\"market_id\":\"u256\",\"outcome_id\":\"u256\",\"close_time\":\"u128\",\"evidence_hash\":\"felt\",\"not_before\":\"u128\",\"deadline\":\"u128\")\"u256\"(\"low\":\"u128\",\"high\":\"u128\")",
);


#[derive(Copy, Drop, Serde, Hash)]
pub struct StarknetDomain {
    name: felt252,
    version: felt252,
    chain_id: felt252,
    revision: felt252,
}

impl StructHashImpl of StructHash<StarknetDomain> {
    fn hash_struct(self: @StarknetDomain) -> felt252 {
        let hash_state = PoseidonTrait::new();
        hash_state.update_with(STARKNET_DOMAIN_TYPE_HASH).update_with(*self).finalize()
    }
}

impl ProposalStructHashImpl of StructHash<ProposedOutcome> {
    fn hash_struct(self: @ProposedOutcome) -> felt252 {
        let hash_state = PoseidonTrait::new();
        hash_state.update_with(PROPOSAL_TYPE_OUTCOME).update_with(*self).finalize()
    }
}

#[derive(Copy, Drop, Serde, PartialEq, starknet::Store)]
pub enum ResolutionState {
    #[default]
    NONE,
    PROPOSED,
    DISPUTED,
    FINALIZED,
}

#[derive(Copy, Drop, Serde, starknet::Store)]
pub struct Resolution {
    pub state: ResolutionState,
    pub proposed_outcome: u256,
    pub proposal_time: u64,
    pub proposer: ContractAddress,
    pub proposer_bond: u256,
    pub disputer: ContractAddress,
    pub disputer_bond: u256,
    pub evidence_uri: felt252,
    pub has_been_disputed: bool,
}

#[derive(Copy, Drop, Serde, PartialEq, starknet::Store)]
pub enum MarketStatus {
    #[default]
    ACTIVE,
    CLOSED,
    RESOLVED,
    INVALID,
}

#[derive(Copy, Drop, Serde, starknet::Store)]
pub struct MarketParams {
    pub market_type: MarketType,
    pub collateral_token: ContractAddress,
    pub close_time: u64,
    pub category: felt252,
    pub metadata_uri: felt252,
    pub creator_stake: u256,
    pub outcome_count: u8,
    pub liquid_parameter: u256,
    pub fixed_fee: u256,
}

#[derive(Copy, Drop, Serde, starknet::Store)]
pub struct Market {
    pub id: u256,
    pub creator: ContractAddress,
    pub market_type: MarketType,
    pub amm: ContractAddress,
    pub collateral_token: ContractAddress,
    pub close_time: u64,
    pub category: felt252,
    pub metadata_uri: felt252,
    pub creator_stake: u256,
    pub outcome_count: u8,
    pub stake_refunded: bool,
    pub status: MarketStatus,
    pub fixed_fee: u256,
}
