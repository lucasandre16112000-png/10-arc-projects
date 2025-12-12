# 🏛️ ARC Projects - Suíte de Aplicações Descentralizadas

Uma suíte completa de três smart contracts implantados na rede Arc Layer 2, incluindo um mercado freelance, um protocolo DeFi e um sistema de identidade descentralizada.

## ✨ Projetos Incluídos

1.  **ArcFreelance**: Mercado freelance descentralizado.
2.  **ArcFinance**: Protocolo DeFi para empréstimos e rendimentos.
3.  **ArcIdentity**: Sistema de identidade descentralizada.

## 🛠️ Tecnologias

- **Solidity 0.8.30+**: Linguagem para smart contracts.
- **Foundry**: Framework de desenvolvimento moderno para Ethereum.
- **OpenZeppelin**: Bibliotecas de segurança.

## 📋 Guia de Instalação e Execução (Para Qualquer Pessoa)

### Pré-requisitos

1.  **Git**: [**Download aqui**](https://git-scm.com/downloads)
2.  **Foundry**: Kit de ferramentas para desenvolvimento em Solidity.
    - Siga as instruções de instalação em [**foundry.paradigm.xyz**](https://foundry.paradigm.xyz/).

### Passo 1: Baixar o Projeto

```bash
git clone https://github.com/lucasandre16112000-png/10-arc-projects.git
cd 10-arc-projects
```

### Passo 2: Compilar os Contratos

```bash
forge build
```

### Passo 3: Executar os Testes

```bash
forge test
```

### Passo 4: Implantar em um Nó Local

- Em um terminal, inicie um nó local:
  ```bash
  anvil
  ```
- Em outro terminal, execute o script de implantação:
  ```bash
  forge script script/Deploy.s.sol:DeployScript --rpc-url http://localhost:8545 --broadcast
  ```

## 👨‍💻 Autor

Lucas André S - [GitHub](https://github.com/lucasandre16112000-png)
