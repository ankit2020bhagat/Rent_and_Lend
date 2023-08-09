require("@nomicfoundation/hardhat-toolbox");
require("dotenv").config();
// require("hardhat-deploy");
require("hardhat-deploy-ethers");
/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.19",
  settings: {
    optimizer: {
      enable: true,
      runs: 200,
    },
  },
  networks: {
    hardhat: {
      chainId: 31337,
    },
    mainnet: {
      url: process.env.MAINNET_URL,
      accounts: [process.env.PRIVATE_KEY],
    },
    mumbai: {
      url: process.env.MUMBAI_URL,
      accounts: [process.env.PRIVATE_KEY],
    },
    sepolia: {
      url: process.env.SEPOLIA_URL,
      accounts: [process.env.PRIVATE_KEY],
    },
  },
  gasReporter: {
    enabled: true,
    currency: "USD",
    noColors: true,
    token: "ETH",
    gasPriceApi: "api.etherscan.io/api?module=proxy&action=eth_gasPrice",
    outputFile: "gas-report.txt",
    coinmarketcap: process.env.COINMARKETCAP,
  },
  mocha: {
    timeout: 50000,
  },
  etherscan: {
    apiKey: process.env.POLYGON_API_KEY,
  },
};
