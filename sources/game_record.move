module ttt_game::game_record {
    use std::string::String;
    use ttt_game::player::{PlayerInfo};


    public struct GameRecord has key, store {
        id: UID,
        player1_nickname: String,
        player2_nickname: String,
        winner: PlayerInfo,

    }
 
    public(package) fun new_game_record(player1_info: PlayerInfo, player2_info: PlayerInfo, winner: PlayerInfo, ctx: &mut TxContext): GameRecord {
        GameRecord {
            id: object::new(ctx),
            player1_nickname: *player1_info.nickname(),
            player2_nickname: *player2_info.nickname(),
            winner,
        }
   }
   
}