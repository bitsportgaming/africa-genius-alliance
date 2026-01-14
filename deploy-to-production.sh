#!/bin/bash
# AGA Production Deployment Script
# Deploys webapp and backend updates to https://africageniusalliance.com

set -e  # Exit on error

echo "🚀 Starting AGA Production Deployment..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Navigate to home directory
cd /home/charlpagne

# Create backup timestamp
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
echo "📦 Backup timestamp: $TIMESTAMP"

# 1. Backup current deployment
echo ""
echo "📋 Step 1: Creating backups..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Backup webapp
if [ -d "aga-webapp" ]; then
    echo "  Backing up aga-webapp to aga-webapp.backup.$TIMESTAMP"
    cp -r aga-webapp "aga-webapp.backup.$TIMESTAMP"
fi

# Backup backend
if [ -d "aga-backend" ]; then
    echo "  Backing up aga-backend to aga-backend.backup.$TIMESTAMP"
    cp -r aga-backend "aga-backend.backup.$TIMESTAMP"
fi

# 2. Extract updates
echo ""
echo "📦 Step 2: Extracting update package..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if [ -f "aga-complete-update.tar.gz" ]; then
    mkdir -p aga-updates-temp
    tar -xzf aga-complete-update.tar.gz -C aga-updates-temp
    echo "  ✅ Update package extracted"
else
    echo "  ❌ Update package not found!"
    exit 1
fi

# 3. Update WebApp files
echo ""
echo "🌐 Step 3: Updating WebApp..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Copy webapp files
if [ -d "aga-updates-temp/web-app" ]; then
    echo "  Copying explore page..."
    cp aga-updates-temp/web-app/app/explore/page.tsx aga-webapp/app/explore/ || true

    echo "  Copying UI components..."
    cp aga-updates-temp/web-app/components/ui/ShareMenu.tsx aga-webapp/components/ui/ || true
    cp aga-updates-temp/web-app/components/ui/index.ts aga-webapp/components/ui/ || true

    echo "  Copying dashboard components..."
    cp aga-updates-temp/web-app/components/dashboard/SupporterDashboard.tsx aga-webapp/components/dashboard/ || true
    cp aga-updates-temp/web-app/components/dashboard/GeniusDashboard.tsx aga-webapp/components/dashboard/ || true

    echo "  ✅ WebApp files updated"
fi

# 4. Update Backend files
echo ""
echo "⚙️  Step 4: Updating Backend..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if [ -d "aga-updates-temp/backend" ]; then
    echo "  Copying routes..."
    cp aga-updates-temp/backend/routes/funding.js aga-backend/routes/ || true

    echo "  Copying services..."
    mkdir -p aga-backend/services
    cp aga-updates-temp/backend/services/blockchainService.js aga-backend/services/ || true

    echo "  Copying smart contracts..."
    mkdir -p aga-backend/contracts
    cp aga-updates-temp/backend/contracts/*.sol aga-backend/contracts/ || true

    echo "  Copying deployment scripts..."
    mkdir -p aga-backend/scripts
    cp aga-updates-temp/backend/scripts/*.js aga-backend/scripts/ || true

    echo "  Copying documentation..."
    cp aga-updates-temp/backend/DONATION_SYSTEM_README.md aga-backend/ || true
    cp aga-updates-temp/DONATION_IMPLEMENTATION_SUMMARY.md aga-backend/ || true

    echo "  ✅ Backend files updated"
fi

# 5. Rebuild WebApp
echo ""
echo "🔨 Step 5: Rebuilding WebApp..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

cd aga-webapp
echo "  Installing dependencies..."
npm install --legacy-peer-deps

echo "  Building production bundle..."
npm run build

echo "  ✅ WebApp rebuilt successfully"

# 6. Restart services
echo ""
echo "🔄 Step 6: Restarting services..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

cd /home/charlpagne

echo "  Restarting aga-webapp..."
pm2 restart aga-webapp

echo "  Restarting aga-backend..."
pm2 restart aga-backend

echo "  Saving PM2 configuration..."
pm2 save

echo "  ✅ Services restarted"

# 7. Verify deployment
echo ""
echo "✅ Step 7: Verifying deployment..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

sleep 3
pm2 list

echo ""
echo "🎉 Deployment Complete!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "✅ WebApp updated and rebuilt"
echo "✅ Backend updated with donation system"
echo "✅ Services restarted"
echo ""
echo "🌐 Live at: https://africageniusalliance.com"
echo ""
echo "📝 What was deployed:"
echo "  ✓ Voting functionality on Explore page"
echo "  ✓ Share menu with multi-platform support"
echo "  ✓ Donation system with USDT/USDC/USD1/BNB support"
echo "  ✓ Blockchain integration for donations"
echo "  ✓ Updated dashboard components"
echo ""
echo "⚠️  Next steps for donation system:"
echo "  1. Generate admin wallet: node aga-backend/scripts/generateAdminWallet.js"
echo "  2. Update .env with wallet details"
echo "  3. Deploy smart contract to BNB Chain"
echo "  4. Add contract address to .env"
echo ""
echo "💾 Backups created:"
echo "  📁 aga-webapp.backup.$TIMESTAMP"
echo "  📁 aga-backend.backup.$TIMESTAMP"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
