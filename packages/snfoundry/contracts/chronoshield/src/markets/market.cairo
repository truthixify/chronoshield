#[starknet::contract]
pub mod Market {
    use core::to_byte_array::FormatAsByteArray;
use core::num::traits::zero;
    use openzeppelin::access::ownable::OwnableComponent;
    use openzeppelin::security::{PausableComponent, ReentrancyGuardComponent};
    use openzeppelin::token::erc20::interface::{IERC20Dispatcher, IERC20DispatcherTrait};
    use openzeppelin::token::erc20::{ERC20Component, ERC20HooksEmptyImpl};
    use starknet::storage::{
        StoragePointerReadAccess, StoragePointerWriteAccess,
    };
    use starknet::{ContractAddress, get_block_timestamp, get_caller_address, get_contract_address};
    use zero::Zero;
    // use crate::interfaces::ilp_token::{ILPTokenDispatcher, ILPTokenDispatcherTrait};
    use crate::interfaces::ioutcome_token::{IOutcomeTokenDispatcher, IOutcomeTokenDispatcherTrait};
    use crate::interfaces::imarket::IMarket;
    use crate::types::{MarketInfo, MarketType};

    #[storage]
    pub struct Storage {
        // pub market_info: MarketInfo,
        pub market_id: u256,
        pub is_paused: bool,
        pub fixed_fee: u256,
        pub yes_pool: u256, // size of yes pool in terms of liquidity
        pub no_pool: u256, // Size of no pool in terms of liquidity
        pub total_yes_shares: u256, // Total yes shares minted
        pub total_no_shares: u256, // Total no shares minted
        pub redemption_funded: bool,
        pub total_collateral: u256,
        pub fee_splitter: ContractAddress,
        pub horizon_perks: ContractAddress,
        pub collateral_token: ContractAddress,
        pub outcome_token: ContractAddress,
        pub close_time: u64,
        pub is_resolved: bool,
        #[substorage(v0)]
        pub ownable: OwnableComponent::Storage,
        #[substorage(v0)]
        pub pausable: PausableComponent::Storage,
        #[substorage(v0)]
        pub reentrancy_guard: ReentrancyGuardComponent::Storage,
        #[substorage(v0)]
        pub erc20: ERC20Component::Storage,
    }

    component!(path: OwnableComponent, storage: ownable, event: OwnableEvent);
    component!(path: PausableComponent, storage: pausable, event: PausableEvent);
    component!(
        path: ReentrancyGuardComponent, storage: reentrancy_guard, event: ReentrancyGuardEvent,
    );
    component!(path: ERC20Component, storage: erc20, event: ERC20Event);

    #[abi(embed_v0)]
    impl OwnableImpl = OwnableComponent::OwnableImpl<ContractState>;
    impl OwnableInternalImpl = OwnableComponent::InternalImpl<ContractState>;

    #[abi(embed_v0)]
    impl ERC20Impl = ERC20Component::ERC20Impl<ContractState>;
    impl ERC20InternalImpl = ERC20Component::InternalImpl<ContractState>;

    #[abi(embed_v0)]
    impl PausableImpl = PausableComponent::PausableImpl<ContractState>;
    impl PausableInternalImpl = PausableComponent::InternalImpl<ContractState>;

    impl ReentrancyGuardInternalImpl = ReentrancyGuardComponent::InternalImpl<ContractState>;


    #[event]
    #[derive(Drop, starknet::Event)]
    pub enum Event {
        LiquidityAdded: LiquidityAdded,
        LiquidityRemoved: LiquidityRemoved,
        SharePurchased: SharePurchased,
        ShareSold: ShareSold,
        #[flat]
        OwnableEvent: OwnableComponent::Event,
        #[flat]
        PausableEvent: PausableComponent::Event,
        #[flat]
        ReentrancyGuardEvent: ReentrancyGuardComponent::Event,
        #[flat]
        ERC20Event: ERC20Component::Event,
    }

    #[derive(Drop, starknet::Event)]
    pub struct LiquidityAdded {
        pub liquidity_provider: ContractAddress,
        pub liquidity_added: u256,
        pub collateral_in: u256,
    }

    #[derive(Drop, starknet::Event)]
    pub struct LiquidityRemoved {
        pub liquidity_provider: ContractAddress,
        pub liquidity_removed: u256,
        pub collateral_out: u256,
    }

    #[derive(Drop, starknet::Event)]
    pub struct SharePurchased {
        pub buyer: ContractAddress,
        pub outcome_id: u256,
        pub shares: u256,
        pub collateral_in: u256,
        pub fee: u256,
    }

    #[derive(Drop, starknet::Event)]
    pub struct ShareSold {
        pub seller: ContractAddress,
        pub outcome_id: u256,
        pub shares: u256,
        pub collateral_out: u256,
        pub fee: u256,
    }

    const OUTCOME_YES: u256 = 0;
    const OUTCOME_NO: u256 = 1;
    const MINIMUM_LIQUIDITY: u256 = 1000;
    const PRICE_PRECISION: u256 = 10 ^ 18;


    #[constructor]
    fn constructor(
        ref self: ContractState,
        market_id: u256,
        fixed_fee: u256,
        collateral_token: ContractAddress,
        outcome_token: ContractAddress,
        fee_splitter: ContractAddress,
        horizon_perks: ContractAddress,
        close_time: u64,
        // lp_token_name: ByteArray,
        // lp_token_symbol: ByteArray,
        admin: ContractAddress,
    ) {
        assert((get_block_timestamp() < close_time), 'Already closed market');
        self.market_id.write(market_id);
        self.fixed_fee.write(fixed_fee);
        self.collateral_token.write(collateral_token);
        self.outcome_token.write(outcome_token);
        self.fee_splitter.write(fee_splitter);
        self.horizon_perks.write(horizon_perks);
        self.close_time.write(close_time);
        self.yes_pool.write(0);
        self.no_pool.write(0);

        let lp_token_name = "LPToken" + market_id.format_as_byte_array(16);
        let lp_token_symbol = market_id.format_as_byte_array(16);
        self.ownable.initializer(admin);
        self.erc20.initializer(lp_token_name, lp_token_symbol);
        // TODO: Initialize ERC20 with the token name and symbol
        // TODO: Deploy feesplitter
        // TODO: Deploy horizon perks
        // TODO: Deploy outcome token
    }

    pub impl MarketImpl of IMarket<ContractState> {
        fn get_market_type(self: @ContractState) -> MarketType {
            // let market_info = self.market_info.read();
            // market_info.market_type
            MarketType::BINARY
        }

        fn get_market_info(self: @ContractState) -> MarketInfo {
            MarketInfo {
                market_id: self.market_id.read(),
                market_type: MarketType::BINARY,
                close_time: self.close_time.read(),
                outcome_count: 2,
                is_resolved: self.is_resolved.read(),
                is_paused: self.is_paused.read(),
                collateral_token: self.collateral_token.read()
            }
        }

        fn buy(ref self: ContractState, outcome_id: u256, collateral_in: u256, min_tokens_out: u256) -> u256 {
            assert(collateral_in != 0, 'Invalid amount');
            assert(outcome_id == OUTCOME_YES || outcome_id == OUTCOME_NO, 'Invalid outcome id');

            let caller = get_caller_address();
            let this_contract = get_contract_address();

            let fixed_fee = self.fixed_fee.read();
            let fee = (collateral_in * fixed_fee) / 10000;
            let collateral_after_fee = collateral_in - fee;

            let tokens_out = collateral_after_fee;
            assert(!(tokens_out < min_tokens_out), 'Slippage exceeded');

            let collateral_token_dispatcher = IERC20Dispatcher {
                contract_address: self.collateral_token.read(),
            };
            collateral_token_dispatcher.transfer_from(caller, this_contract, collateral_in);
            
            if (outcome_id == OUTCOME_YES) {
                self.yes_pool.write(self.yes_pool.read() + collateral_after_fee);
                self.total_yes_shares.write(self.total_yes_shares.read() + tokens_out);
            } else {
                self.no_pool.write(self.no_pool.read() + collateral_after_fee);
                self.total_no_shares.write(self.total_no_shares.read() + tokens_out);
            }
            self.total_collateral.write(self.total_collateral.read() + collateral_after_fee);

            let outcome_token_dispatcher = IOutcomeTokenDispatcher { contract_address: self.outcome_token.read() };
            outcome_token_dispatcher.mint_outcome(self.market_id.read(), outcome_id, caller, tokens_out);

            tokens_out
        }

        fn sell(
            ref self: ContractState, outcome_id: u256, tokens_in: u256, min_collateral_out: u256,
        ) -> u256 {
            assert(tokens_in != 0, 'Invalid token amount');
            assert(outcome_id == OUTCOME_YES || outcome_id == OUTCOME_NO, 'Invalid outcome id');

            let caller = get_caller_address();


            let collateral_before_fee = tokens_in;
            let fixed_fee = self.fixed_fee.read();
            let fee = (collateral_before_fee * fixed_fee) / 10000;
            let collateral_out = collateral_before_fee - fee;
            
            assert(!(collateral_out < min_collateral_out), 'Slippage exceeded');

            let pool = if (outcome_id == OUTCOME_YES) {
                self.yes_pool.read()
            } else {
                self.no_pool.read()
            };

            assert(!(pool < collateral_before_fee), 'Insufficient Liquidity');

            let outcome_token_dispatcher = IOutcomeTokenDispatcher { contract_address: self.outcome_token.read() };
            outcome_token_dispatcher.burn_outcome(self.market_id.read(), outcome_id, caller, tokens_in);
            
            if (outcome_id == OUTCOME_YES) {
                self.yes_pool.write(self.yes_pool.read() - collateral_before_fee);
                self.total_yes_shares.write(self.total_yes_shares.read() - tokens_in);
            } else {
                self.no_pool.write(self.no_pool.read() - collateral_before_fee);
                self.total_no_shares.write(self.total_no_shares.read() - tokens_in);
            }

            self.total_collateral.write(self.total_collateral.read() - collateral_before_fee);

            let collateral_token_dispatcher = IERC20Dispatcher { contract_address: self.collateral_token.read() };
            collateral_token_dispatcher.transfer(caller, collateral_out);

            self.emit(
                ShareSold {
                    seller: caller,
                    outcome_id,
                    shares: tokens_in,
                    collateral_out,
                    fee
                }
            );

            collateral_out
        }

        fn add_liquidity(ref self: ContractState, amount: u256) {
            assert(amount != 0, 'Invalid token amount');

            let collateral_token = IERC20Dispatcher {
                contract_address: self.collateral_token.read(),
            };
            collateral_token.transfer_from(get_caller_address(), get_contract_address(), amount);
            
            let total_supply = self.erc20.total_supply();

            let mut lp_tokens: u256 = 0;
            let zero_address: ContractAddress = Zero::zero();
            if (total_supply == 0) {
                lp_tokens = amount;
                assert(lp_tokens > MINIMUM_LIQUIDITY, 'Minimum Liquidity Required');
                self.erc20.mint(zero_address, MINIMUM_LIQUIDITY);

                lp_tokens -= MINIMUM_LIQUIDITY;

                let half_amount = amount / 2;
                self.yes_pool.write(self.yes_pool.read() + half_amount);
                self.no_pool.write(self.no_pool.read() + (amount - half_amount));

                self.total_yes_shares.write(self.total_yes_shares.read() + half_amount);
                self.total_no_shares.write(self.total_no_shares.read() + (amount - half_amount));
            } else {
                let total_collateral = self.total_collateral.read();
                lp_tokens = (amount * total_supply) / total_collateral;

                // Add proportionally to pools;
                let yes_add = (amount * self.yes_pool.read()) / total_collateral;
                self.yes_pool.write(self.yes_pool.read() + yes_add);

                let no_add = amount - yes_add;
                self.no_pool.write(self.no_pool.read() + no_add);

                self.total_yes_shares.write(self.total_yes_shares.read() + yes_add);
                self.total_no_shares.write(self.total_no_shares.read() + no_add);
            }

            self.total_collateral.write(self.total_collateral.read() + amount);

            self.erc20.mint(get_caller_address(), lp_tokens);

            self
                .emit(
                    LiquidityAdded {
                        liquidity_provider: get_caller_address(),
                        liquidity_added: amount,
                        collateral_in: lp_tokens,
                    },
                );
        }

        fn remove_liquidity(ref self: ContractState, tokens: u256) {
            assert(tokens != 0, 'Invalid token amount');

            let collateral_token = IERC20Dispatcher {
                contract_address: self.collateral_token.read(),
            };
            let total_supply = self.erc20.total_supply();

            assert(
                tokens <= self.erc20.balance_of(get_caller_address()),
                'Insufficient LP Tokens',
            );

            let collateral_out = (tokens * self.total_collateral.read()) / total_supply;

            assert(collateral_out != 0, 'Invalid collateral amount');

            let yes_remove = (tokens * self.yes_pool.read()) / total_supply;
            let no_remove = (tokens * self.no_pool.read()) / total_supply;

            self.yes_pool.write(self.yes_pool.read() - yes_remove);
            self.no_pool.write(self.no_pool.read() - no_remove);

            self.total_collateral.write(self.total_collateral.read() - collateral_out);

            // Update counts proportionally
            let yes_shares_remove = (tokens * self.total_yes_shares.read()) / total_supply;
            let no_shares_remove = (tokens * self.total_no_shares.read()) / total_supply;

            self.total_yes_shares.write(self.total_yes_shares.read() - yes_shares_remove);
            self.total_no_shares.write(self.total_no_shares.read() - no_shares_remove);

            self.erc20.burn(get_caller_address(), tokens);

            collateral_token.transfer(get_caller_address(), collateral_out);

            self
                .emit(
                    LiquidityRemoved {
                        liquidity_provider: get_caller_address(),
                        liquidity_removed: tokens,
                        collateral_out,
                    },
                );
        }

        fn get_price(self: @ContractState, outcome_id: u256) -> u256 {
            PRICE_PRECISION / 2
        }

        fn getQuoteBuy(self: @ContractState, outcome_id: u256, collateral_in: u256, user: ContractAddress) -> (u256, u256) {
            let fee = (collateral_in * self.fixed_fee.read()) / 10000;
            let tokens_out = collateral_in - fee;
            (tokens_out, fee)
        }

        fn getQuoteSell(self: @ContractState, outcome_id: u256, tokens_in: u256, user: ContractAddress) -> (u256, u256) {
            let fee = (tokens_in * self.fixed_fee.read()) / 10000;
            let collateral_out = tokens_in - fee;
            (collateral_out, tokens_in)
        }

        fn get_reserves(self: @ContractState) -> (u256, u256) {
            (self.yes_pool.read(), self.no_pool.read())
        }


        fn fund_redemptions(ref self: ContractState) {
            assert(self.is_resolved.read(), 'Unresolved market');

            let collateral_token_dispatcher = IERC20Dispatcher { contract_address: self.collateral_token.read() };
            let collateral_balance = collateral_token_dispatcher.balance_of(get_contract_address());
            if (collateral_balance > 0) {
                collateral_token_dispatcher.transfer(self.outcome_token.read(), collateral_balance);
                self.redemption_funded.write(true);
            }
        }
    }

    #[generate_trait]
    pub impl InternalImpl of InternalFunctions {
        fn when_not_paused(ref self: ContractState) {
            self.pausable.assert_not_paused();
        }
    }
}
