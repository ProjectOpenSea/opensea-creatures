import * as dotenv from 'dotenv';
import { OpenSeaPort, Network } from 'opensea-js';
import * as fs from 'fs';
dotenv.config();

const HDWalletProvider = require('@truffle/hdwallet-provider');

const env = process.env;

const SECRET: string = env.MNEMONIC || env.PK || "";
const ETH_RPC_URL: string = env.ETH_RPC_URL || "";
const FACTORY_CONTRACT_ADDRESS: string = env.FACTORY_CONTRACT_ADDRESS || "";
const FACTORY_CONTRACT_OWNER_ADDRESS: string =
    env.FACTORY_CONTRACT_OWNER_ADDRESS || "";
const NETWORK: string = env.NETWORK || "";
const NUM_ORDERS: number = +(env.NUM_ORDERS || 0);
const FACTORY_OPTION_ID: number = +(env.FACTORY_OPTION_ID || 0);
const OPENSEA_API_KEY: string = env.OPENSEA_API_KEY || "";

if (!SECRET || !ETH_RPC_URL || !NETWORK || !FACTORY_CONTRACT_OWNER_ADDRESS) {
    console.error(
        "Please set a mnemonic, Alchemy/Infura key, owner, network, API key, nft contract, and factory contract address."
    );
}

if (!FACTORY_CONTRACT_ADDRESS) {
    console.error("Please specify a factory contract address.");
}


const provider = new HDWalletProvider(SECRET, ETH_RPC_URL);
const seaport = new OpenSeaPort(
    provider,
    {
        networkName:
            NETWORK === "mainnet" || NETWORK === "live"
                ? Network.Main
                : Network.Rinkeby,
        apiKey: OPENSEA_API_KEY,
    },
    (arg) => console.log(arg)
);

async function main() {
    console.log("Creating sale...");

    // listing activates in one minute
    const listingTime = Math.round(Date.now() / 1000) + 60;
    // expires in 24 hours
    const expirationTime = listingTime + 60 * 60 * 24;

    const price = 0.1;
    for (let i = 0; i < NUM_ORDERS; ++i) {
        const orderArgs = {
            assets: [
                {
                    tokenId: FACTORY_OPTION_ID,
                    tokenAddress: FACTORY_CONTRACT_ADDRESS,
                },
            ],
            accountAddress: FACTORY_CONTRACT_OWNER_ADDRESS,
            startAmount: price,
            listingTime: listingTime,
            expirationTime: expirationTime,
            numberOfOrders: 10,
        };
        seaport.createFactorySellOrders(orderArgs);

    }
}

main();
