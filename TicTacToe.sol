pragma solidity ^0.4.18;

contract TicTacToe {

    address[2] _playerAddress;
    uint32 _turnLength;

    bytes32 _p1Commitment;
    uint8 _p2Nonce;

    uint8[9] _board;
    uint8 _currentPlayer;
    uint256 _turnDeadline;

    uint8[8][] _win;

    constructor (address opponent, uint32 turnLength, bytes32 p1Commitment) public payable {
        _playerAddress[0] = msg.sender;
        _playerAddress[1] = opponent;
        _turnLength = turnLength;
        _p1Commitment = p1Commitment;

        _win.push([0,1,2]);
        _win.push([3,4,5]);
        _win.push([6,7,8]);
        _win.push([0,3,6]);
        _win.push([1,4,7]);
        _win.push([2,5,8]);
        _win.push([0,4,8]);
        _win.push([2,4,6]);
    }

    function getBalance() view public returns (uint256) {
        return address(this).balance;
    }

    function getDead() view public returns (uint256, uint256) {
        return (block.number, _turnDeadline);
    }

    function getCurrentPlayer() view public returns (uint8) {
        return _currentPlayer;
    }

    function getBoard() view public returns (uint8[9]) {
        return _board;
    }

    function joinGame(uint8 p2Nonce)  public payable {
        require(msg.sender == _playerAddress[1]);
        // require(msg.value >= address(this).balance);
        _p2Nonce = p2Nonce;
    }

    function startGame(uint8 p1Nonce) public {
        require(keccak256(p1Nonce) == _p1Commitment);
        // random by xor 2 nonce when pick last bit the first player
        _currentPlayer = (p1Nonce ^ _p2Nonce) & 0x01;
        _turnDeadline = block.number + _turnLength;
    }

    function checkGameOver() public returns (bool) {
        for (uint8 i = 0; i < 8; i++) {
            if (_board[_win[i][0]] == _currentPlayer + 1 &&
                _board[_win[i][1]] == _currentPlayer + 1 &&
                _board[_win[i][2]] == _currentPlayer + 1)
                return true;
        }
        return false;
    }

    function playMove(uint8 squareToPlay) public {
        require(msg.sender == _playerAddress[_currentPlayer]);
        require(_board[squareToPlay] == 0);
        _board[squareToPlay] = _currentPlayer + 1;
        
        if (checkGameOver())
            selfdestruct(msg.sender);

        // flip current player
        _currentPlayer ^= 0x1;
        // next turn
        _turnDeadline = block.number + _turnLength;
    }

    function defaultGame() public {
        if (block.number > _turnDeadline)
            selfdestruct(msg.sender);
    }

    function getWin() view public returns (uint8[8][])  {
        return _win;
    }
}