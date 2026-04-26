// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract BRVBTCStaking is ReentrancyGuard, Ownable {
    using SafeERC20 for IERC20;

    IERC20 public immutable BRV;
    IERC20 public immutable WBTC;

    uint256 public constant PRECISION = 1e18;
    uint256 public constant MIN_LOCK_DAYS = 1;
    uint256 public constant MAX_LOCK_DAYS = 365;
    uint256 public constant MIN_REWARD_ADD = 1e4;
    uint256 public constant DEFAULT_REWARD_COOLDOWN = 1 hours;

    uint256 public totalStaked;
    uint256 public totalVirtualStaked;
    uint256 public accRewardPerShare;

    uint256 public performanceFee;
    uint256 public rewardCooldown;

    struct User {
        uint256 amount;
        uint256 virtualAmount;
        uint256 rewardDebt;
        uint256 lockUntil;
        uint256 lastDepositTime;
    }

    mapping(address => User) public users;

    event Deposited(address indexed user, uint256 amount, uint256 lockDays, uint256 lockUntil, uint256 multiplier);
    event Withdrawn(address indexed user, uint256 amount);
    event Claimed(address indexed user, uint256 reward, uint256 fee);
    event EmergencyWithdrawn(address indexed user, uint256 amount);
    event RewardAdded(address indexed from, uint256 amount, uint256 newAccRewardPerShare);
    event PerformanceFeeUpdated(uint256 oldFee, uint256 newFee);
    event RewardCooldownUpdated(uint256 oldCooldown, uint256 newCooldown);
    event Swept(address indexed token, address indexed to, uint256 amount);

    modifier onlyWhenUnlocked(address _user) {
        User memory user = users[_user];
        require(user.lockUntil <= block.timestamp, "account locked");
        _;
    }

    constructor(address _brv, address _wbtc) Ownable(msg.sender) {
        require(_brv != address(0) && _wbtc != address(0), "zero address");
        BRV = IERC20(_brv);
        WBTC = IERC20(_wbtc);
        performanceFee = 5e16;
        rewardCooldown = DEFAULT_REWARD_COOLDOWN;
    }

    function _getMultiplier(uint256 lockDays) private pure returns (uint256) {
        if (lockDays == 0) return 1e18;
        return 1e18 + (lockDays * 5e15);
    }

    function _pendingReward(address _user) private view returns (uint256) {
        User memory user = users[_user];
        if (user.virtualAmount == 0) return 0;
        uint256 accumulated = (user.virtualAmount * accRewardPerShare) / PRECISION;
        if (accumulated <= user.rewardDebt) return 0;
        return accumulated - user.rewardDebt;
    }

    function _updateReward(address _user) private returns (uint256 pendingGross) {
        User storage user = users[_user];
        uint256 accumulated = (user.virtualAmount * accRewardPerShare) / PRECISION;
        if (accumulated > user.rewardDebt) {
            pendingGross = accumulated - user.rewardDebt;
            user.rewardDebt = accumulated;
        } else {
            pendingGross = 0;
        }
    }

    function _isRewardReady(address _user) private view returns (bool) {
        return users[_user].lastDepositTime + rewardCooldown <= block.timestamp;
    }

    function _claimReward(address _user) private {
        uint256 pendingGross = _updateReward(_user);
        if (pendingGross == 0) return;
        if (!_isRewardReady(_user)) return;
        uint256 fee = (pendingGross * performanceFee) / PRECISION;
        uint256 net = pendingGross - fee;
        if (net > 0) {
            WBTC.safeTransfer(_user, net);
        }
        if (fee > 0) {
            WBTC.safeTransfer(owner(), fee);
        }
        emit Claimed(_user, net, fee);
    }

    function deposit(uint256 amount, uint256 lockDays) external nonReentrant {
        require(amount > 0, "zero amount");
        require(lockDays <= MAX_LOCK_DAYS, "lock too long");
        require(lockDays == 0 || lockDays >= MIN_LOCK_DAYS, "lock too short");
        User storage user = users[msg.sender];
        _claimReward(msg.sender);
        BRV.safeTransferFrom(msg.sender, address(this), amount);
        uint256 multiplier = _getMultiplier(lockDays);
        uint256 addVirtual = (amount * multiplier) / PRECISION;
        uint256 newLockUntil = 0;
        if (lockDays > 0) {
            newLockUntil = block.timestamp + (lockDays * 1 days);
            if (user.lockUntil > block.timestamp && user.lockUntil > newLockUntil) {
                newLockUntil = user.lockUntil;
            }
        }
        user.amount += amount;
        user.virtualAmount += addVirtual;
        user.lockUntil = newLockUntil;
        user.lastDepositTime = block.timestamp;
        totalStaked += amount;
        totalVirtualStaked += addVirtual;
        user.rewardDebt = (user.virtualAmount * accRewardPerShare) / PRECISION;
        emit Deposited(msg.sender, amount, lockDays, newLockUntil, multiplier);
    }

    function withdraw(uint256 amount) external nonReentrant onlyWhenUnlocked(msg.sender) {
        User storage user = users[msg.sender];
        require(user.amount >= amount, "insufficient balance");
        _claimReward(msg.sender);
        uint256 virtualToRemove = (user.virtualAmount * amount) / user.amount;
        user.amount -= amount;
        user.virtualAmount -= virtualToRemove;
        totalStaked -= amount;
        totalVirtualStaked -= virtualToRemove;
        BRV.safeTransfer(msg.sender, amount);
        user.rewardDebt = (user.virtualAmount * accRewardPerShare) / PRECISION;
        emit Withdrawn(msg.sender, amount);
    }

    function claim() external nonReentrant onlyWhenUnlocked(msg.sender) {
        _claimReward(msg.sender);
    }

    function emergencyWithdraw() external nonReentrant {
        User storage user = users[msg.sender];
        uint256 amount = user.amount;
        require(amount > 0, "nothing to withdraw");
        totalStaked -= amount;
        totalVirtualStaked -= user.virtualAmount;
        user.amount = 0;
        user.virtualAmount = 0;
        user.rewardDebt = 0;
        user.lockUntil = 0;
        BRV.safeTransfer(msg.sender, amount);
        emit EmergencyWithdrawn(msg.sender, amount);
    }

    function addReward(uint256 amount) external nonReentrant {
        require(amount > 0, "zero amount");
        require(totalVirtualStaked > 0, "no stakers");
        require(amount >= MIN_REWARD_ADD, "reward too small");
        WBTC.safeTransferFrom(msg.sender, address(this), amount);
        uint256 rewardPerShare = (amount * PRECISION) / totalVirtualStaked;
        accRewardPerShare += rewardPerShare;
        emit RewardAdded(msg.sender, amount, accRewardPerShare);
    }

    function pendingReward(address _user) external view returns (uint256) {
        User memory user = users[_user];
        if (user.virtualAmount == 0) return 0;
        uint256 accumulated = (user.virtualAmount * accRewardPerShare) / PRECISION;
        if (accumulated <= user.rewardDebt) return 0;
        uint256 gross = accumulated - user.rewardDebt;
        if (!_isRewardReady(_user)) return 0;
        uint256 fee = (gross * performanceFee) / PRECISION;
        return gross - fee;
    }

    function getUserInfo(address _user) external view returns (uint256 amount, uint256 virtualAmount, uint256 lockUntil, uint256 multiplier, uint256 lastDepositTime) {
        User memory user = users[_user];
        amount = user.amount;
        virtualAmount = user.virtualAmount;
        lockUntil = user.lockUntil;
        lastDepositTime = user.lastDepositTime;
        if (amount > 0) {
            multiplier = (virtualAmount * PRECISION) / amount;
        } else {
            multiplier = 1e18;
        }
    }

    function setPerformanceFee(uint256 newFee) external onlyOwner {
        require(newFee <= 2e17, "fee max 20%");
        uint256 old = performanceFee;
        performanceFee = newFee;
        emit PerformanceFeeUpdated(old, newFee);
    }

    function setRewardCooldown(uint256 newCooldown) external onlyOwner {
        require(newCooldown <= 7 days, "cooldown too high");
        uint256 old = rewardCooldown;
        rewardCooldown = newCooldown;
        emit RewardCooldownUpdated(old, newCooldown);
    }

    function sweep(IERC20 _token, address _to, uint256 _amount) external onlyOwner {
        require(_to != address(0), "invalid address");
        require(address(_token) != address(BRV) && address(_token) != address(WBTC), "cannot sweep staking tokens");
        _token.safeTransfer(_to, _amount);
        emit Swept(address(_token), _to, _amount);
    }
}
