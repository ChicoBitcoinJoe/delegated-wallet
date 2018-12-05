pragma solidity ^0.5.0;

import "./external/ListLib.sol";
import "./IDelegatedWallet.sol";

/// @title DelegatedWalletManager Contract
/// @author Joseph Reed
/// @dev This contract's goal is to make it easy for anyone to manage existing and new delagated wallets
contract DelegatedWalletManager {

    using ListLib for ListLib.AddressList;              // Import the data structure AddressList from the ListLib contract

    uint public blockCreated;                           // The block the factory was deployed
    
    mapping (address => ListLib.AddressList) wallets;   // The list of wallets added by each account
    
    /// @notice Constructor to create a DelegatedWalletManager
    constructor () public {
        blockCreated = block.number;
    }

    /// @notice Adds a wallet to the account list.
    /// @param factory The delegated wallet is deployed from the provided 'factory'
    /// @param delegates A list of predefined delegates to add to the wallet
    /// @return True if the wallet was successfully created
    function createWallet (IDelegatedWalletFactory factory, address[] memory delegates) public payable returns (IDelegatedWallet wallet) {
        wallet = factory.createWallet(msg.sender, delegates);
        require(address(wallet) != address(0x0));

        wallets[msg.sender].add(address(wallet));        
        emit AddWallet_event(msg.sender, address(wallet));
    }

    /// @notice Adds a wallet to the account list.
    /// @param wallet The delegated wallet to add to the account list
    /// @return True if the wallet was successfully added
    function addWallet (IDelegatedWallet wallet) public returns (bool success) {
        success = wallets[msg.sender].add(address(wallet));
        emit AddWallet_event(msg.sender, address(wallet));
    }

    /// @notice Removes a wallet from the account list.
    /// @param wallet The delegated wallet to remove from the account list
    /// @return True if the wallet was successfully removed
    function removeWallet (IDelegatedWallet wallet) public returns (bool success) {
        success = wallets[msg.sender].remove(address(wallet));
        if(success)
            emit RemoveWallet_event(msg.sender, address(wallet));
    }

    /// @notice Fetches a wallet list from a given account.
    /// @param account The given account from which to fetch the wallet list
    /// @return an address array of wallets owned by 'account'
    function getWallets (address account) public view returns (address[] memory) {
        return wallets[account].get();
    }
    
    /// @notice Fetches a how many wallets are in the list from a given account.
    /// @param account The given account from which to fetch the wallet list
    /// @return the total number of wallets
    function totalWallets (address account) public view returns (uint) {
        return wallets[account].getLength();
    }
    
    /// @notice Shows if a wallet exists in the wallet list from a given account.
    /// @param account The given account to check
    /// @param wallet The given wallet to check for
    /// @return True if the given wallet exists an accounts wallet list
    function contains (address account, IDelegatedWallet wallet) public view returns (bool) {
        return wallets[account].contains(address(wallet));
    }

    /// @notice Fetches the wallet at index 'i' from the 'account' wallet list
    /// @param account The given account to check
    /// @param i The index to check
    /// @return The wallet address that exists at index 'i' in the 'account' wallet list
    function index (address account, uint i) public view returns (IDelegatedWallet) {
        return IDelegatedWallet(address(uint160(wallets[account].index(i))));
    }

    /// @notice Fetches the index of a given 'wallet' from a given 'account' wallet list
    /// @param account The given account to check
    /// @param wallet The given wallet to check
    /// @return The current index of 'wallet' in 'account' wallet list
    function indexOf (address account, IDelegatedWallet wallet) public view returns (uint) {
        return wallets[account].indexOf(address(wallet));
    }

    event AddWallet_event(address owner, address wallet);
    event RemoveWallet_event(address owner, address wallet);

}
