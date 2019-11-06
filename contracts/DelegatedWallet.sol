pragma solidity ^0.5.0;

import "./external/AddressList.sol";
import "./external/ERC20Token.sol";
import "./external/Owned.sol";

contract IDelegatedWallet {
    function transfer (address payable recipient, address token, uint amount) public returns (bool success);
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

/// @title DelegatedWallet Contract
/// @author Joseph Reed
/// @dev This contract's goal is to make it easy for anyone to add utility to their cryptocurrency wallet through
///      the use of delegates. Delegates can transfer funds out of the wallet but cannot add or remove other delegates.
contract DelegatedWallet is IDelegatedWallet, Owned, Clone {

    using AddressListLib for AddressListLib.AddressList; // Import the data structure AddressList from the AddressListLib contract

    address constant ETHER = address(0x0); // A convencience variable

    AddressListLib.AddressList delegates;  // A list of delegates that can call this contract

    /// @notice Initializes the wallet. Uses 'initialize()' instead of a constructor to make use of the clone
    ///         factory at https://github.com/optionality/clone-factory. In general, 'initialize()' should be
    ///         called directly following it's deployment through the use of a factory.
    /// @param _owner The address that owns the wallet
    function initialize (address _owner) public requireNotInitialized {
        owner = _owner;
    }

    /// @notice Allows accepting Ether as a payment
    function () external payable {
        emit Deposit_event(msg.sender, msg.value);
    }

    ///////////////////////////
    /// Delegate Functions
    ///////////////////////////

    /// @notice Send 'amount' of 'tokens' to 'recipient'
    /// @param token The address of the token to transfer
    /// @param recipient The address of the recipient
    /// @param amount The amount of tokens to be transferred
    /// @return True if the transfer was successful
    function transfer (address token, address payable recipient, uint amount) public onlyDelegates returns (bool success) {
        if(token == ETHER) {
            success = recipient.send(amount);
        }
        else {
            success = ERC20Token(token).transfer(recipient, amount);
        }

        emit Transfer_event(msg.sender, token, recipient, amount, success);
    }

    /// @notice Send 'amount' of 'tokens' to 'recipient'
    /// @param callAddress The address of the contract to call
    /// @param callValue The amount of ether to attach with the call
    /// @param callData The data to send to the call address
    /// @return success returns true if the call throws no errors.
    /// @return returnData contains the returned result of the call
    function call (address callAddress, uint callValue, bytes memory callData) public onlyDelegates returns (bool success, bytes memory returnData) {
        (success, returnData) = callAddress.call.value(callValue)(callData);
        emit Call_event(msg.sender, callAddress, callValue, callData, returnData, success);
    }

    ///////////////////////////
    /// Owner Functions
    ///////////////////////////

    /// @notice Add a new delegate to the list of delegates
    /// @param delegate The address of the new delegate
    /// @return True if the delegate was successfully added
    function addDelegate (address delegate) public onlyOwner returns (bool success) {
        success = delegates.add(delegate);
        if(success) emit AddDelegate_event(delegate);
    }

    /// @notice Remove an existing delegate from the list of delegates
    /// @param delegate The address of an existing delegate
    /// @return True if the delegate was successfully removed
    function removeDelegate (address delegate) public onlyOwner returns (bool success) {
        success = delegates.remove(delegate);
        if(success) emit RemoveDelegate_event(delegate);
    }

    /// @notice Add a new delegate to the list of delegates
    /// @param delegateList The list of addresses to set as delegates
    function addDelegates (address[] memory delegateList) public onlyOwner {
        for (uint i = 0; i < delegateList.length; i++) {
            addDelegate(delegateList[i]);
        }
    }

    /// @notice Remove an existing delegate from the list of delegates
    /// @param delegateList The list of addresses to set as delegates
    function removeDelegates (address[] memory delegateList) public onlyOwner {
        for (uint i = 0; i < delegateList.length; i++) {
            removeDelegate(delegateList[i]);
        }
    }

    ///////////////////////////
    /// Getter Functions
    ///////////////////////////

    /// @notice Gets the balance of the provided token
    /// @param token The token to fetch the balance of
    /// @return The balance of the specified token
    function balanceOf (address token) public view returns (uint balance) {
        if(token == ETHER)
            balance = address(this).balance;
        else
            balance = ERC20Token(token).balanceOf(address(this));
    }

    /// @notice Determine if a given address is a delegate of this wallet
    /// @param account The given address
    /// @return True if 'account' is a delegate
    function isDelegate (address account) public view returns (bool) {
        return delegates.contains(account);
    }

    /// @notice This function is for easily fetching the current list of delegates
    /// @return An address array of all current delegates
    function getDelegateList () public view returns (address[] memory) {
        return delegates.getList();
    }

    /// @notice Get the current total number of delegates
    /// @return The total number of delegates
    function totalDelegates () public view returns (uint) {
        return delegates.getLength();
    }

    /// @notice Fetch a delegate address at a particular index
    /// @param i The index from which to fetch the delegate address
    /// @return The delegate address at index 'i'
    function getDelegateAt (uint i) public view returns (address) {
        return delegates.getValueAt(i);
    }

    /// @notice Fetch the index of a particular delegate address. Note: if the index returns '0',
    ///         it must be called in conjuction with isDelegate() due to '0' being a default return value
    /// @param delegate The delegate address from which to grab the index
    /// @return The index of 'delegate'
    function getIndexOf (address delegate) public view returns (uint) {
        return delegates.getIndexOf(delegate);
    }

    ///////////////////////////
    /// Events and Modifiers
    ///////////////////////////

    modifier onlyDelegates () {
        require(isDelegate(msg.sender), "only a delegate can call this function");
        _;
    }

    event Deposit_event (address indexed sender, uint amount);
    event AddDelegate_event (address delegate);
    event RemoveDelegate_event (address delegate);
    event Transfer_event (
        address indexed delegate,
        address indexed token,
        address indexed recipient,
        uint amount,
        bool success
    );
    event Call_event(
        address indexed delegate,
        address indexed callAddress,
        uint callValue,
        bytes callData,
        bytes returnData,
        bool success
    );

}

/// @title DelegatedWalletFactory Contract
/// @author Joseph Reed
/// @dev This contract makes it easy to deploy delegated wallet.
contract DelegatedWalletFactory is IDelegatedWalletFactory, CloneFactory {

    uint public blockCreated;           // The block the factory was deployed
    address public blueprint;   // The delegated wallet blueprint to supply the clone factory

    /// @notice Constructor to create a DelegatedWalletFactory
    /// @param _blueprint The delegated wallet blueprint
    constructor (address _blueprint) public {
        blockCreated = block.number;    // The block number at the time of deployment
        blueprint = _blueprint;         // The blueprint for every delegated wallet
    }

    /// @notice Creates a delegated wallet with the owner set to 'owner' and predefined 'delegates'
    /// @param owner The owner of the delegated wallet
    /// @param delegates The owner of the delegated wallet
    /// @return The delegated wallet address
    function createWallet (address owner, address[] memory delegates) public payable returns (IDelegatedWallet) {
        // see https://solidity.readthedocs.io/en/v0.5.0/050-breaking-changes.html?highlight=address_make_payable for converting to payable addresses
        address payable clone = address(uint160(createClone(blueprint)));
        DelegatedWallet wallet = DelegatedWallet(clone);
        wallet.initialize(address(this));

        for(uint i = 0; i < delegates.length; i++)
            wallet.addDelegate(delegates[i]);

        wallet.transferOwnership(owner);

        if(msg.value > 0)
            address(wallet).transfer(msg.value);

        emit CreateWallet_event(msg.sender, owner, address(wallet));

        return wallet;
    }

    event CreateWallet_event(address indexed caller, address indexed owner, address wallet);

}

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
