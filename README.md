**Exclusive-Access Pools Hook**

which restricts access to users who meet specific criteria, such as holding an OG NFT or reaching a transaction milestone.

The contract utilizes:
- **OG NFT holding**: Only users who own a specific NFT can access the pool.
- **Transaction milestone**: Users must have completed a minimum number of transactions to access the pool.

### Key Features:
1. **OG NFT-Based Access**: Users must hold a specific OG NFT to access the exclusive liquidity pool.
2. **Transaction Milestone**: Users can also gain access by meeting a transaction milestone, defined by the contract owner.
3. **Liquidity Management**: Only users who meet the access criteria can add or remove liquidity from the pool.
4. **Admin Controls**: The contract owner can update the OG NFT contract address and the transaction milestone criteria.
5. **Security**: Access checks are enforced whenever liquidity is added or removed to ensure only eligible users can interact with the pool.

### Usage

#### Granting Access:
1. **OG NFT Holders**: Any user holding the OG NFT automatically meets the criteria for access.
2. **Transaction Milestone**: Users who reach the required number of transactions will also gain access.
   
#### Adding Liquidity:
- LPs who meet the access criteria can add liquidity by interacting with the pool's `afterAddLiquidity` function, which checks access and updates their transaction count.

#### Removing Liquidity:
- LPs can remove liquidity from the pool only if they have been granted access. The same access control applies to this action as well.

---

### How This Works:

1. **Access Control**: The `hasExclusiveAccess` function checks if a user holds the OG NFT or has met the transaction milestone. If either condition is met, the user is eligible to participate in the pool.
2. **Liquidity Management**: The `afterAddLiquidity` and `afterRemoveLiquidity` functions are only callable by users who have been granted access, providing a controlled environment for exclusive participants.
3. **Admin Flexibility**: The pool owner can change the OG NFT contract address and the minimum transaction count, giving flexibility to manage pool requirements over time.

This smart contract setup can be extended to incorporate other forms of access control criteria, such as governance tokens, staking milestones, or off-chain verifications if required. Let me know if you need any more enhancements!

## Prerequisite

1. Install foundry, see https://book.getfoundry.sh/getting-started/installation

## Running test

1. Install dependencies with `forge install`
2. Run test with `forge test`

## Description

This repository contains example counter hook for both CL and Bin pool types. 
