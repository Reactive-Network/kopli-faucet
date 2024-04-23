// SPDX-License-Identifier: UNLICENSED

pragma solidity >=0.8.0;

contract ReactiveFaucetL1 {
    event PaymentRequest(
        address indexed receiver,
        uint256 indexed amount
    );

    address payable private owner;

    uint256 public max_payout;

    constructor(uint256 _max_payout) {
        max_payout = _max_payout;
        owner = payable(msg.sender);
    }

    modifier onlyOwner() {
        require(msg.sender == owner, 'Unauthorized');
        _;
    }

    receive() external payable {
        _request(msg.sender, msg.value);
    }

    function request(address receiver) external payable {
        _request(receiver, msg.value);
    }

    function withdraw(uint256 amount) external onlyOwner {
        require(amount <= address(this).balance, 'Not enough funds');
        owner.transfer(amount);
    }

    function setMaxPayout(uint256 _max_payout) external onlyOwner {
        max_payout = _max_payout;
    }

    function _request(address receiver, uint256 value) internal {
        uint256 amount = value > max_payout ? max_payout : value;
        require(amount > 0, 'Just no');
        emit PaymentRequest(receiver, amount);
    }
}
