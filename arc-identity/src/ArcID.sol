// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

/**
 * @title ArcID
 * @dev Sistema descentralizado de identidade digital com credenciais verificáveis
 */

contract ArcID {
    
    // Tipos de credencial
    enum CredentialType { IDENTITY, EDUCATION, PROFESSIONAL, FINANCIAL }
    enum CredentialStatus { PENDING, VERIFIED, REVOKED }
    
    // Estrutura de credencial
    struct Credential {
        uint256 id;
        address holder;
        address issuer;
        CredentialType credentialType;
        string data; // JSON com dados da credencial
        CredentialStatus status;
        uint256 issuedAt;
        uint256 expiresAt;
        bool revoked;
    }
    
    // Estrutura de perfil de identidade
    struct IdentityProfile {
        address wallet;
        string name;
        string email;
        uint256 reputationScore;
        uint256 credentialCount;
        uint256 verifiedCredentialCount;
        bool active;
        uint256 createdAt;
    }
    
    // Estrutura de verificador
    struct Verifier {
        address wallet;
        string name;
        string specialization;
        uint256 credentialsIssued;
        uint256 reputationScore;
        bool active;
    }
    
    // Mapeamentos
    mapping(address => IdentityProfile) public identities;
    mapping(address => Verifier) public verifiers;
    mapping(uint256 => Credential) public credentials;
    mapping(address => uint256[]) public userCredentials;
    mapping(address => uint256[]) public verifierIssuedCredentials;
    
    uint256 public credentialCounter = 0;
    uint256 public totalIdentities = 0;
    uint256 public totalVerifiers = 0;
    
    // Eventos
    event IdentityCreated(address indexed user, string name);
    event VerifierRegistered(address indexed verifier, string name);
    event CredentialIssued(uint256 indexed credentialId, address indexed holder, address indexed issuer);
    event CredentialVerified(uint256 indexed credentialId);
    event CredentialRevoked(uint256 indexed credentialId);
    event ReputationUpdated(address indexed user, uint256 newScore);
    
    /**
     * @dev Cria uma nova identidade
     */
    function createIdentity(string memory _name, string memory _email) external {
        require(!identities[msg.sender].active, "Identity already exists");
        
        identities[msg.sender] = IdentityProfile({
            wallet: msg.sender,
            name: _name,
            email: _email,
            reputationScore: 0,
            credentialCount: 0,
            verifiedCredentialCount: 0,
            active: true,
            createdAt: block.timestamp
        });
        
        totalIdentities += 1;
        
        emit IdentityCreated(msg.sender, _name);
    }
    
    /**
     * @dev Registra um novo verificador
     */
    function registerVerifier(
        string memory _name,
        string memory _specialization
    ) external {
        require(!verifiers[msg.sender].active, "Verifier already registered");
        
        verifiers[msg.sender] = Verifier({
            wallet: msg.sender,
            name: _name,
            specialization: _specialization,
            credentialsIssued: 0,
            reputationScore: 0,
            active: true
        });
        
        totalVerifiers += 1;
        
        emit VerifierRegistered(msg.sender, _name);
    }
    
    /**
     * @dev Emite uma credencial
     */
    function issueCredential(
        address _holder,
        CredentialType _type,
        string memory _data,
        uint256 _expiresIn
    ) external returns (uint256) {
        require(verifiers[msg.sender].active, "Not a registered verifier");
        require(identities[_holder].active, "Holder identity not found");
        
        uint256 credentialId = credentialCounter++;
        
        credentials[credentialId] = Credential({
            id: credentialId,
            holder: _holder,
            issuer: msg.sender,
            credentialType: _type,
            data: _data,
            status: CredentialStatus.PENDING,
            issuedAt: block.timestamp,
            expiresAt: block.timestamp + _expiresIn,
            revoked: false
        });
        
        userCredentials[_holder].push(credentialId);
        verifierIssuedCredentials[msg.sender].push(credentialId);
        
        identities[_holder].credentialCount += 1;
        verifiers[msg.sender].credentialsIssued += 1;
        
        emit CredentialIssued(credentialId, _holder, msg.sender);
        
        return credentialId;
    }
    
    /**
     * @dev Verifica uma credencial
     */
    function verifyCredential(uint256 _credentialId) external {
        Credential storage credential = credentials[_credentialId];
        require(credential.issuer == msg.sender, "Only issuer can verify");
        require(credential.status == CredentialStatus.PENDING, "Credential already verified");
        
        credential.status = CredentialStatus.VERIFIED;
        
        identities[credential.holder].verifiedCredentialCount += 1;
        
        // Aumentar reputação
        identities[credential.holder].reputationScore += 10;
        verifiers[msg.sender].reputationScore += 5;
        
        emit CredentialVerified(_credentialId);
    }
    
    /**
     * @dev Revoga uma credencial
     */
    function revokeCredential(uint256 _credentialId) external {
        Credential storage credential = credentials[_credentialId];
        require(credential.issuer == msg.sender, "Only issuer can revoke");
        require(!credential.revoked, "Credential already revoked");
        
        credential.revoked = true;
        credential.status = CredentialStatus.REVOKED;
        
        identities[credential.holder].verifiedCredentialCount -= 1;
        identities[credential.holder].reputationScore -= 5;
        
        emit CredentialRevoked(_credentialId);
    }
    
    /**
     * @dev Obtém credenciais de um usuário
     */
    function getUserCredentials(address _user) 
        external 
        view 
        returns (uint256[] memory) 
    {
        return userCredentials[_user];
    }
    
    /**
     * @dev Obtém informações de uma credencial
     */
    function getCredential(uint256 _credentialId) 
        external 
        view 
        returns (Credential memory) 
    {
        return credentials[_credentialId];
    }
    
    /**
     * @dev Obtém perfil de identidade
     */
    function getIdentity(address _user) 
        external 
        view 
        returns (IdentityProfile memory) 
    {
        return identities[_user];
    }
    
    /**
     * @dev Obtém informações de um verificador
     */
    function getVerifier(address _verifier) 
        external 
        view 
        returns (Verifier memory) 
    {
        return verifiers[_verifier];
    }
    
    /**
     * @dev Verifica se uma credencial é válida
     */
    function isCredentialValid(uint256 _credentialId) 
        external 
        view 
        returns (bool) 
    {
        Credential memory credential = credentials[_credentialId];
        return !credential.revoked && 
               credential.status == CredentialStatus.VERIFIED && 
               block.timestamp < credential.expiresAt;
    }
    
    /**
     * @dev Obtém credenciais verificadas de um usuário
     */
    function getVerifiedCredentials(address _user) 
        external 
        view 
        returns (uint256[] memory) 
    {
        uint256[] memory allCredentials = userCredentials[_user];
        uint256 verifiedCount = 0;
        
        // Contar credenciais verificadas
        for (uint256 i = 0; i < allCredentials.length; i++) {
            if (credentials[allCredentials[i]].status == CredentialStatus.VERIFIED &&
                !credentials[allCredentials[i]].revoked) {
                verifiedCount++;
            }
        }
        
        // Criar array com credenciais verificadas
        uint256[] memory verifiedCredentials = new uint256[](verifiedCount);
        uint256 index = 0;
        
        for (uint256 i = 0; i < allCredentials.length; i++) {
            if (credentials[allCredentials[i]].status == CredentialStatus.VERIFIED &&
                !credentials[allCredentials[i]].revoked) {
                verifiedCredentials[index] = allCredentials[i];
                index++;
            }
        }
        
        return verifiedCredentials;
    }
    
    /**
     * @dev Atualiza reputação de um usuário
     */
    function updateReputation(address _user, int256 _change) external {
        require(verifiers[msg.sender].active, "Only verifiers can update reputation");
        
        int256 newScore = int256(identities[_user].reputationScore) + _change;
        require(newScore >= 0, "Reputation cannot be negative");
        
        identities[_user].reputationScore = uint256(newScore);
        
        emit ReputationUpdated(_user, identities[_user].reputationScore);
    }
}
