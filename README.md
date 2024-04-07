<!-- markdownlint-disable MD033 -->
<h1 align="center">Dymension Rollapp</h1>
<!-- markdownlint-enable MD033 -->

# Rollappd - A template RollApp chain

This repository hosts `rollappd`, a template implementation of a dymension rollapp.

`rollappd` is an example of a working RollApp using `dymension-RDK` and `dymint`.

It uses Cosmos-SDK's [simapp](https://github.com/cosmos/cosmos-sdk/tree/main/simapp) as a reference, but with the following changes:

- minimal app setup
- wired IBC for [ICS 20 Fungible Token Transfers](https://github.com/cosmos/ibc/tree/main/spec/app/ics-020-fungible-token-transfer)
- Uses `dymint` for block sequencing and replacing `tendermint`
- Uses modules from `dymension-RDK` to sync with `dymint` and provide RollApp custom logic

## Overview

**Note**: Requires [Go 1.21](https://go.dev/)

## Quick guide

Get started with [building RollApps](https://docs.dymension.xyz/develop/get-started/setup)

## Installing / Getting started

Build and install the ```rollappd``` binary:

```shell
make install
```

### Initial configuration

export the following variables:

```shell
export ROLLAPP_CHAIN_ID="rollappwasm_1234-1"
export KEY_NAME_ROLLAPP="rol-user"
export BASE_DENOM="awsm"
export DENOM=$(echo "$BASE_DENOM" | sed 's/^.//')
export MONIKER="$ROLLAPP_CHAIN_ID-sequencer"

export ROLLAPP_HOME_DIR="$HOME/.rollapp"
export ROLLAPP_SETTLEMENT_INIT_DIR_PATH="${ROLLAPP_HOME_DIR}/init"
```

if you want to change the max wasm size:

```shell
export MAX_WASM_SIZE=WASM_SIZE_IN_BYTES # 2560000
```

And initialize the rollapp:

```shell
sh scripts/init.sh
```

### Download cw20-ics20 smartcontract

Download cw20-ics20 smartcontract with a specific version:

```shell
sh scripts/download_release.sh v1.0.0
```

### Run rollapp

```shell
rollappd start
```

You should have a running local rollapp!

## Run a rollapp with local settlement node

### Run local dymension hub node

Follow the instructions on [Dymension Hub docs](https://docs.dymension.xyz/develop/get-started/run-base-layers) to run local dymension hub node

all scripts are adjusted to use local hub node that's hosted on the default port `localhost:36657`.

configuration with a remote hub node is also supported, the following variables must be set:

```shell
export HUB_RPC_ENDPOINT="http://localhost"
export HUB_RPC_PORT="36657" # default: 36657
export HUB_RPC_URL="http://3.71.160.88:36657"
export HUB_CHAIN_ID="dymension_100-1"
```

### Create sequencer keys

create sequencer key using `dymd`

```shell
dymd keys add sequencer --keyring-dir ~/.rollapp/sequencer_keys --keyring-backend test
SEQUENCER_ADDR=`dymd keys show sequencer --address --keyring-backend test --keyring-dir ~/.rollapp/sequencer_keys`
```

fund the sequencer account

```shell
# this will retrieve the min bond amount from the hub
# if you're using an new address for registering a sequencer,
# you have to account for gas fees so it should the final value should be increased
BOND_AMOUNT="$(dymd q sequencer params -o json --node ${HUB_RPC_URL} | jq -r '.params.min_bond.amount')$(dymd q sequencer params -o json --node ${HUB_RPC_URL} | jq -r '.params.min_bond.denom')"
echo $BOND_AMOUNT

dymd tx bank send local-user dym1978q3tcxwg0ldzgv7ynfr3mzytr9qfsuwjt7tl 100000000000000000000000adym --keyring-backend test --broadcast-mode block --fees 20000000000000adym -y
```

### Register rollapp on settlement

```shell
sh scripts/settlement/register_rollapp_to_hub.sh
```

### Register sequencer for rollapp on settlement

```shell
sh scripts/settlement/register_sequencer_to_hub.sh
```

### Configure the rollapp

Modify `dymint.toml` in the chain directory (`~/.rollapp/config`)
set:

```shell
sed -i 's/settlement_layer.*/settlement_layer = "dymension"/' ${ROLLAPP_HOME_DIR}/config/dymint.toml
sed -i '/node_address =/c\node_address = '\"$HUB_RPC_URL\" "${ROLLAPP_HOME_DIR}/config/dymint.toml"
sed -i '/rollapp_id =/c\rollapp_id = '\"$ROLLAPP_CHAIN_ID\" "${ROLLAPP_HOME_DIR}/config/dymint.toml"
```

### Run rollapp locally

```shell
rollappd start
```

## Setup IBC between rollapp and local dymension hub node

### Install dymension relayer

```shell
git clone https://github.com/dymensionxyz/go-relayer.git --branch v0.2.0-v2.3.1-relayer
cd go-relayer && make install
```

### Establish IBC channel

while the rollapp and the local dymension hub node running, run:

```shell
sh scripts/ibc/setup_ibc.sh
```

After successful run, the new established channels will be shown

### run the relayer

```shell
rly start hub-rollapp
```

### Deploy the installed contract

```shell
sh scripts/wasm/deploy_contract.sh
```

### Make the ibc transfer

```shell
sh scripts/wasm/ibc_transfer.sh
```

## Developers guide

TODO
