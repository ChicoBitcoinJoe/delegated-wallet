pragma solidity ^0.5.0;

import "./external/Clone.sol";
import "./external/ERC20Token.sol";
import "./Delegated.sol";
import "./Interfaces.sol";

/// @title Delegated Wallet
/// @author Joseph Reed
/// @dev This contract's goal is to make it easy for anyone to add utility to their cryptocurrency wallet through
///      the use of delegates. In general, Delegates will be smart contracts that can transfer funds out of the
///      wallet in predefined ways. Only the owner can add or remove delegates.
contract DelegatedWallet is IDelegatedWallet, Delegated, Payable, Clone {

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

    /// @notice Convenience function to fetch the token balance of the provided token
    /// @param token The token to fetch the balance of
    /// @return The balance of the specified token
    function balanceOf (address token) public view returns (uint balance) {
        if(token == ETHER)
            balance = address(this).balance;
        else
            balance = ERC20Token(token).balanceOf(address(this));
    }

    event Call_event(
        address indexed delegate,
        address indexed callAddress,
        uint callValue,
        bytes callData,
        bytes returnData,
        bool success
    );

    event Deposit_event (
        address indexed sender,
        uint amount
    );

    event Transfer_event (
        address indexed delegate,
        address indexed token,
        address indexed recipient,
        uint amount,
        bool success
    );

}
