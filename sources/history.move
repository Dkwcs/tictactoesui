module ttt_game::history {
    use ttt_game::game_record::{GameRecord};
    use sui::table::Table;

    public struct History has key, store {
        id: UID,
        games: Table<ID, GameRecord>,
    }

    public fun games(self: &mut History): &mut Table<ID, GameRecord> {
       &mut self.games
    }

   fun init(ctx: &mut TxContext) {
        transfer::transfer(History {
            id: object::new(ctx),
            games: sui::table::new(ctx)
        }, ctx.sender())
    }

    #[test_only]
    public fun test_init(ctx: &mut TxContext) {
        init(ctx)
    }
}