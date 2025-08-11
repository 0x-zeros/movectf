
#[test_only]
module book::book_tests;

// use std::debug::print;
use sui::test_scenario;

use book::transfer_a::{Self, ObjectK, ObjectKS};
// use sui::dynamic_object_field as dof;
use sui::dynamic_field as df;


// const ENotImplemented: u64 = 0;

#[test]
fun test_book() {
    // pass
}

#[test]
fun test_id() {
    let ctx = &mut tx_context::dummy();
    let uid = object::new(ctx);
    // uid.delete();

    //Sui验证器不允许使用未在同一函数中创建的UID。这防止了在对象被解包后预先生成和重复使用UID。
    pass_id_as_param(uid);
}

#[test_only]
fun pass_id_as_param(id: UID) {
    id.delete();
}


#[test]
fun test_id2() {

    let alice = @0x0;
    let bob = @0x1;
    let mut scenario_val = test_scenario::begin(alice);
    let scenario = &mut scenario_val;

    // scenario.next_tx(alice);
    {
        book::transfer_a::create_object_k(scenario.ctx());
        book::transfer_a::create_object_ks(scenario.ctx());

        // //从当前发送者的对象池中取出对象   
        // // let obj = scenario.take_from_sender<ObjectK>();
        // // test_scenario::return_to_address<ObjectK>(alice, obj);

        // let obj = scenario.take_from_sender<ObjectKS>();
        // test_scenario::return_to_address<ObjectKS>(alice, obj);
    };

    // scenario.next_tx(bob);
    // {

    // };

    scenario.next_tx(alice);
    {
        //从当前发送者的对象池中取出对象   
        let objK = scenario.take_from_sender<ObjectK>();
        // test_scenario::return_to_address<ObjectK>(alice, objK);

        let objKS = scenario.take_from_sender<ObjectKS>();
        // test_scenario::return_to_address<ObjectKS>(alice, objKS)

        //fail
        // transfer::transfer(objK, bob);
        // transfer::transfer(objKS, bob);

        //success
        transfer::public_transfer(objKS, bob);

        //success
        transfer_a::transfer_k(objK, bob);


        // let r = scenario.take_shared<Random>();
        // crypto::entrypt_flag(flag, &r, scenario.ctx());
        // test_scenario::return_shared(r);
        
        // crypto::decrypt_flag(flag, &mut sui::tx_context::dummy());
    };


    scenario.next_tx(bob);
    {
        let mut objK = scenario.take_from_sender<ObjectK>();
        let objKS = scenario.take_from_sender<ObjectKS>();


        //fail
        // let ObjectK { id } = objK;
        // id.delete();

        // let ObjectKS { id } = objKS;
        // id.delete();

        //测试添加dynamic_field
        // df::add(&mut objK.id, 1, true);
        // df::add(&mut objK.id, 2, false);
        df::add(objK.get_id(), 1, true);
        df::add(objK.get_id(), 2, false);


        test_scenario::return_to_address<ObjectK>(bob, objK);
        test_scenario::return_to_address<ObjectKS>(bob, objKS);
    };


    scenario_val.end();
}





// #[test, expected_failure(abort_code = ::book::book_tests::ENotImplemented)]
// fun test_book_fail() {
//     abort ENotImplemented
// }
