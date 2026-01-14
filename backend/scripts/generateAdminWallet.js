/**
 * Generate Admin Wallet for AGA Donation System
 * This script creates a new Ethereum wallet to receive all donations
 */

const { ethers } = require('ethers');
const fs = require('fs');
const path = require('path');

async function generateAdminWallet() {
    console.log('🔐 Generating AGA Admin Wallet...\n');

    // Create a random wallet
    const wallet = ethers.Wallet.createRandom();

    const walletInfo = {
        address: wallet.address,
        privateKey: wallet.privateKey,
        mnemonic: wallet.mnemonic.phrase,
        createdAt: new Date().toISOString(),
        purpose: 'AGA Donation Admin Wallet',
        network: 'BNB Smart Chain (BSC)',
        note: 'This wallet receives all donations made to Geniuses. Keep the private key and mnemonic EXTREMELY SECURE.'
    };

    // Display wallet information
    console.log('✅ Wallet Generated Successfully!\n');
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    console.log('📍 WALLET ADDRESS:');
    console.log(`   ${walletInfo.address}`);
    console.log('');
    console.log('🔑 PRIVATE KEY:');
    console.log(`   ${walletInfo.privateKey}`);
    console.log('');
    console.log('🗝️  MNEMONIC PHRASE (24 words):');
    console.log(`   ${walletInfo.mnemonic}`);
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

    console.log('⚠️  CRITICAL SECURITY WARNINGS:');
    console.log('   1. NEVER share the private key or mnemonic with anyone');
    console.log('   2. Store them in a secure password manager or hardware wallet');
    console.log('   3. Make multiple encrypted backups in different locations');
    console.log('   4. This wallet will receive ALL donations - protect it accordingly');
    console.log('   5. Consider using a hardware wallet for production\n');

    // Save to secure file (should be added to .gitignore)
    const secureDir = path.join(__dirname, '..', 'secure');
    if (!fs.existsSync(secureDir)) {
        fs.mkdirSync(secureDir, { recursive: true });
    }

    const walletFilePath = path.join(secureDir, 'admin-wallet.json');
    fs.writeFileSync(walletFilePath, JSON.stringify(walletInfo, null, 2));

    console.log(`💾 Wallet information saved to: ${walletFilePath}`);
    console.log('   ⚠️  Add /backend/secure/ to .gitignore immediately!\n');

    // Create .env template
    const envTemplate = `
# AGA Donation Admin Wallet Configuration
# Add these to your .env file (DO NOT commit .env to git)

# Admin wallet address (receives all donations)
DONATION_ADMIN_WALLET=${walletInfo.address}

# Deployer private key (for deploying the contract)
DONATION_DEPLOYER_PRIVATE_KEY=${walletInfo.privateKey}

# Network configuration
BNB_NETWORK=testnet
# For mainnet, change to: BNB_NETWORK=mainnet

# RPC URLs
BNB_TESTNET_RPC=https://data-seed-prebsc-1-s1.binance.org:8545/
BNB_MAINNET_RPC=https://bsc-dataseed.binance.org/

# BSCScan API Key (for contract verification)
BSCSCAN_API_KEY=your_bscscan_api_key_here
`;

    const envTemplatePath = path.join(secureDir, '.env.template');
    fs.writeFileSync(envTemplatePath, envTemplate);

    console.log(`📝 .env template created at: ${envTemplatePath}`);
    console.log('   Copy these values to your .env file\n');

    // Create .gitignore for secure directory
    const gitignorePath = path.join(secureDir, '.gitignore');
    fs.writeFileSync(gitignorePath, '*\n!.gitignore\n');

    console.log('✅ Setup complete!\n');
    console.log('📋 Next Steps:');
    console.log('   1. Backup the wallet information securely');
    console.log('   2. Add the values from .env.template to your main .env file');
    console.log('   3. Add /backend/secure/ to your main .gitignore');
    console.log('   4. Fund the wallet with BNB for gas fees (testnet or mainnet)');
    console.log('   5. Run the contract deployment script\n');

    return walletInfo;
}

// Run the script
if (require.main === module) {
    generateAdminWallet()
        .then(() => process.exit(0))
        .catch(error => {
            console.error('❌ Error generating wallet:', error);
            process.exit(1);
        });
}

module.exports = { generateAdminWallet };
