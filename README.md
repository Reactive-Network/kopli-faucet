# Reactive Faucet Deployment Instructions

You will need the following environment variables configured appropriately to follow this script:

* `SEPOLIA_RPC`
* `SEPOLIA_PRIVATE_KEY`
* `REACTIVE_RPC`
* `REACTIVE_PRIVATE_KEY`
* `DEPLOYER_ADDR`
* `SYSTEM_CONTRACT_ADDR`
* `CALLBACK_SENDER_ADDR`

First deploy the L1 contract to Sepolia:

```
forge create --rpc-url $SEPOLIA_RPC --private-key $SEPOLIA_PRIVATE_KEY src/faucet/ReactiveFaucetL1.sol:ReactiveFaucetL1 --constructor-args 1ether
```

Assign the deployed contract address to the `REACTIVE_FAUCET_L1_ADDR` environment variable.

Now deploy the faucet itself to Reactive Network:

```
forge create --rpc-url $REACTIVE_RPC --private-key $REACTIVE_PRIVATE_KEY src/faucet/ReactiveFaucet.sol:ReactiveFaucet --constructor-args $CALLBACK_SENDER_ADDR 1ether
```

Assign the contract address to `REACTIVE_FAUCET_ADDR`.

Lastly deploy the listener contract:

```
forge create --rpc-url $REACTIVE_RPC --private-key $REACTIVE_PRIVATE_KEY src/faucet/ReactiveFaucetListener.sol:ReactiveFaucetListener --constructor-args $SYSTEM_CONTRACT_ADDR $REACTIVE_FAUCET_L1_ADDR $REACTIVE_FAUCET_ADDR
```

Assign the contract address to `REACTIVE_FAUCET_LISTENER_ADDR`.

Finish the faucet configuration:

```
cast send $REACTIVE_FAUCET_ADDR "setReactive(address)" --rpc-url $REACTIVE_RPC --private-key $REACTIVE_PRIVATE_KEY $DEPLOYER_ADDR
```

Provide some liquidity:

```
cast send $REACTIVE_FAUCET_ADDR --rpc-url $REACTIVE_RPC --private-key $REACTIVE_PRIVATE_KEY --value 5ether
```

And test:

```
cast send $REACTIVE_FAUCET_L1_ADDR --rpc-url $SEPOLIA_RPC --private-key $SEPOLIA_PRIVATE_KEY --value 0.1ether
```
