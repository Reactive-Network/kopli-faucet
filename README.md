# Reactive Faucet App

## Overview

The Reactive Faucet App is a system that operates between L1 (or any other layer) and the Reactive Network. It allows users to request funds from a faucet contract deployed on L1, with these requests being handled by a corresponding contract on the Reactive Network.

## Contracts

The demo involves two contracts:

1. **Origin Chain Contract:** `ReactiveFaucetL1` handles Ether payment requests, defines a maximum payout per request, and emits `PaymentRequest` events containing details of the transaction.

2. **Reactive Contract:** `ReactiveFaucet` operates on the Reactive Network. It subscribes to events on the Sepolia chain, processes callbacks, and distributes Ether to the appropriate receivers based on external `PaymentRequest` events.

## Deployment & Testing

This script guides you through deploying and testing the Reactive Faucet demo on the Sepolia Testnet. Ensure the following environment variables are configured appropriately before proceeding with this scrip:

* `SEPOLIA_RPC`
* `SEPOLIA_PRIVATE_KEY`
* `REACTIVE_RPC`
* `REACTIVE_PRIVATE_KEY`

You can use the recommended Sepolia RPC URL: `https://rpc2.sepolia.org`.

### Step 1

Deploy the `ReactiveFaucetL1` contract to Sepolia and assign the `Deployed to` address from the response to `REACTIVE_FAUCET_L1_ADDR`. Alternatively, you can export the pre-deployed `REACTIVE_FAUCET_L1_ADDR` on Sepolia, which is `0x9b9BB25f1A81078C544C829c5EB7822d747Cf434`.

```bash
forge create --rpc-url $SEPOLIA_RPC --private-key $SEPOLIA_PRIVATE_KEY src/faucet/ReactiveFaucetL1.sol:ReactiveFaucetL1 --constructor-args 1ether
```

### Step 2

Deploy the `ReactiveFaucet` contract to the Reactive Network and assign the `Deployed to` address from the response to `REACTIVE_FAUCET_ADDR`.

```bash
forge create --rpc-url $REACTIVE_RPC --private-key $REACTIVE_PRIVATE_KEY src/faucet/ReactiveFaucet.sol:ReactiveFaucet --value 10ether --constructor-args $REACTIVE_FAUCET_L1_ADDR 1ether
```

### Step 3

Test the faucet:

```bash
cast send $REACTIVE_FAUCET_L1_ADDR --rpc-url $SEPOLIA_RPC --private-key $SEPOLIA_PRIVATE_KEY --value 0.01ether
```

### Optional Steps

To pause the reactive contract, run the command below:

```bash
cast send $REACTIVE_FAUCET_ADDR "pause()" --rpc-url $REACTIVE_RPC --private-key $REACTIVE_PRIVATE_KEY
```

To resume the reactive contract, run the following command: 

```bash
cast send $REACTIVE_FAUCET_ADDR "resume()" --rpc-url $REACTIVE_RPC --private-key $REACTIVE_PRIVATE_KEY
```

Provide additional funds to the reactive contract if needed:

```bash
cast send $REACTIVE_FAUCET_ADDR --rpc-url $REACTIVE_RPC --private-key $REACTIVE_PRIVATE_KEY --value 0.1ether
```