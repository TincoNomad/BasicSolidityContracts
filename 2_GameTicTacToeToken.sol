//SPDX-License-Identifier: GPL-3.0

//Version
pragma solidity >0.8.0 <0.9.0;

//importaition
import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";
import "./Achievement.sol";
import "./Token.sol";

//Contract

contract TicTacToe is VRFConsumerBaseV2{
    struct Game{
        uint[4][4] moves;
        address player1;
        address player2;
        address lastPlayer;
        address winner;
    }

    mapping(uint256 => uint256) requestGames;
    Game[] games;
    mapping (address=>uint) winGames;
    Achievement achievement;
    Token token;

    VRFCoordinatorV2Interface coordinator;
    uint64 idSubscription;

    //Constructor
    constructor(
        address achievementContract, 
        address tokenContract, 
        address coordination, 
        uint64 idSub,
        address vrfCoordinatorAddress
        ) VRFConsumerBaseV2(vrfCoordinatorAddress) {

        achievement = Achievement(achievementContract);
        token = Token(tokenContract);
        coordinator = VRFCoordinatorV2Interface(coordination);
        idSubscription = idSub;
    }

    //Functions
    function startGane(address ply1, address ply2) public returns (uint){
        require(ply1 != ply2);
        uint idGame = games.length;
        Game memory game;
        game.player1 = ply1;
        game.player2 = ply2;
        games.push(game);

        uint requestId = coordinator.requestRandomWords(
            0x474e34a077df58807dbe9c96d3c009b23b3c6d0cce433e59bbf5b34f823bc56c,
            idSubscription,
            3,
            100000,
            1
        );

        requestGames[requestId] = idGame;

        return idGame;
    }

    function fulfillRandomWords(
            uint256 _requestId,
            uint256 [] memory _randomWords
        ) internal override {

            uint idGame = requestGames[_requestId];
            uint random = _randomWords[0];

            if (random % 2 == 0) games[idGame].lastPlayer = games[idGame].player1;
            else games[idGame].lastPlayer = games[idGame].player2;

        }

    function play(uint idGame, uint vertical, uint horizontal) public {
        //validtions
        Game memory game = games[idGame];
        require(msg.sender == game.player1 || msg.sender == game.player2);
        require(horizontal > 0 && horizontal < 4);
        require(vertical > 0 && vertical < 4);
        require(game.moves[horizontal][vertical]==0);
        require(msg.sender != game.lastPlayer);
        require(! gameOver(game));
        require(game.lastPlayer != address(0));

        //save game
        saveMove(idGame, horizontal, vertical);

        //Check if there is a winer or the playboard is full
        uint winner = getWinner(game);
        saveWinner(winner, idGame);

        games[idGame].lastPlayer = msg.sender;

    }

    function saveWinner (uint winner, uint idGame) private {
        if (winner != 0) {
            if (winner == 1) games[idGame].winner = games[idGame].player1;
            else games[idGame].winner = games[idGame].player2;

            winGames[games[idGame].winner]++;
            if (winGames[games[idGame].winner]== 5){
                achievement.generate(games[idGame].winner);
            }

            if (achievement.balanceOf(games[idGame].winner) > 0){
                token.generate(2, games[idGame].winner);
            }

            else {
                token.generate(1, games[idGame].winner);
            }
        }
    }

    function saveMove(uint idGame, uint horizontal, uint vertical) private {
        if (msg.sender == games[idGame].player1) games[idGame].moves[horizontal][vertical] = 1;
        else games[idGame].moves[horizontal][vertical] = 2;
    }

    function checkLine (uint[4][4] memory moves, uint x1, uint y1, uint x2, uint y2, uint x3, uint y3) private pure returns (uint){
        if ((moves[x1][y1] == moves[x2][y2]) && (moves[x2][y2] == moves[x3][y3])) {
            return moves[x1][y1];
        }
        return 0;
    }


    function getWinner(Game memory game) private pure returns (uint){
        //Check diag \
        uint winner = checkLine(game.moves, 1,1,2,2,3,3);
         // Check diag /
        if (winner == 0) winner = checkLine(game.moves, 3,1,2,2,1,3);
        // Check cols |
        if (winner == 0) winner = checkLine(game.moves, 1,1,1,2,1,3);
        if (winner == 0) winner = checkLine(game.moves, 2,1,2,2,2,3);
        if (winner == 0) winner = checkLine(game.moves, 3,1,3,2,3,3);
        // Check rows -
        if (winner == 0) winner = checkLine(game.moves, 1,1,2,1,3,1);
        if (winner == 0) winner = checkLine(game.moves, 1,2,2,2,3,2);
        if (winner == 0) winner = checkLine(game.moves, 1,3,2,3,3,3);

        return winner;
    }

    function gameOver(Game memory game) private pure returns (bool){
        if(game.winner != address(0)) return true;

        for (uint x=1; x<4; x++){
            for (uint y=1; y<4; y++){
                if (game.moves[x][y] == 0) return false;
            }
        }

        return true;    
    }

    //Modifiers
}

