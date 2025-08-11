
// 受限与公开转移
/// 
module book::transfer_b {
    // 类型并非此模块的内部类型
    use book::transfer_a::{ObjectK, ObjectKS};

    // // 失败！ObjectK 没有 `store` 能力，并且 ObjectK 不是此模块的内部类型。
    // public fun transfer_k(k: ObjectK, to: address) {
    //     sui::transfer::transfer(k, to);
    // }

    // // 失败！ObjectKS 具有 `store` 能力，但该函数不是公开的。
    // public fun transfer_ks(ks: ObjectKS, to: address) {
    //     sui::transfer::transfer(ks, to);
    // }

    // // 失败！ObjectK 没有 `store` 能力，而 `public_transfer` 需要 `store` 能力。
    // public fun public_transfer_k(k: ObjectK, to: address) {
    //     sui::transfer::public_transfer(k, to);
    // }

    // 成功！ObjectKS 具有 `store` 能力，并且该函数是公开的。
    public fun public_transfer_ks(y: ObjectKS, to: address) {
        sui::transfer::public_transfer(y, to);
    }
}