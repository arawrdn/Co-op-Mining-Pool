# Co-op Minning Pool
Mini Co-op Mining Pool for proportional ERC-20 token rewards based on ETH contribution.

---

## 1. Introduction

This repository contains the smart contract for a **Mini Co-op Mining Pool** designed for the Ethereum Virtual Machine (EVM) environment.

The contract allows users to contribute **ETH** to a common pool. Rewards, in the form of a specified **ERC-20 token**, are then distributed proportionally based on each participant's ETH contribution percentage. The system uses a gas-efficient **"Pull" mechanism** for claiming rewards.

## 2. Deployment Details

| Parameter | Value |
| :--- | :--- |
| **Deployed Contract Address (CA)** | `0x565e5D468620dEb611A8260a3B9ccf71d63b2d6D` |
| **BaseScan Link** | https://basescan.org/address/0x565e5D468620dEb611A8260a3B9ccf71d63b2d6D |
| **Deployer/Owner Address** | `0x2A6b5204B83C7619c90c4EB6b5365AA0b7d912F7` |
| **Reward Token Address (Hardcoded)** | `0xf3CdFBe745595bf8B9055764936329b6C157FD7D` |
| **Solidity Version** | `0.8.30` |
| **Optimizer** | `Enabled (runs=200)` |

---

## 3. Contract Functions & User Guide

### 3.1. Participant Actions (Users)

| Function | Action | Description |
| :--- | :--- | :--- |
| **`receive()`/`fallback()`** | **Transfer ETH** (to CA) | **Contributes ETH** to the pool. All participants can transfer any amount greater than 0 ETH. |
| **`claimReward()`** | **Claim Tokens** (Tx) | **Pulls** the proportional share of available **Reward Tokens** to the user's wallet. User pays the gas fee. |
| **`withdrawDeposit()`** | **Withdraw ETH** (Tx) | Allows the participant to withdraw their initial ETH contribution. **Requirement:** Must claim all available rewards first. |
| **`getAvailableReward(address)`** | **View** | Checks the number of Reward Tokens the participant can claim. |

### 3.2. Owner/Admin Actions (Deployer)

| Function | Action | Description |
| :--- | :--- | :--- |
| **`recordDummyReward(uint256 _amount)`** | **Record Rewards** (Tx) | **Logs** the amount of Reward Tokens that have been manually transferred by the Owner to the contract CA. **Owner must transfer the tokens separately before calling this.** |
| **`getOwner()`** | **View** | Returns the address of the contract owner. |

---

## 4. Operational Flow (Owner)

The reward process requires two separate steps by the Owner to ensure tokens are available and the ledger is updated:

1.  **Transfer Tokens to Pool:** The Owner **manually sends** the total reward amount (e.g., 400 tokens) from their wallet to the **Pool Contract Address** (`0x565e...2d6D`).
2.  **Record Distribution:** The Owner calls the **`recordDummyReward(400)`** function on the pool contract.
    * **Crucially:** The Owner does not attach ETH or tokens to this transaction. This function only serves to validate that the tokens are physically in the contract and update the internal calculation ledger.

Once recorded, participants can calculate their proportional share of the 400 tokens and claim them via `claimReward()`.

---

## 5. Contract Code (Solidity)

The complete and verified Solidity code for the `Co-op Mining Pool` contract is available in the repository (e.g., `CoOpMiningPool.sol`).
