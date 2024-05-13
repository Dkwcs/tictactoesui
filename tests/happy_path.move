
#[test_only]
module ttt_game::ttt_game_tests {
    use ttt_game::game_entity::{Self, new as new_game_entity, make_turn, delete_game, GameManagerCap};
    use ttt_game::player::{new as new_player};
    use ttt_game::history::{Self, History};
    use sui::test_scenario::{Self, ctx, return_to_sender};
    use std::string::utf8;
    const NO_MARK: u8 = 0;


    #[test]
    fun check_winner() {
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

        //Act
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
        let board = vector[
            vector[NO_MARK, NO_MARK, NO_MARK],
            vector[NO_MARK, NO_MARK, NO_MARK],
            vector[NO_MARK, NO_MARK, NO_MARK],
        ];
        let player1_addr = @0x1;
        let player2_addr = @0x2;
       let mut scenario = test_scenario::begin(player1_addr);

        game_entity::test_init(scenario.ctx());
        history::test_init(scenario.ctx());

        scenario.next_tx(player1_addr);
        let game_manager_cap = scenario.take_from_sender<GameManagerCap>();
        let mut history = scenario.take_from_address<History>(player1_addr);

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