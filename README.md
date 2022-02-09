# ETHroulette

This is a demo casino. **Don't use this contract in the wild.** If you'd like to interact with it it's deployed on ropsten: 

0x10B167C4855eaB4db13C480Ad63BE6aC7E84952a

I put 1 Eth in it. If you manage to steal it, please let me know how.

## Security of random numbers

Since the EVM is a deterministic environment creating random numbers is non-trivial. Other sources of randomness such as `block.timestamp` can be manipulated by the miner. Here I try to do it by not "rolling the ball" immediatly, but in the future. If you place your bet in block number `i`, the random number for your bet is generated in block number `i+1` at the earliest.

In order to beat the casino you need often enough to have an expectation value of your earnigs > 1. You get the best odds betting on a single:
You have a 1:35 payout and a 1/37 chance of winning honestly. With this we can use the fraction of the hash power needed to beat the casino:

![image](https://user-images.githubusercontent.com/6518935/153165582-9a665e18-76ae-45a1-8aa6-dbe1503a9a0b.png)



So if you get to mine every 1000th block you have an edge of 1.008. Additionally the payout routine only get's trigged if the contract is called, so if you are the only one playing at the casino, you could place a bet, wait until you are the winning miner and only then trigger the payout and thus never loosing money. If other are playing, their bet placement will trigger the payout routine and you might not be the miner for this block.


### DM me on twitter if you are hiring: @DeFiDingo
