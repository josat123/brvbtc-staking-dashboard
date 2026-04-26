markdown
# 🚀 BRVBTC Staking Dashboard

[![Deployed on Vercel](https://img.shields.io/badge/Deployed%20on-Vercel-black?logo=vercel&style=for-the-badge)](https://brvbtc-dashboard.vercel.app)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg?style=for-the-badge)](https://opensource.org/licenses/MIT)
[![Built with Next.js](https://img.shields.io/badge/Built%20with-Next.js-black?logo=next.js&style=for-the-badge)](https://nextjs.org)
[![Web3](https://img.shields.io/badge/Web3-RainbowKit-ff69b4?style=for-the-badge&logo=web3.js)](https://rainbowkit.com)
[![Base Chain](https://img.shields.io/badge/Base-Chain-0052FF?style=for-the-badge&logo=coinbase)](https://base.org)
[![Uniswap V4](https://img.shields.io/badge/Uniswap-V4-FF007A?style=for-the-badge&logo=uniswap)](https://uniswap.org)
[![Internal Audit: Passed](https://img.shields.io/badge/Internal%20Audit-Passed-brightgreen?style=for-the-badge)](#)
[![Security Tests: ✅](https://img.shields.io/badge/Security%20Tests-Passing-success?style=for-the-badge)](#)
[![Formal Audit: Pending](https://img.shields.io/badge/Formal%20Audit-Pending-orange?style=for-the-badge)](#)

## 📌 Live Web
**👉 [Staking Page Web](https://brvbtc.com/)**

---

## 💎 What is this?

A **DeFi dashboard** that allows users to stake BRVBTC tokens and earn **real WBTC yield** generated from Uniswap V4 liquidity provider fees.

### 🔄 How it works:
1. Users stake BRVBTC in the smart contract  
2. Protocol provides liquidity to Uniswap V4 BTC-WBTC pools  
3. LP fees are collected in real WBTC  
4. Yield is distributed to stakers automatically  

---

## 🛠️ Tech Stack

| Category | Technologies |
|----------|-------------|
| **Frontend** | Next.js 14 + TypeScript + TailwindCSS |
| **Web3** | RainbowKit + Wagmi + viem |
| **Blockchain** | Ethereum L1 + Polygon L2 |
| **Protocol** | Uniswap V4 (hooks-based liquidity) |

---

## ✨ Features

- ✅ **Stake BRVBTC** with one click
- ✅ **Real-time APR** calculation from actual LP fees
- ✅ **WBTC yield** auto-compounding
- ✅ **Withdraw anytime** (no lockups)
- ✅ **Transparent fee tracking**
- ✅ **Mobile responsive** design
- ✅ **Wallet connect** (MetaMask, WalletConnect, Coinbase)

---

## 📊 Smart Contracts

### Ethereum L1 (Mainnet)

| Contract | Address | Status |
|----------|---------|--------|
| Staking Contract | [`0xd1d82b4b4ab5998954952e4635abf54e10b8b919`](https://etherscan.io/address/0xd1d82b4b4ab5998954952e4635abf54e10b8b919#code) | ✅ Verified |
| BRVBTC Token | [`0x9bc0F4d4B31AdEa0c7Fde6f40a778E4Ce7Bc652d`](https://etherscan.io/token/0x9bc0F4d4B31AdEa0c7Fde6f40a778E4Ce7Bc652d) | ✅ Deployed |
| Bridge | `0xe8681d55585FcDA6a4a39c9a59f39b63fbBa88e8` | ✅ Active |
| Uniswap V4 Pool | Pool ID: `0x9b92d9248bb38aa452c384a8bc228f09fe00b0dd2bab24b23a6c6000731e12c1` | ✅ Active |

### Polygon L2

| Contract | Address | Status |
|----------|---------|--------|
| Staking Contract | [`0x218b9d6c659d3ecff64ebf51710ddcb6c22c35fe`](https://polygonscan.com/address/0x218b9d6c659d3ecff64ebf51710ddcb6c22c35fe#code) | ✅ Verified |
| BRVBTC Token | `0xa5c96d77C280B9F4bA13cd4064C4864Cf69a3BCB` | ✅ Deployed |
| Bridge | `0x0Ef6a63a16fB21dD8398183a154596953Ce4E835` | ✅ Active |
| Uniswap V4 Pool | Pool ID: `0x29cb3f985f71adbe31b3d128449a49a7ce743a9fb0e3d9288077874934dee761` | ✅ Active |

---

## 🔒 Security Status

> 🟡 **Smart contracts are internally audited. Formal audit pending.**  
> 📊 Yield sourced from Uniswap V4 pools (audited)

---

## 📁 Repository Structure
brvbtc-dashboard/
├── app/ # Next.js app router
│ ├── page.tsx # Main dashboard
│ └── layout.tsx # Root layout
├── components/ # React components
│ ├── StakingCard.tsx # Staking UI
│ ├── WalletConnect.tsx# RainbowKit wrapper
│ └── YieldDisplay.tsx # APR & rewards
├── hooks/ # Custom wagmi hooks
│ ├── useStaking.ts
│ └── useYield.ts
├── lib/ # Contract ABIs & configs
│ ├── contracts.ts
│ └── wagmi.ts
├── public/ # Static assets
│ └── logo.png
├── styles/ # Tailwind CSS
│ └── globals.css
├── subgraph/ # Graph protocol indexing
│ └── schema.graphql
└── README.md

text

---

## 🚀 Local Development

```bash
# Clone the repository
git clone https://github.com/josat123/brvbtc-staking-dashboard.git
cd brvbtc-staking-dashboard

# Install dependencies
npm install

# Run development server
npm run dev

# Build for production
npm run build

# Deploy to Vercel
vercel --prod
Environment Variables
Create a .env.local file:

env
NEXT_PUBLIC_WALLET_CONNECT_PROJECT_ID=your_project_id
NEXT_PUBLIC_ALCHEMY_API_KEY=your_alchemy_key
📈 Live Dashboard Preview
text
┌─────────────────────────────────────┐
│   🔗 Wallet: [Connect Wallet]       │
├─────────────────────────────────────┤
│                                     │
│   💎 BRVBTC Staking                 │
│   ┌─────────────────────────────┐   │
│   │ Balance: 1,000 BRVBTC       │   │
│   │ APR: 24.5%                  │   │
│   │ Earned: 0.05 WBTC           │   │
│   │                             │   │
│   │ [Stake]    [Unstake]        │   │
│   └─────────────────────────────┘   │
│                                     │
│   📊 Pool Statistics                │
│   • TVL: $2.5M                      │
│   • Daily Fees: $1,200              │
│   • Total Stakers: 156              │
│                                     │
└─────────────────────────────────────┘
🔗 Important Links
Platform	Link
Live Dashboard	brvbtc-dashboard.vercel.app
Staking Contract (L1)	Etherscan
Staking Contract (L2)	Polygonscan
Uniswap V4 Pool L1	Pool ID 0x9b92...e12c1
Uniswap V4 Pool L2	Pool ID 0x29cb...e761
Documentation	Docs ↗
Report Issue	GitHub Issues
🧪 Testing
bash
# Run unit tests
npm test

# Run end-to-end tests
npm run test:e2e
🤝 Contributing
Fork the repository

Create feature branch (git checkout -b feature/amazing)

Commit changes (git commit -m 'Add amazing feature')

Push (git push origin feature/amazing)

Open Pull Request

📄 License
MIT License – Free for personal and commercial use.

⭐ Support
If you find this project helpful, please give it a ⭐ on GitHub!

Built with ❤️ on Ethereum & Polygon | Report Bug | Request Feature
