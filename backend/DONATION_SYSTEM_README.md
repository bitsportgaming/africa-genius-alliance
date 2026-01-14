# AGA Donation System with Multi-Token Support

Complete blockchain-based donation system supporting **BNB, USDT, USDC, and USD1** on BNB Smart Chain.

## 🌟 Features

- ✅ Multi-token support: BNB, USDT, USDC, USD1
- ✅ Automatic forwarding to admin wallet
- ✅ 100% transparent on-chain transactions
- ✅ Anonymous donation option
- ✅ Donation messages
- ✅ Complete audit trail
- ✅ Real-time blockchain verification
- ✅ Fallback to database if blockchain unavailable

## 📋 Table of Contents

1. [Architecture Overview](#architecture-overview)
2. [Smart Contract](#smart-contract)
3. [Setup Instructions](#setup-instructions)
4. [Deployment Guide](#deployment-guide)
5. [API Reference](#api-reference)
6. [Testing](#testing)
7. [Security](#security)

---

## Architecture Overview

### Flow Diagram

```
User Donation
     ↓
Frontend UI (Select Token: USDT/USDC/USD1/BNB)
     ↓
Backend API (/api/funding/donate)
     ↓
Blockchain Service
     ↓
Smart Contract (AGADonationContractV2)
     ↓
Auto-forward to Admin Wallet
     ↓
Transaction Confirmation
```

### Components

1. **Smart Contract**: `DonationContractV2.sol` - Handles token donations and auto-forwarding
2. **Blockchain Service**: `blockchainService.js` - Interfaces with smart contract
3. **API Routes**: `funding.js` - REST endpoints for donations
4. **Database**: MongoDB - Records for redundancy and querying

---

## Smart Contract

### AGADonationContractV2

Located at: `/backend/contracts/DonationContractV2.sol`

#### Key Features:
- Supports BNB and 3 stablecoins (USDT, USDC, USD1)
- Automatic forwarding to admin wallet
- No fees - 100% goes to admin wallet
- Immutable donation records on-chain
- Emergency recovery functions

#### Token Addresses (BSC Mainnet):
- **USDT**: `0x55d398326f99059fF775485246999027E3197955`
- **USDC**: `0x8AC76a51cc950d9822D68b83fE1Ad97B32Cd580d`
- **USD1**: `0x5eE84583f67D5EcEa5420dBb42b462896E7f8D06`

#### Token Addresses (BSC Testnet):
- **USDT**: `0x337610d27c682E347C9cD60BD4b3b107C9d34dDd`
- **USDC**: `0x64544969ed7EBf5f083679233325356EbE738930`

---

## Setup Instructions

### Step 1: Generate Admin Wallet

This wallet will receive ALL donations.

```bash
cd backend
node scripts/generateAdminWallet.js
```

**Output:**
```
✅ Wallet Generated Successfully!

📍 WALLET ADDRESS:
   0x1234...5678

🔑 PRIVATE KEY:
   0xabcd...ef01

🗝️  MNEMONIC PHRASE:
   word1 word2 ... word24
```

**⚠️ CRITICAL**:
- Store the private key and mnemonic in a secure password manager
- NEVER commit these to git
- Make encrypted backups in multiple locations
- Consider using a hardware wallet for production

### Step 2: Configure Environment Variables

Add to your `.env` file:

```env
# Donation System Configuration
DONATION_ADMIN_WALLET=0x1234...5678  # From step 1
DONATION_DEPLOYER_PRIVATE_KEY=0xabcd...ef01  # From step 1

# Network (testnet for testing, mainnet for production)
BNB_NETWORK=testnet

# RPC URLs
BNB_TESTNET_RPC=https://data-seed-prebsc-1-s1.binance.org:8545/
BNB_MAINNET_RPC=https://bsc-dataseed.binance.org/

# Contract address (fill after deployment)
DONATION_CONTRACT_ADDRESS=

# BSCScan API Key (optional, for verification)
BSCSCAN_API_KEY=your_api_key_here
```

### Step 3: Fund Deployer Wallet

Send BNB to your admin wallet address for gas fees:

**Testnet BNB**: Get free testnet BNB from https://testnet.binance.org/faucet-smart

**Mainnet BNB**: You'll need ~0.05 BNB for deployment and initial transactions

---

## Deployment Guide

### Option 1: Deploy with Remix (Recommended for Quick Start)

1. Go to https://remix.ethereum.org

2. Create new file: `DonationContractV2.sol`

3. Paste contract code from `/backend/contracts/DonationContractV2.sol`

4. Compile:
   - Compiler version: `0.8.20` or higher
   - Press `Ctrl+S` or click "Compile"

5. Deploy:
   - Tab: "Deploy & Run Transactions"
   - Environment: "Injected Provider - MetaMask"
   - Make sure MetaMask is connected to BSC Testnet or Mainnet
   - Constructor Parameters:
     ```
     _adminWallet: 0x1234...5678  (your admin wallet address)
     ```
   - Click "Deploy"
   - Confirm transaction in MetaMask

6. Copy contract address after deployment

7. Update `.env`:
   ```env
   DONATION_CONTRACT_ADDRESS=0xYOUR_CONTRACT_ADDRESS_HERE
   ```

### Option 2: Deploy with Hardhat

```bash
# Install Hardhat
npm install --save-dev hardhat @nomicfoundation/hardhat-toolbox

# Initialize Hardhat
npx hardhat init

# Move contract
mv backend/contracts/DonationContractV2.sol contracts/

# Create deployment script
cat > scripts/deploy-donation.js << 'EOF'
async function main() {
  const adminWallet = process.env.DONATION_ADMIN_WALLET;

  const Contract = await ethers.getContractFactory("AGADonationContractV2");
  const contract = await Contract.deploy(adminWallet);
  await contract.waitForDeployment();

  console.log("Contract deployed to:", await contract.getAddress());
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
EOF

# Deploy
npx hardhat run scripts/deploy-donation.js --network bscTestnet
```

### Option 3: Deploy with Foundry

```bash
# Install Foundry
curl -L https://foundry.paradigm.xyz | bash
foundryup

# Deploy
forge create --rpc-url $BNB_TESTNET_RPC \
  --private-key $DONATION_DEPLOYER_PRIVATE_KEY \
  --constructor-args $DONATION_ADMIN_WALLET \
  src/DonationContractV2.sol:AGADonationContractV2
```

### Verify Contract on BSCScan

```bash
# Using Hardhat
npx hardhat verify --network bscMainnet CONTRACT_ADDRESS "ADMIN_WALLET_ADDRESS"

# Or manually on BSCScan
# 1. Go to https://bscscan.com/verifyContract
# 2. Enter contract address
# 3. Select compiler version 0.8.20
# 4. Paste flattened source code
# 5. Add constructor ABI: ["address"]
# 6. Add constructor arguments (admin wallet)
```

---

## API Reference

### Make a Donation

**Endpoint**: `POST /api/funding/donate`

**Request Body**:
```json
{
  "donorId": "user123",
  "donorName": "John Doe",
  "recipientId": "genius456",
  "recipientType": "genius",
  "amount": 25,
  "currency": "USD",
  "message": "Keep up the great work!",
  "isAnonymous": false,
  "paymentMethod": "crypto",
  "paymentToken": "USDT"  // Options: "BNB", "USDT", "USDC", "USD1"
}
```

**Response**:
```json
{
  "success": true,
  "data": {
    "donationId": "abc123...",
    "amount": 25,
    "recipientId": "genius456",
    "paymentStatus": "completed",
    "transactionId": "0x1234...5678"
  },
  "blockchain": {
    "transactionHash": "0x1234...5678",
    "donationId": "0xabcd...ef01",
    "forwardedToAdmin": true,
    "explorer": "https://bscscan.com/tx/0x1234...5678"
  }
}
```

### Get Genius Donations

**Endpoint**: `GET /api/funding/received/:geniusId`

**Response**:
```json
{
  "success": true,
  "data": {
    "donations": [...],
    "total": 1250.50,
    "count": 42
  }
}
```

---

## Testing

### Test with Mock Data (No Blockchain)

If `DONATION_CONTRACT_ADDRESS` is not set, the system automatically returns mock data:

```bash
# Test donation
curl -X POST http://localhost:3000/api/funding/donate \
  -H "Content-Type: application/json" \
  -d '{
    "donorId": "test123",
    "donorName": "Test User",
    "recipientId": "genius456",
    "recipientType": "genius",
    "amount": 10,
    "paymentMethod": "crypto",
    "paymentToken": "USDT"
  }'
```

### Test on Testnet

1. Deploy contract to BSC Testnet
2. Get testnet USDT/USDC from faucets
3. Make test donations
4. Verify on https://testnet.bscscan.com

### Testnet Faucets

- **BNB Testnet**: https://testnet.binance.org/faucet-smart
- **USDT Testnet**: https://testnet.binance.org/faucet-smart (after getting BNB, swap for USDT on testnet DEX)

---

## Security

### Smart Contract Security

✅ **Implemented**:
- Immediate fund forwarding (no funds held in contract)
- Owner-only admin wallet updates
- Input validation on all functions
- Emergency recovery functions
- No reentrancy vulnerabilities (CEI pattern)

### Backend Security

✅ **Implemented**:
- Private keys stored in environment variables
- Fallback to database if blockchain fails
- Transaction hash verification
- Error handling and logging

### Best Practices

1. **Private Key Management**:
   - Never commit `.env` to git
   - Use hardware wallet for mainnet
   - Rotate keys periodically
   - Use multi-sig for admin wallet

2. **Monitoring**:
   - Monitor admin wallet balance
   - Set up alerts for large donations
   - Regular audit of blockchain transactions

3. **Upgrades**:
   - Contract is not upgradeable (immutable)
   - To upgrade, deploy new contract and update `DONATION_CONTRACT_ADDRESS`

---

## Supported Tokens

| Token | Symbol | Decimals | Mainnet Address | Testnet Address |
|-------|--------|----------|----------------|-----------------|
| Binance Coin | BNB | 18 | Native | Native |
| Tether USD | USDT | 18 | 0x55d3...7955 | 0x3376...4dDd |
| USD Coin | USDC | 18 | 0x8AC7...580d | 0x6454...8930 |
| USD1 | USD1 | 18 | 0x5eE8...8D06 | N/A |

---

## Troubleshooting

### "Insufficient allowance" error

The contract needs approval to spend tokens on behalf of the user. This is automatically handled by the blockchain service, but if you see this error:

```javascript
// Manually approve spending
await tokenContract.approve(donationContractAddress, amount);
```

### "Transaction failed" error

Check:
1. User has enough token balance
2. User has enough BNB for gas fees
3. Contract address is correct
4. Network is correct (testnet vs mainnet)

### Admin wallet not receiving funds

Verify:
1. Check transaction on BSCScan - was it successful?
2. Verify admin wallet address in contract: `contract.adminWallet()`
3. Check if funds were actually sent (View transaction details)

---

## Next Steps

1. ✅ Generate admin wallet
2. ✅ Deploy smart contract
3. ✅ Verify contract on BSCScan
4. ✅ Test with small amounts
5. ✅ Integrate frontend UI
6. ✅ Set up monitoring
7. ✅ Go live!

---

## Support

For issues or questions:
- Check BSCScan for transaction details
- Review backend logs
- Test with mock data first
- Verify contract deployment

---

**Built with ❤️ for Africa Genius Alliance**

*Empowering African leaders through transparent, blockchain-based support*
