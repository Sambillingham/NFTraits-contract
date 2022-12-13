require("@nomiclabs/hardhat-waffle");
require("@nomiclabs/hardhat-etherscan");
require("hardhat-gas-reporter");
require('dotenv').config();

/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  solidity: {
    version: "0.8.17",
    settings: {
      optimizer: {
        enabled: true,
        runs: 2000,
        details: {
            yul: true,
            yulDetails: {
                stackAllocation: true,
                optimizerSteps: "dhfoDgvulfnTUtnIf"
            }
        }
    }
    },
  },
  networks: {
    goerli: {
      url: process.env.GOERLI_ALCHEMY_KEY, 
      accounts: [process.env.PRIVATE_KEY],
    },
    mumbai: {
      url: process.env.MUMBAI_ALCHEMY_KEY, 
      accounts: [process.env.PRIVATE_KEY],
    },
  },
  gasReporter: {
    currency: 'USD',
    coinmarketcap: process.env.COINCAP_API,
  },
  etherscan: {
    apiKey: process.env.ETHERSCAN_API,
    // apiKey: process.env.POLYSCAN_API,
  }
};
