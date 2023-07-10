# Gas Optimizaiton Research

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

# Calldata, Memory comparison

Gas fee comparision of calldata and memory.

| Method          | Gas Fee | Net Gas Fee | Save(Compare to writeByCalldata) |
| --------------- | ------- | ----------- | -------------------------------- |
| writeByCalldata | 91372   | 91372       | 0                                |
| writeByMemory   | 92164   | 92142       | 770 (≈0.8%)                      |

### Conclusion
- It is recommended to use calldata for variable writing in preference.


# Unchecked and checked comparison

Before Solidity 0.8.0, the SafeMath library needed to be imported manually to prevent the data overflow attack.

In following Solidity version, solidity will perform a check every time data changes to determine if there is an overflow and thus decide whether to throw an exception.

This mechanism also brings additional gas consumption. 

Therefore, solidity provides unchecked block modifier to effectively remove the intermediate overflow detection, achieving the purpose of gas saving.

In this unit testing, I run unchecked block and without unchecked block 1000 times to evaluate the gas consumption.

Here is the result:

| Method           | Gas Fee | Net Gas Fee | Save(Compare to writeByCalldata) |
| ---------------- | ------- | ----------- | -------------------------------- |
| withoutUnckecked | 415751  | 415751      | 0                                |
| withUnckecked    | 113773  | 113751      | 302000 (≈73%)                    |

### Conclusion

If the security is under control, it is recommended to utilize unchecked for gas optimization.


# Swap function comparison

There are three methods that can be used to exchange the values of two variables.

We list the code as follow:

```solidity
// normal swap
function Swap(uint x, uint y) public returns(uint, uint){
  uint z = y;
  y = x;
  x = z;
  return (x, y);
}

// swap 2 variables with destructuring assignment
function DesSwap(uint x, uint y) public returns(uint, uint){
    (x, y) = (y, x);
    return (x, y);
}

// swap 2 variables with bit operation
function BitOperationSwap(uint x, uint y) public returns(uint, uint){
  x = x | y;
  y = x | y;
  x = x | y;
  return (x, y);
}
```

Here is the gas consumption:

| Method           | Net Gas Fee | Save(Compare to BitOperationSwap) |
| ---------------- | ----------- | --------------------------------- |
| Swap             | 36375       | 234                               |
| DesSwap          | 36371       | 238                               |
| BitOperationSwap | 36609       | 0                                 |

# Conclusion

Swap 2 variables with destructuring assignment will not help you to save gas, but it makes your code look better.