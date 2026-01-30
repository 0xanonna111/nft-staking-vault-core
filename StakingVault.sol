// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract StakingVault is ReentrancyGuard, Ownable {
    IERC721 public immutable nftCollection;
    IERC20 public immutable rewardToken;

    uint256 public rewardRatePerHour = 10 * 10**18; // 10 tokens per hour

    struct Stake {
        address owner;
        uint256 timestamp;
    }

    // Mapping from tokenId to Stake details
    mapping(uint256 => Stake) public vault;

    constructor(address _nftCollection, address _rewardToken) Ownable(msg.sender) {
        nftCollection = IERC721(_nftCollection);
        rewardToken = IERC20(_rewardToken);
    }

    function stake(uint256[] calldata tokenIds) external nonReentrant {
        for (uint256 i = 0; i < tokenIds.length; i++) {
            uint256 tokenId = tokenIds[i];
            require(nftCollection.ownerOf(tokenId) == msg.sender, "Not owner");

            nftCollection.transferFrom(msg.sender, address(this), tokenId);

            vault[tokenId] = Stake({
                owner: msg.sender,
                timestamp: block.timestamp
            });
        }
    }

    function unstake(uint256[] calldata tokenIds) external nonReentrant {
        uint256 totalReward = 0;

        for (uint256 i = 0; i < tokenIds.length; i++) {
            uint256 tokenId = tokenIds[i];
            Stake memory deposited = vault[tokenId];
            require(deposited.owner == msg.sender, "Not the staker");

            uint256 stakedDuration = block.timestamp - deposited.timestamp;
            totalReward += (stakedDuration * rewardRatePerHour) / 3600;

            delete vault[tokenId];
            nftCollection.transferFrom(address(this), msg.sender, tokenId);
        }

        if (totalReward > 0) {
            rewardToken.transfer(msg.sender, totalReward);
        }
    }

    function setRewardRate(uint256 _rate) external onlyOwner {
        rewardRatePerHour = _rate;
    }
}
