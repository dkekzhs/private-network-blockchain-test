// smart-contract/contracts/Matcher.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract Matcher {
    enum MatchStatus { NotRegistered, Matched, Unmatched }

    struct MatchRecord {
        bytes32 hashValue;
        MatchStatus status;
    }

    mapping(string => MatchRecord) private matches;

    event MatchRequested(string txId, bytes32 hashValue);
    event MatchVerified(string txId, MatchStatus status);

    function registerMatch(string memory txId, bytes32 hashValue) external {
        require(matches[txId].status == MatchStatus.NotRegistered, "Already registered");

        matches[txId] = MatchRecord({
            hashValue: hashValue,
            status: MatchStatus.Matched
        });

        emit MatchRequested(txId, hashValue);
    }

    function verifyMatch(string memory txId, bytes32 hashValue) external {
        MatchRecord storage record = matches[txId];

        if (record.status == MatchStatus.NotRegistered) {
            emit MatchVerified(txId, MatchStatus.NotRegistered);
            return;
        }

        if (record.hashValue == hashValue) {
            record.status = MatchStatus.Matched;
        } else {
            record.status = MatchStatus.Unmatched;
        }

        emit MatchVerified(txId, record.status);
    }

    function getMatchStatus(string memory txId) external view returns (MatchStatus, bytes32) {
        MatchRecord storage record = matches[txId];
        return (record.status, record.hashValue);
    }
}
