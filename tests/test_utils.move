module ttt_game::test_utils {
    use sui::test_scenario::{Self, Scenario};
    use ttt_game::game_entity::{GameEntity, make_turn};
    use ttt_game::player::{new as new_player, Player};
    use std::string::utf8;
    const PLAYER1_ADDR: address = @0x1; 
    const PLAYER2_ADDR: address = @0x2;

    #[test_only]
    public fun scenario(): Scenario {
        test_scenario::begin(PLAYER1_ADDR)
    }
    #[test_only]
    public fun players_addr(): (address, address) {
        (PLAYER1_ADDR, PLAYER2_ADDR)
    }

    #[test_only]
    public fun test_player1(ctx: &mut TxContext): Player {
        new_player(utf8(b"Player1Nick"), PLAYER1_ADDR, ctx)
    }

    #[test_only]
    public fun test_player2(ctx: &mut TxContext): Player {
        new_player(utf8(b"Player2Nick"), PLAYER2_ADDR, ctx)
    }


    #[test_only]
    public fun play_simple_game(game: &mut GameEntity, addr1: address, addr2: address, scenario: &mut Scenario) {
        scenario.next_tx(addr1);
        make_turn(game, 0, 0, scenario.ctx());

        scenario.next_tx(addr2);
        make_turn(game, 1, 0, scenario.ctx());

        scenario.next_tx(addr1);
        make_turn(game, 0, 1, scenario.ctx());

        scenario.next_tx(addr2);   
        make_turn(game, 1, 1, scenario.ctx());

        scenario.next_tx(addr1);   
        make_turn(game, 0, 2, scenario.ctx());
    }
}