pragma solidity ^0.5.0;

import "./external/AddressListLib.sol";
import "./Interfaces.sol";

/// @title DelegatedWalletManager Contract
/// @author Joseph Reed
/// @dev This contract's goal is to make it easy for anyone to manage new and existing delegated wallets
contract DelegatedWalletManager is IDelegatedWalletManager {

    using AddressListLib for AddressListLib.AddressList; // Import the data structure AddressList from the AddressListLib contract

    uint public blockCreated; // The block the factory was deployed

    mapping (address => AddressListLib.AddressList) wallets;   // The list of wallets added by each account

    /// @notice Constructor to create a DelegatedWalletManager
    constructor () public {
        blockCreated = block.number;
    }

    /// @notice Adds a wallet to the account list.
    /// @param factory The delegated wallet is deployed from the provided 'factory'
    /// @param delegates A list of predefined delegates to add to the wallet
    /// @return True if the wallet was successfully created
    function createWallet (IDelegatedWalletFactory factory, address[] memory delegates) public payable returns (IDelegatedWallet wallet) {
        wallet = factory.createWallet.value(msg.value)(msg.sender, delegates);
        require(address(wallet) != address(0x0), "wallet failed to deploy from factory");
        addWallet(wallet);
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

    /// @notice Adds a wallet to the account list.
    /// @param walletList The delegated wallet to add to the account list
    /// @return True if the wallet was successfully added
    function addWallets (IDelegatedWallet[] memory walletList) public {
        for (uint i = 0; i < walletList.length; i++) {
            addWallet(walletList[i]);
        }
    }

    /// @notice Removes a wallet from the account list.
    /// @param walletList The delegated wallet to remove from the account list
    /// @return True if the wallet was successfully removed
    function removeWallets (IDelegatedWallet[] memory walletList) public {
        for (uint i = 0; i < walletList.length; i++) {
            removeWallet(walletList[i]);
        }
    }

    /// @notice Fetches a wallet list from a given account.
    /// @param account The given account from which to fetch the wallet list
    /// @return an address array of wallets owned by 'account'
    function getWallets (address account) public view returns (address[] memory) {
        return wallets[account].getList();
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
    function getWalletAt (address account, uint i) public view returns (IDelegatedWallet) {
        return IDelegatedWallet(address(uint160(wallets[account].getValueAt(i))));
    }

    /// @notice Fetches the index of a given 'wallet' from a given 'account' wallet list
    /// @param account The given account to check
    /// @param wallet The given wallet to check
    /// @return The current index of 'wallet' in 'account' wallet list
    function getIndexOf (address account, IDelegatedWallet wallet) public view returns (uint) {
        return wallets[account].getIndexOf(address(wallet));
    }

    event AddWallet_event(address indexed owner, address wallet);
    event RemoveWallet_event(address indexed owner, address wallet);

}
