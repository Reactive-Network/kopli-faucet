# Reactive Faucet App

## Overview

The Reactive Faucet App links the Reactive Network with any EVM-compatible chain. Users can request funds from a faucet contract on another chain, with the Reactive Network processing the request via a corresponding contract.

## Contracts

- **Origin Chain Contract:** [ReactiveFaucetL1](https://github.com/Reactive-Network/kopli-faucet/blob/main/src/faucet/ReactiveFaucetL1.sol) handles Ether payment requests, defines a maximum payout per request, and emits `PaymentRequest` events containing details of the transaction.

- **Reactive Contract:** [ReactiveFaucet](https://github.com/Reactive-Network/kopli-faucet/blob/main/src/faucet/ReactiveFaucet.sol) operates on the Reactive Network. It subscribes to events on the Sepolia chain, processes callbacks, and distributes Ether to the appropriate receivers based on external `PaymentRequest` events.

## Deployment & Testing

To deploy the contracts to Ethereum Sepolia and Kopli Testnet, follow these steps. Replace the relevant keys, addresses, and endpoints as needed. Make sure the following environment variables are correctly configured before proceeding:

* `SEPOLIA_RPC` — RPC URL for Ethereum Sepolia, (see [Chainlist](https://chainlist.org/chain/11155111))
* `SEPOLIA_PRIVATE_KEY` — Ethereum Sepolia private key
* `REACTIVE_RPC` — RPC URL for Reactive Kopli (see [Reactive Docs](https://dev.reactive.network/kopli-testnet#reactive-kopli-information))
* `REACTIVE_PRIVATE_KEY` — Reactive Kopli private key

### Step 1

```bash
export REACTIVE_FAUCET_L1_ADDR=0x9b9BB25f1A81078C544C829c5EB7822d747Cf434
```

Find more information on Reactive faucet address [here](https://dev.reactive.network/kopli-testnet#kopli-testnet-information).

Deploy the `ReactiveFaucetL1` contract to Ethereum Sepolia and assign the `Deployed to` address from the response to `REACTIVE_FAUCET_L1_ADDR`. You can skip this step and export the pre-deployed `REACTIVE_FAUCET_L1_ADDR` for Ethereum Sepolia shown above.

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

To pause the reactive contract:

```bash
cast send $REACTIVE_FAUCET_ADDR "pause()" --rpc-url $REACTIVE_RPC --private-key $REACTIVE_PRIVATE_KEY
```

To resume the reactive contract:

```bash
cast send $REACTIVE_FAUCET_ADDR "resume()" --rpc-url $REACTIVE_RPC --private-key $REACTIVE_PRIVATE_KEY
```

Provide additional funds to the reactive contract if needed:

```bash
cast send $REACTIVE_FAUCET_ADDR --rpc-url $REACTIVE_RPC --private-key $REACTIVE_PRIVATE_KEY --value 0.1ether
```