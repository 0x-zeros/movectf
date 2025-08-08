module upgrage::counter;

use sui::event;

//event
public struct Progress has copy, drop {
    reached: u64
}

public struct Counter has key {
    id: UID,
    value: u64,
}

fun init(ctx: &mut TxContext) {
    transfer::share_object(Counter {
        id: object::new(ctx),
        value: 0,
    })
}

public fun increment(c: &mut Counter) {
    c.value = c.value + 1;

    //  if (c.value % 100 == 0) {
        event::emit(Progress { reached: c.value });
    // }
}

