module ttt_game::game_entity {
    use ttt_game::player::{PlayerInfo};
    use ttt_game::game_record::Self;
    use ttt_game::history::{History};
    use sui::table;
    use ttt_game::player::Player;
    use sui::event;
    
    const NO_MARK: u8 = 0;
    const X_MARK: u8 = 1;
    const O_MARK: u8 = 2;


    const EInvalidCurrentPlayer: u64 = 0;
    const EUnkownPlayer: u64 = 1;
    const EInvalidTurnLocation: u64 = 2;
    const EGameIsFinished: u64 = 3;

    public struct GameEntity has key {
        id: UID,
        player1: PlayerInfo,
        player1_mark: u8,
        player2: PlayerInfo,
        player2_mark: u8,
        current_player: PlayerInfo,
        winner: Option<PlayerInfo>,
        is_finished: bool,
        game_board: vector<vector<u8>>
    }

    public struct GameManagerCap has key {
        id: UID
    }


    fun init(ctx: &mut TxContext) {
        transfer::transfer(GameManagerCap {
            id: object::new(ctx)
        }, ctx.sender())
    }

    fun game_board(self: &GameEntity) : &vector<vector<u8>> {
        &self.game_board
    }
    
    public(package) fun is_finished(self: &GameEntity) : bool {
        self.is_finished
    }

    public(package) fun player1_info(self: &GameEntity) : &PlayerInfo {
        &self.player1
    }
    
    public(package) fun player2_info(self: &GameEntity) : &PlayerInfo {
        &self.player2
    }

    fun game_board_mut(self: &mut GameEntity) : &mut vector<vector<u8>> {
        &mut self.game_board
    }

    public(package) fun winner(self: &GameEntity) : &Option<PlayerInfo> {
        &self.winner
    }

    entry fun create_game (_: &GameManagerCap, player1: &Player, player2: &Player, ctx: &mut TxContext) {
        let id = object::new(ctx);
        let board = vector[
            vector[NO_MARK, NO_MARK, NO_MARK],
            vector[NO_MARK, NO_MARK, NO_MARK],
            vector[NO_MARK, NO_MARK, NO_MARK],
        ];
        let ttt_game = GameEntity {
            id,
            player1: *player1.info(),
            player1_mark: X_MARK,
            player2: *player2.info(),
            player2_mark: O_MARK, 
            current_player: *player1.info(),
            is_finished: false,
            winner: option::none(),
            game_board: board,
        };
        event::emit(
            GameStartedEvent {
            game_id: object::uid_to_inner(&ttt_game.id),
            player1_info: *player1.info(),
            player2_info: *player2.info()
        });

        transfer::share_object(ttt_game);
     }

    entry fun delete_game(_: &GameManagerCap, history: &mut History, game: GameEntity, ctx: &mut TxContext) {
        let game_record = game_record::new_game_record(*game.player1_info(), *game.player2_info(), *game.winner.borrow(), ctx);
        table::add(history.games(), object::id(&game_record), game_record);
        game.destroy();
     }

    public fun destroy(self: GameEntity) {
        let GameEntity { id, player1: _, player2: _, player1_mark: _, player2_mark: _, current_player: _, is_finished: _, winner: _, game_board: _ } = self;
        object::delete(id);
    }

    entry fun make_turn(game: &mut GameEntity, row: u64, col: u64, ctx: &TxContext) {
        // Check if game isn't finished
        assert!(!game.is_finished, EGameIsFinished);
        let sender = ctx.sender();

        // Only current registered player can make a turn
        assert!(game.current_player.addr() == sender , EInvalidCurrentPlayer);
        if (row > 2 && col > 2) { 
            abort EInvalidTurnLocation
        };

        // Check index is not out of bounds and empty mark space
        turn_validation(game.game_board(), row, col);
        let curr_player_mark = game.get_curr_player_mark();
        *game.game_board_mut()[row].borrow_mut(col) = curr_player_mark;
        let winner = game.check_winner();
        if (winner.is_some()) {
            game.is_finished = true;
            game.winner = winner;
            event::emit(
                GameFinishedEvent {
                game_id: object::uid_to_inner(&game.id),
                winner: *winner.borrow(), // abort is imposible here
            });
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

    fun get_curr_player_mark(game: &GameEntity): u8 {
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

     fun change_curr_player(game: &mut GameEntity) {
        if(game.current_player == game.player1) {
            game.current_player = game.player2;
        }
        else {
            game.current_player = game.player1;
        }
     }

    //TODO: refactor(more optimise)
    public(package) fun check_winner(game: &GameEntity) : Option<PlayerInfo> {
        let mut counter = 0;
        let game_board = game.game_board();
        while (counter < 3) {
            if ((game_board[counter][0] == X_MARK && game_board[counter][0] == game_board[counter][1] && game_board[counter][0] == game_board[counter][2]) ||
            (game_board[0][counter] == X_MARK && game_board[0][counter] == game_board[1][counter] && game_board[0][counter] == game_board[2][counter])
            ) {
                return option::some(*game.player1_info())
            };
            if ((game_board[counter][0] == O_MARK && game_board[counter][0] == game_board[counter][1] && game_board[counter][0] == game_board[counter][2]) ||
            (game_board[0][counter] == O_MARK && game_board[0][counter] == game_board[1][counter] && game_board[0][counter] == game_board[2][counter])) {
                return option::some(*game.player2_info())
            };
            counter = counter + 1;
        };

        // Check diagonals
        if ((game_board[0][0] == X_MARK && game_board[0][0] == game_board[1][1] && game_board[0][0] == game_board[2][2]) || 
            (game_board[0][2] == X_MARK && game_board[0][2] == game_board[1][1] && game_board[0][2] == game_board[2][0])) {
               return option::some(*game.player1_info())
        };
        if ((game_board[0][0] == O_MARK && game_board[0][0] == game_board[1][1] && game_board[0][0] == game_board[2][2]) || 
            (game_board[0][2] == O_MARK && game_board[0][2] == game_board[1][1] && game_board[0][2] == game_board[2][0])) {
               return option::some(*game.player2_info())
        };
        option::none()
     }


    public struct GameFinishedEvent has copy, drop {
        game_id: ID,
        winner: PlayerInfo,
    }

   public struct GameStartedEvent has copy, drop {
        game_id: ID,
        player1_info: PlayerInfo,
        player2_info: PlayerInfo,
    }

    #[test_only]
    public fun new (player1: PlayerInfo, player2: PlayerInfo, ctx: &mut TxContext): GameEntity {
        let id = object::new(ctx);
        let board = vector[
            vector[NO_MARK, NO_MARK, NO_MARK],
            vector[NO_MARK, NO_MARK, NO_MARK],
            vector[NO_MARK, NO_MARK, NO_MARK],
        ];
        let game_entity = GameEntity {
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

       game_entity
     }
     
    #[test_only]
    public fun test_init(ctx: &mut TxContext) {
        init(ctx)
    }
} 