const HDWalletProvider = require("truffle-hdwallet-provider");

const MNEMONIC = process.env.MNEMONIC;
const INFURA_KEY = process.env.INFURA_KEY;

const needsInfura = process.env.npm_config_argv &&
      (process.env.npm_config_argv.includes('rinkeby') ||
       process.env.npm_config_argv.includes('live'));

if ((!MNEMONIC || !INFURA_KEY) && needsInfura) {
  console.error('Please set a mnemonic and infura key.');
  process.exit(0);
}

module.exports = {
  networks: {
    development: {
      host: "localhost",
      port: 7545,
      gas: 4600000,
      network_id: "*" // Match any network id
    },
    rinkeby: {
      provider: function() {
        return new HDWalletProvider(
          MNEMONIC,
          "https://rinkeby.infura.io/v3/" + INFURA_KEY
        );
      },
      network_id: "*",
      networkCheckTimeout: 10000000
    },
    live: {
      network_id: 1,
      provider: function() {
        return new HDWalletProvider(
          MNEMONIC,
          "https://mainnet.infura.io/v3/" + INFURA_KEY
        );
      },
      gas: 4000000,
      gasPrice: 5000000000
    }
  },
  mocha: {
    reporter: 'eth-gas-reporter',
    reporterOptions : {
      currency: 'USD',
      gasPrice: 2
    }
  },
  compilers: {
    solc: {
      version: "^0.5.0"
    }
  }
};
