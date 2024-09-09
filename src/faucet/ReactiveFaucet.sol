// SPDX-License-Identifier: UNLICENSED

pragma solidity >=0.8.0;

import '../AbstractCallback.sol';
import '../AbstractPausableReactive.sol';

contract ReactiveFaucet is AbstractPausableReactive, AbstractCallback {
    uint256 private constant SEPOLIA_CHAIN_ID = 11155111;
    uint256 private constant REACTIVE_CHAIN_ID = 0x512578;

    uint256 private constant PAYMENT_REQUEST_TOPIC_0 = 0x8e191feb68ec1876759612d037a111be48d8ec3db7f72e4e7d321c2c8008bd0d;

    uint64 private constant CALLBACK_GAS_LIMIT = 1000000;

    // State specific to ReactVM contract instance

    address private l1;
    uint256 public max_payout;

    constructor(address _l1, uint256 _max_payout) AbstractCallback(address(SERVICE_ADDR)) payable {
        max_payout = _max_payout;
        l1 = _l1;
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

    receive() external payable {}

    function dispense(address sender, address payable receiver, uint256 amount) external onlyReactive(sender) {
        require(amount <= max_payout, 'Max payout exceeded');
        require(amount <= address(this).balance, 'Not enough funds');
        receiver.transfer(amount);
    }

    function setMaxPayout(uint256 _max_payout) external onlyOwner {
        max_payout = _max_payout;
    }

    // Methods specific to ReactVM contract instance

    function react(
        uint256 /* chain_id */,
        address /* _contract */,
        uint256 /* topic_0 */,
        uint256 topic_1,
        uint256 topic_2,
        uint256 /* topic_3 */,
        bytes calldata /* data */,
        uint256 /* block_number */,
        uint256 /* op_code */
    ) external vmOnly {
        bytes memory payload = abi.encodeWithSignature(
            "dispense(address,address,uint256)",
            address(0),
            address(uint160(topic_1)),
            topic_2 / 10
        );
        emit Callback(REACTIVE_CHAIN_ID, address(this), CALLBACK_GAS_LIMIT, payload);
    }
}
