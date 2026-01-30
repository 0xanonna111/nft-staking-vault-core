const hre = require("hardhat");

async function main() {
  const NFT_ADDR = "0x..."; // Your NFT Contract
  const TOKEN_ADDR = "0x..."; // Your Reward Token Contract

  const Vault = await hre.ethers.getContractFactory("StakingVault");
  const vault = await Vault.deploy(NFT_ADDR, TOKEN_ADDR);

  await vault.waitForDeployment();
  console.log("Staking Vault deployed to:", await vault.getAddress());
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
