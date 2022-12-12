const hre = require("hardhat");

async function main() {
  const NFTraitsFactory = await hre.ethers.getContractFactory("NFTraits");
  const NFTraits = await NFTraitsFactory.deploy();

  await NFTraits.deployed();

  console.log(`deployed to ${NFTraits.address}`);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
