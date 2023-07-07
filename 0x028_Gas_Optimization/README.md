# GasOptimizaitonResearch

Gas optimization is extremely important to minimize the cost of deployment and gas fees for the end user. 
This project demonstrates a series of testings to compare the gas fee among differet coding pattern.

The hardhat gas reporter plugin is used for gas estimation.

```shell
npm i hardhat-gas-reporter --save-dev\
```

The configuration of hardhat-gas-reporter is listed as follows:

```javascript
require("@nomicfoundation/hardhat-toolbox");
require("hardhat-gas-reporter");

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.18",
  gasReporter: {
    enabled: true,
    outputFile: "GasReporter.txt",
    noColors: true,
    token: "ETH"
  },
};
```
# Estimate the gas fee in USD

Here is way to transfer gas fee to USD currency in realtime, we get the currency information from coinmarketcap.

Add dotenv to your environment.

```shell
npm i dotenv --save-dev
```
Add dotenv and hardhat-gas-reporter to `hardhat.config.js`

```javascript
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
    coinmarketcap: COINMACKETCAP_API_KEY,
    token: "ETH"
  },
};
```

Create a `.env` file in root folder, add following string.

```shell
COINMACKETCAP_API_KEY = {Your CoinMacketCap API KEY}
```

# Constant, Immutable, Variable comparison

In solidity, the MethodID order of the functions will effect the gas fee. 
The later the sort will consume more. Each position will have an extra 22 gas.

Here is the MethodID order of the functions in this example:

```
addVarC(): 0x75abe8c5
addVarI(): 0x81685e40
AddVarV(): 0xdb49f15c
```

Therefore, the result of gas fee are list following:

| Method  | Gas Fee | Net Gas Fee | Save(Compare to varibale) |
| ------- | ------- | ----------- | ------------------------- |
| addVarC | 23400   | 23400       | 66                        |
| addVarI | 43422   | 23400       | 66                        |
| AddVarV | 23510   | 23466       | 0                         |

Due to the limitation of hardhat, I can't achieve the cost of single read.

Here are the pure reading result in remix ide:

| Keywork   | Net Gas Fee | Save(Compare to varibale) |
| --------- | ----------- | ------------------------- |
| constant  | 161         | 2100 (≈93%)               |
| immutable | 161         | 2100 (≈93%)               |
| variable  | 2261        | 0                         |

### Conclusion
- In practical, The variable definitions should be avoided as much as possible;
- For constants that do not need to be modified, it is recommended to use const to define them, which is the best in terms of functionality and gas.