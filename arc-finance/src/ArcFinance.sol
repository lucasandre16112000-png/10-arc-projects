// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

/**
 * @title ArcFinance
 * @dev Dashboard de finanças pessoais para rastrear receitas e despesas em stablecoins
 */

contract ArcFinance {
    
    // Tipos de transação
    enum TransactionType { INCOME, EXPENSE }
    
    // Estrutura de transação
    struct Transaction {
        uint256 id;
        TransactionType transactionType;
        string category;
        uint256 amount;
        string description;
        uint256 timestamp;
    }
    
    // Estrutura de resumo mensal
    struct MonthlySummary {
        uint256 month;
        uint256 totalIncome;
        uint256 totalExpense;
        uint256 balance;
    }
    
    // Mapeamentos
    mapping(address => Transaction[]) public userTransactions;
    mapping(address => MonthlySummary[]) public userMonthlySummaries;
    mapping(address => uint256) public userTotalIncome;
    mapping(address => uint256) public userTotalExpense;
    mapping(address => uint256) public userBalance;
    mapping(address => bool) public registeredUsers;
    
    uint256 public totalUsers = 0;
    
    // Eventos
    event TransactionRecorded(
        address indexed user,
        uint256 indexed transactionId,
        TransactionType transactionType,
        uint256 amount,
        string category
    );
    event UserRegistered(address indexed user);
    event MonthlySummaryUpdated(address indexed user, uint256 month, uint256 balance);
    
    /**
     * @dev Registra um novo usuário
     */
    function registerUser() external {
        require(!registeredUsers[msg.sender], "User already registered");
        
        registeredUsers[msg.sender] = true;
        totalUsers += 1;
        
        emit UserRegistered(msg.sender);
    }
    
    /**
     * @dev Registra uma receita
     */
    function recordIncome(
        uint256 _amount,
        string memory _category,
        string memory _description
    ) external {
        require(registeredUsers[msg.sender], "User not registered");
        require(_amount > 0, "Amount must be greater than 0");
        
        uint256 transactionId = userTransactions[msg.sender].length;
        
        userTransactions[msg.sender].push(Transaction({
            id: transactionId,
            transactionType: TransactionType.INCOME,
            category: _category,
            amount: _amount,
            description: _description,
            timestamp: block.timestamp
        }));
        
        userTotalIncome[msg.sender] += _amount;
        userBalance[msg.sender] += _amount;
        
        emit TransactionRecorded(
            msg.sender,
            transactionId,
            TransactionType.INCOME,
            _amount,
            _category
        );
    }
    
    /**
     * @dev Registra uma despesa
     */
    function recordExpense(
        uint256 _amount,
        string memory _category,
        string memory _description
    ) external {
        require(registeredUsers[msg.sender], "User not registered");
        require(_amount > 0, "Amount must be greater than 0");
        require(userBalance[msg.sender] >= _amount, "Insufficient balance");
        
        uint256 transactionId = userTransactions[msg.sender].length;
        
        userTransactions[msg.sender].push(Transaction({
            id: transactionId,
            transactionType: TransactionType.EXPENSE,
            category: _category,
            amount: _amount,
            description: _description,
            timestamp: block.timestamp
        }));
        
        userTotalExpense[msg.sender] += _amount;
        userBalance[msg.sender] -= _amount;
        
        emit TransactionRecorded(
            msg.sender,
            transactionId,
            TransactionType.EXPENSE,
            _amount,
            _category
        );
    }
    
    /**
     * @dev Obtém todas as transações de um usuário
     */
    function getUserTransactions(address _user) 
        external 
        view 
        returns (Transaction[] memory) 
    {
        return userTransactions[_user];
    }
    
    /**
     * @dev Obtém o número de transações de um usuário
     */
    function getUserTransactionCount(address _user) 
        external 
        view 
        returns (uint256) 
    {
        return userTransactions[_user].length;
    }
    
    /**
     * @dev Obtém uma transação específica
     */
    function getTransaction(address _user, uint256 _transactionId) 
        external 
        view 
        returns (Transaction memory) 
    {
        require(_transactionId < userTransactions[_user].length, "Transaction not found");
        return userTransactions[_user][_transactionId];
    }
    
    /**
     * @dev Obtém resumo financeiro de um usuário
     */
    function getFinancialSummary(address _user) 
        external 
        view 
        returns (
            uint256 totalIncome,
            uint256 totalExpense,
            uint256 balance,
            uint256 transactionCount
        ) 
    {
        return (
            userTotalIncome[_user],
            userTotalExpense[_user],
            userBalance[_user],
            userTransactions[_user].length
        );
    }
    
    /**
     * @dev Calcula a taxa de poupança
     */
    function getSavingsRate(address _user) 
        external 
        view 
        returns (uint256) 
    {
        uint256 totalIncome = userTotalIncome[_user];
        if (totalIncome == 0) return 0;
        
        return ((totalIncome - userTotalExpense[_user]) * 100) / totalIncome;
    }
    
    /**
     * @dev Obtém transações de um mês específico
     */
    function getMonthlyTransactions(address _user, uint256 _month) 
        external 
        view 
        returns (Transaction[] memory) 
    {
        Transaction[] memory allTransactions = userTransactions[_user];
        uint256 count = 0;
        
        // Contar transações do mês
        for (uint256 i = 0; i < allTransactions.length; i++) {
            uint256 txMonth = (allTransactions[i].timestamp / 2592000) % 12;
            if (txMonth == _month) {
                count++;
            }
        }
        
        // Criar array com transações do mês
        Transaction[] memory monthlyTransactions = new Transaction[](count);
        uint256 index = 0;
        
        for (uint256 i = 0; i < allTransactions.length; i++) {
            uint256 txMonth = (allTransactions[i].timestamp / 2592000) % 12;
            if (txMonth == _month) {
                monthlyTransactions[index] = allTransactions[i];
                index++;
            }
        }
        
        return monthlyTransactions;
    }
    
    /**
     * @dev Obtém estatísticas por categoria
     */
    function getCategoryStats(address _user, string memory _category) 
        external 
        view 
        returns (uint256 income, uint256 expense) 
    {
        Transaction[] memory transactions = userTransactions[_user];
        
        for (uint256 i = 0; i < transactions.length; i++) {
            if (keccak256(abi.encodePacked(transactions[i].category)) == 
                keccak256(abi.encodePacked(_category))) {
                
                if (transactions[i].transactionType == TransactionType.INCOME) {
                    income += transactions[i].amount;
                } else {
                    expense += transactions[i].amount;
                }
            }
        }
    }
}
