/**
 * BNB Chain Blockchain Service for Voting and Donations
 * Handles vote recording and donation processing on BNB Smart Chain
 */

const { ethers } = require('ethers');

// BNB Chain configuration
const BNB_CONFIG = {
    mainnet: {
        chainId: 56,
        rpcUrl: 'https://bsc-dataseed.binance.org/',
        explorerUrl: 'https://bscscan.com'
    },
    testnet: {
        chainId: 97,
        rpcUrl: 'https://data-seed-prebsc-1-s1.binance.org:8545/',
        explorerUrl: 'https://testnet.bscscan.com'
    }
};

// Voting contract ABI (minimal interface)
const VOTING_ABI = [
    'function createElection(string electionId, uint256 startTime, uint256 endTime) external returns (uint256)',
    'function castVote(uint256 electionId, string candidateId, string voterId) external',
    'function getVote(uint256 electionId, string voterId) external view returns (string candidateId, uint256 timestamp)',
    'function getElectionVotes(uint256 electionId) external view returns (uint256)',
    'function isElectionActive(uint256 electionId) external view returns (bool)',
    'event VoteCast(uint256 indexed electionId, string voterId, string candidateId, uint256 timestamp)',
    'event ElectionCreated(uint256 indexed electionId, string externalId, uint256 startTime, uint256 endTime)'
];

// Donation contract ABI V2 (supports BNB and stablecoins)
const DONATION_ABI = [
    'function donateBNB(string memory geniusId, string memory message, bool isAnonymous) external payable returns (bytes32)',
    'function donateToken(string memory geniusId, uint256 amount, address tokenAddress, string memory message, bool isAnonymous) external returns (bytes32)',
    'function getDonation(bytes32 donationId) external view returns (address donor, string memory geniusId, uint256 amount, uint8 paymentType, uint256 timestamp, string memory message, bool isAnonymous)',
    'function getGeniusTotalDonations(string memory geniusId) external view returns (uint256)',
    'function getGeniusDonationCount(string memory geniusId) external view returns (uint256)',
    'function getGeniusDonationsByType(string memory geniusId, uint8 paymentType) external view returns (uint256)',
    'function getTotalDonationsCount() external view returns (uint256)',
    'function getTokenAddress(uint8 paymentType) external pure returns (address)',
    'function adminWallet() external view returns (address)',
    'function getContractBalance() external view returns (uint256)',
    'event DonationReceived(bytes32 indexed donationId, address indexed donor, string indexed geniusId, uint256 amount, uint8 paymentType, uint256 timestamp, bool isAnonymous)',
    'event DonationForwarded(bytes32 indexed donationId, address indexed adminWallet, uint256 amount, uint8 paymentType)'
];

// ERC20 Token ABI (for token approvals and transfers)
const ERC20_ABI = [
    'function approve(address spender, uint256 amount) external returns (bool)',
    'function allowance(address owner, address spender) external view returns (uint256)',
    'function balanceOf(address account) external view returns (uint256)',
    'function decimals() external view returns (uint8)',
    'function symbol() external view returns (string)'
];

// Stablecoin addresses on BNB Smart Chain
const STABLECOIN_ADDRESSES = {
    mainnet: {
        USDT: '0x55d398326f99059fF775485246999027E3197955',
        USDC: '0x8AC76a51cc950d9822D68b83fE1Ad97B32Cd580d',
        USD1: '0x5eE84583f67D5EcEa5420dBb42b462896E7f8D06'
    },
    testnet: {
        USDT: '0x337610d27c682E347C9cD60BD4b3b107C9d34dDd',
        USDC: '0x64544969ed7EBf5f083679233325356EbE738930',
        USD1: '0x0000000000000000000000000000000000000000' // Placeholder for testnet
    }
};

// Payment types (matching contract enum)
const PaymentType = {
    BNB: 0,
    USDT: 1,
    USDC: 2,
    USD1: 3
};

class BlockchainService {
    constructor() {
        this.network = process.env.BNB_NETWORK || 'testnet';
        this.config = BNB_CONFIG[this.network];
        this.votingContractAddress = process.env.VOTING_CONTRACT_ADDRESS || '';
        this.donationContractAddress = process.env.DONATION_CONTRACT_ADDRESS || '';
        this.privateKey = process.env.BNB_PRIVATE_KEY || '';

        if (this.privateKey) {
            this.provider = new ethers.JsonRpcProvider(this.config.rpcUrl);
            this.wallet = new ethers.Wallet(this.privateKey, this.provider);

            if (this.votingContractAddress) {
                this.votingContract = new ethers.Contract(this.votingContractAddress, VOTING_ABI, this.wallet);
            }

            if (this.donationContractAddress) {
                this.donationContract = new ethers.Contract(this.donationContractAddress, DONATION_ABI, this.wallet);
            }
        }
    }

    isVotingConfigured() {
        return !!(this.privateKey && this.votingContractAddress && this.provider);
    }

    isDonationConfigured() {
        return !!(this.privateKey && this.donationContractAddress && this.provider);
    }

    isConfigured() {
        return this.isVotingConfigured() || this.isDonationConfigured();
    }

    getExplorerUrl(txHash) {
        return `${this.config.explorerUrl}/tx/${txHash}`;
    }

    /**
     * Record a vote on the blockchain
     */
    async recordVote(electionIdOnChain, candidateId, voterId) {
        if (!this.isVotingConfigured()) {
            // Return mock data if blockchain not configured
            return this.generateMockTransaction();
        }

        try {
            const tx = await this.votingContract.castVote(electionIdOnChain, candidateId, voterId);
            const receipt = await tx.wait();

            return {
                success: true,
                transactionHash: receipt.hash,
                blockNumber: receipt.blockNumber,
                blockHash: receipt.blockHash,
                gasUsed: receipt.gasUsed.toString(),
                status: 'confirmed',
                explorerUrl: this.getExplorerUrl(receipt.hash)
            };
        } catch (error) {
            console.error('Blockchain vote error:', error);
            throw new Error(`Failed to record vote on blockchain: ${error.message}`);
        }
    }

    /**
     * Create an election on the blockchain
     */
    async createElectionOnChain(electionId, startTime, endTime) {
        if (!this.isVotingConfigured()) {
            return { success: true, electionIdOnChain: Math.floor(Math.random() * 1000000), mock: true };
        }

        try {
            const tx = await this.votingContract.createElection(
                electionId,
                Math.floor(new Date(startTime).getTime() / 1000),
                Math.floor(new Date(endTime).getTime() / 1000)
            );
            const receipt = await tx.wait();

            // Parse election ID from event
            const event = receipt.logs.find(log => log.fragment?.name === 'ElectionCreated');
            const electionIdOnChain = event ? event.args[0] : 0;

            return {
                success: true,
                electionIdOnChain: Number(electionIdOnChain),
                transactionHash: receipt.hash,
                blockNumber: receipt.blockNumber
            };
        } catch (error) {
            console.error('Blockchain election creation error:', error);
            throw new Error(`Failed to create election on blockchain: ${error.message}`);
        }
    }

    /**
     * Verify a vote exists on blockchain
     */
    async verifyVote(electionIdOnChain, voterId) {
        if (!this.isVotingConfigured()) {
            return { verified: false, reason: 'Blockchain not configured' };
        }

        try {
            const [candidateId, timestamp] = await this.votingContract.getVote(electionIdOnChain, voterId);
            return {
                verified: !!candidateId,
                candidateId,
                timestamp: Number(timestamp),
                votedAt: new Date(Number(timestamp) * 1000)
            };
        } catch (error) {
            return { verified: false, reason: error.message };
        }
    }

    /**
     * Get token address for the current network
     */
    getTokenAddress(tokenSymbol) {
        const addresses = STABLECOIN_ADDRESSES[this.network];
        return addresses[tokenSymbol] || null;
    }

    /**
     * Process a donation on the blockchain (supports BNB and stablecoins)
     * @param {string} geniusId - ID of the genius receiving the donation
     * @param {number} amountInUSD - Donation amount in USD
     * @param {string} message - Optional message from donor
     * @param {boolean} isAnonymous - Whether donation is anonymous
     * @param {string} paymentToken - Token to use: 'BNB', 'USDT', 'USDC', or 'USD1'
     * @returns {Promise<Object>} Transaction details including hash and donation ID
     */
    async processDonation(geniusId, amountInUSD, message = '', isAnonymous = false, paymentToken = 'USDT') {
        if (!this.isDonationConfigured()) {
            // Return mock data if blockchain not configured
            return this.generateMockDonation(geniusId, amountInUSD, paymentToken);
        }

        try {
            let tx, receipt, donationId;

            if (paymentToken === 'BNB') {
                // Convert USD to BNB (in production, use price oracle)
                const bnbPrice = 600; // 1 BNB ≈ $600
                const amountInBNB = amountInUSD / bnbPrice;
                const amountInWei = ethers.parseEther(amountInBNB.toFixed(8));

                // Call donateBNB function on contract
                tx = await this.donationContract.donateBNB(
                    geniusId,
                    message,
                    isAnonymous,
                    { value: amountInWei }
                );

                receipt = await tx.wait();
            } else {
                // Stablecoin donation (USDT, USDC, USD1)
                const tokenAddress = this.getTokenAddress(paymentToken);
                if (!tokenAddress || tokenAddress === '0x0000000000000000000000000000000000000000') {
                    throw new Error(`${paymentToken} not supported on ${this.network}`);
                }

                // Most stablecoins use 18 decimals on BSC
                const decimals = 18;
                const amountInTokens = ethers.parseUnits(amountInUSD.toFixed(6), decimals);

                // First, approve the donation contract to spend tokens
                const tokenContract = new ethers.Contract(tokenAddress, ERC20_ABI, this.wallet);

                // Check current allowance
                const currentAllowance = await tokenContract.allowance(this.wallet.address, this.donationContractAddress);

                if (currentAllowance < amountInTokens) {
                    console.log(`Approving ${paymentToken} spend...`);
                    const approveTx = await tokenContract.approve(this.donationContractAddress, amountInTokens);
                    await approveTx.wait();
                    console.log(`${paymentToken} approval confirmed`);
                }

                // Call donateToken function on contract
                tx = await this.donationContract.donateToken(
                    geniusId,
                    amountInTokens,
                    tokenAddress,
                    message,
                    isAnonymous
                );

                receipt = await tx.wait();
            }

            // Parse DonationReceived event to get donation ID
            const donationEvent = receipt.logs.find(log => {
                try {
                    const parsed = this.donationContract.interface.parseLog(log);
                    return parsed?.name === 'DonationReceived';
                } catch {
                    return false;
                }
            });

            if (donationEvent) {
                const parsed = this.donationContract.interface.parseLog(donationEvent);
                donationId = parsed.args[0]; // First arg is donationId
            }

            return {
                success: true,
                donationId: donationId,
                transactionHash: receipt.hash,
                blockNumber: receipt.blockNumber,
                blockHash: receipt.blockHash,
                gasUsed: receipt.gasUsed.toString(),
                amountInUSD: amountInUSD,
                paymentToken: paymentToken,
                status: 'confirmed',
                explorerUrl: this.getExplorerUrl(receipt.hash),
                forwardedToAdmin: true
            };
        } catch (error) {
            console.error('Blockchain donation error:', error);
            throw new Error(`Failed to process donation on blockchain: ${error.message}`);
        }
    }

    /**
     * Get total donations for a genius from blockchain
     */
    async getGeniusTotalDonations(geniusId) {
        if (!this.isDonationConfigured()) {
            return { total: 0, count: 0, mock: true };
        }

        try {
            const totalWei = await this.donationContract.getGeniusTotalDonations(geniusId);
            const count = await this.donationContract.getGeniusDonationCount(geniusId);

            const totalBNB = ethers.formatEther(totalWei);
            // Mock USD conversion (use price oracle in production)
            const totalUSD = parseFloat(totalBNB) * 300;

            return {
                total: totalUSD,
                totalBNB: parseFloat(totalBNB),
                count: Number(count),
                geniusId
            };
        } catch (error) {
            console.error('Error getting genius donations:', error);
            return { total: 0, count: 0, error: error.message };
        }
    }

    /**
     * Get admin wallet address
     */
    async getAdminWallet() {
        if (!this.isDonationConfigured()) {
            return { address: process.env.DONATION_ADMIN_WALLET || 'Not configured', mock: true };
        }

        try {
            const adminWallet = await this.donationContract.adminWallet();
            return { address: adminWallet };
        } catch (error) {
            console.error('Error getting admin wallet:', error);
            return { address: null, error: error.message };
        }
    }

    /**
     * Generate mock donation for development/testing
     */
    generateMockDonation(geniusId, amountInUSD, paymentToken = 'USDT') {
        const mockDonationId = '0x' + [...Array(64)].map(() => Math.floor(Math.random() * 16).toString(16)).join('');
        const mockTxHash = '0x' + [...Array(64)].map(() => Math.floor(Math.random() * 16).toString(16)).join('');

        return {
            success: true,
            donationId: mockDonationId,
            transactionHash: mockTxHash,
            blockNumber: Math.floor(Math.random() * 1000000) + 35000000,
            blockHash: '0x' + [...Array(64)].map(() => Math.floor(Math.random() * 16).toString(16)).join(''),
            gasUsed: paymentToken === 'BNB' ? '52000' : '85000',
            amountInUSD: amountInUSD,
            paymentToken: paymentToken,
            status: 'confirmed',
            explorerUrl: `${this.config.explorerUrl}/tx/${mockTxHash}`,
            forwardedToAdmin: true,
            mock: true
        };
    }

    /**
     * Generate mock transaction for development/testing
     */
    generateMockTransaction() {
        const mockHash = '0x' + [...Array(64)].map(() => Math.floor(Math.random() * 16).toString(16)).join('');
        const mockBlockHash = '0x' + [...Array(64)].map(() => Math.floor(Math.random() * 16).toString(16)).join('');
        
        return {
            success: true,
            transactionHash: mockHash,
            blockNumber: Math.floor(Math.random() * 1000000) + 35000000,
            blockHash: mockBlockHash,
            gasUsed: '52000',
            status: 'confirmed',
            explorerUrl: `${this.config.explorerUrl}/tx/${mockHash}`,
            mock: true
        };
    }
}

module.exports = new BlockchainService();

