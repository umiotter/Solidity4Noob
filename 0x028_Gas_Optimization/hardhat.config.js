require("@nomicfoundation/hardhat-toolbox");
require('dotenv').config()
require("hardhat-gas-reporter");

const COINMACKETCAP_API_KEY = process.env.COINMACKETCAP_API_KEY

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.18",
  gasReporter: {
    enabled: true,
    outputFile: "GasReporter.txt",
    noColors: true,
    currency: "USD", 
    // coinmarketcap: COINMACKETCAP_API_KEY,
    token: "ETH"
  },
};
