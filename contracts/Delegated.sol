pragma solidity ^0.5.0;

import "./external/AddressListLib.sol";
import "./external/Owned.sol";

contract Delegated is Owned {

    using AddressListLib for AddressListLib.AddressList; // Import the data structure AddressList from the AddressListLib contract

    AddressListLib.AddressList delegates;  // A list of delegates that can call this contract

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
    /// Modifiers and Events
    ///////////////////////////

    modifier onlyDelegates () {
        require(isDelegate(msg.sender), "only a delegate can call this function");
        _;
    }

    event AddDelegate_event (address delegate);
    event RemoveDelegate_event (address delegate);

}
