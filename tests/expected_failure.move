
#[test_only]
module ttt_game::expected_failure {
    use ttt_game::game_entity::{new as new_game_entity, Self, make_turn};
    use ttt_game::player::{new as new_player};
    use sui::test_scenario;
    use std::string::utf8;
    const NO_MARK: u8 = 0;


    #[test, expected_failure(abort_code = game_entity::EInvalidCurrentPlayer)]
    fun invalid_current_player() {
        //Arrange
        let board = vector[
            vector[NO_MARK, NO_MARK, NO_MARK],
            vector[NO_MARK, NO_MARK, NO_MARK],
            vector[NO_MARK, NO_MARK, NO_MARK],
        ];
        let player1_addr = @0x1;
        let player2_addr = @0x2;
        let mut scenario = test_scenario::begin(player1_addr);
        let player1 = new_player(utf8(b"Player1Nick"), player1_addr, scenario.ctx());
        scenario.next_tx(player2_addr);
        let player2 = new_player(utf8(b"Player2Nick"), player2_addr, scenario.ctx());
       

        let mut ttt_game = new_game_entity(player1.player_info(), player2.player_info(), board, scenario.ctx());
    
        //Act & Assert
        make_turn(&mut ttt_game, 0, 0, scenario.ctx());

        ttt_game.destroy();
        player1.destroy();
        player2.destroy();
        test_scenario::end(scenario);
    }

    #[test, expected_failure(abort_code = game_entity::EInvalidCurrentPlayer)]
    fun unknown_player() {
        //Arrange
        let board = vector[
            vector[NO_MARK, NO_MARK, NO_MARK],
            vector[NO_MARK, NO_MARK, NO_MARK],
            vector[NO_MARK, NO_MARK, NO_MARK],
        ];
        let player1_addr = @0x1;
        let player2_addr = @0x2;
        let unkown_player_adrr = @0x3;
        let mut scenario = test_scenario::begin(player1_addr);
        let player1 = new_player(utf8(b"Player1Nick"), player1_addr, scenario.ctx());
        scenario.next_tx(player2_addr);
        let player2 = new_player(utf8(b"Player2Nick"), player2_addr, scenario.ctx());
       

        let mut ttt_game = new_game_entity(player1.player_info(), player2.player_info(), board, scenario.ctx());
    
        //Act & Assert
        scenario.next_tx(unkown_player_adrr);
        make_turn(&mut ttt_game, 0, 0, scenario.ctx());

        ttt_game.destroy();
        player1.destroy();
        player2.destroy();
        test_scenario::end(scenario);
    }

    #[test, expected_failure(abort_code = game_entity::EInvalidTurnLocation)]
    fun invalid_turn_location() {
        //Arrange
        let board = vector[
            vector[NO_MARK, NO_MARK, NO_MARK],
            vector[NO_MARK, NO_MARK, NO_MARK],
            vector[NO_MARK, NO_MARK, NO_MARK],
        ];
        let player1_addr = @0x1;
        let player2_addr = @0x2;
        let mut scenario = test_scenario::begin(player1_addr);
        let player1 = new_player(utf8(b"Player1Nick"), player1_addr, scenario.ctx());
        scenario.next_tx(player2_addr);
        let player2 = new_player(utf8(b"Player2Nick"), player2_addr, scenario.ctx());
       

        let mut ttt_game = new_game_entity(player1.player_info(), player2.player_info(), board, scenario.ctx());

        //Act & Assert
        scenario.next_tx(player1_addr);
        make_turn(&mut ttt_game, 0, 0, scenario.ctx());

        scenario.next_tx(player2_addr);
        make_turn(&mut ttt_game, 0, 0, scenario.ctx());

        ttt_game.destroy();
        player1.destroy();
        player2.destroy();
        test_scenario::end(scenario);
    }

    #[test, expected_failure(abort_code = game_entity::EGameIsFinished)]
    fun game_has_already_finished() {
        //Arrange
        let board = vector[
            vector[NO_MARK, NO_MARK, NO_MARK],
            vector[NO_MARK, NO_MARK, NO_MARK],
            vector[NO_MARK, NO_MARK, NO_MARK],
        ];
        let player1_addr = @0x1;
        let player2_addr = @0x2;
        let mut scenario = test_scenario::begin(player1_addr);
        let player1 = new_player(utf8(b"Player1Nick"), player1_addr, scenario.ctx());
        scenario.next_tx(player2_addr);
        let player2 = new_player(utf8(b"Player2Nick"), player2_addr, scenario.ctx());
       

        let mut ttt_game = new_game_entity(player1.player_info(), player2.player_info(), board, scenario.ctx());

        //Act & Assert
        scenario.next_tx(player1_addr);
        make_turn(&mut ttt_game, 0, 0, scenario.ctx());

        scenario.next_tx(player2_addr);
        make_turn(&mut ttt_game, 1, 0, scenario.ctx());

        scenario.next_tx(player1_addr);
        make_turn(&mut ttt_game, 0, 1, scenario.ctx());

        scenario.next_tx(player2_addr);   
        make_turn(&mut ttt_game, 1, 1, scenario.ctx());

        scenario.next_tx(player1_addr);   
        make_turn(&mut ttt_game, 0, 2, scenario.ctx());

        scenario.next_tx(player2_addr);   
        make_turn(&mut ttt_game, 1, 2, scenario.ctx());

        ttt_game.destroy();
        player1.destroy();
        player2.destroy();
        test_scenario::end(scenario);
    }




    // #[test_only]
    // fun play_test_game(game_entity: &mut GameEntity, ctx: &mut TxContext) {

    // }
}