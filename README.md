# Delegated Wallet

A delegated wallet uses a plugin like approach for letting decentralized applications have access to your wallet. The wallet keeps an internal list of delegates that can be added and removed at will by the wallet owner. A delegate can transfer ether or any ERC20 token from the wallet at any time so it is critical to only add vetted smart contracts as delegates or funds can be stolen.

```
function transfer (address payable recipient, address token, uint amount) public onlyDelegates returns (bool success);
function call (address callAddress, uint callValue, bytes memory callData) public onlyDelegates returns (bool success, bytes memory returnData);
function balanceOf (address token) public view returns (uint balance);
function isDelegate (address _address) public view returns (bool success);
```

| Kovan Contract | Contract Address |
| --- | --- |
| Address List Lib | 0x2605524186207E6f933aA63647Ab3Ae7803923a4 |
| Delegated Wallet Blueprint | 0x4f2acC21b7Ba2d225b16F220F03b72F5C6ed7013 |
| Delegated Wallet Factory | 0x142d44A4a1b281Ba3b9979a4F21B515477105189 |
| Delegated Wallet Manager | 0x05f1d50Cc81CAd13e0927AaE133f83B6fE681AA3 |
