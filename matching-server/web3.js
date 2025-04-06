// web3.js
const { Web3 } = require('web3');
const contractJson = require('./abi/Matcher.json');

const web3 = new Web3('http://localhost:8545'); // Besu RPC

const contractAddress = '0xYourDeployedContractAddress';
const account = '0xYourBesuAccount'; // Unlock된 계정

const matcherContract = new web3.eth.Contract(contractJson.abi, contractAddress);

module.exports = {
    web3,
    matcherContract,
    account
};
