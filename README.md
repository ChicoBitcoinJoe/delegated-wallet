# Delegated Wallet

A delegated wallet uses a plugin like approach for letting decentralized applications have access to your wallet. The wallet keeps an internal list of delegates that can be added and removed at will by the wallet owner. A delegate can transfer ether or any ERC20 token from the wallet at any time so it is critical to only add vetted smart contracts as delegates or funds can be stolen. 

```
	function transfer (address token, address payable recipient, uint amount) public onlyDelegates returns (bool success);
	unction call(address callAddress, uint callValue, bytes memory callData) public onlyDelegates returns (bool success, bytes memory returnData);
	function addDelegate(address delegate) public onlyOwner returns (bool success)
	function removeDelegate(address delegate) public onlyOwner returns (bool success)
```

| Kovan Contract | Contract Address |
| --- | --- |
| Address List Lib | 0x3B09fdAE6D5c6C2A5aC1A4F34C11a78B86632aAA |
| Delegated Wallet Blueprint | 0x80cf81788B463a08b1c7df0C2564ac1dc9AdA8Da |
| Delegated Wallet Factory | 0xDf3f0E883208345488bAE43Eb642f9f34F000CB8 |
| Delegated Wallet Manager | 0x9E25Ef3C6e23c9a7095A9968e88Ff09212947A36 |

## Decentralized Delegates

1. [Recurring Alarm Clock Scheduler](https://github.com/everchain-project/recurring-alarm-clock) ([demo](https://everchain-project.github.io/recurring-alarm-clock/))
2. [Recurring Payment Scheduler](https://github.com/everchain-project/recurring-payment-scheduler) (no demo yet)
