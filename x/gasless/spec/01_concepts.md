<!--
order: 1
-->

# Concepts

## Gasless

The Gasless module provides functionality for Developers (Native Go and Smart Contract) to cover the execution fees of transactions interacting with their contracts or Messages. This aims to improve the user experience and help onboard wallets with little to no available funds. 
Developers can setup their MessageTypes and Contracts with Gasless by first creating a GasTank and whitelisting MessageTypes and ContractAddresses with preferred configurations and then funding it with chain's native fee token. 
Clients can then interact with the Messages and Contract normally as usuall and the fee for the tx will be decucted from the gastank


### Creating a GasTank

There can be multiple gastanks, each of which can be with unique configuration.

```console
foo@bar:~$ aibd tx gasless create-gas-tank [fee-denom] [max-fee-usage-per-tx] [max-txs-count-per-consumer] [max-fee-usage-per-consumer] [txs-allowed] [contracts-allowed] [gas-deposit]
```

e.g
```console
foo@bar:~$ aibd tx gasless create-gas-tank aaib 2000000 100 200000000 "/cosmos.bank.v1beta1.MsgMultiSend,/cosmos.bank.v1beta1.MsgSend" "rol14hj2tavq8f....,rol14hj2t...." 100000000aaib --from cooluser --chain-id test-1
```

In the above tx - 
- `fee-denom` - all txs with this fee-denom can consume gas from this gas tank
- `max-fee-usage-per-tx` - maximum fee a tx can utilize, if the asked tx fee > max-fee-usage-per-tx, then the fee will be decuted for the tx maker.
- `max-txs-count-per-consumer` - no. of txs allowed for each address
- `max-fee-usage-per-consumer` - max fee usage for each address
- `txs-allowed` - list of message types, which are to be whitelisted for gasless tx
- `contracts-allowed` - list of contract addresses, which are to be whitelisted for gasless tx
- `gas-deposit` - initial deposit for the gastank

>Note : anyone can create the gastank and whitelist the contract address or message type of their own will

### Authorizing Actors

The creator or owner of the gastank can allow other trusted addresses to manage their gas tanks, these actors can block and unblock the specific address/consumers txs going through this tank.

```console
foo@bar:~$ aibd tx gasless update-authorized-actors [gas-tank-id] [actors] 
```

e.g
```console
foo@bar:~$ aibd tx gasless update-authorized-actors 1 "rol14hj2tavq8f....,rol14hj2t...." 100000000aaib --from cooluser --chain-id test-1
```

### Updating GasTank Status

A GasTank can be disabled and enabled by owner anytime

```console
foo@bar:~$ aibd tx gasless update-gas-tank-status [gas-tank-id]
```

e.g
```console
foo@bar:~$ aibd tx gasless update-gas-tank-status 1 --from cooluser --chain-id test-1
```

if the GasTank is active, running the above tx will make it as inactive and do vice-versa if it was inactive.


### Updating GasTank Configs

Configurations of the gas tank can be updated buy he owner of the GasTank

```console
foo@bar:~$ aibd tx gasless update-gas-tank-config [gas-tank-id] [max-fee-usage-per-tx] [max-txs-count-per-consumer] [max-fee-usage-per-consumer] [txs-allowed] [contracts-allowed]
```

e.g
```console
foo@bar:~$ aibd tx gasless update-gas-tank-config 1 10000000 20 200000000 "" "rol14hj2tavq8f........" --from cooluser --chain-id test-1
```

### Block Consumer

GasTank owner or Authorized Actor can block the specific address, so fee cannot be sponsored for any txs from these addresses.

```console
foo@bar:~$ aibd tx gasless block-consumer [gas-tank-id] [consumer]
```

e.g
```console
foo@bar:~$ aibd tx gasless block-consumer 1 rol14hj2tavq8f........ --from cooluser --chain-id test-1
```

### Unblock Consumer

GasTank owner or Authorized Actor can ubblock consmer

```console
foo@bar:~$ aibd tx gasless unblock-consumer [gas-tank-id] [consumer]
```

e.g
```console
foo@bar:~$ aibd tx gasless unblock-consumer 1 rol14hj2tavq8f........ --from cooluser --chain-id test-1
```


### Updating GasConsumer Limit

GasTank owner can increase or decrease the gas consumption limit of the specific user.

```console
foo@bar:~$ aibd tx gasless update-consumer-limit [gas-tank-id] [consumer] [total-txs-allowed] [total-fee-consumption-allowed]
```

e.g
```console
foo@bar:~$ aibd tx gasless update-consumer-limit 1 rol14hj2tavq8f........ 40 40000000 --from cooluser --chain-id test-1
```


### Funding a GasTank

If GasTank exhausts its funds, one can fill up the tank using reserve address through bank send command

```console
foo@bar:~$ aibd tx bank send cooluser [gas-tank-reserve-address] [funds-to-deposit] --from cooluser --chain-id test-1
```


### Client Interactions

Clients can interact with MessageTypes and Contracts registered with GasTank in gasless module.

No additional step is to be taken by the client and can make the tx as usuall, aftert that the gas fee is taken care of by the GasTank.

```console
foo@bar:~$ aibd tx wasm execute [contract_address] --from cooluser --chain-id test-1 --fees 25000aaib
```

- `--fees` 25000aaib from above example will be now deducted from the GasTank if contract_address is whitelisted.