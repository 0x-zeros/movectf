module solve_week1::solve;

use std::bcs;
use std::hash::sha3_256;
use std::string;
// use sui::event;
use sui::random::Random;
// use sui::transfer::share_object;

use week1::challenge::{get_flag, Challenge};

//todo 该函数应该去掉public，暂时不改了
#[allow(lint(public_random))]
public entry fun solve_get_flag(challenge: &mut Challenge, rand: &Random, ctx: &mut TxContext) {
    let github_id = string::utf8(b"f59ace72-504c-486e-8fdf-7e2e353d1f13");//0x-zeros

    let challenge_secret = string::utf8(b"Letsmovectf_week1");
    //score
    let secret_hash = sha3_256(*string::as_bytes(&challenge_secret));
    let score = (((*vector::borrow(&secret_hash, 0) as u64) << 24) |
                ((*vector::borrow(&secret_hash, 1) as u64) << 16) |
                ((*vector::borrow(&secret_hash, 2) as u64) << 8) |
                (*vector::borrow(&secret_hash, 3) as u64));

    //guess
    let guess = vector::empty();

    //bcs_input
    let mut bcs_input = bcs::to_bytes(&challenge_secret);
    vector::append(&mut bcs_input, *string::as_bytes(&github_id));
    let hash_input = sha3_256(bcs_input);

    //seed
    let secret_bytes = *string::as_bytes(&challenge_secret);
    let secret_len = vector::length(&secret_bytes);
    let seed = secret_len * 2;

    //magic_number
    let magic_number = score % 1000 + seed;


    //call get_flag
    get_flag(score, guess, hash_input, github_id, magic_number, seed, challenge, rand, ctx);
}
