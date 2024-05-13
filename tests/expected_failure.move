
#[test_only]
module ttt_game::expected_failure {
    use ttt_game::game_entity::{new as new_game_entity, Self, make_turn};
    use sui::test_scenario;
    use ttt_game::test_utils::{scenario, test_player1, test_player2, players_addr, play_simple_game};


    #[test, expected_failure(abort_code = game_entity::EInvalidCurrentPlayer)]
    fun invalid_current_player() {
        //Arrange
        let mut scenario = scenario();
        let player1 = test_player1(scenario.ctx());
        let player2 = test_player2(scenario.ctx());

        let mut ttt_game = new_game_entity(player1.player_info(), player2.player_info(), scenario.ctx());
    
        //Act & Assert
        scenario.next_tx(player2.player_info().addr());
        make_turn(&mut ttt_game, 0, 0, scenario.ctx());

        ttt_game.destroy();
        player1.destroy();
        player2.destroy();
        test_scenario::end(scenario);
    }

    #[test, expected_failure(abort_code = game_entity::EInvalidCurrentPlayer)]
    fun unknown_player() {
        //Arrange
        let unkown_player_adrr = @0x3;
        let mut scenario = scenario();
        let player1 = test_player1(scenario.ctx());
        let player2 = test_player2(scenario.ctx());

        let mut ttt_game = new_game_entity(player1.player_info(), player2.player_info(), scenario.ctx());
    
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
        let (player1_addr, player2_addr ) = players_addr();
        let mut scenario = scenario();
        let player1 = test_player1(scenario.ctx());
        let player2 = test_player2(scenario.ctx());
       

        let mut ttt_game = new_game_entity(player1.player_info(), player2.player_info(), scenario.ctx());

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
        let (player1_addr, player2_addr ) = players_addr();
        let mut scenario = scenario();
        let player1 = test_player1(scenario.ctx());
        let player2 = test_player2(scenario.ctx());
       

        let mut ttt_game = new_game_entity(player1.player_info(), player2.player_info(), scenario.ctx());

        //Act & Assert
        play_simple_game(&mut ttt_game, player1_addr, player2_addr, &mut scenario);


        scenario.next_tx(player2_addr);   
        make_turn(&mut ttt_game, 1, 2, scenario.ctx());

        ttt_game.destroy();
        player1.destroy();
        player2.destroy();
        test_scenario::end(scenario);
    }
}