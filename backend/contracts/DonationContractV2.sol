// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title AGA Donation Contract V2
 * @notice Handles donations to Geniuses in BNB, USDT, USDC, and USD1
 * @dev All donations are automatically forwarded to the admin wallet for centralized management
 */

interface IERC20 {
    function transfer(address to, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);
}

contract AGADonationContractV2 {
    // Admin wallet that receives all donations
    address payable public adminWallet;

    // Contract owner (for admin wallet updates if needed)
    address public owner;

    // Supported stablecoin addresses on BNB Smart Chain
    address public constant USDT = 0x55d398326f99059fF775485246999027E3197955; // BSC Mainnet USDT
    address public constant USDC = 0x8AC76a51cc950d9822D68b83fE1Ad97B32Cd580d; // BSC Mainnet USDC
    address public constant USD1 = 0x5eE84583f67D5EcEa5420dBb42b462896E7f8D06; // BSC Mainnet USD1

    // Testnet addresses (for testing)
    address public constant USDT_TESTNET = 0x337610d27c682E347C9cD60BD4b3b107C9d34dDd;
    address public constant USDC_TESTNET = 0x64544969ed7EBf5f083679233325356EbE738930;

    // Payment type enum
    enum PaymentType {
        BNB,
        USDT,
        USDC,
        USD1
    }

    // Donation record structure
    struct Donation {
        address donor;
        string geniusId;
        uint256 amount;
        PaymentType paymentType;
        uint256 timestamp;
        string message;
        bool isAnonymous;
    }

    // Mapping from donation ID to Donation
    mapping(bytes32 => Donation) public donations;

    // Array of all donation IDs for enumeration
    bytes32[] public donationIds;

    // Mapping from genius ID to total donations received (in USD equivalent)
    mapping(string => uint256) public geniusTotalDonations;

    // Mapping from genius ID to donation count
    mapping(string => uint256) public geniusDonationCount;

    // Track donations by payment type
    mapping(string => mapping(PaymentType => uint256)) public geniusDonationsByType;

    // Events
    event DonationReceived(
        bytes32 indexed donationId,
        address indexed donor,
        string indexed geniusId,
        uint256 amount,
        PaymentType paymentType,
        uint256 timestamp,
        bool isAnonymous
    );

    event DonationForwarded(
        bytes32 indexed donationId,
        address indexed adminWallet,
        uint256 amount,
        PaymentType paymentType
    );

    event AdminWalletUpdated(
        address indexed oldWallet,
        address indexed newWallet
    );

    // Modifiers
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    /**
     * @notice Constructor sets the admin wallet and owner
     * @param _adminWallet The wallet that will receive all donations
     */
    constructor(address payable _adminWallet) {
        require(_adminWallet != address(0), "Admin wallet cannot be zero address");
        adminWallet = _adminWallet;
        owner = msg.sender;
    }

    /**
     * @notice Donate BNB to a Genius
     * @param geniusId The unique ID of the genius receiving the donation
     * @param message Optional message from the donor
     * @param isAnonymous Whether the donation should be anonymous
     * @return donationId The unique ID of this donation
     */
    function donateBNB(
        string memory geniusId,
        string memory message,
        bool isAnonymous
    ) external payable returns (bytes32) {
        require(msg.value > 0, "Donation amount must be greater than 0");
        require(bytes(geniusId).length > 0, "Genius ID cannot be empty");

        bytes32 donationId = _createDonationRecord(
            geniusId,
            msg.value,
            PaymentType.BNB,
            message,
            isAnonymous
        );

        // Immediately forward BNB to admin wallet
        (bool success, ) = adminWallet.call{value: msg.value}("");
        require(success, "Failed to forward BNB to admin wallet");

        emit DonationForwarded(donationId, adminWallet, msg.value, PaymentType.BNB);

        return donationId;
    }

    /**
     * @notice Donate stablecoins (USDT, USDC, USD1) to a Genius
     * @param geniusId The unique ID of the genius receiving the donation
     * @param amount Amount of tokens to donate (with token decimals, usually 18)
     * @param tokenAddress Address of the token contract
     * @param message Optional message from the donor
     * @param isAnonymous Whether the donation should be anonymous
     * @return donationId The unique ID of this donation
     */
    function donateToken(
        string memory geniusId,
        uint256 amount,
        address tokenAddress,
        string memory message,
        bool isAnonymous
    ) external returns (bytes32) {
        require(amount > 0, "Donation amount must be greater than 0");
        require(bytes(geniusId).length > 0, "Genius ID cannot be empty");

        // Determine payment type based on token address
        PaymentType paymentType = _getPaymentType(tokenAddress);
        require(paymentType != PaymentType.BNB, "Use donateBNB for BNB donations");

        // Transfer tokens from donor to this contract
        IERC20 token = IERC20(tokenAddress);
        require(
            token.transferFrom(msg.sender, address(this), amount),
            "Token transfer from donor failed"
        );

        bytes32 donationId = _createDonationRecord(
            geniusId,
            amount,
            paymentType,
            message,
            isAnonymous
        );

        // Immediately forward tokens to admin wallet
        require(
            token.transfer(adminWallet, amount),
            "Failed to forward tokens to admin wallet"
        );

        emit DonationForwarded(donationId, adminWallet, amount, paymentType);

        return donationId;
    }

    /**
     * @notice Internal function to create donation record
     */
    function _createDonationRecord(
        string memory geniusId,
        uint256 amount,
        PaymentType paymentType,
        string memory message,
        bool isAnonymous
    ) internal returns (bytes32) {
        // Generate unique donation ID
        bytes32 donationId = keccak256(
            abi.encodePacked(
                msg.sender,
                geniusId,
                amount,
                paymentType,
                block.timestamp,
                donationIds.length
            )
        );

        // Store donation record
        donations[donationId] = Donation({
            donor: msg.sender,
            geniusId: geniusId,
            amount: amount,
            paymentType: paymentType,
            timestamp: block.timestamp,
            message: message,
            isAnonymous: isAnonymous
        });

        // Add to donation IDs array
        donationIds.push(donationId);

        // Update genius statistics (amount is in token units or wei)
        geniusTotalDonations[geniusId] += amount;
        geniusDonationCount[geniusId] += 1;
        geniusDonationsByType[geniusId][paymentType] += amount;

        // Emit donation event
        emit DonationReceived(
            donationId,
            msg.sender,
            geniusId,
            amount,
            paymentType,
            block.timestamp,
            isAnonymous
        );

        return donationId;
    }

    /**
     * @notice Get payment type from token address
     */
    function _getPaymentType(address tokenAddress) internal view returns (PaymentType) {
        if (tokenAddress == USDT || tokenAddress == USDT_TESTNET) {
            return PaymentType.USDT;
        } else if (tokenAddress == USDC || tokenAddress == USDC_TESTNET) {
            return PaymentType.USDC;
        } else if (tokenAddress == USD1) {
            return PaymentType.USD1;
        }
        revert("Unsupported token");
    }

    /**
     * @notice Get donation details by ID
     */
    function getDonation(bytes32 donationId) external view returns (
        address donor,
        string memory geniusId,
        uint256 amount,
        PaymentType paymentType,
        uint256 timestamp,
        string memory message,
        bool isAnonymous
    ) {
        Donation memory d = donations[donationId];
        return (
            d.donor,
            d.geniusId,
            d.amount,
            d.paymentType,
            d.timestamp,
            d.message,
            d.isAnonymous
        );
    }

    /**
     * @notice Get total donations received by a genius (sum of all payment types)
     */
    function getGeniusTotalDonations(string memory geniusId) external view returns (uint256) {
        return geniusTotalDonations[geniusId];
    }

    /**
     * @notice Get donation count for a genius
     */
    function getGeniusDonationCount(string memory geniusId) external view returns (uint256) {
        return geniusDonationCount[geniusId];
    }

    /**
     * @notice Get donations by payment type for a genius
     */
    function getGeniusDonationsByType(
        string memory geniusId,
        PaymentType paymentType
    ) external view returns (uint256) {
        return geniusDonationsByType[geniusId][paymentType];
    }

    /**
     * @notice Get total number of donations in the system
     */
    function getTotalDonationsCount() external view returns (uint256) {
        return donationIds.length;
    }

    /**
     * @notice Get token address for mainnet
     */
    function getTokenAddress(PaymentType paymentType) external pure returns (address) {
        if (paymentType == PaymentType.USDT) return USDT;
        if (paymentType == PaymentType.USDC) return USDC;
        if (paymentType == PaymentType.USD1) return USD1;
        revert("Invalid payment type");
    }

    /**
     * @notice Update admin wallet (only owner)
     */
    function updateAdminWallet(address payable newAdminWallet) external onlyOwner {
        require(newAdminWallet != address(0), "New admin wallet cannot be zero address");
        address oldWallet = adminWallet;
        adminWallet = newAdminWallet;
        emit AdminWalletUpdated(oldWallet, newAdminWallet);
    }

    /**
     * @notice Get contract balance (should always be 0 as funds are forwarded immediately)
     */
    function getContractBalance() external view returns (uint256) {
        return address(this).balance;
    }

    /**
     * @notice Emergency function to recover accidentally sent tokens (only owner)
     */
    function recoverTokens(address tokenAddress, uint256 amount) external onlyOwner {
        IERC20(tokenAddress).transfer(owner, amount);
    }

    /**
     * @notice Emergency function to recover accidentally sent BNB (only owner)
     */
    function recoverBNB(uint256 amount) external onlyOwner {
        payable(owner).transfer(amount);
    }
}
