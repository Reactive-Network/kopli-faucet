# Reactive Faucet App

## Overview

The Reactive Faucet App is a system that operates between L1 (or any other layer) and the Reactive Network. This demo enables users to request funds from a faucet contract deployed on L1 and receive them through the `ReactiveFaucetListener` contract deployed on the Reactive Network.

## Origin Chain Contract

The `ReactiveFaucetL1` contract is designed to handle payment requests and facilitate fund distribution the blockchain. It allows users to request payments and defines a maximum payout limit for each request. The contract emits a `PaymentRequest` event whenever a payment request is made, specifying the receiver and the amount. Ownership of the contract is restricted to a single address, set during deployment, and only the owner can perform specific actions such as withdrawing funds or setting the maximum payout limit.

The contract can accept Ether through its `receive` function, which processes incoming payment requests. Users can also directly call the `request` function to request a payout, subject to the maximum payout limit. The owner can withdraw funds from the contract using the `withdraw` function, provided there are sufficient funds available. Additionally, the owner can update the maximum payout limit by calling the `setMaxPayout` function.

The `_request` internal function handles the logic for processing payment requests. It ensures that the requested amount does not exceed the maximum payout and that the amount is greater than zero before emitting the `PaymentRequest` event.

## Reactive Contract

The `ReactiveFaucetListener` contract facilitates interaction between the Reactive Network and the Sepolia chain by subscribing to specific events and handling callbacks. It monitors `PaymentRequest` events on the Sepolia chain and triggers corresponding actions on the Reactive Network.

The contract is initialized with the addresses of the service, the Layer 1 contract, and the faucet contract. Upon deployment, it subscribes to `PaymentRequest` events on the Sepolia chain. The contract includes functionality to pause and resume its operations, which involves unsubscribing and resubscribing to the monitored events.

The `react` function processes events, specifically handling `PaymentRequest` topics by preparing a callback payload to dispense funds via the faucet contract. The contract ensures that only the owner can pause or resume its operations, and it enforces separate execution paths for the Reactive Network and ReactVM instances.

## Destination Chain Contract

The `ReactiveFaucet` contract manages the distribution of funds on the Reactive Network based on external requests. The contract is initialized with the address of a callback sender and a maximum payout limit. It maintains strict control over fund distribution to ensure security and proper authorization.

The contract designates the deployer as the owner, who can update the reactive address, callback sender address, and the maximum payout limit. Fund distribution is handled through the `dispense` function, which verifies that the request comes from the authorized callback sender and matches the reactive address. The function ensures the requested amount does not exceed the maximum payout and that sufficient funds are available.

The contract also includes a fallback function `receive` to receive funds. This ensures that the faucet can be replenished as needed. The overall structure emphasizes secure and controlled fund distribution within the Reactive Network environment.

## Further Considerations

The Reactive Faucet system can be further improved in several areas:

- Security Enhancements: Strengthen access control and implement security checks to safeguard funds and prevent unauthorized access.

- Gas Optimization: Refine contract functions to reduce gas costs.

- Error Handling: Develop error handling to manage exceptions and edge cases.

- External Integration: Integrate with other DeFi protocols and applications to expand functionality and utility.

## Deployment & Testing

This script guides you through deploying and testing the Reactive Faucet demo on the Sepolia Testnet. Ensure the following environment variables are configured appropriately before proceeding with this scrip:

* `SEPOLIA_RPC`
* `SEPOLIA_PRIVATE_KEY`
* `REACTIVE_RPC`
* `REACTIVE_PRIVATE_KEY`
* `DEPLOYER_ADDR`
* `SYSTEM_CONTRACT_ADDR`
* `CALLBACK_SENDER_ADDR`

`DEPLOYER_ADDR` is also your RVM ID. `CALLBACK_SENDER_ADDR` is a fixed EOA address, specific to each network, used by the reactive network to generate transaction callbacks. You can use the recommended Sepolia RPC URL: `https://rpc2.sepolia.org`.

### Step 1

Deploy the `ReactiveFaucetL1` contract to Sepolia and assign the `Deployed to` address from the response to `REACTIVE_FAUCET_L1_ADDR`.

```bash
forge create --rpc-url $SEPOLIA_RPC --private-key $SEPOLIA_PRIVATE_KEY src/faucet/ReactiveFaucetL1.sol:ReactiveFaucetL1 --constructor-args 1ether
```

### Step 2

Deploy the `ReactiveFaucet` contract to the Reactive Network and assign the `Deployed to` address from the response to `REACTIVE_FAUCET_ADDR`.

```bash
forge create --rpc-url $REACTIVE_RPC --private-key $REACTIVE_PRIVATE_KEY src/faucet/ReactiveFaucet.sol:ReactiveFaucet --constructor-args $CALLBACK_SENDER_ADDR 1ether
```

### Step 3

Deploy the `ReactiveFaucetListener` contract to the Reactive Network and assign the `Deployed to` contract address from the response to `REACTIVE_FAUCET_LISTENER_ADDR`.

```bash
forge create --rpc-url $REACTIVE_RPC --private-key $REACTIVE_PRIVATE_KEY src/faucet/ReactiveFaucetListener.sol:ReactiveFaucetListener --constructor-args $SYSTEM_CONTRACT_ADDR $REACTIVE_FAUCET_L1_ADDR $REACTIVE_FAUCET_ADDR
```

### Step 4

Complete the faucet configuration:

```bash
cast send $REACTIVE_FAUCET_ADDR "setReactive(address)" --rpc-url $REACTIVE_RPC --private-key $REACTIVE_PRIVATE_KEY $DEPLOYER_ADDR
```

Provide some liquidity:

```bash
cast send $REACTIVE_FAUCET_ADDR --rpc-url $REACTIVE_RPC --private-key $REACTIVE_PRIVATE_KEY --value 5ether
```

Test the faucet:

```bash
cast send $REACTIVE_FAUCET_L1_ADDR --rpc-url $SEPOLIA_RPC --private-key $SEPOLIA_PRIVATE_KEY --value 0.1ether
```