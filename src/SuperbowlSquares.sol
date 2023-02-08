// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "openzeppelin-contracts/contracts/access/Ownable.sol";

contract SuperbowlSquares is Ownable {
    uint256 public squarePrice;
    bool public numbersSet = false;
    mapping(uint256 => address) public squares;

    constructor(uint256 price) {
        squarePrice = price;
    }

    error WrongPrice(uint256 expected, uint256 actual);
    error NumbersSet();
    error OutOfBoundsSelection(uint256 selection);

    function buySquare(uint256 squareNumber) public payable {
        if (numbersSet) {
            revert NumbersSet();
        }

        if (msg.value != squarePrice) {
            revert WrongPrice(squarePrice, msg.value);
        }

        if (squareNumber < 1 || squareNumber > 100) {
            revert OutOfBoundsSelection(squareNumber);
        }

        require(squares[squareNumber] == address(0), "Square is already taken");
        squares[squareNumber] = msg.sender;
    }

    function setNumbers() public onlyOwner {
        // ...
    }
}
