module ttt_game::history {
    use ttt_game::game_record::{GameRecord, Self};
    use ttt_game::player::PlayerInfo;
    use sui::table::Table;

    public struct History has key {
        id: UID,
        games: Table<ID, GameRecord>,
    }

    public fun games(self: &History): &Table<ID, GameRecord> {
       &self.games
    }

   public fun add_game(self: &mut History, player1_info: PlayerInfo, player2_info: PlayerInfo, winner: PlayerInfo, ctx: &mut TxContext) {
        let game_record = game_record::new_game_record(player1_info, player2_info,winner, ctx);
        self.games.add(object::id(&game_record), game_record)
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