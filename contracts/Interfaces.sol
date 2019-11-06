pragma solidity ^0.5.0;

contract Payable {
    address constant ETHER = address(0x0);
    function () external payable;
}

contract IDelegatedWallet {
    function transfer (address token, address payable recipient, uint amount) public returns (bool success);
    function call (address callAddress, uint callValue, bytes memory callData) public returns (bool success, bytes memory returnData);
    function balanceOf (address token) public view returns (uint balance);
    function isDelegate (address _address) public view returns (bool success);
    function () external payable;
}

contract IDelegatedWalletFactory {
    function createWallet (address owner, address[] memory delegates) public payable returns (IDelegatedWallet);
}

contract IDelegatedWalletManager {
    function createWallet (IDelegatedWalletFactory factory, address[] memory delegates) public payable returns (IDelegatedWallet wallet);
    function addWallet (IDelegatedWallet wallet) public returns (bool success);
    function removeWallet (IDelegatedWallet wallet) public returns (bool success);
    function getWallets (address account) public view returns (address[] memory);
    function totalWallets (address account) public view returns (uint);
    function contains (address account, IDelegatedWallet wallet) public view returns (bool);
    function getWalletAt (address account, uint i) public view returns (IDelegatedWallet);
    function getIndexOf (address account, IDelegatedWallet wallet) public view returns (uint);
}
