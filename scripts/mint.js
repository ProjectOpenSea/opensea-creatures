const fs = require('fs')
const HDWalletProvider = require("truffle-hdwallet-provider")
const web3 = require('web3')
const Abacus = require('@abacusprotocol/sdk-node')
const MNEMONIC = process.env.MNEMONIC
const INFURA_KEY = process.env.INFURA_KEY
const CONTRACT_ADDRESS = process.env.CONTRACT_ADDRESS
const OWNER_ADDRESS = process.env.OWNER_ADDRESS
const NETWORK = process.env.NETWORK
const ABACUS_APP_ID = process.env.ABACUS_APP_ID
const ABACUS_API_KEY = process.env.ABACUS_API_KEY
const NUM_PUFFS = 12

const abacus = new Abacus({
    apiKey: ABACUS_API_KEY,
    applicationId: ABACUS_APP_ID
})

if (!MNEMONIC || !INFURA_KEY) {
    console.error("Please set a mnemonic and infura key.")
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


const FIRST_NAMES = ['Herbie', 'Jessica', 'Fluffles', 'Dave', 'Randy']
const LAST_NAMES = ['McPufflestein', 'McDonald', 'Winkleton']
const INT_ATTRIBUTES = [5, 2, 3, 4, 8]
const FLOAT_ATTRIBUTES = [1.4, 2.3, 11.7, 90.2, 1.2]
const STR_ATTRIBUTES = [
    'happy',
    'sad',
    'sleepy',
    'boring'
]
const BOOST_ATTRIBUTES = [10, 40, 30]
const PERCENT_BOOST_ATTRIBUTES = [5, 10, 15]
const NUMBER_ATTRIBUTES = [1, 2, 1, 1]

function _buildAttribute(traitType, options, tokenId, displayType) {
    const trait = {
        'trait_type': traitType,
        'value': options[tokenId % options.length]
    }
    if (displayType) {
        trait.display_type = displayType
    }
    return trait
}

function _buildPuffMeta(tokenId, fileUrl, fileRef) {
    const puffName = FIRST_NAMES[tokenId % FIRST_NAMES.length] + ' ' + LAST_NAMES[tokenId % LAST_NAMES.length]
    const attributes = [
        _buildAttribute('level', INT_ATTRIBUTES, tokenId),
        _buildAttribute('stamina', FLOAT_ATTRIBUTES, tokenId),
        _buildAttribute('personality', STR_ATTRIBUTES, tokenId),
        _buildAttribute('puff_power', BOOST_ATTRIBUTES, tokenId, 'boost_number'),
        _buildAttribute('stamina_increase', PERCENT_BOOST_ATTRIBUTES, tokenId, 'boost_percentage'),
        _buildAttribute('generation', NUMBER_ATTRIBUTES, tokenId, 'number'),
    ]

    return {
        'name': puffName,
        'description': "Generic puff description. This really should be customized.",
        'image': null,
        'image_ref': fileRef,
        'external_url': `https://cryptopuff.io/${tokenId}`,
        'attributes': attributes
    }
}

async function main() {
    const web3Instance = new web3(
        new HDWalletProvider(MNEMONIC, `https://${NETWORK}.infura.io/${INFURA_KEY}`)
    )

    const itemContract = new web3Instance.eth.Contract(ABI, CONTRACT_ADDRESS, { gasLimit: "1000000" })

    for (var i = 0; i < NUM_PUFFS; i++) {
        const puffId = i + 1
        const uploadResult = await abacus.uploadFile({
            file: fs.createReadStream(`${__dirname}/../assets/${puffId}.png`)
        })
        const writeResult = await abacus.writeAnnotations({
            entityId: {
                tokenAddress: CONTRACT_ADDRESS,
                tokenId: puffId
            },
            annotations: {
                annotations: {
                    abacus_kv: _buildPuffMeta(puffId, uploadResult.fileRef)
                },
                files: {
                    eth_checksum: {
                        image: uploadResult.fileRef
                    }
                }
            }
        })
        console.log(uploadResult, writeResult)
        const tokenUri = abacus.getTokenURI({
            tokenId: {
                tokenAddress: CONTRACT_ADDRESS,
                tokenId: puffId
            }
        })
        const result = await itemContract.methods.mintTo(OWNER_ADDRESS, tokenUri).send({ from: OWNER_ADDRESS });
        console.log(result.transactionHash)
    } 
}

main()