
#[test_only]
module game::game_tests;
// uncomment this line to import the module
// use game::ez_game::weighted_rob;
use sui::math;

const ENotImplemented: u64 = 0;

#[test]
fun test_game() {
    // pass
}

// #[test, expected_failure(abort_code = ::game::game_tests::ENotImplemented)]
// fun test_game_fail() {
//     abort ENotImplemented
// }

#[test_only]
use std::debug::print;

#[test]
fun test_game_print() {
    print(&b"111");
    print(&111);
}

// #[test]
// fun test_vector1() {
//     let mut v = vector::empty<u64>();
//     vector::push_back(&mut v, 1);
//     vector::push_back(&mut v, 2);
//     vector::push_back(&mut v, 3);
//     print(&v);

//     print(&vector::length(&v));
// }

#[test]
fun test_vector() {
    let mut initial_part = vector::empty<u64>();
        vector::push_back(&mut initial_part, 1);
        vector::push_back(&mut initial_part, 1);
        vector::push_back(&mut initial_part, 3);
        vector::push_back(&mut initial_part, 1);
        vector::push_back(&mut initial_part, 1);

        let mut weights = vector::empty<u64>();
        vector::push_back(&mut weights, 1);
        vector::push_back(&mut weights, 1);
        vector::push_back(&mut weights, 2);
        vector::push_back(&mut weights, 1);
        vector::push_back(&mut weights, 1);

        // print(&initial_part);
        // print(&vector::length(&initial_part));

        // print(&weights);
        // print(&vector::length(&weights));

        let mut user_input = vector::empty<u64>();
        let mut j = 0;
        while (j < 23) {
            vector::push_back(&mut user_input, 1);
            j = j + 1;
        };
        std::debug::print(&b"user_input:".to_string());
        print(&user_input);
        print(&vector::length(&user_input));


        let mut houses = initial_part;
        vector::append(&mut houses, user_input);
        std::debug::print(&b"houses:".to_string());
        print(&houses);
        // print(&vector::length(&houses));


        let mut i = vector::length(&initial_part);
        // print(&i);
        while (i < vector::length(&houses)) { //weights 为 初始化的weights (append) {len(houses)个1: 1,1,2,1,1, 5个1， len(user_input)个1}  ; {}为houses
            vector::push_back(&mut weights, 1);
            i = i + 1;
        };
        std::debug::print(&b"weights:".to_string());
        print(&weights);
        // print(&vector::length(&weights));

        let amount_robbed = weighted_rob(&houses, &weights);
        std::debug::print(&b"amount_robbed:".to_string());
        print(&amount_robbed);
}


#[allow(deprecated_usage)]
    public fun weighted_rob(houses: &vector<u64>, weights: &vector<u64>): u64 {
        let n = vector::length(houses);
        assert!(n == vector::length(weights), 0);
        if (n == 0) {
            return 0
        };
        let mut v = vector::empty<u64>();
        vector::push_back(&mut v, *vector::borrow(houses, 0) * *vector::borrow(weights, 0)); //1*1=1
        if (n > 1) {
            vector::push_back(&mut v, math::max(
                *vector::borrow(houses, 0) * *vector::borrow(weights, 0), //1*1=1
                *vector::borrow(houses, 1) * *vector::borrow(weights, 1) //1*1=1
            ));
        };
        let mut i = 2;
        while (i < n) {
            let dp_i_1 = *vector::borrow(&v, i - 1);
            let dp_i_2_plus_house = *vector::borrow(&v, i - 2) + *vector::borrow(houses, i) * *vector::borrow(weights, i);
            vector::push_back(&mut v, math::max(dp_i_1, dp_i_2_plus_house));
            i = i + 1;
        };

        std::debug::print(&b"v:".to_string());
        print(&v);
        print(&vector::length(&v));

        *vector::borrow(&v, n - 1)
    }
