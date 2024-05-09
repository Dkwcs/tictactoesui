module ttt_game::ttt_game {
    //use ttt_game::game_board::GameBoard;
    use ttt_game::player::Player;
    const NO_MARK: u8 = 0;
    const X_MARK: u8 = 1;
    const O_MARK: u8 = 2;


    const EInvalidCurrentTurnPlayer: u64 = 0;
    const EUnkownPlayer: u64 = 1;
    const EInvalidTurnLocation: u64 = 2;
    const EGameIsFinished: u64 = 3;

    public struct TTTGAME has key, store {
        id: UID,
        player1: address,
        player1_mark: u8,
        player2: address,
        player2_mark: u8,
        current_player: address,
        winner: Option<address>,
        is_finished: bool,
        game_board: vector<vector<u8>>
    }

    fun game_board(ttt_game: &TTTGAME) : &vector<vector<u8>> {
        &ttt_game.game_board
    }
    
    fun player1(ttt_game: &TTTGAME) : address {
        ttt_game.player1
    }
    
    fun player2(ttt_game: &TTTGAME) : address {
        ttt_game.player2
    }
    
    fun game_board_mut(ttt_game: &mut TTTGAME) : &mut vector<vector<u8>> {
        &mut ttt_game.game_board
    }

    #[test_only]
    public fun new (player1: address, player2: address, board: vector<vector<u8>>, ctx: &mut TxContext): TTTGAME {
        let id = object::new(ctx);

        let ttt_game = TTTGAME {
            id,
            player1,
            player1_mark: X_MARK,
            player2,
            player2_mark: O_MARK, 
            current_player: player1,
            is_finished: false,
            winner: option::none(),
            game_board: board,
        };

       ttt_game
     }

    entry fun create_game (player1: &Player, player2: &Player, ctx: &mut TxContext) {
        let id = object::new(ctx);

        let board = vector[
            vector[NO_MARK, NO_MARK, NO_MARK],
            vector[NO_MARK, NO_MARK, NO_MARK],
            vector[NO_MARK, NO_MARK, NO_MARK],
        ];
        let ttt_game = TTTGAME {
            id,
            player1: player1.addr(),
            player1_mark: X_MARK,
            player2: player2.addr(),
            player2_mark: O_MARK, 
            current_player: player1.addr(),
            is_finished: false,
            winner: option::none(),
            game_board: board,
        };
        transfer::public_share_object(ttt_game);
     }

     entry fun reset_game (game: &mut TTTGAME, player1: &Player, ctx: &mut TxContext) {
        let board = game.game_board_mut();
        *board = vector[
            vector[NO_MARK, NO_MARK, NO_MARK],
            vector[NO_MARK, NO_MARK, NO_MARK],
            vector[NO_MARK, NO_MARK, NO_MARK],
        ];
        game.is_finished = false;
        game.current_player = player1.addr();
        game.winner = option::none();

     }

    entry fun make_turn(game: &mut TTTGAME, row: u64, col: u64, ctx: &mut TxContext) {
        assert!(!game.is_finished, EGameIsFinished);
        let sender = ctx.sender();
        assert!(game.current_player == sender , EInvalidCurrentTurnPlayer);
        if (row > 2 && col > 2) { 
            abort EInvalidTurnLocation
        };
        turn_validation(game.game_board(), row, col);
        let curr_player_mark = game.get_curr_player_mark();
        let mark_place =  game.game_board_mut()[row].borrow_mut(col);
        *mark_place = curr_player_mark;
        let winner = game.check_winner();
        if (winner.is_some()) {
            game.is_finished = true;
            game.winner = winner;
        }
        else {
            game.change_curr_player();
        }
     }

    fun turn_validation(game_board: &vector<vector<u8>>, row: u64, col: u64) {
        if (row > 2 || col > 2 || game_board[row][col] != NO_MARK) {
            abort EInvalidTurnLocation
        };
     }

    fun get_curr_player_mark(game: &TTTGAME): u8 {
        if(game.current_player == game.player1) {
            game.player1_mark
        }
        else if (game.current_player == game.player2) {
            game.player2_mark
        }
        else {
            abort EUnkownPlayer
        }
     }

     fun change_curr_player(game: &mut TTTGAME) {
        if(game.current_player == game.player1) {
            game.current_player = game.player2;
        }
        else {
            game.current_player = game.player1;
        }
     }

     public(package) fun check_winner(game: &TTTGAME) : Option<address> {
        let mut counter = 0;
        let game_board = game.game_board();
        while (counter < 3) {
            if ((game_board[counter][0] == X_MARK && game_board[counter][0] == game_board[counter][1] && game_board[counter][0] == game_board[counter][2]) ||
            (game_board[0][counter] == X_MARK && game_board[0][counter] == game_board[1][counter] && game_board[0][counter] == game_board[2][counter])
            ) {
                return option::some(game.player1())
            };
            if ((game_board[counter][0] == O_MARK && game_board[counter][0] == game_board[counter][1] && game_board[counter][0] == game_board[counter][2]) ||
            (game_board[0][counter] == O_MARK && game_board[0][counter] == game_board[1][counter] && game_board[0][counter] == game_board[2][counter])) {
                return option::some(game.player2())
            };
            counter = counter + 1;
        };

        // Check diagonals
        if ((game_board[0][0] == X_MARK && game_board[0][0] == game_board[1][1] && game_board[0][0] == game_board[2][2]) || 
            (game_board[0][2] == X_MARK && game_board[0][2] == game_board[1][1] && game_board[0][2] == game_board[2][0])) {
               return option::some(game.player1())
        };
        if ((game_board[0][0] == O_MARK && game_board[0][0] == game_board[1][1] && game_board[0][0] == game_board[2][2]) || 
            (game_board[0][2] == O_MARK && game_board[0][2] == game_board[1][1] && game_board[0][2] == game_board[2][0])) {
               return option::some(game.player2())
        };
        option::none()
     }
} 