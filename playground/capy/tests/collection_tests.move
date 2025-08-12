
#[test_only]
module capy::collection_tests;

use sui::random::{Self, Random, new_generator};
use std::debug::print;
use sui::test_scenario;
use capy::capy;
use sui::table::{Self, Table};

//测试 使用 decrypt.sage 脚本计算出来的flag 是否正确

#[test]
fun test() {
    let dev = @0x0;
    let mut scenario_val = test_scenario::begin(dev);
    let scenario = &mut scenario_val;
    scenario.next_tx(dev);
    {
        test_table_equal(scenario.ctx());
        test_table(scenario.ctx());


        // random::create_for_testing(scenario.ctx());
    };

    scenario.next_tx(dev);
    {

        

        // let r = scenario.take_shared<Random>();
        // crypto::entrypt_flag(flag, &r, scenario.ctx());
        // test_scenario::return_shared(r);
        
        // crypto::decrypt_flag(flag, &mut sui::tx_context::dummy());
    };

    scenario_val.end();
}

#[test_only]
fun test_table_equal(ctx: &mut TxContext) {

    //Quiz: Would two table objects containing the exact same key-value pairs be equal to each other when checked with the === operator? Try it out.
    //== 下面的测试都fail, 意思是不相等
    
    let mut table1 = table::new<u64, u64>(ctx);
    let mut table2 = table::new<u64, u64>(ctx);
    //assert!(&table1 === &table2, 0); //=== 编译不过，没有这个运算符

    // table1.add(0, 1000);
    // table2.add(0, 1000);
    // assert!(&table1 == &table2, 0);

    // table1.add(1, 2000);
    // table2.add(1, 2000);
    // assert!(&table1 == &table2, 0);


    table1.add(0, 1000);
    table2.add(0, 1000);
    assert!(&table1 != &table2, 0);

    table1.add(1, 2000);
    table2.add(1, 2000);
    assert!(&table1 != &table2, 0);



    table1.drop();
    table::drop(table2);
}

#[test_only]
fun test_table(ctx: &mut TxContext) {
 
    let mut table1 = table::new<u64, u64>(ctx);
    table1.add(0, 1000);
    table1.add(1, 2000);

    let v0 = table1.borrow(0);
    let v1 = table1.borrow(1);

    let u0 = &table1[0];
    let u1 = &table1[1];

    assert!(v0 == u0 && v0 == 1000, 0);
    assert!(v1 == u1 && v1 == 2000, 1);

    table1.drop();
}

#[test_only]
public struct S has copy, drop { f: u64, s: vector<u8> }
// public struct S has drop { f: u64, s: vector<u8> }

#[test]
fun always_true(): bool {
    let s = S { f: 0, s: b"" };
    s == s
}

#[test]
fun always_false(): bool {
    let s = S { f: 0, s: b"" };
    s != s
}

#[test]
fun test1(){
    let s = S { f: 0, s: b"" };
    let s2 = S { f: 0, s: b"" };
    assert!(s == s2, 0);
    assert!(copy s == copy s2, 1); //copy?
    assert!(s == s2, 0);

    assert!(&s == &s2, 2);
}

#[test]
fun test2(){
    // assert!(0 == 0, 0);
    // assert!(1u128 == 2u128, 1);
    // assert!(b"hello" != x"00", 2);
}