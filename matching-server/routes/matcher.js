const express = require('express');
const router = express.Router();
const crypto = require('crypto');
const { matcherContract, web3, account } = require('../web3');

router.get('/hash-schema', (req, res) => {
    res.json({
        schema: 'SHA-256',
        inputFormat: 'JSON.stringify({...})',
    });
});

router.post('/match', async (req, res) => {
    const { txId, hashValue } = req.body;

    try {
        const existing = await matcherContract.methods.getMatchStatus(txId).call();
        if (existing[0] === '0') {
            // Not registered
            await matcherContract.methods.registerMatch(txId, hashValue).send({ from: account });
            res.json({ status: 'registered' });
        } else {
            await matcherContract.methods.verifyMatch(txId, hashValue).send({ from: account });
            const newStatus = await matcherContract.methods.getMatchStatus(txId).call();
            res.json({ status: newStatus[0] === '1' ? 'matched' : 'unmatched' });
        }
    } catch (e) {
        console.error(e);
        res.status(500).send('Error processing match');
    }
});

router.get('/status/:txId', async (req, res) => {
    try {
        const { txId } = req.params;
        const result = await matcherContract.methods.getMatchStatus(txId).call();
        let statusText = ['not_registered', 'matched', 'unmatched'][result[0]];
        res.json({ status: statusText, hashValue: result[1] });
    } catch (e) {
        res.status(500).send('Error fetching status');
    }
});

module.exports = router;
