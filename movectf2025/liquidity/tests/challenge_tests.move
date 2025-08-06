
#[test_only]
module liquidity::challenge_tests;

use liquidity::challenge;
use sui::math;

use std::debug::print;



#[test]
fun test_challenge() {
    print(&b"test_challenge:".to_string());

    let amount_out: u64 = 10000000;
    let swap_fee: u64 = 1000;
    let fee_precision: u64 = 100_000;
    let fee = amount_out * swap_fee / fee_precision;

    print(&b"fee:".to_string());
    print(&fee);

    // let c = 1000 / 0;
}
