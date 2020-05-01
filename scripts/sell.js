const opensea = require('opensea-js')
const OpenSeaPort = opensea.OpenSeaPort;
const Network = opensea.Network;
const MnemonicWalletSubprovider = require('@0x/subproviders').MnemonicWalletSubprovider
const RPCSubprovider = require('web3-provider-engine/subproviders/rpc')
const Web3ProviderEngine = require('web3-provider-engine')

const MNEMONIC = process.env.MNEMONIC
const INFURA_KEY = process.env.INFURA_KEY
const FACTORY_CONTRACT_ADDRESS = process.env.FACTORY_CONTRACT_ADDRESS
const NFT_CONTRACT_ADDRESS = process.env.NFT_CONTRACT_ADDRESS
const OWNER_ADDRESS = process.env.OWNER_ADDRESS
const NETWORK = process.env.NETWORK
const API_KEY = process.env.API_KEY || "" // API key is optional but useful if you're doing a high volume of requests.

if (!MNEMONIC || !INFURA_KEY || !NETWORK || !OWNER_ADDRESS) {
    console.error("Please set a mnemonic, infura key, owner, network, API key, nft contract, and factory contract address.")
    return
}

if (!FACTORY_CONTRACT_ADDRESS && !NFT_CONTRACT_ADDRESS) {
    console.error("Please either set a factory or NFT contract address.")
    return
}

const BASE_DERIVATION_PATH = `44'/60'/0'/0`

const mnemonicWalletSubprovider = new MnemonicWalletSubprovider({ mnemonic: MNEMONIC, baseDerivationPath: BASE_DERIVATION_PATH})
const infuraRpcSubprovider = new RPCSubprovider({
    rpcUrl: 'https://' + NETWORK + '.infura.io/v3/' + INFURA_KEY,
})

const providerEngine = new Web3ProviderEngine()
providerEngine.addProvider(mnemonicWalletSubprovider)
providerEngine.addProvider(infuraRpcSubprovider)
providerEngine.start();

const seaport = new OpenSeaPort(providerEngine, {
    networkName: NETWORK === 'mainnet' ? Network.Main : Network.Rinkeby,
    apiKey: API_KEY
}, (arg) => console.log(arg))

async function main() {

    // Example: simple fixed-price sale of an item owned by a user. 
    console.log("Auctioning an item for a fixed price...")
    const fixedPriceSellOrder = await seaport.createSellOrder({
        asset: {
            tokenId: "1",
            tokenAddress: NFT_CONTRACT_ADDRESS,
        },
        startAmount: .05,
        expirationTime: 0,
        accountAddress: OWNER_ADDRESS
    })    
    console.log(`Successfully created a fixed-price sell order! ${fixedPriceSellOrder.asset.openseaLink}\n`)

    // // Example: Dutch auction.
    console.log("Dutch auctioning an item...")
    const expirationTime = Math.round(Date.now() / 1000 + 60 * 60 * 24)
    const dutchAuctionSellOrder = await seaport.createSellOrder({
        asset: {
            tokenId: "2",
            tokenAddress: NFT_CONTRACT_ADDRESS,
        },
        startAmount: .05,
        endAmount: .01,
        expirationTime: expirationTime,
        accountAddress: OWNER_ADDRESS
    })
    console.log(`Successfully created a dutch auction sell order! ${dutchAuctionSellOrder.asset.openseaLink}\n`)

    // Example: English auction.
    console.log("English auctioning an item in DAI...")
    const wethAddress = NETWORK == 'mainnet' ? '0xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2' : "0xc778417e063141139fce010982780140aa0cd5ab"
    const englishAuctionSellOrder = await seaport.createSellOrder({
        asset: {
            tokenId: "3",
            tokenAddress: NFT_CONTRACT_ADDRESS,
        },
        startAmount: .03,
        expirationTime: expirationTime,
        waitForHighestBid: true,
        paymentTokenAddress: wethAddress,
        accountAddress: OWNER_ADDRESS
    })
    console.log(`Successfully created an English auction sell order! ${englishAuctionSellOrder.asset.openseaLink}\n`)

}

main()