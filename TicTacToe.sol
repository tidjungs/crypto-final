pragma solidity ^0.4.18;

contract TicTacToe {

    address[2] _playerAddress;
    uint32 _turnLength;

    bytes32 _p1Commitment;
    uint8 _p2Nonce;

    uint8[9] _board;
    uint8 _currentPlayer;
    uint256 _turnDeadline;

    function TicTacToe(address opponent, uint32 turnLength, bytes32 p1Commitment) public {
        _playerAddress[0] = msg.sender;
        _playerAddress[1] = opponent;
        _turnLength = turnLength;
        _p1Commitment = p1Commitment;
    }

    function checkCurrentPlayer() view public returns (uint8) {
        return _currentPlayer;
    }

    function joinGame(uint8 p2Nonce) public payable returns (bool success) {
        require(msg.sender == _playerAddress[1]);
        require(msg.value >= address(this).balance);
        _p2Nonce = p2Nonce;
        return true;
    }

    function startGame(uint8 p1Nonce) public {
        require(keccak256(p1Nonce) == _p1Commitment);
        // random by xor 2 nonce when pick last bit the first player
        _currentPlayer = (p1Nonce ^ _p2Nonce) & 0x01;
        _turnDeadline = block.number + _turnLength;
    }

    // function keccak(uint8 a) internal pure returns (bytes32)  {
    //     return keccak256(a);
    // }

    function playMove(uint8 squareToPlay) public {
        require(msg.sender == _playerAddress[_currentPlayer]);
        _board[squareToPlay] = _currentPlayer;
        
        // if (checkGameOver())
        //     selfdestruct(msg.sender);

        // flip current player
        _currentPlayer ^= 0x1;
        // next turn
        // _turnDeadline = block.number + _turnLength;
    }

    function defaultGame() public {
        if (block.number > _turnDeadline)
            selfdestruct(msg.sender);
    }

    // function checkGameOver() public returns (bool) {
    //     return false;
    // }

}