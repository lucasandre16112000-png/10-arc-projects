# ARC Projects - Decentralized Application Suite

A comprehensive suite of three smart contracts deployed on Arc Layer 2 network, including a freelance marketplace, DeFi protocol, and decentralized identity system.

## ✨ Projects Included

### 1. ArcFreelance - Decentralized Freelance Marketplace
- Freelancer registration and profile management
- Job creation and acceptance workflow
- Secure payment in USDC
- Rating and reputation system
- 5% platform fee

### 2. ArcFinance - DeFi Protocol
- Lending and borrowing functionality
- Liquidity pool management
- Multi-token support
- Yield farming mechanisms
- Risk management features

### 3. ArcIdentity - Decentralized Identity System
- On-chain identity registration
- Verifiable credentials
- Reputation tracking
- Integration with other contracts
- Privacy-preserving design

## 🛠️ Technologies

- **Solidity 0.8.30+**: Smart contract language
- **Foundry**: Modern Ethereum development framework
- **Forge**: Build and test tool
- **Cast**: CLI for contract interaction
- **Anvil**: Local Ethereum node
- **OpenZeppelin**: Security libraries

## 📦 Installation

### Prerequisites
- Foundry (Forge, Cast, Anvil)
- Git
- Node.js 16+ (optional, for frontend)

### Setup Foundry

```bash
curl -L https://foundry.paradigm.xyz | bash
foundryup
```

### Clone Repository

```bash
git clone https://github.com/lucasandre16112000-png/10-arc-projects.git
cd 10-arc-projects
```

## 🚀 Building and Testing

### Build Contracts
```bash
forge build
```

### Run Tests
```bash
forge test
```

### Format Code
```bash
forge fmt
```

### Gas Snapshots
```bash
forge snapshot
```

## 🔧 Local Development

### Start Local Node
```bash
anvil
```

### Deploy to Local Node
```bash
forge script script/Deploy.s.sol:DeployScript --rpc-url http://localhost:8545 --broadcast
```

## 🌐 Deployment

### Deploy to Arc Testnet
```bash
forge script script/Deploy.s.sol:DeployScript \
  --rpc-url <arc_testnet_rpc> \
  --private-key <your_private_key> \
  --broadcast
```

### Deploy to Arc Mainnet
```bash
forge script script/Deploy.s.sol:DeployScript \
  --rpc-url <arc_mainnet_rpc> \
  --private-key <your_private_key> \
  --broadcast \
  --verify
```

## 📊 Contract Addresses

After deployment, contract addresses will be displayed. Store them for future reference.

## 🔐 Security Features

- **Access Control**: Role-based permissions
- **Input Validation**: Comprehensive parameter checking
- **Reentrancy Protection**: Safe external calls
- **Gas Optimization**: Efficient storage and computation
- **Event Logging**: Complete audit trail

## 📁 Project Structure

```
.
├── src/
│   ├── ArcFreelance.sol    # Freelance marketplace
│   ├── ArcFinance.sol      # DeFi protocol
│   └── ArcIdentity.sol     # Identity system
├── script/
│   └── Deploy.s.sol        # Deployment script
├── test/
│   ├── ArcFreelance.t.sol  # Freelance tests
│   ├── ArcFinance.t.sol    # Finance tests
│   └── ArcIdentity.t.sol   # Identity tests
├── lib/
│   └── forge-std/          # Foundry standard library
├── foundry.toml            # Foundry configuration
└── README.md               # This file
```

## 📚 Documentation

Each contract includes:
- NatSpec comments for all functions
- Parameter descriptions
- Return value documentation
- Event documentation

## 🧪 Testing

Run specific contract tests:
```bash
forge test --match-contract ArcFreelance
forge test --match-contract ArcFinance
forge test --match-contract ArcIdentity
```

Run with verbosity:
```bash
forge test -vvv
```

## 🔍 Verification

Verify contracts on Arc explorer:
```bash
forge verify-contract <contract_address> <contract_name> --chain-id <chain_id>
```

## 📄 License

This project is open source and available under the MIT License.

## 👨‍💻 Author

Lucas André - [GitHub](https://github.com/lucasandre16112000-png)

## 🤝 Contributing

Contributions are welcome! Please follow Solidity best practices and include tests for new features.

## ⚠️ Disclaimer

These contracts are provided for educational purposes. Always conduct thorough audits before mainnet deployment.
