// SPDX-License-Identifier: GPL-3.0-or-later Or MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "Presale.sol";

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
    uint8 vestingFirstRelease;
    uint8 vestingCycle;
    uint8 vestingRelease;
    bool teamVesting;
    uint teamVestingTotal;
    uint8 teamVestingFirstReleaseAfter;
    uint8 teamVestingFirstRelease;
    uint8 teamVestingCycle;
    uint8 teamVestingRelease;
}

contract Launcher is Ownable {

    address[] public presales;
    mapping(address => address[]) public ownerToPresales;
    uint public feeAmount = 75e16;
    uint public tokenFee = 150;
    uint public bnbFee = 150;
    address public feeTo;
    uint public minPresaleTime = 3600;
    uint public maxPresaleTime = 3600 * 24 * 30;
    address[] public failedPresales;
    address[] public succeededPresales;

    // event PresaleCreated(address owner, address token, address presale);
    
    constructor() Ownable() {
        feeTo = msg.sender;
    }

    function createPresale(address token, uint presale_rate, uint softcap, uint hardcap, uint min, uint max, uint pcs_liquidity, uint pcs_rate, uint32 start_time, uint32 end_time, uint32 unlock_time) payable external {
        require (msg.value >= feeAmount, "Insufficient payment!");
        require (start_time > block.timestamp, "Invalid start time");
        require (end_time >= start_time + minPresaleTime, "Too short presale time");
        require (end_time <= start_time + maxPresaleTime, "Too long presale time");
        require (unlock_time >= end_time, "Invalid unlock time");
        
        Presale.PresaleData memory presaleData;
        presaleData.token = token;
        presaleData.presale_rate = presale_rate;
        presaleData.softcap = softcap;
        presaleData.hardcap = hardcap;
        presaleData.min = min;
        presaleData.max = max;
        presaleData.pcs_liquidity = pcs_liquidity;
        presaleData.pcs_rate = pcs_rate;
        presaleData.start_time = start_time;
        presaleData.end_time = end_time;
        presaleData.unlock_time = unlock_time;
        presaleData.creator = msg.sender;
        presaleData.feeAddress = feeTo;
        presaleData.feeBnbPortion = bnbFee;
        presaleData.feeTokenPortion = tokenFee;

        Presale presale = new Presale(presaleData);
        address presale_address = address(presale);

        presales.push(presale_address);
        ownerToPresales[msg.sender].push(presale_address);
        
        uint tokenAmount = 0;
    
        tokenAmount = _calcTokenAmount(presaleData);
    
        IERC20(token).transferFrom(msg.sender, presale_address, tokenAmount);

        payable(feeTo).transfer(feeAmount);
        if (feeAmount < msg.value) {
            payable(msg.sender).transfer(msg.value - feeAmount);
        }
        
        _consolidatePresales();
        
        // emit PresaleCreated(msg.sender, token, address(presale));
    }
    
    function _calcTokenAmount(Presale.PresaleData memory presaleData) view internal returns(uint) {
        uint tokenDecimals = IERC20Metadata(presaleData.token).decimals();
        
        uint presaleTokenAmount = (10**tokenDecimals) * presaleData.hardcap * presaleData.presale_rate / 1e18;
        uint feeTokenAmount = presaleTokenAmount * tokenFee / 10000;
        
        uint lockTokenAmount = presaleData.hardcap * presaleData.pcs_liquidity * (10**tokenDecimals) * presaleData.pcs_rate / 1e20;
        
        return presaleTokenAmount + feeTokenAmount + lockTokenAmount;
    }

    function setFee(address _feeTo, uint _feeAmount, uint _tokenFee, uint _bnbFee) external onlyOwner {
        feeTo = _feeTo;
        tokenFee = _tokenFee;
        bnbFee = _bnbFee;
        feeAmount = _feeAmount;
    }
    
    function getPresaleForToken(address token) external view returns(Presale) {
        
    }
    
    function _consolidatePresales() internal {
        for (uint i = 0; i < presales.length; i++) {
            Presale presale = Presale(payable(presales[i]));
            
            if (presales[i] == address(0)) continue;
            
            Presale.PresaleData memory presaleData = presale.getPresaleData();
            
            if (presaleData.end_time <= block.timestamp) continue;
            
            if (presale.collected() < presaleData.softcap) {
                failedPresales.push(presales[i]);
            } else {
                succeededPresales.push(presales[i]);
            }
            
            delete presales[i];
        }
    }
    
}