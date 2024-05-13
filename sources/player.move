module ttt_game::player {
    use std::string::String;

    public struct Player has key, store {
            id: UID,
            addr: address,
            nickname: String
    }

    public struct PlayerInfo has store, copy, drop {
        addr: address,
        nickname: String,
    }

    public fun nickname(self: &PlayerInfo) : String {
        self.nickname
    }
    entry fun create_player(nickname: String, ctx: &mut TxContext) {
        let player = Player {
            id: object::new(ctx),
            addr: ctx.sender(),
            nickname,
        };
        transfer::public_freeze_object(player);
    }

    public fun destroy(self: Player) {
        let Player { id, addr: _, nickname: _ } = self;
        object::delete(id);
    }

    public fun player_info(self: &Player) : PlayerInfo {
        PlayerInfo {
            addr: self.addr,
            nickname: self.nickname
        }
    }

    public fun addr(self: &PlayerInfo): address {
        self.addr
    }

    #[test_only]
    public fun new(nickname: String, addr: address, ctx: &mut TxContext): Player {
        let id = object::new(ctx);

        let player = Player {
            id,
            addr,
            nickname
        };

       player
     }

}