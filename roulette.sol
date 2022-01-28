// SPDX-License-Identifier: CC-BY-SA-4.0

pragma solidity ^0.8.11;

contract roulette{
    struct bet{
        address payable bettor;
        uint bet_blocknumber;
        uint[] winning_numbers;
        uint[] winnig_amount;
    }

    address owner;
    uint security;
    bytes32 random_seed;
    mapping(uint => bet) bet_list;
    uint first = 1;
    uint last = 0;

    modifier shuffle {
        random_seed = keccak256(abi.encodePacked(random_seed,
                                             block.difficulty, 
                                             block.timestamp,
                                             block.coinbase,
                                             gasleft()));
        for(uint i = block.number - security; i <= block.number; i++){
            random_seed = keccak256(abi.encodePacked(random_seed, blockhash(i)));
        }
        _;
    }

    modifier payout {
        payout_winnings();
        _;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    constructor (uint _security){
        owner = msg.sender;
        security = _security;
    }

    function push_bet(bet calldata incoming_bet) private {
        last += 1;
        bet_list[last] = incoming_bet;
    }

    function pop_bet() private {
        require(last >= first);
        delete bet_list[first];
        first += 1;
    }

    function getrandom(uint nmax) private shuffle returns(uint) {
        uint x = uint(random_seed) % nmax;
        return x;
    }

    function payout_winnings() public shuffle{

    }

    function close_casion() public onlyOwner{
        selfdestruct(payable(owner));
    }
}