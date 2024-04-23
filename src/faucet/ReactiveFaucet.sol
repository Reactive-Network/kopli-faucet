// SPDX-License-Identifier: UNLICENSED

pragma solidity >=0.8.0;

contract ReactiveFaucet {
    address private owner;
    address private callback_sender;
    address private reactive;

    uint256 public max_payout;

    constructor(address _callback_sender, uint256 _max_payout) {
        callback_sender = _callback_sender;
        max_payout = _max_payout;
        owner = msg.sender;
        reactive = address(0);
    }

    modifier onlyOwner() {
        require(msg.sender == owner, 'Not authorized');
        _;
    }

    modifier onlyReactive(address sender) {
        require(msg.sender == callback_sender, 'Not authorized (callback sender)');
        require(sender == reactive, 'Not authorized (reactive)');
        _;
    }

    function dispense(address sender, address payable receiver, uint256 amount) external onlyReactive(sender) {
        require(amount <= max_payout, 'Max payout exceeded');
        require(amount <= address(this).balance, 'Not enough funds');
        receiver.transfer(amount);
    }

    function setReactive(address _reactive) external onlyOwner {
        reactive = _reactive;
    }

    function setCallbackSender(address _callback_sender) external onlyOwner {
        callback_sender = _callback_sender;
    }

    function setMaxPayout(uint256 _max_payout) external onlyOwner {
        max_payout = _max_payout;
    }

    receive() external payable {
    }
}
