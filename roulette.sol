// SPDX-License-Identifier: CC-BY-SA-4.0

pragma solidity ^0.8.11;

contract roulette{
    struct Bet{
        address payable bettor;
        uint bet_blocknumber;
        uint[] winning_numbers;
        uint winnig_amount;
    }

    address owner;
    uint security;
    bytes32 random_seed;
    mapping(uint => Bet) bet_list;
    uint first_bet = 1;
    uint last_bet = 0;

    modifier shuffle {
        random_seed = keccak256(abi.encodePacked(random_seed,
                                             block.difficulty, 
                                             block.timestamp,
                                             block.coinbase,
                                             gasleft()));
        //for(uint i = max(0, block.number - security); i <= block.number; i++){
        //    random_seed = keccak256(abi.encodePacked(random_seed, blockhash(i)));
        //}
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
        require(security > 0, "Can't have 0 security");
    }

    function push_bet(Bet memory incoming_bet) private {
        last_bet += 1;
        bet_list[last_bet] = incoming_bet;
    }

    function pop_bet() private {
        require(last_bet >= first_bet);
        delete bet_list[first_bet];
        first_bet += 1;
    }

    function max(uint a, uint b)  pure private returns(uint){
        if(a > b){
            return a;
        }else{
            return b;
        }
    }


    function getrandom(uint nmax) private shuffle returns(uint) {
        uint x = uint(random_seed) % nmax;
        return x;
    }

    function payout_winnings() public shuffle{
        uint i = first_bet;
        while(i <= last_bet){
            if(bet_list[i].bet_blocknumber > block.number - security){
                break;
            }else{
                bool won = false;
                uint ball = getrandom(37);
                for(uint j = 0; j < bet_list[i].winning_numbers.length; j++){
                    if(bet_list[i].winning_numbers[j] == ball){
                        won = true;
                    }
                }

                if(won){
                    bet_list[i].bettor.transfer(bet_list[i].winnig_amount);
                }
                pop_bet();
            }
        }

    }

    function bet_odd() payable public shuffle{
        uint winning_amount = msg.value * 2;
        require(10 * winning_amount <= address(this).balance, "Stakes to high for me");

        uint[] memory winning_numbers = new uint[](18);
        for(uint i = 0; i < 18; i++){
            winning_numbers[i] = (i*2) + 1;
        }

        push_bet(Bet(payable(msg.sender), block.number, winning_numbers, winning_amount));
    }

    function close_casion() public onlyOwner{
        selfdestruct(payable(owner));
    }

    function deposite() external payable onlyOwner{}
} 