pragma solidity ^0.5.0;

import "./CloneFactory.sol";

contract Clone {

  CloneFactory public cloneFactory;

  uint public blockInitialized;

  modifier requireNotInitialized () {
    require(blockInitialized == 0);
    cloneFactory = CloneFactory(msg.sender);
    _;
    blockInitialized = block.number;
  }

}
