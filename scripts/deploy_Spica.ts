
// Importing necessary functionalities from the Hardhat package.
import { ethers } from 'hardhat'

async function main() {
    // Retrieve the first signer, typically the default account in Hardhat, to use as the deployer.
    const [deployer] = await ethers.getSigners();
    const instanceSpica = await ethers.deployContract("SpicaToken");
    await instanceSpica.waitForDeployment()
    const Spica_Address = await instanceSpica.getAddress();
    console.log(`Spica is deployed. ${Spica_Address}`);
}

// This pattern allows the use of async/await throughout and ensures that errors are caught and handled properly.
main().catch(error => {
    console.error(error)
    process.exitCode = 1
})