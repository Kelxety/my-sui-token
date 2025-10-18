/// Create a simple coin with icon.
module love_ph::love_ph {
    use std::option;
    use sui::coin::{Self, TreasuryCap};
    use sui::transfer;
    use sui::tx_context::{sender, TxContext};
    use sui::url::{Self, Url};

    /// OTW and the type for the Token.
    struct LOVE_PH has drop {}

    // Most of the magic happens in the initializer for the demonstration
    // purposes; however half of what's happening here could be implemented as
    // a single / set of PTBs.
    fun init(otw: LOVE_PH, ctx: &mut TxContext) {
        let treasury_cap = create_currency(otw, ctx);
        transfer::public_transfer(treasury_cap, sender(ctx));
    }

    /// Internal: not necessary, but moving this call to a separate function for
    /// better visibility of the Closed Loop setup in `init`.
    fun create_currency<T: drop>(otw: T, ctx: &mut TxContext): TreasuryCap<T> {
        let url = url::new_unsafe_from_bytes(
            b"https://github.com/Kelxety/my-sui-token/blob/main/love_ph.png",
        );

        let (treasury_cap, metadata) = coin::create_currency(
            otw,
            9,
            b"LPH",
            b"Love PH",
            b"Coin for Loving PH tourism sites or communities",
            option::some(url),
            ctx,
        );

        transfer::public_freeze_object(metadata);
        treasury_cap
    }

    /// Mint `amount` of `Coin` and send it to `recipient`.
    public entry fun mint(
        c: &mut TreasuryCap<LOVE_PH>,
        amount: u64,
        recipient: address,
        ctx: &mut TxContext,
    ) {
        coin::mint_and_transfer(c, amount, recipient, ctx);
    }

    #[test_only]
    public fun init_for_test(ctx: &mut TxContext) {
        init(LOVE_PH {}, ctx);
    }
}

#[test_only]
/// Implements tests for most common scenarios for the coin example.
module love_ph::love_ph_tests {
    use love_ph::love_ph::{LOVE_PH, init_for_test};
    use sui::coin::{Self, TreasuryCap};
    use sui::test_scenario as ts;

    #[test]
    fun mint_transfer_update() {
        let addr1 = @0xA;
        let addr2 = @0xB;

        // init simple_token module
        let scenario = ts::begin(addr1);
        {
            init_for_test(ts::ctx(&mut scenario));
        };

        // mint
        ts::next_tx(&mut scenario, addr1);
        {
            let tc = ts::take_from_sender<TreasuryCap<LOVE_PH>>(&scenario);
            coin::mint_and_transfer<LOVE_PH>(&mut tc, 10000000000, addr2, ts::ctx(&mut scenario));
            ts::return_to_sender(&scenario, tc);
        };

        ts::end(scenario);
    }
}
