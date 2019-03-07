const opensea = require('opensea-js')
const OpenSeaPort = opensea.OpenSeaPort;
const Network = opensea.Network;

const MnemonicWalletSubprovider = require('@0x/subproviders').MnemonicWalletSubprovider
const RPCSubprovider = require('web3-provider-engine/subproviders/rpc')
const Web3ProviderEngine = require('web3-provider-engine')

const MNEMONIC = process.env.MNEMONIC
const BASE_DERIVATION_PATH = `44'/60'/0'/0`

const mnemonicWalletSubprovider = new MnemonicWalletSubprovider({ mnemonic: MNEMONIC, baseDerivationPath: BASE_DERIVATION_PATH})
const infuraRpcSubprovider = new RPCSubprovider({
    rpcUrl: 'https://' + NETWORK + '.infura.io/v3/' + INFURA_KEY,
})

const providerEngine = new Web3ProviderEngine()
providerEngine.addProvider(mnemonicWalletSubprovider)
providerEngine.addProvider(infuraRpcSubprovider)
providerEngine.start();

export const seaport = new OpenSeaPort(providerEngine, {
    networkName: NETWORK === 'mainnet' ? Network.Main : Network.Rinkeby,
    apiKey: API_KEY
}, (arg) => console.log(arg))

export const web3Instance = new web3(
    providerEngine
)