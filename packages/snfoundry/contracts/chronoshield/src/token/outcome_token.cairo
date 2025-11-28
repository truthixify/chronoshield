#[starknet::contract]
pub mod OutcomeToken {
    use openzeppelin::access::ownable::OwnableComponent;
    use openzeppelin::introspection::src5::SRC5Component;
    use openzeppelin::token::erc1155::{ERC1155Component, ERC1155HooksEmptyImpl};
    use starknet::event::EventEmitter;
    use starknet::storage::{
        Map, StoragePathEntry, StoragePointerReadAccess, StoragePointerWriteAccess,
    };
    use starknet::{ContractAddress, get_caller_address};
    use crate::interfaces::ioutcome_token::IOutcomeToken;

    #[storage]
    pub struct Storage {
        #[substorage(v0)]
        pub erc1155: ERC1155Component::Storage,
        #[substorage(v0)]
        pub src5: SRC5Component::Storage,
        #[substorage(v0)]
        pub ownable: OwnableComponent::Storage,
        pub authorized_markets: Map<ContractAddress, bool>,
        pub market_collateral: Map<u256, ContractAddress>, //market_id -> ContractAddress
        pub winning_outcome: Map<u256, u256> // market_id -> outcome_id
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    pub enum Event {
        #[flat]
        ERC1155Event: ERC1155Component::Event,
        #[flat]
        SRC5Event: SRC5Component::Event,
        #[flat]
        OwnableEvent: OwnableComponent::Event,
        OutcomeMinted: OutcomeMinted,
        OutcomeBurned: OutcomeBurned,
        WinningOutcomeSet: WinningOutcomeSet,
    }

    #[derive(Drop, starknet::Event)]
    pub struct OutcomeMinted {
        pub market_id: u256,
        pub outcome_id: u256,
        pub to: ContractAddress,
        pub amount: u256,
    }

    #[derive(Drop, starknet::Event)]
    pub struct OutcomeBurned {
        pub market_id: u256,
        pub outcome_id: u256,
        pub from: ContractAddress,
        pub amount: u256,
    }

    #[derive(Drop, starknet::Event)]
    pub struct WinningOutcomeSet {
        market_id: u256,
        outcome_id: u256,
    }

    component!(path: ERC1155Component, storage: erc1155, event: ERC1155Event);
    component!(path: SRC5Component, storage: src5, event: SRC5Event);
    component!(path: OwnableComponent, storage: ownable, event: OwnableEvent);

    #[abi(embed_v0)]
    impl ERC1155MixinImpl = ERC1155Component::ERC1155MixinImpl<ContractState>;
    impl ERC1155InternalImpl = ERC1155Component::InternalImpl<ContractState>;

    #[abi(embed_v0)]
    impl OwnableImpl = OwnableComponent::OwnableImpl<ContractState>;
    impl OwnableInternalImpl = OwnableComponent::InternalImpl<ContractState>;

    #[constructor]
    fn constructor(ref self: ContractState, uri: ByteArray, owner: ContractAddress) {
        self.erc1155.initializer(uri);
        self.ownable.initializer(owner);
    }

    const UNRESOLVED: u256 = 0xffffffffffffffffffffffffffffffff; // max u256

    impl OutcomeTokenImpl of IOutcomeToken<ContractState> {
        // Admin Functions

        fn authorize_market(ref self: ContractState, market: ContractAddress, authorized: bool) {
            self.ownable.assert_only_owner();
            self.authorized_markets.entry(market).write(true);
        }

        fn register_market(ref self: ContractState, market_id: u256, collateral: ContractAddress) {
            self.ownable.assert_only_owner();
            self.market_collateral.entry(market_id).write(collateral);
            self.winning_outcome.entry(market_id).write(UNRESOLVED);
        }

        fn set_winning_outcome(ref self: ContractState, market_id: u256, outcome_id: u256) {
            let market = get_caller_address();
            assert(self.authorized_markets.entry(market).read(), 'Unauthorized market');
            assert(self.winning_outcome.entry(market_id).read() == UNRESOLVED, 'Already resolved');

            self.winning_outcome.entry(market_id).write(outcome_id);
            self.emit(WinningOutcomeSet { market_id, outcome_id });
        }

        // Market Functions
        fn mint_outcome(
            ref self: ContractState,
            market_id: u256,
            outcome_id: u256,
            to: ContractAddress,
            amount: u256,
        ) {
            let market = get_caller_address();
            assert((self.authorized_markets.entry(market).read()), 'Unauthorized market');
            let token_id = self.encode_token_id(market_id, outcome_id);

            self.erc1155.mint_with_acceptance_check(to, token_id, amount, array![].span());

            self.emit(OutcomeMinted { market_id, outcome_id, to, amount });
        }

        fn burn_outcome(
            ref self: ContractState,
            market_id: u256,
            outcome_id: u256,
            from: ContractAddress,
            amount: u256,
        ) {
            let market = get_caller_address();
            assert((self.authorized_markets.entry(market).read()), 'Unauthorized market');
            let token_id = self.encode_token_id(market_id, outcome_id);

            self.erc1155.burn(from, token_id, amount);
            self.emit(OutcomeBurned { market_id, outcome_id, from, amount });
        }

        // Read functions
        fn balance_of_outcome(
            self: @ContractState, user: ContractAddress, market_id: u256, outcome_id: u256,
        ) -> u256 {
            let token_id = (market_id * 256) + outcome_id;
            self.erc1155.balance_of(user, token_id)
        }

        fn is_resolved(self: @ContractState, market_id: u256) -> bool {
            self.winning_outcome.entry(market_id).read() != UNRESOLVED
        }
    }

    #[generate_trait]
    impl OutcomeTokenInternalImpl of InternalFunctions {
        fn encode_token_id(ref self: ContractState, market_id: u256, outcome_id: u256) -> u256 {
            (market_id * 256) + outcome_id
        }

        fn decode_token_id(ref self: ContractState, token_id: u256) -> (u256, u256) {
            let outcome_id = token_id % 256;
            let market_id = token_id / 256;
            (market_id, outcome_id)
        }
    }
}
