// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;


// Uncomment this line to use console.log
// import "hardhat/console.sol";

import "solmate/src/tokens/ERC20.sol";

contract Staking {
   address jonStaking;
    uint256 factor = 1e11;
    uint256 delta = 3854;
    address BAYC = 0xBC4CA0EdA7647A8aB7C2061c2E118A18a936f13D;

    struct userData{
        uint216 stakedAmount;
        uint40 lastTimeStaked;
    }

    mapping(address => userData) userDatas;

    event Staked(address indexed user, uint216 amount);
    event Withdrawn(address indexed user, uint216 amount);
    event InterestCompounded(address indexed user, uint216 amount);

    constructor(address _jonStaking){
        jonStaking = _jonStaking;
    }


    function stake(uint256 _amount) external {
        assert(ERC20(jonStaking).transferFrom(msg.sender, address(this), _amount));
        userData storage u = userDatas[msg.sender];
        assert(BAYU(BAYC).balanceOf(msg.sender) > 0);

        if(u.stakedAmount > 0){
            uint256 currentRewards = getRewards(msg.sender);
            u.stakedAmount += uint216(currentRewards);
            emit InterestCompounded(msg.sender, uint216(currentRewards));
        }
        //update storage
        u.stakedAmount += uint216(_amount);
        u.lastTimeStaked = uint40(block.timestamp);
        emit Staked(msg.sender, uint216(_amount));
    }


     function unstake(uint256 _amount) external {
        userData storage u = userDatas[msg.sender];
        assert(u.stakedAmount >= _amount);
        uint216 amountToSend = uint216(_amount);
        amountToSend += getRewards(msg.sender);
        //update storage
        u.stakedAmount -= uint216(_amount);
        u.lastTimeStaked = uint40(block.timestamp);
        ERC20(jonStaking).transfer(msg.sender, amountToSend);
        emit Withdrawn(msg.sender, amountToSend);
    }

    function getUser(address _user) public view returns (userData memory u) {
        u = userDatas[_user];
    }


    function getRewards(address _user)
        internal
        view
        returns (uint216 interest__)
    {
        userData memory u = userDatas[_user];
        if (u.stakedAmount > 0) {
            uint216 currentAmount = u.stakedAmount;
            uint40 lastTime = u.lastTimeStaked;
            uint40 duration = uint40(block.timestamp) - lastTime;
            interest__ = uint216(delta * duration * currentAmount);
            interest__ /= uint216(factor);
        }
    }
}

interface BAYU {
    function balanceOf(address owner) external view returns (uint256);
}
