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
| Delegated Wallet Blueprint | 0x40981163D09F654f20cAD34E85deC377534E5445 |
| Delegated Wallet Factory | 0x1DC4ebA1883dcAA61bb585A5729d29D693bc443B |
| Delegated Wallet Manager | 0x84C4C1be0184a58cebbFaC2779d7088567a388C4 |
