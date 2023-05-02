require("dotenv").config();
require("@nomiclabs/hardhat-ethers");

const { INFURA_API_URL, PRIVATE_KEY } = process.env;

module.exports = {
  solidity: "0.8.19",
  defaultNetwork: "sepolia",
  networks: {
    hardhat: {},
    sepolia: {
      url: INFURA_API_URL,
      accounts: [`0x${PRIVATE_KEY}`],
    },
  },
};
