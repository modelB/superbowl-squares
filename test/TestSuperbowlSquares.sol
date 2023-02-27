// SPDX-License-Identifier: MIT
 
pragma solidity ^0.8.7;
 
import "forge-std/Test.sol";
// import "./utils/Cheats.sol";
// import "../MyNFT.sol";
 
contract SuperbowlSquaresTest is Test {
   address public owner;
   address bob = address(0x12345);
  
 
   function setUp() public {
       owner = msg.sender;
       vm.label(address(this), "Spritely test contract");
       vm.deal(address(bob), 1000 ether);
   }
 
   function canBuySquare() public {
    address[] memory squares = new address[](100);
    for (uint256 i = 0; i < 100; i++) {
        squares[i] = address(0);
    }
    
   }
 
   function testCanMintToken() public {
    //    myNFT.setSaleIsActive(true);
    //    vm.prank(address(bob));
    //    myNFT.mint{value: 30000000 gwei}(1);
    //    assertEq(myNFT.balanceOf(address(bob)), 1);
   }
}