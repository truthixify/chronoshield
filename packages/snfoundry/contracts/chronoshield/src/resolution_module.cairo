#[starknet::contract]
pub mod ResolutionModule {
    use core::num::traits::Zero;
    use openzeppelin::access::ownable::OwnableComponent;
    use openzeppelin::security::ReentrancyGuardComponent;
    use openzeppelin::token::erc20::interface::{IERC20Dispatcher, IERC20DispatcherTrait};
    use starknet::event::EventEmitter;
    use starknet::storage::{
        Map, StoragePathEntry, StoragePointerReadAccess, StoragePointerWriteAccess,
    };
    use starknet::{ContractAddress, get_block_timestamp, get_caller_address, get_contract_address};
    use crate::interfaces::ioutcome_token::{IOutcomeTokenDispatcher, IOutcomeTokenDispatcherTrait};
    use crate::interfaces::iresolution_module::IResolutionModule;
    use crate::types::{Resolution, ResolutionState};

    #[storage]
    pub struct Storage {
        pub outcome_token: ContractAddress,
        pub bond_token: ContractAddress,
        pub resolutions: Map<u256, Resolution>, //market_id => Resolution
        pub dispute_window: u64,
        pub min_bond: u256,
        pub arbitrator: ContractAddress,
        #[substorage(v0)]
        pub ownable: OwnableComponent::Storage,
        #[substorage(v0)]
        pub reentrancy_guard: ReentrancyGuardComponent::Storage,
    }

    component!(
        path: ReentrancyGuardComponent, storage: reentrancy_guard, event: ReentrancyGuardEvent,
    );
    component!(path: OwnableComponent, storage: ownable, event: OwnableEvent);

    #[event]
    #[derive(Drop, starknet::Event)]
    pub enum Event {
        ResolutionProposed: ResolutionProposed,
        Disputed: Disputed,
        Finalized: Finalized,
        BondRefunded: BondRefunded,
        BondSlashed: BondSlashed,
        DisputeWindowUpdated: DisputeWindowUpdated,
        MinBondUpdated: MinBondUpdated,
        ArbitratorUpdated: ArbitratorUpdated,
        #[flat]
        OwnableEvent: OwnableComponent::Event,
        #[flat]
        ReentrancyGuardEvent: ReentrancyGuardComponent::Event,
    }

    #[derive(Drop, starknet::Event)]
    pub struct ResolutionProposed {
        #[key]
        pub market_id: u256,
        #[key]
        pub outcome_id: u256,
        #[key]
        pub proposer: ContractAddress,
        pub bond: u256,
        pub evidence_uri: felt252,
        pub deadline: u64,
    }

    #[derive(Drop, starknet::Event)]
    pub struct Disputed {
        #[key]
        pub market_id: u256,
        #[key]
        pub disputer: ContractAddress,
        pub bond: u256,
        pub reason: ByteArray,
    }

    #[derive(Drop, starknet::Event)]
    pub struct Finalized {
        #[key]
        pub market_id: u256,
        #[key]
        pub outcome_id: u256,
        pub was_disputed: bool,
    }

    #[derive(Drop, starknet::Event)]
    pub struct BondRefunded {
        #[key]
        pub recipient: ContractAddress,
        pub amount: u256,
    }

    #[derive(Drop, starknet::Event)]
    pub struct BondSlashed {
        #[key]
        pub slashed_address: ContractAddress,
        #[key]
        pub recipient: ContractAddress,
        pub amount: u256,
    }

    #[derive(Drop, starknet::Event)]
    pub struct DisputeWindowUpdated {
        pub old_window: u64,
        pub new_window: u64,
    }

    #[derive(Drop, starknet::Event)]
    pub struct MinBondUpdated {
        pub old_bond: u256,
        pub new_bond: u256,
    }

    #[derive(Drop, starknet::Event)]
    pub struct ArbitratorUpdated {
        #[key]
        pub old_arbitrator: ContractAddress,
        #[key]
        pub new_arbitrator: ContractAddress,
    }

    #[constructor]
    fn constructor(
        ref self: ContractState,
        bond_token: ContractAddress,
        outcome_token: ContractAddress,
        arbitrator: ContractAddress,
    ) {
        self.bond_token.write(bond_token);
        self.outcome_token.write(outcome_token);
        self.arbitrator.write(arbitrator);
        self.dispute_window.write(48 * 60 * 60);
        self.min_bond.write(1000);
    }

    #[abi(embed_v0)]
    impl OwnableImpl = OwnableComponent::OwnableImpl<ContractState>;
    impl OwnableInternalImpl = OwnableComponent::InternalImpl<ContractState>;

    impl ReentrancyGuardInternalImpl = ReentrancyGuardComponent::InternalImpl<ContractState>;

    #[abi(embed_v0)]
    pub impl ResolutionModuleImpl of IResolutionModule<ContractState> {
        fn propose_resolution(
            ref self: ContractState,
            market_id: u256,
            outcome_id: u256,
            bond_amount: u256,
            evidence_uri: felt252,
        ) {
            let caller = get_caller_address();
            let now = get_block_timestamp();

            let resolution = Resolution {
                state: ResolutionState::PROPOSED,
                proposed_outcome: outcome_id,
                proposal_time: now,
                proposer: caller,
                proposer_bond: bond_amount,
                evidence_uri,
                disputer: Zero::zero(),
                disputer_bond: 0,
                has_been_disputed: false,
            };

            let outcome_token_dispatcher = IOutcomeTokenDispatcher {
                contract_address: self.outcome_token.read(),
            };
            assert(!(outcome_token_dispatcher.is_resolved(market_id)), 'Market Already Resolved');
            assert(!(bond_amount < self.min_bond.read()), 'Insufficient Bond');

            let bond_token_dispatcher = IERC20Dispatcher {
                contract_address: self.bond_token.read(),
            };
            bond_token_dispatcher.transfer_from(caller, get_contract_address(), bond_amount);

            self.resolutions.entry(market_id).write(resolution);

            self
                .emit(
                    ResolutionProposed {
                        market_id,
                        outcome_id,
                        proposer: caller,
                        bond: bond_amount,
                        evidence_uri,
                        deadline: now + self.dispute_window.read(),
                    },
                );
        }

        fn dispute(ref self: ContractState, market_id: u256, bond_amount: u256, reason: ByteArray) {
            let mut resolution = self.resolutions.entry(market_id).read();
            assert(resolution.state == ResolutionState::PROPOSED, 'Invalid resolution state');

            let now = get_block_timestamp();
            assert(
                now > (resolution.proposal_time + self.dispute_window.read()),
                'Dispute window closed',
            );
            assert(!(bond_amount < self.min_bond.read()), 'Insufficient bond');

            let caller = get_caller_address();

            let bond_token_dispatcher = IERC20Dispatcher {
                contract_address: self.bond_token.read(),
            };
            bond_token_dispatcher.transfer_from(caller, get_contract_address(), bond_amount);

            resolution.state = ResolutionState::DISPUTED;
            resolution.disputer = caller;
            resolution.disputer_bond = bond_amount;
            resolution.has_been_disputed = true;

            self.resolutions.entry(market_id).write(resolution);

            self.emit(Disputed { market_id, disputer: caller, bond: bond_amount, reason });
        }

        fn finalize(ref self: ContractState, market_id: u256) {
            let mut resolution = self.resolutions.entry(market_id).read();
            assert(resolution.state == ResolutionState::PROPOSED, 'Invalid State');

            let now = get_block_timestamp();
            assert(
                now < (resolution.proposal_time + self.dispute_window.read()),
                'Dispute window open',
            );

            resolution.state = ResolutionState::FINALIZED;

            let outcome_token_dispatcher = IOutcomeTokenDispatcher {
                contract_address: self.outcome_token.read(),
            };
            outcome_token_dispatcher.set_winning_outcome(market_id, resolution.proposed_outcome);

            let bond_token_dispatcher = IERC20Dispatcher {
                contract_address: self.bond_token.read(),
            };
            bond_token_dispatcher.transfer(resolution.proposer, resolution.proposer_bond);
            self.resolutions.entry(market_id).write(resolution);

            self
                .emit(
                    BondRefunded {
                        recipient: resolution.proposer, amount: resolution.proposer_bond,
                    },
                );

            self
                .emit(
                    Finalized {
                        market_id,
                        outcome_id: resolution.proposed_outcome,
                        was_disputed: resolution.has_been_disputed,
                    },
                );
        }

        fn finalize_disputed(
            ref self: ContractState, market_id: u256, outcome_id: u256, slash_proposer: bool,
        ) {
            let caller = get_caller_address();
            assert(
                caller == self.arbitrator.read() && caller == self.ownable.owner(),
                'Unauthorized caller',
            );

            let mut resolution = self.resolutions.entry(market_id).read();
            assert(resolution.state == ResolutionState::DISPUTED, 'Invalid State');

            resolution.state = ResolutionState::FINALIZED;

            let outcome_token_dispatcher = IOutcomeTokenDispatcher {
                contract_address: self.outcome_token.read(),
            };
            outcome_token_dispatcher.set_winning_outcome(market_id, outcome_id);

            self.resolutions.entry(market_id).write(resolution);

            let bond_token_dispatcher = IERC20Dispatcher {
                contract_address: self.bond_token.read(),
            };

            if (slash_proposer) {
                bond_token_dispatcher.transfer(resolution.disputer, resolution.disputer_bond);

                self
                    .emit(
                        BondRefunded {
                            recipient: resolution.disputer, amount: resolution.disputer_bond,
                        },
                    );

                bond_token_dispatcher.transfer(resolution.disputer, resolution.proposer_bond);
                self
                    .emit(
                        BondSlashed {
                            slashed_address: resolution.proposer,
                            recipient: resolution.disputer,
                            amount: resolution.proposer_bond,
                        },
                    );
            } else {
                bond_token_dispatcher.transfer(resolution.proposer, resolution.proposer_bond);
                self
                    .emit(
                        BondRefunded {
                            recipient: resolution.proposer, amount: resolution.proposer_bond,
                        },
                    );

                bond_token_dispatcher.transfer(resolution.proposer, resolution.disputer_bond);
                self
                    .emit(
                        BondSlashed {
                            slashed_address: resolution.disputer,
                            recipient: resolution.proposer,
                            amount: resolution.disputer_bond,
                        },
                    );
            }

            self
                .emit(
                    Finalized { market_id, outcome_id, was_disputed: resolution.has_been_disputed },
                )
        }

        fn set_dispute_window(ref self: ContractState, new_window: u64) {
            self.ownable.assert_only_owner();
            assert(new_window != 0, 'Invalid window');
            let old_window = self.dispute_window.read();
            self.dispute_window.write(new_window);
            self.emit(DisputeWindowUpdated { old_window, new_window });
        }

        fn set_min_bond(ref self: ContractState, new_min_bond: u256) {
            self.ownable.assert_only_owner();
            assert(new_min_bond != 0, 'Invalid amount');
            let old_bond = self.min_bond.read();
            self.min_bond.write(new_min_bond);

            self.emit(MinBondUpdated { old_bond, new_bond: new_min_bond });
        }

        fn set_arbitrator(ref self: ContractState, new_arbitrator: ContractAddress) {
            let old_arbitrator = self.arbitrator.read();
            self.arbitrator.write(new_arbitrator);
            self.emit(ArbitratorUpdated { old_arbitrator, new_arbitrator });
        }

        fn get_resolution_state(self: @ContractState, market_id: u256) -> ResolutionState {
            self.resolutions.entry(market_id).read().state
        }

        fn can_dispute(self: @ContractState, market_id: u256) -> bool {
            let resolution = self.resolutions.entry(market_id).read();
            let dispute_window = self.dispute_window.read();

            let deadline = resolution.proposal_time + dispute_window;

            resolution.state == ResolutionState::PROPOSED && get_block_timestamp() <= deadline
        }

        fn can_finalize(self: @ContractState, market_id: u256) -> bool {
            let resolution = self.resolutions.entry(market_id).read();
            let dispute_window = self.dispute_window.read();

            let deadline = resolution.proposal_time + dispute_window;

            resolution.state == ResolutionState::PROPOSED && get_block_timestamp() > deadline
        }

        fn get_dispute_time_remaining(self: @ContractState, market_id: u256) -> u64 {
            let resolution = self.resolutions.entry(market_id).read();
            let dispute_window = self.dispute_window.read();

            let deadline = resolution.proposal_time + dispute_window;
            let now = get_block_timestamp();

            let time_remaining = if now >= deadline {
                0
            } else {
                deadline - now
            };

            time_remaining
        }
    }
}
