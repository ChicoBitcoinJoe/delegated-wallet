pragma solidity ^0.5.0;

import "./external/ERC20.sol";
import "./external/Owned.sol";
import "./AddressListLib.sol";
import "./IDelegatedWallet.sol";

/// @title DelegatedWallet Contract
/// @author Joseph Reed
/// @dev This contract's goal is to make it easy for anyone to add utility to their cryptocurrency wallet through
///      the use of delegates. Delegates can transfer funds out of the wallet but cannot add or remove other delegates. 
contract DelegatedWallet is Owned, IDelegatedWallet {

    using AddressListLib for AddressListLib.AddressList; // Import the data structure AddressList from the AddressListLib contract

    uint public blockCreated;       // records the block when the contract is created
    address public factory;         // records the factory that deployed this wallet
    AddressListLib.AddressList delegates;  // the list of delegates that can call the transfer function

    /// @notice Initializes the wallet. Uses 'initialize()' instead of a constructor to make use of the clone 
    ///         factory at https://github.com/optionality/clone-factory. In general, 'initialize()' should be  
    ///         called directly following it's deployment through the use of a factory.
    /// @param _owner The address that owns the wallet
    function initialize (address _owner) public {
        require(blockCreated == 0, "block created can only be set once");

        blockCreated = block.number;
        factory = msg.sender;

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
        if(token == address(0x0))
            success = recipient.send(amount);
        else
            success = ERC20(token).transfer(recipient, amount);
        
        emit Transfer_event(msg.sender, token, recipient, amount, success);
    }

    /// @notice Send 'amount' of 'tokens' to 'recipient'
    /// @param callAddress The address of the token to transfer
    /// @param callData The address of the recipient
    /// @return success returns true if the call throws no errors. returnData contains the returned result of the call
    function call(address callAddress, uint callValue, bytes memory callData) public onlyDelegates returns (bool success, bytes memory returnData) {
        (success, returnData) = callAddress.call.value(callValue)(callData);

        emit Call_event(msg.sender, callAddress, callValue, callData, returnData, success);
    }

///////////////////////////
/// Owner Functions
///////////////////////////

    /// @notice Add a new delegate to the list of delegates
    /// @param delegate The address of the new delegate
    /// @return True if the delegate was successfully added
    function addDelegate(address delegate) public onlyOwner returns (bool success) {
        success = delegates.add(delegate);
        
        if(success)
            emit AddDelegate_event(delegate);
    }
    
    /// @notice Remove an existing delegate from the list of delegates
    /// @param delegate The address of an existing delegate
    /// @return True if the delegate was successfully removed
    function removeDelegate(address delegate) public onlyOwner returns (bool success) {
        success = delegates.remove(delegate);
        
        if(success)
            emit RemoveDelegate_event(delegate);
    }

///////////////////////////
/// Getter Functions
///////////////////////////

    /// @notice Gets the balance of the provided token
    /// @param token The token to fetch the balance of. address(0x0) == native ether
    /// @return The balance of the specified token
    function balanceOf (address token) public view returns (uint balance) {
        if(token == address(0x0))
            balance = address(this).balance;
        else
            balance = ERC20(token).balanceOf(address(this));
    }

    /// @notice Determine if a given address is a delegate of this wallet
    /// @param account The given address
    /// @return True if 'account' is a delegate
    function isDelegate (address account) public view returns (bool) {
        return delegates.contains(account);
    }

    /// @notice This function is for easily fetching the current list of delegates
    /// @return An address array of all current delegates
    function getDelegates () public view returns (address[] memory) {
        return delegates.array;
    }

    /// @notice Get the current total number of delegates
    /// @return The total number of delegates
    function totalDelegates () public view returns (uint) {
        return delegates.getLength();
    }

    /// @notice Fetch a delegate address at a particular index
    /// @param i The index from which to fetch the delegate address
    /// @return The delegate address at index 'i' 
    function index (uint i) public view returns (address) {
        return delegates.index(i);
    }
    
    /// @notice Fetch the index of a particular delegate address. Note: if the index returns '0', 
    ///         it must be called in conjuction with isDelegate() due to '0' being a default return value
    /// @param delegate The delegate address from which to grab the index
    /// @return The index of 'delegate' 
    function indexOf (address delegate) public view returns (uint) {
        return delegates.indexOf(delegate);
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
