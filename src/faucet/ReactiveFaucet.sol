// SPDX-License-Identifier: UNLICENSED

pragma solidity >=0.8.0;

import '../../lib/reactive-lib/src/abstract-base/AbstractCallback.sol';
import '../../lib/reactive-lib/src/abstract-base/AbstractPausableReactive.sol';

contract ReactiveFaucet is AbstractPausableReactive, AbstractCallback {

    uint256 private constant SEPOLIA_CHAIN_ID = 11155111;
    uint256 private constant PAYMENT_REQUEST_TOPIC_0 = 0x8e191feb68ec1876759612d037a111be48d8ec3db7f72e4e7d321c2c8008bd0d;
    uint256 private constant EXCHANGE_RATE_FACTOR = 10000;
    uint64 private constant CALLBACK_GAS_LIMIT = 1000000;

    // State specific to ReactVM contract instance
    address private l1;
    uint256 public max_payout;
    uint256 public exchangeRate;

    constructor(address _l1, uint256 _max_payout, uint256 _exchangeRate) AbstractCallback(address(SERVICE_ADDR)) payable {
        l1 = _l1;
        max_payout = _max_payout;
        exchangeRate = _exchangeRate;
        bytes memory payload = abi.encodeWithSignature(
            "subscribe(uint256,address,uint256,uint256,uint256,uint256)",
            SEPOLIA_CHAIN_ID,
            l1,
            PAYMENT_REQUEST_TOPIC_0,
            REACTIVE_IGNORE,
            REACTIVE_IGNORE,
            REACTIVE_IGNORE
        );
        (bool subscription_result,) = address(service).call(payload);
        if (!subscription_result) {
            vm = true;
        }
    }

    modifier onlyReactive(address sender) {
        require(msg.sender == address(service), 'Not authorized (callback sender)');
        require(sender == owner, 'Not authorized (reactive)');
        _;
    }

    function getPausableSubscriptions() override internal view returns (Subscription[] memory) {
        Subscription[] memory result = new Subscription[](1);
        result[0] = Subscription(
            SEPOLIA_CHAIN_ID,
            l1,
            PAYMENT_REQUEST_TOPIC_0,
            REACTIVE_IGNORE,
            REACTIVE_IGNORE,
            REACTIVE_IGNORE
        );
        return result;
    }

    function dispense(address sender, address payable receiver, uint256 amount) external onlyReactive(sender) {
        uint256 adjustedAmount = (amount * exchangeRate) / EXCHANGE_RATE_FACTOR;

        require(adjustedAmount <= max_payout, 'Max payout exceeded');
        require(adjustedAmount <= address(this).balance, 'Not enough funds');

        receiver.transfer(adjustedAmount);
    }

    function setMaxPayout(uint256 _max_payout) external onlyOwner {
        max_payout = _max_payout;
    }

    function setExchangeRate(uint256 _exchangeRate) external onlyOwner {
        exchangeRate = _exchangeRate;
    }

    // Methods specific to ReactVM contract instance

    function react(LogRecord calldata log) external vmOnly {
        uint256 amount = log.topic_2 / 10;
        bytes memory payload = abi.encodeWithSignature(
            "dispense(address,address,uint256)",
            address(0),
            address(uint160(log.topic_1)),
            amount
        );
        emit Callback(block.chainid, address(this), CALLBACK_GAS_LIMIT, payload);
    }
}
