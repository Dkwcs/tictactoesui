module ttt_game::player {
    use std::string::String;

    /// Represents a player object.
    public struct Player has key {
            id: UID,
            info: PlayerInfo
    }

    /// Player object projection with all required information to store.
    public struct PlayerInfo has store, copy, drop {
        addr: address,
        nickname: String,
    }


    public fun nickname(self: &PlayerInfo) : &String {
        &self.nickname
    }

    /// Registers a new immutable `Player` object associated with the `sender`.
    entry fun create_player(nickname: String, ctx: &mut TxContext) {
        let player = Player {
            id: object::new(ctx),
            info: PlayerInfo {
                addr: ctx.sender(),
                nickname,
            }
        };
        transfer::freeze_object(player);
    }

    /// Desctructor of player object.
    public fun destroy(self: Player) {
        let Player { id, info: _ } = self;
        object::delete(id);
    }

    public fun info(self: &Player) : &PlayerInfo {
        &self.info
    }

    public fun addr(self: &PlayerInfo): address {
        self.addr
    }

    #[test_only]
    /// A constructor used for testing.
    public fun new(nickname: String, addr: address, ctx: &mut TxContext): Player {
        let id = object::new(ctx);

        let player = Player {
            id,
            info: PlayerInfo {
                addr,
                nickname
            }
        };

       player
     }

}