use starknet::ContractAddress;

#[starknet::interface]
pub trait ILPToken<T> {
    fn mint(ref self: T, recipient: ContractAddress, amount: u256);
    fn burn(ref self: T, recipient: ContractAddress, amount: u256);
}
