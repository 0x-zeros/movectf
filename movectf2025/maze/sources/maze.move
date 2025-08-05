module maze::maze {
    use sui::event;
    use std::string::{Self, String};

    const E_NOT_OWNER: u64 = 1;
    const E_CHALLENGE_NOT_COMPLETE: u64 = 2;
    const E_CHALLENGE_ALREADY_COMPLETE: u64 = 3;


    const ROW: u64 = 10;
    const COL: u64 = 11;

    //# = 35 (墙)
    //S = 83 (起点)
    //* = 42 (路径)
    //E = 69 (终点)
    const MAZE: vector<u8> = b"#S########\n#**#######\n##*#######\n##***#####\n####*#####\n##***###E#\n##*#####*#\n##*#####*#\n##*******#\n##########";
    // 行0: #S########\n  (位置0-10)
    // 行1: #**#######\n  (位置11-21) 
    // 行2: ##*#######\n  (位置22-32)
    // 行3: ##***#####\n  (位置33-43)
    // 行4: ####*#####\n  (位置44-54)
    // 行5: ##***###E#\n  (位置55-65)
    // 行6: ##*#####*#\n  (位置66-76)
    // 行7: ##*#####*#\n  (位置77-87)
    // 行8: ##*******#\n  (位置88-98)
    // 行9: ##########\n  (位置99-109)

    //moves： sdssddssaasssddddddwww

    const START_POS: u64 = 1;


    public struct ChallengeStatus has key, store {
        id: UID,
        owner: address,
        challenge_complete: bool,
    }

    public struct FlagEvent has copy, drop {
        sender: address,
        flag: String,
        github_id: String,
        success: bool,
    }
    
    public struct InvalidMove has copy, drop {}
    
    public struct HitWall has copy, drop {}
    
    public struct Success has copy, drop {
        path: String,
    }

    public entry fun create_challenge(ctx: &mut TxContext) {
        let sender = tx_context::sender(ctx);

        let challenge = ChallengeStatus {
            id: object::new(ctx),
            owner: sender,
            challenge_complete: false,
        };

        transfer::public_transfer(challenge, sender);
    }

    
    public entry fun complete_challenge(
        challenge: &mut ChallengeStatus,
        moves: vector<u8>,
        ctx: &mut TxContext,
    ) {
        let sender = tx_context::sender(ctx);
        assert!(challenge.owner == sender, E_NOT_OWNER);
        assert!(!challenge.challenge_complete, E_CHALLENGE_ALREADY_COMPLETE);
        
        
        let mut current_pos = START_POS;

        let len = vector::length(&moves);
        let mut i = 0;

        while (i < len) {
            let c = *vector::borrow(&moves, i);
            let mut new_pos = current_pos;

            // ASCII values: w=119, s=115, a=97, d=100
            if (c == 119) { //w向上
                if (current_pos >= COL) {
                    new_pos = current_pos - COL; 
                } else {
                    event::emit(InvalidMove {});
                    break
                }
            }
            else if (c == 115) { //s向下
                new_pos = current_pos + COL;  //(bug)缺少最下面一行check与处理，会越界
            }
            else if (c == 97) { //a向左
                if (current_pos % COL != 0) {
                    new_pos = current_pos - 1; 
                } else {
                    event::emit(InvalidMove {});
                    break
                }
            }
            else if (c == 100) { //d向右
                if (current_pos % COL != COL - 1) {
                    new_pos = current_pos + 1; 
                } else {
                    event::emit(InvalidMove {});
                    break
                }
            }
            else { 
                i = i + 1; //(?) 被忽略的无效move？
                continue
            };

            // Boundary check
            if (new_pos >= ROW * COL) { //只能通过上面的漏洞的s向下来实现？
                event::emit(InvalidMove {});
                break
            };

            let cell = maze_at(new_pos);

            //# = 35 (墙)
            //S = 83 (起点)
            //* = 42 (路径)
            //E = 69 (终点)
            if (cell == 35) {//墙
                event::emit(HitWall {});
                break
            };

            if (cell == 69) {//终点
                challenge.challenge_complete = true;
                event::emit(Success { path: string::utf8(moves) });
                break
            };

            current_pos = new_pos;
            i = i + 1;
        };
    
    }

    
    public entry fun claim_flag(
        challenge: &ChallengeStatus,
        github_id: String,
        ctx: &mut TxContext
    ) {
        let sender = tx_context::sender(ctx);
        assert!(challenge.owner == sender, E_NOT_OWNER);
        
        assert!(challenge.challenge_complete, E_CHALLENGE_NOT_COMPLETE);
        
        event::emit(FlagEvent {
            sender: tx_context::sender(ctx),
            flag: string::utf8(b"CTF{Letsmovectf}"),
            github_id,
            success: true
        }); 
    }

    public fun get_challenge_status(challenge: &ChallengeStatus): (bool) {
        challenge.challenge_complete
    }

    // 正常情况下maze_pos 等于 pos， 直接用pos就行啊，重新算一遍很多余。
    // 但是这里存在,是为了配合漏洞的s向下来实现越界 ? 好像也不是？计算结果并不会变，调用maze_at之前有len 越界check
    fun maze_at(pos: u64): u8 {
        let maze_ref = &MAZE;
        let row = pos / COL;
        let col = pos % COL;
        let maze_pos = row * COL + col;
        
        assert!(maze_pos < vector::length(maze_ref), 1);
        *vector::borrow(maze_ref, maze_pos)
    }

}