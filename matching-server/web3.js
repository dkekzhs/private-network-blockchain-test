// web3.js
const { Web3 } = require('web3');
const contractJson = require('./abi/Matcher.json');

const web3 = new Web3('http://localhost:8545'); // Besu RPC

const pk = "0x95afc758fbe4b2e21fd4938611b746205999f0588b28eb279efa804db4a598e7";
const account = web3.eth.accounts.privateKeyToAccount(pk);
const contractAddress = "0x115fc5B81318EA57395296C5a7b7F965e8b7615D";

console.log(account);

const matcherContract = new web3.eth.Contract(contractJson.abi, contractAddress);

module.exports = {
    web3,
    matcherContract,
    account
};
