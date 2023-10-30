// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

contract Array {


        struct Game {
            address player;
            uint256 move;
        }

    Game[] public games;

    function addGame(address _player, uint256 _move) public {
        games.push(Game(_player, _move));
    }

    function getMoves() public view returns (uint256[] memory _moves) {
        _moves = new uint256[](games.length);
        for (uint256 i = 0; i < games.length; i++) {
            _moves[i] = games[i].move;
        }
    }
}
