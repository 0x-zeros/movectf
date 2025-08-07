/*
/// Module: boar_slayer
module boar_slayer::boar_slayer;
*/

// For Move coding conventions, see
// https://docs.sui.io/concepts/sui-move-concepts/conventions


module boar_slayer::boar_slayer;

// use sui::event;
// use sui::object::{Self, ID, UID};
// use sui::transfer;
// use sui::tx_context::{Self, TxContext};
// use sui::clock;
// use sui::table::{Self, Table};



public struct NoUse has key{
    id: UID,
    value: u64,
}

fun init(ctx: &mut TxContext) {
    let noUse = NoUse {
        id: object::new(ctx),
        value: 0,
    };
    transfer::share_object(noUse);
}

public struct Obj has key{
        id: UID,
        value: u64,
}

public fun new_obj(count: u64,addr:address, ctx: &mut TxContext){
    let mut i = 0;
    while(i < count){
        let obj = Obj{
            id: object::new(ctx),
            value: 1,
        };
        transfer::transfer(obj,addr);
        i = i + 1;
    }
}

public fun burn(obj: Obj, _ctx: &mut TxContext){
    
    let Obj{id, value:_} = obj;
    object::delete(id);

}