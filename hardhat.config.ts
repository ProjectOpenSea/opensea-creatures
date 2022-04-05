/**
* @type import('hardhat/config').HardhatUserConfig
*/

import dotenv from 'dotenv';
import '@nomiclabs/hardhat-ethers';
import { subtask } from 'hardhat/config';
import { TASK_COMPILE_SOLIDITY_GET_SOURCE_PATHS } from "hardhat/builtin-tasks/task-names";

dotenv.config();

subtask(TASK_COMPILE_SOLIDITY_GET_SOURCE_PATHS)
  .setAction(async (_, __, runSuper) => {
    const paths = await runSuper();
    console.log(paths)
    return paths.filter((p: any) =>
      !p.includes("/test/"));
  });

const { ALCHEMY_KEY, ACCOUNT_PRIVATE_KEY } = process.env;

module.exports = {
  solidity: "0.8.9",
  defaultNetwork: "rinkeby",
  networks: {
    hardhat: {},
    rinkeby: {
      url: `https://eth-rinkeby.alchemyapi.io/v2/${ALCHEMY_KEY}`,
      accounts: [`0x${ACCOUNT_PRIVATE_KEY}`]
    },
    ethereum: {
      chainId: 1,
      url: `https://eth-mainnet.alchemyapi.io/v2/${ALCHEMY_KEY}`,
      accounts: [`0x${ACCOUNT_PRIVATE_KEY}`]
    },
  },
  paths: { cache: 'hh-cache' }
}