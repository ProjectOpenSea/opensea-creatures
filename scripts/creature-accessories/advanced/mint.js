const HDWalletProvider = require("truffle-hdwallet-provider")
const web3 = require('web3')
const MNEMONIC = process.env.MNEMONIC
const INFURA_KEY = process.env.INFURA_KEY
const FACTORY_CONTRACT_ADDRESS = process.env.FACTORY_CONTRACT_ADDRESS
const OWNER_ADDRESS = process.env.OWNER_ADDRESS
const NETWORK = process.env.NETWORK

if (!MNEMONIC || !INFURA_KEY || !OWNER_ADDRESS || !NETWORK) {
    console.error("Please set a mnemonic, infura key, owner, network, and contract address.")
    return
}

const FACTORY_ABI = [{
    "constant": false,
    "inputs": [
        {
            "internalType": "uint256",
            "name": "_optionId",
            "type": "uint256"
        },
        {
            "internalType": "address",
            "name": "_toAddress",
            "type": "address"
        },
        {
            "internalType": "uint256",
            "name": "_amount",
            "type": "uint256"
        }
    ],
    "name": "open",
    "outputs": [],
    "payable": false,
    "stateMutability": "nonpayable",
    "type": "function"
}]

/**
 * For now, this script just opens a lootbox.
 */
async function main() {
    const provider = new HDWalletProvider(MNEMONIC, `https://${NETWORK}.infura.io/v3/${INFURA_KEY}`)
    const web3Instance = new web3(
        provider
    )

    if (!FACTORY_CONTRACT_ADDRESS) {
        console.error("Please set an NFT contract address.")
        return
    }

    const factoryContract = new web3Instance.eth.Contract(FACTORY_ABI, FACTORY_CONTRACT_ADDRESS, { gasLimit: "1000000" })
    const result = await factoryContract.methods.open(0, OWNER_ADDRESS, 1).send({ from: OWNER_ADDRESS });
    console.log("Created. Transaction: " + result.transactionHash)
}

main()
