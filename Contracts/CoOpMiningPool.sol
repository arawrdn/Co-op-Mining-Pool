// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

// Minimal interface for the ERC-20 Reward Token
interface IERC20 {
    function transfer(address to, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

/**
 * @title CoOpMiningPool
 * @dev Mini Co-Op Mining Pool contract using ETH contribution for proportional Token reward distribution (Pull Mechanism).
 */
contract CoOpMiningPool {
    address private immutable i_owner;
    
    // Correct Checksummed Address for the Dummy Reward Token
    IERC20 public immutable rewardToken = IERC20(0xf3CdFBe745595bf8B9055764936329b6C157FD7D);

    // Mappings and State Variables
    mapping(address => uint256) private s_contribution; // ETH contributed
    mapping(address => uint256) private s_rewardsClaimed; // Token rewards already claimed

    uint256 private s_totalContribution; // Total ETH in the pool
    // PERBAIKAN: Menggunakan uint256 (bukan uint255)
    uint256 private s_totalTokenReward;  // Total Token rewards recorded by the owner

    // Events
    event ContributionMade(address indexed participant, uint256 amount);
    event RewardClaimed(address indexed participant, uint256 tokenAmount);
    event DummyRewardRecorded(uint256 tokenAmount);
    event DepositWithdrawn(address indexed participant, uint256 amount);

    constructor() {
        i_owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == i_owner, "Only Owner is allowed");
        _;
    }

    // =================================================================
    // 1. ETH DEPOSIT (CONTRIBUTION) LOGIC
    // =================================================================
    
    function _handleDeposit() internal {
        require(msg.value > 0, "Deposit must be greater than 0 ETH"); 
        
        s_contribution[msg.sender] += msg.value;
        s_totalContribution += msg.value;

        emit ContributionMade(msg.sender, msg.value);
    }

    receive() external payable {
        _handleDeposit();
    }
    
    fallback() external payable {
        _handleDeposit();
    }

    // =================================================================
    // 2. TOKEN REWARD SIMULATION (RECORD)
    // =================================================================

    function recordDummyReward(uint256 _amount) external onlyOwner {
        require(_amount > 0, "Reward amount must be greater than 0");
        
        uint256 tokenBalance = rewardToken.balanceOf(address(this));
        
        require(s_totalTokenReward + _amount <= tokenBalance, "Token reward was not transferred to pool contract");
        
        s_totalTokenReward += _amount;
        
        emit DummyRewardRecorded(_amount);
    }

    // =================================================================
    // 3. REWARD CLAIM & CALCULATION (PULL MECHANISM)
    // =================================================================
    
    function getAvailableReward(address _participant) public view returns (uint256) {
        if (s_totalContribution == 0) {
            return 0;
        }

        uint256 totalPoolReward = s_totalTokenReward;
        
        uint256 individualContribution = s_contribution[_participant];
        uint256 totalRewardShare = (individualContribution * totalPoolReward) / s_totalContribution;

        return totalRewardShare - s_rewardsClaimed[_participant];
    }
    
    function claimReward() external {
        uint256 rewardAmount = getAvailableReward(msg.sender);
        require(rewardAmount > 0, "No available token reward to claim");

        s_rewardsClaimed[msg.sender] += rewardAmount;
        
        bool success = rewardToken.transfer(msg.sender, rewardAmount);
        require(success, "Failed to send Reward Token");

        emit RewardClaimed(msg.sender, rewardAmount);
    }

    // =================================================================
    // 4. ETH DEPOSIT WITHDRAWAL
    // =================================================================

    function withdrawDeposit() external {
        uint256 contributionAmount = s_contribution[msg.sender];
        require(contributionAmount > 0, "No contribution to withdraw");
        
        require(getAvailableReward(msg.sender) == 0, "Claim available rewards first");

        s_contribution[msg.sender] = 0;
        s_totalContribution -= contributionAmount;

        (bool success, ) = payable(msg.sender).call{value: contributionAmount}("");
        require(success, "ETH transfer failed");

        emit DepositWithdrawn(msg.sender, contributionAmount);
    }
    
    // =================================================================
    // 5. VIEW FUNCTIONS
    // =================================================================

    function getParticipantContribution(address _participant) public view returns (uint256) {
        return s_contribution[_participant];
    }

    function getTotalContribution() public view returns (uint256) {
        return s_totalContribution;
    }

    function getTotalTokenReward() public view returns (uint256) {
        return s_totalTokenReward;
    }
    
    function getOwner() public view returns (address) {
        return i_owner;
    }
}
