// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

/**
 * @title ArcFreelance
 * @dev Marketplace descentralizado para freelancers na rede Arc
 * Permite que freelancers ofereçam serviços e recebam pagamento em USDC
 */

interface IERC20 {
    function transfer(address to, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

contract ArcFreelance {
    // USDC token address na Arc testnet
    address public constant USDC = 0x1C7D4b196cb0C6F48759E0E99Ff9Fbc3122Bf86d;
    
    // Estados dos trabalhos
    enum JobStatus { OPEN, ACCEPTED, COMPLETED, PAID, CANCELLED }
    
    // Estrutura de um trabalho
    struct Job {
        uint256 id;
        address client;
        address freelancer;
        string title;
        string description;
        uint256 budget;
        JobStatus status;
        uint256 createdAt;
        uint256 completedAt;
    }
    
    // Estrutura de perfil de freelancer
    struct FreelancerProfile {
        address wallet;
        string name;
        string skills;
        uint256 totalEarnings;
        uint256 jobsCompleted;
        uint256 rating;
        bool active;
    }
    
    // Mapeamentos
    mapping(uint256 => Job) public jobs;
    mapping(address => FreelancerProfile) public freelancers;
    mapping(address => uint256[]) public freelancerJobs;
    mapping(address => uint256[]) public clientJobs;
    
    uint256 public jobCounter = 0;
    uint256 public platformFee = 5; // 5% fee
    uint256 public totalVolume = 0;
    
    // Eventos
    event JobCreated(uint256 indexed jobId, address indexed client, uint256 budget);
    event JobAccepted(uint256 indexed jobId, address indexed freelancer);
    event JobCompleted(uint256 indexed jobId);
    event JobPaid(uint256 indexed jobId, uint256 amount);
    event FreelancerRegistered(address indexed freelancer, string name);
    event RatingUpdated(address indexed freelancer, uint256 newRating);
    
    // Modificadores
    modifier onlyJobClient(uint256 _jobId) {
        require(jobs[_jobId].client == msg.sender, "Only job client can call this");
        _;
    }
    
    modifier onlyFreelancer(uint256 _jobId) {
        require(jobs[_jobId].freelancer == msg.sender, "Only assigned freelancer can call this");
        _;
    }
    
    /**
     * @dev Registra um novo freelancer
     */
    function registerFreelancer(string memory _name, string memory _skills) external {
        require(!freelancers[msg.sender].active, "Already registered");
        
        freelancers[msg.sender] = FreelancerProfile({
            wallet: msg.sender,
            name: _name,
            skills: _skills,
            totalEarnings: 0,
            jobsCompleted: 0,
            rating: 0,
            active: true
        });
        
        emit FreelancerRegistered(msg.sender, _name);
    }
    
    /**
     * @dev Cria um novo trabalho
     */
    function createJob(
        string memory _title,
        string memory _description,
        uint256 _budget
    ) external returns (uint256) {
        require(_budget > 0, "Budget must be greater than 0");
        require(
            IERC20(USDC).transferFrom(msg.sender, address(this), _budget),
            "USDC transfer failed"
        );
        
        uint256 jobId = jobCounter++;
        
        jobs[jobId] = Job({
            id: jobId,
            client: msg.sender,
            freelancer: address(0),
            title: _title,
            description: _description,
            budget: _budget,
            status: JobStatus.OPEN,
            createdAt: block.timestamp,
            completedAt: 0
        });
        
        clientJobs[msg.sender].push(jobId);
        totalVolume += _budget;
        
        emit JobCreated(jobId, msg.sender, _budget);
        return jobId;
    }
    
    /**
     * @dev Freelancer aceita um trabalho
     */
    function acceptJob(uint256 _jobId) external {
        Job storage job = jobs[_jobId];
        require(job.status == JobStatus.OPEN, "Job is not open");
        require(freelancers[msg.sender].active, "Not a registered freelancer");
        
        job.freelancer = msg.sender;
        job.status = JobStatus.ACCEPTED;
        
        freelancerJobs[msg.sender].push(_jobId);
        
        emit JobAccepted(_jobId, msg.sender);
    }
    
    /**
     * @dev Freelancer marca trabalho como completo
     */
    function completeJob(uint256 _jobId) external onlyFreelancer(_jobId) {
        Job storage job = jobs[_jobId];
        require(job.status == JobStatus.ACCEPTED, "Job is not accepted");
        
        job.status = JobStatus.COMPLETED;
        job.completedAt = block.timestamp;
        
        emit JobCompleted(_jobId);
    }
    
    /**
     * @dev Cliente paga o freelancer
     */
    function payFreelancer(uint256 _jobId) external onlyJobClient(_jobId) {
        Job storage job = jobs[_jobId];
        require(job.status == JobStatus.COMPLETED, "Job is not completed");
        
        uint256 fee = (job.budget * platformFee) / 100;
        uint256 freelancerAmount = job.budget - fee;
        
        job.status = JobStatus.PAID;
        
        // Transferir para freelancer
        require(
            IERC20(USDC).transfer(job.freelancer, freelancerAmount),
            "Payment transfer failed"
        );
        
        // Atualizar perfil do freelancer
        freelancers[job.freelancer].totalEarnings += freelancerAmount;
        freelancers[job.freelancer].jobsCompleted += 1;
        
        emit JobPaid(_jobId, freelancerAmount);
    }
    
    /**
     * @dev Avalia um freelancer
     */
    function rateFreelancer(address _freelancer, uint256 _rating) external {
        require(_rating >= 1 && _rating <= 5, "Rating must be between 1 and 5");
        require(freelancers[_freelancer].active, "Freelancer not found");
        
        // Simples média (em produção seria mais sofisticado)
        uint256 currentRating = freelancers[_freelancer].rating;
        freelancers[_freelancer].rating = (currentRating + _rating) / 2;
        
        emit RatingUpdated(_freelancer, freelancers[_freelancer].rating);
    }
    
    /**
     * @dev Obtém informações de um trabalho
     */
    function getJob(uint256 _jobId) external view returns (Job memory) {
        return jobs[_jobId];
    }
    
    /**
     * @dev Obtém perfil de um freelancer
     */
    function getFreelancer(address _freelancer) external view returns (FreelancerProfile memory) {
        return freelancers[_freelancer];
    }
    
    /**
     * @dev Obtém trabalhos de um cliente
     */
    function getClientJobs(address _client) external view returns (uint256[] memory) {
        return clientJobs[_client];
    }
    
    /**
     * @dev Obtém trabalhos de um freelancer
     */
    function getFreelancerJobs(address _freelancer) external view returns (uint256[] memory) {
        return freelancerJobs[_freelancer];
    }
}
