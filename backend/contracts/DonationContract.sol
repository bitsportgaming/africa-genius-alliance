// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title AGA Donation Contract
 * @notice Handles donations to Geniuses with automatic forwarding to admin wallet
 * @dev All donations are automatically forwarded to the admin wallet for centralized management
 */
contract AGADonationContract {
    // Admin wallet that receives all donations
    address payable public adminWallet;

    // Contract owner (for admin wallet updates if needed)
    address public owner;

    // Donation record structure
    struct Donation {
        address donor;
        string geniusId;
        uint256 amount;
        uint256 timestamp;
        string message;
        bool isAnonymous;
    }

    // Mapping from donation ID to Donation
    mapping(bytes32 => Donation) public donations;

    // Array of all donation IDs for enumeration
    bytes32[] public donationIds;

    // Mapping from genius ID to total donations received
    mapping(string => uint256) public geniusTotalDonations;

    // Mapping from genius ID to donation count
    mapping(string => uint256) public geniusDonationCount;

    // Events
    event DonationReceived(
        bytes32 indexed donationId,
        address indexed donor,
        string indexed geniusId,
        uint256 amount,
        uint256 timestamp,
        bool isAnonymous
    );

    event DonationForwarded(
        bytes32 indexed donationId,
        address indexed adminWallet,
        uint256 amount
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
     * @notice Donate to a Genius
     * @param geniusId The unique ID of the genius receiving the donation
     * @param message Optional message from the donor
     * @param isAnonymous Whether the donation should be anonymous
     * @return donationId The unique ID of this donation
     */
    function donate(
        string memory geniusId,
        string memory message,
        bool isAnonymous
    ) external payable returns (bytes32) {
        require(msg.value > 0, "Donation amount must be greater than 0");
        require(bytes(geniusId).length > 0, "Genius ID cannot be empty");

        // Generate unique donation ID
        bytes32 donationId = keccak256(
            abi.encodePacked(
                msg.sender,
                geniusId,
                msg.value,
                block.timestamp,
                donationIds.length
            )
        );

        // Store donation record
        donations[donationId] = Donation({
            donor: msg.sender,
            geniusId: geniusId,
            amount: msg.value,
            timestamp: block.timestamp,
            message: message,
            isAnonymous: isAnonymous
        });

        // Add to donation IDs array
        donationIds.push(donationId);

        // Update genius statistics
        geniusTotalDonations[geniusId] += msg.value;
        geniusDonationCount[geniusId] += 1;

        // Emit donation event
        emit DonationReceived(
            donationId,
            msg.sender,
            geniusId,
            msg.value,
            block.timestamp,
            isAnonymous
        );

        // Immediately forward funds to admin wallet
        (bool success, ) = adminWallet.call{value: msg.value}("");
        require(success, "Failed to forward donation to admin wallet");

        emit DonationForwarded(donationId, adminWallet, msg.value);

        return donationId;
    }

    /**
     * @notice Get donation details by ID
     * @param donationId The ID of the donation
     * @return Donation struct with all details
     */
    function getDonation(bytes32 donationId) external view returns (
        address donor,
        string memory geniusId,
        uint256 amount,
        uint256 timestamp,
        string memory message,
        bool isAnonymous
    ) {
        Donation memory d = donations[donationId];
        return (
            d.donor,
            d.geniusId,
            d.amount,
            d.timestamp,
            d.message,
            d.isAnonymous
        );
    }

    /**
     * @notice Get total donations received by a genius
     * @param geniusId The ID of the genius
     * @return Total amount donated in wei
     */
    function getGeniusTotalDonations(string memory geniusId) external view returns (uint256) {
        return geniusTotalDonations[geniusId];
    }

    /**
     * @notice Get donation count for a genius
     * @param geniusId The ID of the genius
     * @return Number of donations received
     */
    function getGeniusDonationCount(string memory geniusId) external view returns (uint256) {
        return geniusDonationCount[geniusId];
    }

    /**
     * @notice Get total number of donations in the system
     * @return Total donation count
     */
    function getTotalDonationsCount() external view returns (uint256) {
        return donationIds.length;
    }

    /**
     * @notice Update admin wallet (only owner)
     * @param newAdminWallet The new admin wallet address
     */
    function updateAdminWallet(address payable newAdminWallet) external onlyOwner {
        require(newAdminWallet != address(0), "New admin wallet cannot be zero address");
        address oldWallet = adminWallet;
        adminWallet = newAdminWallet;
        emit AdminWalletUpdated(oldWallet, newAdminWallet);
    }

    /**
     * @notice Get contract balance (should always be 0 as funds are forwarded immediately)
     * @return Contract balance in wei
     */
    function getContractBalance() external view returns (uint256) {
        return address(this).balance;
    }
}
