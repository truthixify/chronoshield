use starknet::ContractAddress;

#[starknet::interface]
pub trait IFeeSplitter<TContractState> {
    fn register_market(ref self: TContractState, market_id: u256, creator: ContractAddress);
    fn update_fee_config(
        ref self: TContractState,
        market_id: u256,
        protocol_basis_points: u256,
        creator_basis_points: u256,
    );
    fn set_protocol_treasury(ref self: TContractState, new_treasury: ContractAddress);
    fn distribute(
        ref self: TContractState,
        market_id: u256,
        token: ContractAddress,
        amount: u256,
        protocol_basis_points: u256,
    );
    fn claim_creator_fees(ref self: TContractState, market_id: u256, token: ContractAddress);
    fn claim_creator_fees_multiple(
        ref self: TContractState, market_ids: Array<u256>, tokens: Array<ContractAddress>,
    );
    fn claim_protocol_fees(ref self: TContractState, token: ContractAddress);
    fn claim_protocol_fees_multiple(ref self: TContractState, tokens: Array<ContractAddress>);
    fn get_creator_pending_fees(
        self: @TContractState, market_id: u256, token: ContractAddress,
    ) -> u256;
    fn get_protocol_pending_fees(self: @TContractState, token: ContractAddress) -> u256;
    fn get_fee_config(self: @TContractState, market_id: u256) -> (u256, u256);
}
