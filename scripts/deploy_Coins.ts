// Importing necessary functionalities from the Hardhat package.
import { ethers } from "hardhat";

async function main() {
  // Retrieve the first signer, typically the default account in Hardhat, to use as the deployer.
  const [deployer] = await ethers.getSigners();
  const instanceUSDC = await ethers.deployContract("USDCToken");
  await instanceUSDC.waitForDeployment();
  const USDC_address = await instanceUSDC.getAddress();
  console.log(`USDC is deployed. ${USDC_address}`);

  const instanceUSDT = await ethers.deployContract("USDTToken");
  await instanceUSDT.waitForDeployment();
  const USDT_address = await instanceUSDT.getAddress();
  console.log(`USDT is deployed. ${USDT_address}`);

  const instanceBUSD = await ethers.deployContract("BUSDToken");
  await instanceBUSD.waitForDeployment();
  const BUSD_address = await instanceBUSD.getAddress();
  console.log(`BUSD is deployed. ${BUSD_address}`);

  const instanceDAI = await ethers.deployContract("DAIToken");
  await instanceDAI.waitForDeployment();
  const DAI_address = await instanceDAI.getAddress();
  console.log(`DAI is deployed. ${DAI_address}`);
}

// This pattern allows the use of async/await throughout and ensures that errors are caught and handled properly.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
