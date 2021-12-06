/**
 * @type import('hardhat/config').HardhatUserConfig
 */
require('@nomiclabs/hardhat-ethers')
require('hardhat-artifactor')
require("@nomiclabs/hardhat-etherscan")

module.exports = {
  solidity: "0.8.10",
  settings: {
    optimizer: {
      enabled: true,
      runs: 200
    }

  },
  networks: {
    hardhat: {
      accounts: {
        mnemonic: "candy maple cake sugar pudding cream honey rich smooth crumble sweet treat"
      },
      loggingEnabled: false,
      allowUnlimitedContractSize: false
    },
    goerli: {
      url: "https://goerli.infura.io/v3/9aa3d95b3bc440fa88ea12eaa4456161",
      accounts: {
        mnemonic: "candy maple cake sugar pudding cream honey rich smooth crumble sweet treat"
      },
    }
  },
  etherscan: {
    apiKey: "ISWN73946TYJT6P79Z64X826RWVES7PFS3"
  }
};
