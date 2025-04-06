require("@nomicfoundation/hardhat-toolbox");
const fs = require("fs");

module.exports = {
  solidity: "0.8.20",
  networks: {
    besu: {
      url: "http://localhost:8545",
      accounts: [fs.readFileSync("../besu-network/validator.key", "utf-8").trim()]
    }
  }
};
