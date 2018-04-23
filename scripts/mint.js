const HDWalletProvider = require("truffle-hdwallet-provider")
const web3 = require('web3')
const MNEMONIC = process.env.MNEMONIC
const INFURA_KEY = process.env.INFURA_KEY
const CONTRACT_ADDRESS = process.env.CONTRACT_ADDRESS
const OWNER_ADDRESS = process.env.OWNER_ADDRESS
const NETWORK = process.env.NETWORK
const NUM_PUFFS = 12

if (!MNEMONIC || !INFURA_KEY) {
  console.error("Please set a mnemonic and infura key.")
  return
}

const ABI = [{ "constant": false, "inputs": [ {  "name": "_to", "type": "address" }, { "name": "_tokenURI", "type": "string" } ], "name": "mintTo", "outputs": [], "payable": false, "stateMutability": "nonpayable", "type": "function" }]

function callContract(contract, methodName, ...args) {
    return new Promise((resolve, reject) => {
      contract[methodName](...args, (err, result) => {
        if (!err) { 
          resolve(result);
        } 
        else reject(err);
      });
    });
}

async function main() {
    const web3Instance = new web3(
        new HDWalletProvider(MNEMONIC, `https://${NETWORK}.infura.io/${INFURA_KEY}`)
    )
    
    const itemContract = web3Instance.eth.contract(ABI).at(CONTRACT_ADDRESS)
    for (var i = 0; i < NUM_PUFFS; i++) {
        const puffId = i + 1
        const result = await callContract(itemContract, "mintTo", OWNER_ADDRESS, `https://cryptopuffs-api.herokuapp.com/api/puff/${puffId}`,
            { from: OWNER_ADDRESS })
        console.log(`https://${NETWORK}.etherscan.io/tx/${result}`)
    }
}

main()