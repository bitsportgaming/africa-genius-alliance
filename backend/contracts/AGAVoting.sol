// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/**
 * @title AGAVoting
 * @dev Smart contract for Africa Genius Alliance voting on BNB Chain
 * Implements classic voting: 1 vote per user per election
 */
contract AGAVoting {
    address public owner;
    address public authorizedVoter; // Backend service address
    
    struct Election {
        string externalId;      // MongoDB election ID
        uint256 startTime;
        uint256 endTime;
        uint256 totalVotes;
        bool exists;
    }
    
    struct Vote {
        string candidateId;
        uint256 timestamp;
        bool exists;
    }
    
    // electionId => Election
    mapping(uint256 => Election) public elections;
    uint256 public electionCount;
    
    // electionId => voterId => Vote
    mapping(uint256 => mapping(string => Vote)) public votes;
    
    // Events
    event ElectionCreated(uint256 indexed electionId, string externalId, uint256 startTime, uint256 endTime);
    event VoteCast(uint256 indexed electionId, string voterId, string candidateId, uint256 timestamp);
    event AuthorizedVoterUpdated(address indexed newAuthorizedVoter);
    
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner");
        _;
    }
    
    modifier onlyAuthorized() {
        require(msg.sender == owner || msg.sender == authorizedVoter, "Not authorized");
        _;
    }
    
    constructor() {
        owner = msg.sender;
        authorizedVoter = msg.sender;
    }
    
    /**
     * @dev Set authorized voter address (backend service)
     */
    function setAuthorizedVoter(address _authorizedVoter) external onlyOwner {
        authorizedVoter = _authorizedVoter;
        emit AuthorizedVoterUpdated(_authorizedVoter);
    }
    
    /**
     * @dev Create a new election
     */
    function createElection(
        string calldata externalId,
        uint256 startTime,
        uint256 endTime
    ) external onlyAuthorized returns (uint256) {
        require(endTime > startTime, "Invalid time range");
        
        electionCount++;
        elections[electionCount] = Election({
            externalId: externalId,
            startTime: startTime,
            endTime: endTime,
            totalVotes: 0,
            exists: true
        });
        
        emit ElectionCreated(electionCount, externalId, startTime, endTime);
        return electionCount;
    }
    
    /**
     * @dev Cast a vote (called by backend on behalf of user)
     */
    function castVote(
        uint256 electionId,
        string calldata candidateId,
        string calldata voterId
    ) external onlyAuthorized {
        Election storage election = elections[electionId];
        require(election.exists, "Election not found");
        require(block.timestamp >= election.startTime, "Election not started");
        require(block.timestamp <= election.endTime, "Election ended");
        require(!votes[electionId][voterId].exists, "Already voted");
        require(bytes(candidateId).length > 0, "Invalid candidate");
        
        votes[electionId][voterId] = Vote({
            candidateId: candidateId,
            timestamp: block.timestamp,
            exists: true
        });
        
        election.totalVotes++;
        
        emit VoteCast(electionId, voterId, candidateId, block.timestamp);
    }
    
    /**
     * @dev Get vote for a user in an election
     */
    function getVote(uint256 electionId, string calldata voterId) 
        external view returns (string memory candidateId, uint256 timestamp) 
    {
        Vote storage vote = votes[electionId][voterId];
        return (vote.candidateId, vote.timestamp);
    }
    
    /**
     * @dev Get total votes for an election
     */
    function getElectionVotes(uint256 electionId) external view returns (uint256) {
        return elections[electionId].totalVotes;
    }
    
    /**
     * @dev Check if election is currently active
     */
    function isElectionActive(uint256 electionId) external view returns (bool) {
        Election storage election = elections[electionId];
        return election.exists && 
               block.timestamp >= election.startTime && 
               block.timestamp <= election.endTime;
    }
    
    /**
     * @dev Check if user has voted in election
     */
    function hasVoted(uint256 electionId, string calldata voterId) external view returns (bool) {
        return votes[electionId][voterId].exists;
    }
}

