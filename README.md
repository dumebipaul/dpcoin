# dpcoin

DP Coin (`dpcoin`) is a simple fungible token implemented as a Clarity smart contract and managed with [Clarinet](https://github.com/hirosystems/clarinet).

This project is intended as a starting point for experimenting with Clarity, fungible token mechanics, and local development using Clarinet.

## Project structure

- `Clarinet.toml` – Clarinet project configuration, contract registration, and analysis settings
- `contracts/dpcoin.clar` – DP Coin smart contract implementation
- `settings/` – Network configuration templates:
  - `settings/Mainnet.toml`
  - `settings/Testnet.toml`
  - `settings/Devnet.toml`
- `LICENSE` – Project license (MIT)

## Prerequisites

- [Clarinet](https://docs.hiro.so/clarinet) **v3.10.0+** installed and available on your `PATH` (already verified in this environment)
- A recent version of `bash`/`zsh` or another shell
- Optionally, Node.js (for tests and tooling if you expand this project)

To verify Clarinet is installed:

```bash path=null start=null
clarinet --version
```

## Getting started

From the project root:

```bash path=null start=null
cd dpcoin
clarinet check
```

This will:

- Load `Clarinet.toml`
- Discover `contracts/dpcoin.clar`
- Run syntax and basic semantic checks on the Clarity code

## Contract overview

The `dpcoin` contract is a simple fungible token with the following characteristics:

- **Symbol:** `DPC`
- **Decimals:** `6` (i.e. `1 DPC = 1_000_000 base units`)
- **Owner:** the account that deploys the contract
- **Total supply:** tracked in a data variable and updated on mint/burn

### State

- `owner` – `principal` that is allowed to mint tokens and transfer ownership
- `total-supply` – total number of tokens currently in circulation
- `balances` – map from `principal` → `uint` balance

### Read-only functions

- `get-owner` → `response principal uint` – returns the current owner
- `get-total-supply` → `response uint uint` – returns the total supply
- `get-balance (who principal)` → `response uint uint` – returns the balance of `who` (defaults to `u0` if absent)

### Public functions

- `mint (recipient principal) (amount uint)`
  - Only callable by `owner`
  - Mints `amount` tokens to `recipient`
  - Increases `total-supply`
- `burn (amount uint)`
  - Callable by any account
  - Burns `amount` tokens from `tx-sender`
  - Decreases `total-supply`
- `transfer (recipient principal) (amount uint)`
  - Transfers `amount` tokens from `tx-sender` to `recipient`
- `set-owner (new-owner principal)`
  - Only callable by current `owner`
  - Transfers contract ownership to `new-owner`

### Error codes

- `ERR-NOT-AUTHORIZED` – `u100` – caller is not allowed to perform the action
- `ERR-INSUFFICIENT-BALANCE` – `u101` – caller does not have enough balance
- `ERR-INVALID-AMOUNT` – `u102` – amount is zero (`u0`)

## Typical workflows

### 1. Check the contract

From the project root:

```bash path=null start=null
clarinet check
```

### 2. Open a REPL (console)

To experiment with the contract interactively:

```bash path=null start=null
clarinet console
```

In the console, you can call read-only functions, for example:

```clar path=null start=null
(contract-call? .dpcoin get-total-supply)
(contract-call? .dpcoin get-balance 'ST3NBRSFKX28FQ2ZJ1MAKX58HKHSDGNV5N7R21XCP)
```

### 3. Minting and transferring in the console

Example (assuming the deployer is the owner):

```clar path=null start=null
;; Mint 1_000 DPC (taking into account 6 decimals)
(contract-call? .dpcoin mint 'ST3NBRSFKX28FQ2ZJ1MAKX58HKHSDGNV5N7R21XCP u1000000000)

;; Transfer some tokens to another account
(contract-call? .dpcoin transfer 'ST2CY5V39NHDPWSXMW9QDT3HC3GD6Q6XX4CFRK9AG u500000000)
```

## Notes

- The mnemonic values in `settings/Devnet.toml` are **test/devnet-only** values from the Clarinet template and should never be used for real funds.
- If you plan to deploy to Testnet or Mainnet, update `settings/Testnet.toml` and `settings/Mainnet.toml` with your own secure mnemonics.

## License

This project is licensed under the MIT License. See `LICENSE` for details.
