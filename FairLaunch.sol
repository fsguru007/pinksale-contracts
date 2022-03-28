// SPDX-License-Identifier: GPL-3.0-or-later Or MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "./IPancakeRouter02.sol";

interface IPancakeFactory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
}

interface ILauncher {
    function routers(uint _id) external view returns (address);
}

struct TeamVesting {
    uint total;
    uint firstReleaseDelay;
    uint firstRelease;
    uint cycle;
    uint cycleRelease;
}

struct FairlaunchData {
    address token;
    uint tokenAmount;
    uint softcap;
    uint pcs_liquidity;
    uint start_time;
    uint end_time;
    uint unlock_time;
    string logo_link;
    string description;
    string metadata;
    address creator;
    address feeAddress;
    uint feeBnbPortion;
    uint feeTokenPortion;
    uint8 router;
    bool teamVesting;
    TeamVesting teamVestingData;
}

contract ReentranceGuard {
    bool private _ENTERED;

    modifier noReentrance() {
        require (!_ENTERED, "No re-entrance");
        _ENTERED = true;
        _;
        _ENTERED = false;
    }
}

contract FairLaunch is Ownable, ReentranceGuard {

    mapping(address => uint) public contributes;
    uint public collected = 0;
    uint tokenDecimals;
    address public pcsRouter = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    mapping(address => uint) private userClaims;

    uint claimedTeamVesting = 0;
    uint finishedTime = 0;
    bool finished = false;
    
    FairlaunchData launchData;

    constructor(FairlaunchData memory _launch, address _router) {
        launchData = _launch;
        pcsRouter = _router;
        
        tokenDecimals = IERC20Metadata(launchData.token).decimals();
    }

    modifier onlyCreator() {
        require (msg.sender == launchData.creator, "Access denied");
        _;
    }
    
    receive() external payable {
        _contribute(msg.sender, msg.value);
    }

    function setMetaData(string memory logo_link, string memory description, string memory others) external onlyCreator {
        launchData.logo_link = logo_link;
        launchData.description = description;
        launchData.metadata = others;
    }

    function contribute() payable external {
        _contribute(msg.sender, msg.value);
    }
    
    function _contribute(address user, uint amount) internal {
        require (block.timestamp >= launchData.start_time, "Presale is not started yet");
        require (block.timestamp <= launchData.end_time, "Presale already ended");

        collected += amount;
        contributes[user] = amount;
    }

    function claim() external noReentrance {
        require (contributes[msg.sender] > 0, "You have no contributes");
        require (finished, "The presale is still active");
        require (collected >= launchData.softcap, "The presale failed");

        uint amount = contributes[msg.sender] * launchData.tokenAmount / collected;

        require (amount > userClaims[msg.sender], "You claimed all");

        IERC20(launchData.token).transfer(msg.sender, amount - userClaims[msg.sender]);
        userClaims[msg.sender] = amount;
    }

    function withdraw() external noReentrance {
        require (contributes[msg.sender] > 0, "You have not contributed");
        require (block.timestamp >= launchData.end_time, "The presale is still active");
        require (collected < launchData.softcap, "You cannot withdraw now. Claim your tokens instead");

        payable(msg.sender).transfer(contributes[msg.sender]);
        contributes[msg.sender] = 0;
    }

    function finalize() external onlyCreator {
        require (collected >= launchData.softcap, "Presale failed or not ended yet");
        
        uint feeBnb = collected * launchData.feeBnbPortion / 10000;
        uint bnbAmountToLock = (collected - feeBnb) * launchData.pcs_liquidity / 100;

        uint tokenAmount = launchData.tokenAmount * launchData.pcs_liquidity / 100;

        lockLP(bnbAmountToLock, tokenAmount);

        payable(launchData.feeAddress).transfer(feeBnb);

        if (launchData.pcs_liquidity < 100) {
            payable(launchData.creator).transfer(collected - bnbAmountToLock - feeBnb);
        }
        
        IERC20(launchData.token).transferFrom(address(this), launchData.feeAddress, launchData.tokenAmount * launchData.feeTokenPortion / 10000);

        finished = true;
        finishedTime = block.timestamp;

    }

    function lockLP(uint bnbAmount, uint tokenAmount) internal {

        IERC20(launchData.token).approve(address(pcsRouter), tokenAmount);

        IPancakeRouter02(pcsRouter).addLiquidityETH{value: bnbAmount}(
            launchData.token,
            tokenAmount,
            0,
            0,
            address(this),
            block.timestamp
        );
    }
    
    function getFairlaunchData() view public returns(FairlaunchData memory) {
        return launchData;
    }

    function claimTeamVesting(address to) external onlyCreator {
        require (finished, "The presale is not finished");
        require (claimedTeamVesting < launchData.teamVestingData.total, "All claimed");

        uint firstReleaseTime = finishedTime + launchData.teamVestingData.firstReleaseDelay;

        require (block.timestamp >= firstReleaseTime, "You can't claim yet");

        uint cycleRelease = launchData.teamVestingData.total * launchData.teamVestingData.cycleRelease / 100;

        uint claimableAmount = launchData.teamVestingData.total * launchData.teamVestingData.firstRelease / 100 + (block.timestamp - firstReleaseTime) / launchData.teamVestingData.cycle * cycleRelease - claimedTeamVesting;

        if (claimableAmount + claimedTeamVesting > launchData.teamVestingData.total) {
            claimableAmount = launchData.teamVestingData.total - claimedTeamVesting;
        }

        claimedTeamVesting += claimableAmount;

        IERC20(launchData.token).transfer(payable(to), claimableAmount);
    }
}
