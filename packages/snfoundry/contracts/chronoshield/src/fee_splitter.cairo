#[starknet::contract]
pub mod FeeSplitter {
    use core::num::traits::Zero;
    use openzeppelin::access::ownable::OwnableComponent;
    use openzeppelin::security::ReentrancyGuardComponent;
    use openzeppelin::token::erc20::interface::{IERC20Dispatcher, IERC20DispatcherTrait};
    use starknet::event::EventEmitter;
    use starknet::storage::{
        Map, StoragePathEntry, StoragePointerReadAccess, StoragePointerWriteAccess,
    };
    use starknet::{ContractAddress, get_caller_address, get_contract_address};
    use crate::interfaces::ifee_splitter::IFeeSplitter;
    use crate::types::FeeConfig;

    #[storage]
    pub struct Storage {
        #[substorage(v0)]
        pub reentrancy_guard: ReentrancyGuardComponent::Storage,
        #[substorage(v0)]
        pub ownable: OwnableComponent::Storage,
        pub markets_to_fee_configs: Map<u256, FeeConfig>, //market_id -> FeeConfig
        pub markets_to_creators: Map<u256, ContractAddress>,
        pub creator_pending_fees: Map<
            u256, Map<ContractAddress, u256>,
        >, //market_id -> token -> amount
        pub protocol_pending_fees: Map<ContractAddress, u256>,
        pub protocol_basis_points: u256,
        pub creator_basis_points: u256,
        pub protocol_treasury: ContractAddress,
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    pub enum Event {
        FeeDistributed: FeeDistributed,
        FeeClaimed: FeeClaimed,
        ProtocolFeeClaimed: ProtocolFeeClaimed,
        MarketRegistered: MarketRegistered,
        FeeConfigUpdated: FeeConfigUpdated,
        #[flat]
        ReentrancyGuardEvent: ReentrancyGuardComponent::Event,
        #[flat]
        OwnableEvent: OwnableComponent::Event,
    }

    component!(
        path: ReentrancyGuardComponent, storage: reentrancy_guard, event: ReentrancyGuardEvent,
    );
    component!(path: OwnableComponent, storage: ownable, event: OwnableEvent);

    #[abi(embed_v0)]
    pub impl OwnableImpl = OwnableComponent::OwnableImpl<ContractState>;
    pub impl OwnableInternalImpl = OwnableComponent::InternalImpl<ContractState>;

    impl ReentrancyGuardInternalImpl = ReentrancyGuardComponent::InternalImpl<ContractState>;

    #[derive(Drop, starknet::Event)]
    pub struct FeeDistributed {
        #[key]
        pub market_id: u256,
        pub token: ContractAddress,
        pub total_amount: u256,
        pub protocol_amount: u256,
        pub creator_amount: u256,
        pub protocol_basis_points: u256,
    }

    #[derive(Drop, starknet::Event)]
    pub struct FeeClaimed {
        #[key]
        pub market_id: u256,
        #[key]
        pub creator: ContractAddress,
        pub token: ContractAddress,
        pub amount: u256,
    }

    #[derive(Drop, starknet::Event)]
    pub struct ProtocolFeeClaimed {
        pub token: ContractAddress,
        pub amount: u256,
    }

    #[derive(Drop, starknet::Event)]
    pub struct MarketRegistered {
        #[key]
        pub market_id: u256,
        #[key]
        pub creator: ContractAddress,
    }

    #[derive(Drop, starknet::Event)]
    pub struct FeeConfigUpdated {
        #[key]
        pub market_id: u256,
        pub protocol_basis_points: u256,
        pub creator_basis_points: u256,
    }

    const BASIS_POINTS_DENOMINATOR: u256 = 10000;

    #[constructor]
    fn constructor(
        ref self: ContractState, owner: ContractAddress, protocol_treasury: ContractAddress,
    ) {
        self.protocol_basis_points.write(1000);
        self.creator_basis_points.write(9000);
        self.ownable.initializer(owner);
        self.protocol_treasury.write(protocol_treasury);
    }

    #[abi(embed_v0)]
    pub impl FeeSplitterImpl of IFeeSplitter<ContractState> {
        fn register_market(ref self: ContractState, market_id: u256, creator: ContractAddress) {
            self.ownable.assert_only_owner();
            let market_creator = self.markets_to_creators.entry(market_id).read();
            assert(market_creator.is_zero(), 'Market already registered');

            self.markets_to_creators.entry(market_id).write(creator);
            self.markets_to_fee_configs.entry(market_id).write(Default::default());

            self.emit(MarketRegistered { market_id, creator })
        }

        fn update_fee_config(
            ref self: ContractState,
            market_id: u256,
            protocol_basis_points: u256,
            creator_basis_points: u256,
        ) {
            let market_creator = self.markets_to_creators.entry(market_id).read();
            assert(market_creator.is_non_zero(), 'Market not registered');
            assert(
                protocol_basis_points + creator_basis_points == BASIS_POINTS_DENOMINATOR,
                'Invalid Fee Config',
            );

            self
                .markets_to_fee_configs
                .entry(market_id)
                .write(FeeConfig { protocol_basis_points, creator_basis_points });

            self.emit(FeeConfigUpdated { market_id, protocol_basis_points, creator_basis_points });
        }

        fn set_protocol_treasury(ref self: ContractState, new_treasury: ContractAddress) {
            assert(new_treasury.is_non_zero(), 'Invalid new treausry');
            self.protocol_treasury.write(new_treasury);
        }

        fn distribute(
            ref self: ContractState,
            market_id: u256,
            token: ContractAddress,
            amount: u256,
            protocol_basis_points: u256,
        ) {
            let market_creator = self.markets_to_creators.entry(market_id).read();
            assert(market_creator.is_non_zero(), 'Market not registered');
            assert(amount != 0, 'Invalid amount');
            assert(!(protocol_basis_points > 10000), 'Invalid fee config');

            let protocol_amount = (amount * protocol_basis_points) / BASIS_POINTS_DENOMINATOR;
            let creator_amount = BASIS_POINTS_DENOMINATOR - protocol_amount;

            self
                .protocol_pending_fees
                .entry(token)
                .write(self.protocol_pending_fees.entry(token).read() + protocol_amount);
            self
                .creator_pending_fees
                .entry(market_id)
                .entry(token)
                .write(
                    self.creator_pending_fees.entry(market_id).entry(token).read() + creator_amount,
                );

            let token_dispatcher = IERC20Dispatcher { contract_address: token };
            token_dispatcher.transfer_from(get_caller_address(), get_contract_address(), amount);

            self
                .emit(
                    FeeDistributed {
                        market_id,
                        token,
                        total_amount: amount,
                        protocol_amount,
                        creator_amount,
                        protocol_basis_points,
                    },
                );
        }

        fn claim_creator_fees(ref self: ContractState, market_id: u256, token: ContractAddress) {
            let creator = self.markets_to_creators.entry(market_id).read();
            assert(get_caller_address() == creator, 'Not the creator');

            let amount = self.creator_pending_fees.entry(market_id).entry(token).read();
            assert(amount != 0, 'No fees to claim');

            self.creator_pending_fees.entry(market_id).entry(token).write(0);

            let token_dispatcher = IERC20Dispatcher { contract_address: token };
            token_dispatcher.transfer(creator, amount);

            self.emit(FeeClaimed { market_id, creator, token, amount });
        }

        fn claim_creator_fees_multiple(
            ref self: ContractState, market_ids: Array<u256>, tokens: Array<ContractAddress>,
        ) {
            assert(market_ids.len() == tokens.len(), 'Array lengths mismatch');

            for i in 0..market_ids.len() {
                let market_id = *market_ids.at(i);
                let token = *tokens.at(i);

                let creator = self.markets_to_creators.entry(market_id).read();

                if (creator.is_zero()) {
                    continue;
                }

                let creator_pending_fees = self
                    .creator_pending_fees
                    .entry(market_id)
                    .entry(token)
                    .read();
                if (creator_pending_fees.is_zero()) {
                    continue;
                }

                self.creator_pending_fees.entry(market_id).entry(token).write(0);

                let token_dispatcher = IERC20Dispatcher { contract_address: token };
                token_dispatcher.transfer(creator, creator_pending_fees);

                self.emit(FeeClaimed { market_id, creator, token, amount: creator_pending_fees });
            }
        }

        fn claim_protocol_fees(ref self: ContractState, token: ContractAddress) {
            let protocol_treasury = self.protocol_treasury.read();
            assert(get_caller_address() == protocol_treasury, 'Not authorized');

            let amount = self.protocol_pending_fees.entry(token).read();
            assert(amount != 0, 'Inavlid amount');

            self.protocol_pending_fees.entry(token).write(0);

            let token_dispatcher = IERC20Dispatcher { contract_address: token };
            token_dispatcher.transfer(protocol_treasury, amount);

            self.emit(ProtocolFeeClaimed { token, amount });
        }

        fn claim_protocol_fees_multiple(ref self: ContractState, tokens: Array<ContractAddress>) {
            let protocol_treasury = get_caller_address();
            assert(protocol_treasury == self.protocol_treasury.read(), 'Not authorized');
            for i in 0..tokens.len() {
                let token = *tokens.at(i);
                let amount = self.protocol_pending_fees.entry(token).read();

                assert(amount != 0, 'Invalid amount');

                self.protocol_pending_fees.entry(token).write(0);

                let token_dispatcher = IERC20Dispatcher { contract_address: token };
                token_dispatcher.transfer(protocol_treasury, amount);

                self.emit(ProtocolFeeClaimed { token, amount });
            }
        }

        fn get_creator_pending_fees(
            self: @ContractState, market_id: u256, token: ContractAddress,
        ) -> u256 {
            self.creator_pending_fees.entry(market_id).entry(token).read()
        }

        fn get_protocol_pending_fees(self: @ContractState, token: ContractAddress) -> u256 {
            self.protocol_pending_fees.entry(token).read()
        }

        fn get_fee_config(self: @ContractState, market_id: u256) -> (u256, u256) {
            let fee_config = self.markets_to_fee_configs.entry(market_id).read();
            (fee_config.protocol_basis_points, fee_config.creator_basis_points)
        }
    }
}
