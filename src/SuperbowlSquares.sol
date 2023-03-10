// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "chainlink/contracts/src/v0.8/ConfirmedOwner.sol";
import "chainlink/contracts/src/v0.8/VRFV2WrapperConsumerBase.sol";

contract SuperbowlSquares is VRFV2WrapperConsumerBase, ConfirmedOwner {
    event RequestSent(uint256 requestId, uint32 numWords);
    event RequestFulfilled(
        uint256 requestId,
        uint256[] randomWords,
        uint256 payment
    );

    error WrongPrice(uint256 expected, uint256 actual);
    error NumbersSet();
    error OutOfBoundsSelection(uint256 selection);
    error AlreadyTaken(uint256 selection);
    error NoBalance();
    error TransferFailed();

    struct RequestStatus {
        uint256 paid; // amount paid in link
        bool fulfilled; // whether the request has been successfully fulfilled
        uint256[] randomWords;
    }

    mapping(uint256 => RequestStatus) public s_requests; /* requestId --> requestStatus */
    mapping(uint256 => address) public squares;
    mapping(address => uint256) internal balancesByAddress;
    uint256 public squarePrice;
    uint256 private numSquaresBought = 0;
    bool public numbersSet = false;

    // past requests Id.
    uint256[] public requestIds;
    uint256 public lastRequestId;

    // Depends on the number of requested values that you want sent to the
    // fulfillRandomWords() function. Test and adjust
    // this limit based on the network that you select, the size of the request,
    // and the processing of the callback request in the fulfillRandomWords()
    // function.
    uint32 callbackGasLimit = 100000;

    // The default is 3, but you can set this higher.
    uint16 requestConfirmations = 3;

    // For this example, retrieve 2 random values in one request.
    // Cannot exceed VRFV2Wrapper.getConfig().maxNumWords.
    uint32 numWords = 2;

    // Address LINK - hardcoded for Goerli
    address linkAddress = 0x326C977E6efc84E512bB9C30f76E30c160eD06FB;

    // address WRAPPER - hardcoded for Goerli
    address wrapperAddress = 0x708701a1DfF4f478de54383E49a627eD4852C816;

    constructor(uint256 price)
        ConfirmedOwner(msg.sender)
        VRFV2WrapperConsumerBase(linkAddress, wrapperAddress)
    {
        squarePrice = price;
    }

    function getSquares() public view returns (address[100] memory squaresAddresses) {
        for (uint256 i = 1; i <= 100; i++) {
            squaresAddresses[i - 1] = squares[i];
        }
        return squaresAddresses;
    }

    function requestRandomWords()
        internal
        onlyOwner
        returns (uint256 requestId)
    {
        requestId = requestRandomness(
            callbackGasLimit,
            requestConfirmations,
            numWords
        );
        s_requests[requestId] = RequestStatus({
            paid: VRF_V2_WRAPPER.calculateRequestPrice(callbackGasLimit),
            randomWords: new uint256[](0),
            fulfilled: false
        });
        requestIds.push(requestId);
        lastRequestId = requestId;
        emit RequestSent(requestId, numWords);
        return requestId;
    }

    function fulfillRandomWords(
        uint256 _requestId,
        uint256[] memory _randomWords
    ) internal override {
        require(s_requests[_requestId].paid > 0, "request not found");
        s_requests[_requestId].fulfilled = true;
        s_requests[_requestId].randomWords = _randomWords;
        emit RequestFulfilled(
            _requestId,
            _randomWords,
            s_requests[_requestId].paid
        );
    }

    function getRequestStatus(uint256 _requestId)
        external
        view
        returns (
            uint256 paid,
            bool fulfilled,
            uint256[] memory randomWords
        )
    {
        require(s_requests[_requestId].paid > 0, "request not found");
        RequestStatus memory request = s_requests[_requestId];
        return (request.paid, request.fulfilled, request.randomWords);
    }

    /**
     * Allow withdraw of Link tokens from the contract
     */
    function withdrawLink() public onlyOwner {
        LinkTokenInterface link = LinkTokenInterface(linkAddress);
        require(
            link.transfer(msg.sender, link.balanceOf(address(this))),
            "Unable to transfer"
        );
    }

    function withdrawBalance() public payable {
        if (balancesByAddress[msg.sender] == 0) {
            revert NoBalance();
        }
        uint256 payment = balancesByAddress[msg.sender];
        balancesByAddress[msg.sender] = 0;
        (bool success, ) = msg.sender.call{value: payment}("");
        if (success != true) {
            revert TransferFailed();
        }
    }

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

        if (squares[squareNumber] != address(0)) {
            revert AlreadyTaken(squareNumber);
        }

        squares[squareNumber] = msg.sender;
    }

    function setNumbers() public onlyOwner {
        if (numbersSet) {
            revert NumbersSet();
        }

        requestRandomWords();
    }

    receive() external payable {}
}
