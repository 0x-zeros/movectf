module upgrage::counter_v1;

/// Not the right admin for this counter
const ENotAdmin: u64 = 0;

/// Calling functions from the wrong package version
const EWrongVersion: u64 = 1;

// 1. Track the current version of the module
const VERSION: u64 = 1;

public struct Counter has key {
    id: UID,
    // 2. Track the current version of the shared object
    version: u64,
    // 3. Associate the `Counter` with its `AdminCap`
    admin: ID,
    value: u64,
}

public struct AdminCap has key {
    id: UID,
}

fun init(ctx: &mut TxContext) {
    let admin = AdminCap { id: object::new(ctx) };

    transfer::share_object(Counter {
        id: object::new(ctx),
        version: VERSION,
        admin: object::id(&admin),
        value: 0,
    });

    transfer::transfer(admin, ctx.sender());
}

public fun increment(c: &mut Counter) {
    // 4. Guard the entry of all functions that access the shared object
    //    with a version check.
    assert!(c.version == VERSION, EWrongVersion);
    c.value = c.value + 1;
}