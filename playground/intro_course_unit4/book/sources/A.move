
// 受限与公开转移

/// 为 `ObjectK` 和 `ObjectKS` 分别定义 `key` 和 `key + store`的能力
module book::transfer_a {
    public struct ObjectK has key { id: UID }
    public struct ObjectKS has key, store { id: UID }





    public fun create_object_k(ctx: &mut TxContext) {
        let id = object::new(ctx);
        transfer::transfer(ObjectK { id }, ctx.sender())
    }


//    │         transfer::transfer(ObjectK { id }, ctx.sender())
//    │                            ^^^^^^^^^^^^^^
//    │                            │         │
//    │                            │         The UID must come directly from sui::object::new. Or for tests, it can come from sui::test_scenario::new_object
//    │                            Invalid object creation without a newly created UID.
    // public fun create_object_k_2(id: UID, ctx: &mut TxContext) {
    //     transfer::transfer(ObjectK { id }, ctx.sender())
    // }

    public fun create_object_ks(ctx: &mut TxContext) {
        let id = object::new(ctx);
        transfer::transfer(ObjectKS { id }, ctx.sender())
    }


    public fun transfer_k(k: ObjectK, to: address) {
        sui::transfer::transfer(k, to);
    }

    public fun transfer_ks(ks: ObjectKS, to: address) {
        sui::transfer::transfer(ks, to);
    }

    // public fun public_transfer_k(k: ObjectK, to: address) {
    //     sui::transfer::public_transfer(k, to);
    // }

    // 成功！ObjectKS 具有 `store` 能力，并且该函数是公开的。
    public fun public_transfer_ks(y: ObjectKS, to: address) {
        sui::transfer::public_transfer(y, to);
    }


    //对UID的可变访问是一种安全风险
    public fun get_id(k: &mut ObjectK): &mut UID {
        &mut k.id
    }
}


