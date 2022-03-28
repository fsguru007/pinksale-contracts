// SPDX-License-Identifier: GPL-3.0-or-later Or MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "FairLaunch.sol";

contract Launcher is Ownable {

    mapping(address => address[]) public ownerToLaunchs;
    mapping(address => address) public tokenToLaunch;
    mapping(address => bool) public isLaunch;

    uint public feeAmount = 75e16;
    uint public tokenFee = 150;
    uint public bnbFee = 150;
    address public feeTo;
    uint public minLaunchTime = 3600;
    uint public maxLaunchTime = 3600 * 24 * 30;

    address[] public routers;

    event LaunchCreated(address owner, address token, address launch, uint start, uint end);
    event LaunchFinished(address launch, address token, uint softcap);
    
    constructor(address _router) Ownable() {
        feeTo = msg.sender;
        routers.add(_router);
    }

    function createLaunch(FairlaunchData memory _launchData) payable external {
        require (msg.value >= feeAmount, "Insufficient payment!");
        require (_launchData.start_time > block.timestamp, "Invalid start time");
        require (_launchData.end_time >= _launchData.start_time + minLaunchTime, "Too short launch time");
        require (_launchData.end_time <= _launchData.start_time + maxLaunchTime, "Too long launch time");
        require (_launchData.unlock_time >= _launchData.end_time, "Invalid unlock time");
        require (routers[_launchData.router] != address(0), "Invalid router index");
        
        _launchData.creator = msg.sender;

        _launchData.tokenFee = tokenFee;
        _launchData.bnbFee = bnbFee;

        FairLaunch launch = new Launch(_launchData, routers[_launchData.router]);
        address launch_address = address(launch);

        ownerToLaunchs[msg.sender].push(launch_address);
        tokenToLaunch[_launchData.token] = launch_address;
        
        uint tokenAmount = 0;
    
        tokenAmount = _calcTokenAmount(_launchData);
    
        IERC20(token).transferFrom(msg.sender, launch_address, tokenAmount);

        payable(feeTo).transfer(feeAmount);
        if (feeAmount < msg.value) {
            payable(msg.sender).transfer(msg.value - feeAmount);
        }
        
        emit LaunchCreated(msg.sender, token, launch_address, _launchData.start_time, _launchData.end_time);
    }
    
    function _calcTokenAmount(LaunchData memory launchData) view internal returns(uint) {

        uint feeTokenAmount = launchData.tokenAmount * tokenFee / 10000;
        
        uint lockTokenAmount = launchData.tokenAmount * launchData.pcs_liquidity / 100;

        uint teamVestingAmount = 0;
        if (launchData.teamVesting) {
            teamVestingAmount = launchData.teamVestingData.total;
        }
        
        return launchData.tokenAmount + feeTokenAmount + lockTokenAmount + teamVestingAmount;
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

    function emitFinished(address _launch, address _token, uint _softcap) external {
        emit LaunchFinished(_launch, _token, _softcap);
    }
}