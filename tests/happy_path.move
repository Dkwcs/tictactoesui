
#[test_only]
module ttt_game::ttt_game_tests {
    use ttt_game::game_entity::{Self, new as new_game_entity, delete_game, GameManagerCap};
    use ttt_game::history::{Self, History};
    use sui::test_scenario::{Self, ctx, return_to_sender};
    use ttt_game::test_utils::{scenario, test_player1, test_player2, players_addr, play_simple_game};

    #[test]
    fun check_winner() {
        //Arrange
        let (player1_addr, player2_addr ) = players_addr();
        let mut scenario = scenario();
        let player1 = test_player1(scenario.ctx());
        let player2 = test_player2(scenario.ctx());
       
        let mut ttt_game = new_game_entity(player1.player_info(), player2.player_info(), scenario.ctx());

        //Act
        play_simple_game(&mut ttt_game, player1_addr, player2_addr, &mut scenario);

        let winner = ttt_game.check_winner();

        //Assert
        assert!(ttt_game.is_finished(), 0);
        assert!(winner.borrow().addr() == player1_addr, 1);

        ttt_game.destroy();
        player1.destroy();
        player2.destroy();
        test_scenario::end(scenario);
    }

     #[test]
    fun history_created() {
        //Arrange
        let (player1_addr, player2_addr ) = players_addr();
        let mut scenario = scenario();

        game_entity::test_init(scenario.ctx());
        history::test_init(scenario.ctx());

        scenario.next_tx(player1_addr);
        let game_manager_cap = scenario.take_from_sender<GameManagerCap>();
        let mut history = scenario.take_from_address<History>(player1_addr);

        let player1 = test_player1(scenario.ctx());
        let player2 = test_player2(scenario.ctx());

        let mut ttt_game = new_game_entity(player1.player_info(), player2.player_info(), scenario.ctx());

        //Act & Assert
        play_simple_game(&mut ttt_game, player1_addr, player2_addr, &mut scenario);

        assert!(ttt_game.is_finished(), 0);

        delete_game(&game_manager_cap, &mut history, ttt_game, scenario.ctx());
        assert!(history.games().length() == 1, 0);
    
        player1.destroy();
        player2.destroy();
        scenario.return_to_sender(game_manager_cap);
        scenario.return_to_sender(history);
        test_scenario::end(scenario);

    }
}