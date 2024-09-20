// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {PoolKey} from "pancake-v4-core/src/types/PoolKey.sol";
import {BalanceDelta, toBalanceDelta} from "pancake-v4-core/src/types/BalanceDelta.sol";
import {ICLPoolManager} from "pancake-v4-core/src/pool-cl/interfaces/ICLPoolManager.sol";
import {CLBaseHook} from "./CLBaseHook.sol";
import "openzeppelin-contracts/contracts/token/ERC721/IERC721.sol"; // Importing ERC721 for OG NFT check
import "openzeppelin-contracts/contracts/access/Ownable.sol";

contract ExclusiveAccessPool is CLBaseHook, Ownable {
    using SafeMath for uint256;

    struct UserInfo {
        uint256 transactionCount;
        bool hasAccess;
    }

    mapping(address => UserInfo) public users;
    IERC721 public ogNftContract; // Address of the OG NFT contract
    uint256 public minTransactionCount; // Minimum transaction milestone required for pool access

    event AccessGranted(address indexed user);
    event LiquidityAdded(address indexed provider, uint256 amount0, uint256 amount1, uint256 timestamp);

    constructor(ICLPoolManager _poolManager, address _ogNftContract, uint256 _minTransactionCount)
        CLBaseHook(_poolManager)
    {
        ogNftContract = IERC721(_ogNftContract); // Set the OG NFT contract address
        minTransactionCount = _minTransactionCount; // Set the minimum transaction milestone
    }

    function getHooksRegistrationBitmap() external pure override returns (uint16) {
        return _hooksRegistrationBitmapFrom(
            Permissions({
                beforeInitialize: false,
                afterInitialize: false,
                beforeAddLiquidity: true,
                afterAddLiquidity: true,
                beforeRemoveLiquidity: false,
                afterRemoveLiquidity: true,
                beforeSwap: false,
                afterSwap: false,
                beforeDonate: false,
                afterDonate: false,
                beforeSwapReturnsDelta: false,
                afterSwapReturnsDelta: false,
                afterAddLiquidityReturnsDelta: false,
                afterRemoveLiquidityReturnsDelta: true
            })
        );
    }

    // Check if the user meets criteria for exclusive access
    function hasExclusiveAccess(address user) public view returns (bool) {
        // Check if user holds the OG NFT
        bool holdsOGNft = ogNftContract.balanceOf(user) > 0;

        // Check if user meets the transaction milestone
        bool meetsTransactionRequirement = users[user].transactionCount >= minTransactionCount;

        return holdsOGNft || meetsTransactionRequirement;
    }

    // Grant access to users who meet the criteria
    function grantAccess(address user) external onlyOwner {
        require(hasExclusiveAccess(user), "User does not meet the access criteria");
        users[user].hasAccess = true;
        emit AccessGranted(user);
    }

    // Add liquidity, only for users with exclusive access
    function afterAddLiquidity(
        address sender,
        PoolKey calldata key,
        ICLPoolManager.ModifyLiquidityParams calldata params,
        BalanceDelta delta,
        bytes calldata hookData
    ) external override poolManagerOnly returns (bytes4, BalanceDelta) {
        require(users[sender].hasAccess, "Access denied: Exclusive pool");

        // Increment transaction count each time liquidity is added
        users[sender].transactionCount = users[sender].transactionCount.add(1);

        emit LiquidityAdded(sender, delta.amount0(), delta.amount1(), block.timestamp);

        return (this.afterAddLiquidity.selector, delta);
    }

    // Function to remove liquidity with the same access restrictions
    function afterRemoveLiquidity(
        address sender,
        PoolKey calldata key,
        ICLPoolManager.ModifyLiquidityParams calldata params,
        BalanceDelta delta,
        bytes calldata hookData
    ) external override poolManagerOnly returns (bytes4, BalanceDelta) {
        require(users[sender].hasAccess, "Access denied: Exclusive pool");
        return (this.afterRemoveLiquidity.selector, delta);
    }

    // Allow the owner to change the OG NFT contract address if necessary
    function setOGNftContract(address _ogNftContract) external onlyOwner {
        ogNftContract = IERC721(_ogNftContract);
    }

    // Allow the owner to update the transaction milestone
    function setMinTransactionCount(uint256 _minTransactionCount) external onlyOwner {
        minTransactionCount = _minTransactionCount;
    }
}
