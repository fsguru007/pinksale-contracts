// SPDX-License-Identifier: GPL-3.0-or-later Or MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "Presale.sol";

contract Launcher is Ownable {

    mapping(address => address[]) public ownerToPresales;
    mapping(address => address) public tokenToPresale;
    mapping(address => bool) public isPresale;

    uint public feeAmount = 75e16;
    uint public tokenFee = 150;
    uint public bnbFee = 150;
    address public feeTo;
    uint public minPresaleTime = 3600;
    uint public maxPresaleTime = 3600 * 24 * 30;

    address[] public routers;

    event PresaleCreated(address owner, address token, address presale, uint start, uint end);
    event PresaleFinished(address presale, address token, uint raised, uint softcap);
    
    constructor(address _router) Ownable() {
        feeTo = msg.sender;
        routers.add(_router);
    }

    function createPresale(PresaleData memory _presaleData) payable external {
        require (msg.value >= feeAmount, "Insufficient payment!");
        require (_presaleData.start_time > block.timestamp, "Invalid start time");
        require (_presaleData.end_time >= _presaleData.start_time + minPresaleTime, "Too short presale time");
        require (_presaleData.end_time <= _presaleData.start_time + maxPresaleTime, "Too long presale time");
        require (_presaleData.unlock_time >= _presaleData.end_time, "Invalid unlock time");
        require (routers[_presaleData.router] != address(0), "Invalid router index");
        
        _presaleData.creator = msg.sender;

        Presale presale = new Presale(_presaleData, routers[_presaleData.router]);
        address presale_address = address(presale);

        ownerToPresales[msg.sender].push(presale_address);
        tokenToPresale[_presaleData.token] = presale_address;
        
        uint tokenAmount = 0;
    
        tokenAmount = _calcTokenAmount(_presaleData);
    
        IERC20(token).transferFrom(msg.sender, presale_address, tokenAmount);

        payable(feeTo).transfer(feeAmount);
        if (feeAmount < msg.value) {
            payable(msg.sender).transfer(msg.value - feeAmount);
        }

        isPresale[presale_address] = true;
        
        emit PresaleCreated(msg.sender, token, presale_address, _presaleData.start_time, _presaleData.end_time);
    }
    
    function _calcTokenAmount(PresaleData memory presaleData) view internal returns(uint) {
        uint tokenDecimals = IERC20Metadata(presaleData.token).decimals();
        
        uint presaleTokenAmount = (10**tokenDecimals) * presaleData.hardcap * presaleData.presale_rate / 1e18;
        uint feeTokenAmount = presaleTokenAmount * tokenFee / 10000;
        
        uint lockTokenAmount = presaleData.hardcap * presaleData.pcs_liquidity * (10**tokenDecimals) * presaleData.pcs_rate / 1e20;

        uint teamVestingAmount = 0;
        if (presaleData.teamVesting) {
            teamVestingAmount = presaleData.teamVestingData.total;
        }
        
        return presaleTokenAmount + feeTokenAmount + lockTokenAmount + teamVestingAmount;
    }

    function setFee(address _feeTo, uint _feeAmount, uint _tokenFee, uint _bnbFee) external onlyOwner {
        feeTo = _feeTo;
        tokenFee = _tokenFee;
        bnbFee = _bnbFee;
        feeAmount = _feeAmount;
    }
    
    function addRouter(address _router) external {
        routers.add(_router);
    }

    function emitFinished(address _presale, address _token, uint _raised, uint _softcap) external {
        require (isPresale(_presale) && msg.sender == _presale, "Invalid access");
        emit PresaleFinished(_presale, _token, _raised, _softcap);
    }

    function ownerPresales(address owner) external returns (address[] calldata) {
        return ownerToPresales[owner];
    }
}