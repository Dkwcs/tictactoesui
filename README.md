# Tic tac toe game

It is a simple version of famous tic tac toe game based on blockchain.

## Introduction

Two players who take turns marking the spaces in a three-by-three grid with X or O. The player who succeeds in placing three of their marks in a horizontal, vertical, or diagonal row is the winner.

## Documentation

Detailed source-based documentation can be generated executing the following command from the directory contained this file:

```bash
sui move build --doc
```

and can be found in the `./build/ttt_game/docs` folder.

## Demo

The first step is to publish the compiled package:

```bash
sui client publish --gas-budget 100000000      
```

As a result, our module is published and created instances of `History` and `GameManagerCap`.

```rust
----- Transaction Effects ----
Status : Success
Created Objects:
  - ID: 0x3692e3b72770d38ca32b2eabc4e3030a825c406145775582d0413746fbcbfa2d , Owner: Account
  - ID: 0x5677efda21975c324457693810f1153047946636bd1378041d4fea7d4e5e7edc , Owner: Account
```

To simplify the future commands, let's create several exports:

```bash
export PACKAGE_ID=0xe8bbb0802f56cd65149f8f3835e6fc66ea242ae1cd2c216996b7d3344462de35
export GAMEMANCAP_ID=0x5677efda21975c324457693810f1153047946636bd1378041d4fea7d4e5e7edc
export HISTORY_ID=0x3692e3b72770d38ca32b2eabc4e3030a825c406145775582d0413746fbcbfa2d
```

Now we can register several players on different addresses, for example:

```bash
sui client call --function create_player --package $PACKAGE_ID --module player --args Player1Nick --gas-budget 10000000
sui client switch --address zen-heliotrope
sui client call --function create_player --package $PACKAGE_ID --module player --args Player2Nick --gas-budget 10000000
```

```rust
----- Transaction Effects ----
Status : Success
Created Objects:
  - ID: 0xe3d3fccc6443c4abbe7511ab775576770802a8ebdef94cb37740a5ec0bb59150 , Owner: Immutable

  ----- Transaction Effects ----
Status : Success
Created Objects:
  - ID: 0x35c313f9edeb8aacfd354c50cf0f2a13d643fcb4639714a60748233925154d96 , Owner: Immutable
```


And again, make several exports:

```bash
export PLAYER1_ID=0xe3d3fccc6443c4abbe7511ab775576770802a8ebdef94cb37740a5ec0bb59150
export PLAYER2_ID=0x35c313f9edeb8aacfd354c50cf0f2a13d643fcb4639714a60748233925154d96
```

Now we can create a game with 2 existed players from the address that has appropriate capability:

```bash
sui client call --function create_game --package $PACKAGE_ID --module game_entity --args $GAMEMANCAP_ID $PLAYER1_ID $PLAYER2_ID --gas-budget 10000000
```

```rust
----- Transaction Effects ----
Status : Success
Created Objects:
  - ID: 0x73175de7eddbf28001a86b5fe6acc47530519f1cd4ca206eff2cdea98188a7d0 , Owner: Shared
```

```bash
export GAME_ID=0x73175de7eddbf28001a86b5fe6acc47530519f1cd4ca206eff2cdea98188a7d0
```
Now each player can take an action on his turn, with chosen location(from default player 1 has X mark, player2 - 0 mark)

```bash
sui client call --function make_turn --package $PACKAGE_ID --module game_entity --args $GAME_ID 1 1 --gas-budget 10000000
```

After all, account with game manager capability can turn game into history.

```bash
sui client call --function delete_game --package $PACKAGE_ID --module game_entity --args $GAMEMANCAP_ID $HISTORY_ID $GAME_ID --gas-budget 10000000
```

## Improvements

Add checking for draw.
Add rewards for winner.
