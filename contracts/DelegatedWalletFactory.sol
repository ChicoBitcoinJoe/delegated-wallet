pragma solidity ^0.5.0;

import "./external/CloneFactory.sol";
import "./DelegatedWallet.sol";

/// @title DelegatedWalletFactory Contract
/// @author Joseph Reed
/// @dev The DelegatedWalletFactory makes it easy to deploy delegated wallet. It provides several
///      helper functions to deploy a wallet in several ways
contract DelegatedWalletFactory is CloneFactory {
    
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
    function createWallet (address owner, address[] memory delegates) public returns (DelegatedWallet wallet) {
        // see https://solidity.readthedocs.io/en/v0.5.0/050-breaking-changes.html?highlight=address_make_payable for converting to payable addresses
        address payable clone = address(uint160(createClone(blueprint)));
        wallet = DelegatedWallet(clone);
        wallet.initialize(address(this));

        for(uint i = 0; i < delegates.length; i++)
            wallet.addDelegate(delegates[i]);
        
        wallet.transferOwnership(owner);

        emit CreateWallet_event(msg.sender, owner, address(wallet));
    }
    
    event CreateWallet_event (address indexed caller, address indexed owner, address wallet);
    
}
