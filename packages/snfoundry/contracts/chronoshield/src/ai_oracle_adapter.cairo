#[starknet::contract]
pub mod AIOracleAdapter {
    use core::hash::{HashStateExTrait, HashStateTrait};
    use core::num::traits::Zero;
    use core::poseidon::{PoseidonTrait, poseidon_hash_span};
    use openzeppelin::access::ownable::OwnableComponent;
    use openzeppelin::account::interface::{ISRC6Dispatcher, ISRC6DispatcherTrait};
    use openzeppelin::security::ReentrancyGuardComponent;
    use openzeppelin::token::erc20::interface::{IERC20Dispatcher, IERC20DispatcherTrait};
    use openzeppelin::utils::cryptography::nonces::NoncesComponent;
    use openzeppelin::utils::snip12::{OffchainMessageHash, SNIP12Metadata};
    use starknet::event::EventEmitter;
    use starknet::secp256_trait::is_valid_signature;
    use starknet::storage::{
        Map, StoragePathEntry, StoragePointerReadAccess, StoragePointerWriteAccess,
    };
    use starknet::{ContractAddress, get_block_timestamp, get_caller_address, get_contract_address};
    use crate::interfaces::iaioracle_adapter::IAiOracleAdapter;
    use crate::types::ProposedOutcome;

    #[storage]
    pub struct Storage {
        pub resolution_module: ContractAddress,
        pub bond_token: ContractAddress,
        pub allowed_signers: Map<ContractAddress, bool>,
        pub used_signatures: Map<felt252, bool>,
        #[substorage(v0)]
        pub ownable: OwnableComponent::Storage,
        #[substorage(v0)]
        pub re_entrancy_guard: ReentrancyGuardComponent::Storage,
        #[substorage(v0)]
        pub nonces: NoncesComponent::Storage,
    }

    component!(path: OwnableComponent, storage: ownable, event: OwnableEvent);
    component!(
        path: ReentrancyGuardComponent, storage: re_entrancy_guard, event: ReentrancyGuardEvent,
    );
    component!(path: NoncesComponent, storage: nonces, event: NoncesEvent);

    #[event]
    #[derive(Drop, starknet::Event)]
    pub enum Event {
        SignerAdded: SignerAdded,
        SignerRemoved: SignerRemoved,
        AIProposalSubmitted: AIProposalSubmitted,
        #[flat]
        OwnableEvent: OwnableComponent::Event,
        #[flat]
        ReentrancyGuardEvent: ReentrancyGuardComponent::Event,
        #[flat]
        NoncesEvent: NoncesComponent::Event,
    }

    #[derive(Drop, starknet::Event)]
    pub struct SignerAdded {
        #[key]
        pub signer: ContractAddress,
    }

    #[derive(Drop, starknet::Event)]
    pub struct SignerRemoved {
        #[key]
        pub signer: ContractAddress,
    }

    #[derive(Drop, starknet::Event)]
    pub struct AIProposalSubmitted {
        #[key]
        pub market_id: u256,
        #[key]
        pub outcome_id: u256,
        #[key]
        pub proposer: ContractAddress,
        pub ai_signer: ContractAddress,
        pub bond_amount: u256,
        pub signature_hash: felt252,
    }

    #[constructor]
    fn constructor(
        ref self: ContractState,
        resolution_module: ContractAddress,
        bond_token: ContractAddress,
        initial_signer: ContractAddress,
        owner: ContractAddress,
    ) {
        self.ownable.initializer(owner);
        assert(
            (resolution_module.is_non_zero()
                && bond_token.is_non_zero()
                && initial_signer.is_non_zero()),
            'Invalid address',
        );
        self.resolution_module.write(resolution_module);
        self.bond_token.write(bond_token);
        self.allowed_signers.entry(initial_signer).write(true);
        self.emit(SignerAdded { signer: initial_signer });
    }

    #[abi(embed_v0)]
    pub impl OwnableImpl = OwnableComponent::OwnableImpl<ContractState>;
    impl OwnableInternalImpl = OwnableComponent::InternalImpl<ContractState>;

    impl ReentrancyGuardInternalImpl = ReentrancyGuardComponent::InternalImpl<ContractState>;

    #[abi(embed_v0)]
    impl NoncesImpl = NoncesComponent::NoncesImpl<ContractState>;
    impl NoncesInternalImpl = NoncesComponent::InternalImpl<ContractState>;

    impl SNIP12MetadataImpl of SNIP12Metadata {
        fn name() -> felt252 {
            'AIOracleAdapter'
        }
        fn version() -> felt252 {
            'v1'
        }
    }

    pub impl AIOracleAdapterImpl of IAiOracleAdapter<ContractState> {
        fn propose_ai(
            ref self: ContractState,
            proposal: ProposedOutcome,
            signature_r: felt252,
            signature_s: felt252,
            bond_amount: u256,
            evidence_uris: Array<felt252>,
            nonce: felt252,
        ) {
            let caller = get_caller_address();
            let now = get_block_timestamp();
            assert(now >= proposal.not_before, 'Signature not yet valid');
            assert(now <= proposal.close_time, 'Signature expired');

            self.nonces.use_checked_nonce(caller, nonce);

            let mut new_hash_state = PoseidonTrait::new();
            let signature_hash = new_hash_state
                .update_with(signature_r)
                .update_with(signature_s)
                .finalize();
            assert(!(self.used_signatures.entry(signature_hash).read()), 'Signature already used');

            let evidence_hash = self._hash_evidence(@evidence_uris);
            assert(evidence_hash == proposal.evidence_hash, 'Invalid evidence hash');

            let is_valid_signature = self
                ._verify_signature(proposal, signature_r, signature_s, caller);
            assert(is_valid_signature, 'Invalid signature');

            self.used_signatures.entry(signature_hash).write(true);

            let bond_token_dispatcher = IERC20Dispatcher {
                contract_address: self.bond_token.read(),
            };
            bond_token_dispatcher.transfer_from(caller, get_contract_address(), bond_amount);
            bond_token_dispatcher.approve(self.resolution_module.read(), bond_amount);

            // resolution_module_dispatcher.propose_resolution(...)

            self
                .emit(
                    AIProposalSubmitted {
                        market_id: proposal.market_id,
                        outcome_id: proposal.outcome_id,
                        proposer: caller,
                        ai_signer: caller, // this is not correct
                        bond_amount,
                        signature_hash,
                    },
                );
        }

        fn add_signer(ref self: ContractState, signer: ContractAddress) {
            self.ownable.assert_only_owner();
            assert(signer.is_non_zero(), 'Invalid signer');
            self.allowed_signers.entry(signer).write(true);
            self.emit(SignerAdded { signer });
        }

        fn remove_signer(ref self: ContractState, signer: ContractAddress) {
            self.ownable.assert_only_owner();
            self.allowed_signers.entry(signer).write(false);
            self.emit(SignerRemoved { signer });
        }
    }

    #[generate_trait]
    impl InternalImpl of InternalFunctions {
        // Hash evidence URIs
        fn _hash_evidence(self: @ContractState, evidence_uris: @Array<felt252>) -> felt252 {
            poseidon_hash_span(evidence_uris.span())
        }

        fn _verify_signature(
            self: @ContractState,
            proposal: ProposedOutcome,
            signature_r: felt252,
            signature_s: felt252,
            owner: ContractAddress,
        ) -> bool {
            let hash = proposal.get_message_hash(owner);

            let signature = array![signature_r, signature_s];

            let is_valid_signature_felt = ISRC6Dispatcher { contract_address: owner }
                .is_valid_signature(hash, signature);

            let is_valid_signature = is_valid_signature_felt == starknet::VALIDATED
                || is_valid_signature_felt == 1;
            is_valid_signature
            // TODO: I do not like this, look for a way instead to get the address back from the
        // signature, and then assert that he is an allowed signer
        }
    }
}
