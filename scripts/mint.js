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

const ABI = [{
    "constant": false,
    "inputs": [{ "name": "_to", "type": "address" },
        { "name": "_tokenURI", "type": "string" }
    ],
    "name": "mintTo",
    "outputs": [],
    "payable": false,
    "stateMutability": "nonpayable",
    "type": "function"
}]

async function main() {
    const web3Instance = new web3(
        new HDWalletProvider(MNEMONIC, `https://${NETWORK}.infura.io/${INFURA_KEY}`)
    )

    const itemContract = new web3Instance.eth.Contract(ABI, CONTRACT_ADDRESS, { gasLimit: "1000000" })

    for (var i = 0; i < NUM_PUFFS; i++) {
        const puffId = i + 1
        const result = await itemContract.methods.mintWithTokenURI(OWNER_ADDRESS,
            `https://cryptopuffs-api.herokuapp.com/api/puff/${puffId}`).send({ from: OWNER_ADDRESS });
        console.log(result.transactionHash)
    } 
}

main()