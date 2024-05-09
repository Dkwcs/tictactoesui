module ttt_game::player {

    public struct Player has key, store {
            id: UID,
            addr: address,
    }


    entry fun create_player(ctx: &mut TxContext) {
        let player = Player {
            id: object::new(ctx),
            addr: ctx.sender(),
        };
        transfer::public_freeze_object(player);
    }

    public fun addr(self: &Player): address {
        self.addr
    }

    
}