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

struct PresaleVesting {
    uint8 firstRelease;
    uint8 cycle;
    uint8 cycleRelease;
}

struct TeamVesting {
    uint total;
    uint8 firstReleaseDelay;
    uint8 firstRelease;
    uint8 cycle;
    uint8 cycleRelease;
}

struct PresaleData {
    address token;
    uint presale_rate;
    uint softcap;
    uint hardcap;
    uint min;
    uint max;
    uint pcs_liquidity;
    uint pcs_rate;
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
    bool whitelist;
    uint8 refundType;
    uint8 router;
    bool presaleVesting;
    PresaleVesting presaleVestingData;
    bool teamVesting;
    TeamVesting teamVestingData;
}

contract Presale is Ownable {

    mapping(address => uint) public contributes;
    uint public collected = 0;
    uint tokenDecimals;
    address public pcsRouter = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    mapping(address => bool) public whitelisted;
    
    PresaleData presaleData;

    constructor(PresaleData memory _presale, address _router) {
        presaleData = _presale;
        pcsRouter = _router;
        
        tokenDecimals = IERC20Metadata(presaleData.token).decimals();
    }

    modifier onlyCreator() {
        require (msg.sender == presaleData.creator, "Access denied");
        _;
    }
    
    receive() external payable {
        _contribute(msg.sender, msg.value);
    }

    function setMetaData(string memory logo_link, string memory description, string memory others) external onlyCreator {
        presaleData.logo_link = logo_link;
        presaleData.description = description;
        presaleData.metadata = others;
    }

    function contribute() payable external {
        _contribute(msg.sender, msg.value);
    }
    
    function _contribute(address user, uint amount) internal {
        require (amount >= presaleData.min && amount <= presaleData.max, "Invalid contribution amount");
        require (block.timestamp >= presaleData.start_time, "Presale is not started yet");
        require (block.timestamp <= presaleData.end_time, "Presale already ended");

        uint left = presaleData.hardcap - collected;

        uint contributeAmount = amount;
        uint returnAmount = 0;

        if (left <= contributeAmount) {
            returnAmount = contributeAmount - left;
            contributeAmount = left;
        }
        
        uint available = presaleData.max - contributes[user];
        if (contributeAmount > available) {
            returnAmount += contributeAmount - available;
            contributeAmount = available;
        }

        collected += contributeAmount;

        // payable(address(this)).transfer(contributeAmount);
        if (returnAmount > 0) {
            payable(user).transfer(returnAmount);
        }

        contributes[user] = contributeAmount;
    }

    function claim() external {
        require (contributes[msg.sender] > 0, "You have not contributed");
        require (block.timestamp >= presaleData.end_time, "The presale is still active");
        require (collected >= presaleData.hardcap, "The presale failed");

        IERC20(presaleData.token).transfer(msg.sender, contributes[msg.sender] * presaleData.presale_rate / (10 ** (18 - tokenDecimals)));
        contributes[msg.sender] = 0;
    }

    function withdraw() external {
        require (contributes[msg.sender] > 0, "You have not contributed");
        require (block.timestamp >= presaleData.end_time, "The presale is still active");
        require (collected < presaleData.hardcap, "You cannot withdraw now. Claim your tokens instead");

        payable(msg.sender).transfer(contributes[msg.sender]);
        contributes[msg.sender] = 0;
    }

    function finalize() external onlyCreator {
        require (collected >= presaleData.hardcap, "Presale failed or not ended yet");

        uint bnbAmountToLock = presaleData.hardcap * presaleData.pcs_liquidity / 100;
        lockLP(bnbAmountToLock);
        
        uint feeBnb = collected * presaleData.feeBnbPortion / 10000;
        payable(presaleData.feeAddress).transfer(feeBnb);
        payable(presaleData.creator).transfer(collected - bnbAmountToLock - feeBnb);
        
        IERC20(presaleData.token).transferFrom(address(this), presaleData.feeAddress, collected * presaleData.presale_rate * presaleData.feeTokenPortion / 10**(22-tokenDecimals) );
    }

    function lockLP(uint bnbAmount) internal {

        uint tokenAmount = bnbAmount * presaleData.pcs_rate;
        IERC20(presaleData.token).approve(address(pcsRouter), tokenAmount);

        IPancakeRouter02(pcsRouter).addLiquidityETH{value: bnbAmount}(
            presaleData.token,
            tokenAmount,
            0,
            0,
            address(this),
            block.timestamp
        );
    }

    function getStatus() view external returns(uint) {
        if (collected >= presaleData.hardcap) return 3;
        /** if (block.timestamp > ) ; */
        return 1;
    }
    
    function getPresaleData() view public returns(PresaleData memory) {
        return presaleData;
    }

    function whitelistUsers(address[] calldata users, bool _whitelisted) external {
        uint i;
        for (i = 0; i < users.length; i+=1) {
            whitelisted[users[i]] = _whitelisted;
        }
    }

    function claimTeamVesting() external {

    }
}
