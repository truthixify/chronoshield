#[starknet::contract]
pub mod MarketFactory {
    use core::array;
    use core::num::traits::Zero;
    use openzeppelin::access::ownable::OwnableComponent;
    use openzeppelin::security::ReentrancyGuardComponent;
    use starknet::storage::{
        Map, MutableVecTrait, StoragePathEntry, StoragePointerReadAccess, StoragePointerWriteAccess,
        Vec, VecTrait,
    };
    use starknet::syscalls::deploy_syscall;
    use starknet::{
        ClassHash, ContractAddress, SyscallResultTrait, get_block_timestamp, get_caller_address,
    };
    use crate::interfaces::ifee_splitter::{IFeeSplitterDispatcher, IFeeSplitterDispatcherTrait};
    use crate::interfaces::imarket_factory::IMarketFactory;
    use crate::interfaces::ioutcome_token::{IOutcomeTokenDispatcher, IOutcomeTokenDispatcherTrait};
    use crate::types::{Market, MarketParams, MarketStatus, MarketType};

    #[storage]
    pub struct Storage {
        #[substorage(v0)]
        pub ownable: OwnableComponent::Storage,
        #[substorage(v0)]
        pub reentrancy_guard: ReentrancyGuardComponent::Storage,
        pub outcome_token: ContractAddress,
        pub fee_splitter: ContractAddress,
        // horizon perks
        // horizon token,
        pub next_market_id: u256,
        pub min_creator_stake: u256,
        pub markets: Map<u256, Market>,
        pub all_market_ids: Vec<u256>,
        pub markets_by_category: Map<felt252, Vec<u256>>,
        pub markets_by_creator: Map<ContractAddress, Vec<u256>>,
        pub market_class_hash: ClassHash,
    }

    component!(path: OwnableComponent, storage: ownable, event: OwnableEvent);
    component!(
        path: ReentrancyGuardComponent, storage: reentrancy_guard, event: ReentrancyGuardEvent,
    );

    #[event]
    #[derive(Drop, starknet::Event)]
    pub enum Event {
        #[flat]
        OwnableEvent: OwnableComponent::Event,
        #[flat]
        ReentrancyGuardEvent: ReentrancyGuardComponent::Event,
        MarketCreated: MarketCreated,
        CreatorStakeRefunded: CreatorStakeRefunded,
        MarketStatusUpdated: MarketStatusUpdated,
        MinCreatorStakeUpdated: MinCreatorStakeUpdated,
    }

    #[derive(Drop, starknet::Event)]
    pub struct MarketCreated {
        #[key]
        pub market_id: u256,
        #[key]
        pub creator: ContractAddress,
        #[key]
        pub address: ContractAddress,
        pub collateral_token: ContractAddress,
        pub close_time: u64,
        pub category: felt252,
        pub metadata_uri: felt252,
        pub creator_stake: u256,
    }

    #[derive(Drop, starknet::Event)]
    pub struct CreatorStakeRefunded {
        #[key]
        pub market_id: u256,
        #[key]
        pub creator: ContractAddress,
        pub amount: u256,
    }

    #[derive(Drop, starknet::Event)]
    pub struct MarketStatusUpdated {
        #[key]
        pub market_id: u256,
        pub old_status: MarketStatus,
        pub new_status: MarketStatus,
    }

    #[derive(Drop, starknet::Event)]
    pub struct MinCreatorStakeUpdated {
        pub old_stake: u256,
        pub new_stake: u256,
    }

    #[constructor]
    fn constructor(
        ref self: ContractState,
        outcome_token: ContractAddress,
        fee_splitter: ContractAddress,
        owner: ContractAddress,
    ) {
        self.ownable.initializer(owner);
        assert(
            (outcome_token.is_non_zero() && fee_splitter.is_non_zero() && owner.is_non_zero()),
            'Invalid address',
        );
        self.outcome_token.write(outcome_token);
        self.fee_splitter.write(fee_splitter);
        self.next_market_id.write(1);
        self.min_creator_stake.write(100_u256);
    }

    #[abi(embed_v0)]
    impl OwnableImpl = OwnableComponent::OwnableImpl<ContractState>;
    impl OwnableInternalImpl = OwnableComponent::InternalImpl<ContractState>;

    impl ReentrancyGuardInternalImpl = ReentrancyGuardComponent::InternalImpl<ContractState>;

    impl MarketFactoryImpl of IMarketFactory<ContractState> {
        fn create_market(
            ref self: ContractState, market_params: MarketParams, salt: felt252,
        ) -> u256 {
            assert(market_params.collateral_token.is_non_zero(), 'Invalid collateral token');
            assert(get_block_timestamp() < market_params.close_time, 'Already past close time');
            assert(
                !(market_params.creator_stake < self.min_creator_stake.read()),
                'Insufficient creator stake',
            );
            assert(market_params.category.is_non_zero(), 'Invalid market category');

            let creator = get_caller_address();

            let market_id = self.next_market_id.read();
            self.next_market_id.write(market_id + 1);

            // transfer creator stake with horizon perks

            let outcome_token_dispatcher = IOutcomeTokenDispatcher {
                contract_address: self.outcome_token.read(),
            };
            outcome_token_dispatcher.register_market(market_id, market_params.collateral_token);

            let fee_splitter_dispatcher = IFeeSplitterDispatcher {
                contract_address: self.fee_splitter.read(),
            };
            fee_splitter_dispatcher.register_market(market_id, creator);

            let (market_address, market) = self._deploy_market(market_id, market_params, salt);

            outcome_token_dispatcher.set_market_authorization(market_address, true);

            self.markets.entry(market_id).write(market);
            self.all_market_ids.push(market_id);
            self.markets_by_category.entry(market.category).push(market_id);
            self.markets_by_creator.entry(creator).push(market_id);

            self.emit(
                MarketCreated {
                    market_id,
                    creator,
                    address: market_address,
                    collateral_token: market.collateral_token,
                    close_time: market.close_time,
                    category: market.category,
                    metadata_uri: market.metadata_uri,
                    creator_stake: market.creator_stake
                }
            );

            market_id
        }

        fn refund_creator_stake(ref self: ContractState, market_id: u256) {
            assert(market_id != 0, 'Invalid market id');
            let mut market = self.markets.entry(market_id).read();
            assert(!market.stake_refunded, 'Stake already refunded');

            let outcome_token_dispatcher = IOutcomeTokenDispatcher { contract_address: self.outcome_token.read() };
            assert(outcome_token_dispatcher.is_resolved(market_id), 'Market not resolved');

            market.stake_refunded = true;
            self.markets.entry(market_id).write(market);

            // horizon token transfer back to creator

            self.emit(
                CreatorStakeRefunded {
                    market_id,
                    creator: market.creator,
                    amount: market.creator_stake
                }
            );
        }

        fn update_market_status(ref self: ContractState, market_id: u256) {
            assert(market_id != 0, 'Invalid market id');
            let mut market = self.markets.entry(market_id).read();

            let old_status = market.status;
            let new_status = self._compute_market_status(market);

            assert(old_status != new_status, 'Market unchanged');
            market.status = new_status;

            self.markets.entry(market_id).write(market);
            self.emit(
                MarketStatusUpdated {
                    market_id, old_status, new_status
                }
            );

        }

        fn set_min_creator_stake(ref self: ContractState, new_min_stake: u256) {
            assert(new_min_stake != 0, 'Invalid minimum stake');
            let old_stake = self.min_creator_stake.read();
            self.min_creator_stake.write(new_min_stake);

            self.emit(
                MinCreatorStakeUpdated {
                    old_stake, new_stake: new_min_stake
              }
            );
        }

        fn get_market_count(self: @ContractState) -> u256 {
            self.all_market_ids.len().into()
        }

        fn get_market(self: @ContractState, market_id: u256) -> Market {
            self.markets.entry(market_id).read()
        }

        fn get_all_market_ids(self: @ContractState) -> Array<u256> {
            let mut market_ids = array![];

            for i in 0..self.all_market_ids.len() {
                market_ids.append(self.all_market_ids[i].read());
            }

            market_ids
        }

        fn get_market_ids_by_category(self: @ContractState, category: felt252) -> Array<u256> {
            let mut market_ids = array![];
            let category_ids = self.markets_by_category.entry(category);

            for i in 0..category_ids.len() {
                market_ids.append(category_ids[i].read());
            }

            market_ids
        }

        fn get_market_ids_by_creator(
            self: @ContractState, creator: ContractAddress,
        ) -> Array<u256> {
            let mut market_ids = array![];
            let creator_ids = self.markets_by_creator.entry(creator);

            for i in 0..creator_ids.len() {
                market_ids.append(creator_ids[i].read());
            }

            market_ids
        }

        fn get_markets(self: @ContractState, offset: u256, limit: u256) -> Array<Market> {
            let mut markets = array![];
            for i in offset..limit {
                let market = self.markets.entry(i).read();
                markets.append(market);
            }
            markets
        }

        fn get_active_markets(self: @ContractState, offset: u256, limit: u256) -> Array<Market> {
            let mut markets = array![];
            for i in offset..limit {
                let market = self.markets.entry(i).read();
                if market.status == MarketStatus::ACTIVE {
                    markets.append(market);
                }
            }
            markets
        }

        fn market_exists(self: @ContractState, market_id: u256) -> bool {
            let market = self.markets.entry(market_id).read();

            market.id != 0
        }
    }

    #[generate_trait]
    impl InternalImpl of InternalFunctions {
        fn _deploy_market(
            ref self: ContractState, market_id: u256, market_params: MarketParams, salt: felt252,
        ) -> (ContractAddress, Market) {
            assert(market_params.outcome_count == 2, 'Invalid outcome count');
            let creator = get_caller_address();

            let mut market = Market {
                id: market_id,
                creator,
                market_type: MarketType::BINARY,
                amm: Zero::zero(),
                collateral_token: market_params.collateral_token,
                close_time: market_params.close_time,
                category: market_params.category,
                metadata_uri: market_params.metadata_uri,
                creator_stake: market_params.creator_stake,
                outcome_count: 2,
                stake_refunded: false,
                status: MarketStatus::ACTIVE,
                fixed_fee: market_params.fixed_fee,
            };

            let mut constructor_calldata = array![];
            market_id.serialize(ref constructor_calldata);
            market_params.fixed_fee.serialize(ref constructor_calldata);
            market_params.collateral_token.serialize(ref constructor_calldata);
            self.outcome_token.read().serialize(ref constructor_calldata);
            self.fee_splitter.read().serialize(ref constructor_calldata);
            market_params.close_time.serialize(ref constructor_calldata);
            creator.serialize(ref constructor_calldata);

            let market_class_hash: ClassHash = self.market_class_hash.read();

            let (market_address, _) = deploy_syscall(
                market_class_hash, salt, constructor_calldata.span(), false,
            )
                .unwrap_syscall();

            market.amm = market_address;

            (market_address, market)
        }

        fn _compute_market_status(ref self: ContractState, market: Market) -> MarketStatus {
            let outcome_token_dispatcher = IOutcomeTokenDispatcher { contract_address: self.outcome_token.read() };
            
            if outcome_token_dispatcher.is_resolved(market.id) {
                MarketStatus::RESOLVED
            } else if get_block_timestamp() > market.close_time {
                MarketStatus::CLOSED
            } else {
                MarketStatus::ACTIVE
            }
        }   
    }
}
