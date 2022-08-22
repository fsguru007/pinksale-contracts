// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IAirdropFactory {
  function addUserClaim(address user, address token, uint amount) external;
  function increaseParticipants() external;
}

contract Airdrop {
  IERC20 token;
  address public owner;
  bool public started;
  bool public cancelled;

  IAirdropFactory public factory;

  address[] public users;
  uint[] public amounts;

  uint public totalAllocation;
  uint public claimedAmount;

  mapping(address => uint) public userAmounts;
  mapping(address => uint) public userClaims;

  modifier onlyOwner {
    require (msg.sender == owner, "Permission denied!");
    _;
  }

  constructor(address _owner, IERC20 _token) {
    owner = _owner;
    token = _token;

    factory = IAirdropFactory(msg.sender);
  }

  function start() external onlyOwner {
    started = true;
  }

  function cancel() external onlyOwner {
    cancelled = true;
  }

  function setAllocations(address[] memory _users, uint[] memory _amounts) external onlyOwner {
    require (!cancelled, "Cancelled");
    require (_users.length == _amounts.length, "Invalid params");

    uint i = 0;
    for (i = 0; i < _users.length; i+=1) {
      users.push(_users[i]);
      amounts.push(_amounts[i]);
      totalAllocation = totalAllocation + _amounts[i] - userAmounts[users[i]];
      userAmounts[users[i]] = _amounts[i];
    }
  }

  function removeAllocations() external onlyOwner {
    uint i;
    for (i = 0; i < users.length; i+=1) {
      userAmounts[users[i]] = 0;
    }

    totalAllocation = 0;
    delete users;
    delete amounts;
  }

  function claim() external {
    require ( started, "Not started" );
    require ( !cancelled, "Cancelled" );
    require ( userAmounts[msg.sender] > userClaims[msg.sender], "Nothing to claim" );

    uint amount = userAmounts[msg.sender] - userClaims[msg.sender];

    claimedAmount += amount;
    
    token.transferFrom(owner, msg.sender, amount);
    userClaims[msg.sender] = userAmounts[msg.sender];

    factory.addUserClaim(msg.sender, address(token), amount);
    factory.increaseParticipants();
  }
}

contract AirdropFactory is Ownable {

  address public feeAddress;
  uint public fee;
  mapping(address => bool) public isAirdrop;
  uint public totalParticipants;
  uint public totalAirdrops;

  address[] public airdropTokens;
  address[] public airdropAddresses;

  struct ClaimEntity {
    address token;
    uint amount;
  }

  mapping(address => ClaimEntity[]) private _userClaims;

  event AirdropCreated(address token, address owner, address airdrop);

  struct Entity {
    address airdrop;
    address token;
  }

  constructor() {
  }

  modifier onlyAirdrop {
    require (isAirdrop[msg.sender], "Fuck off");
    _;
  }

  function setFee(address _to, uint _fee) external onlyOwner {
    feeAddress = _to;
    fee = _fee;
  }

  function create(IERC20 _token) external payable {
    require (msg.value >= fee, "Insufficient fee!");

    address airdrop = address(new Airdrop(msg.sender, _token));

    emit AirdropCreated(address(_token), msg.sender, airdrop);
    isAirdrop[airdrop] = true;
    totalAirdrops++;

    airdropTokens.push(address(_token));
    airdropAddresses.push(airdrop);

    Address.sendValue(payable(feeAddress), msg.value);
  }

  function increaseParticipants() external onlyAirdrop {
    totalParticipants++;
  }

  function addUserClaim(address user, address token, uint amount) external onlyAirdrop {
    _userClaims[user].push(ClaimEntity(token, amount));
  }

  function getAirdrops(uint from, uint to) public view returns (Entity[] memory) {
    require (from >= 0 && to > from, "Invalid params");

    if (to > airdropTokens.length) to = airdropTokens.length;

    Entity[] memory res = new Entity[](to - from);

    uint i = 0;
    for (i = from; i < to; i+=1) {
      res[i - from] = Entity(airdropAddresses[i], airdropTokens[i]);
    }

    return res;
  }

  function userClaims(address user) public view returns (ClaimEntity[] memory) {
    return _userClaims[user];
  }
}
