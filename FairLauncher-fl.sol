// SPDX-License-Identifier: MIT

// File: node_modules\@openzeppelin\contracts\utils\Context.sol

pragma solidity ^0.8.0;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

// File: @openzeppelin\contracts\access\Ownable.sol

pragma solidity ^0.8.0;


/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _setOwner(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// File: node_modules\@openzeppelin\contracts\token\ERC20\IERC20.sol

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// File: @openzeppelin\contracts\token\ERC20\extensions\IERC20Metadata.sol

pragma solidity ^0.8.0;


/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}


// File: IPancakeRouter02.sol

pragma solidity ^0.8.0;

interface IPancakeRouter01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}

interface IPancakeRouter02 is IPancakeRouter01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

// File: FairLaunch.sol

pragma solidity ^0.8.0;





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

// File: FairLauncher.sol

pragma solidity ^0.8.0;


contract Launcher is Ownable {

    mapping(address => address[]) public ownerToLaunches;
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
        routers.push(_router);
    }

    function createLaunch(FairlaunchData memory _launchData) payable external {
        require (msg.value >= feeAmount, "Insufficient payment!");
        require (_launchData.start_time > block.timestamp, "Invalid start time");
        require (_launchData.end_time >= _launchData.start_time + minLaunchTime, "Too short launch time");
        require (_launchData.end_time <= _launchData.start_time + maxLaunchTime, "Too long launch time");
        require (_launchData.unlock_time >= _launchData.end_time, "Invalid unlock time");
        require (routers[_launchData.router] != address(0), "Invalid router index");
        
        _launchData.creator = msg.sender;

        _launchData.feeTokenPortion = tokenFee;
        _launchData.feeBnbPortion = bnbFee;

        FairLaunch launch = new FairLaunch(_launchData, routers[_launchData.router]);
        address launch_address = address(launch);

        ownerToLaunches[msg.sender].push(launch_address);
        tokenToLaunch[_launchData.token] = launch_address;
        
        uint tokenAmount = 0;
    
        tokenAmount = _calcTokenAmount(_launchData);
    
        IERC20(_launchData.token).transferFrom(msg.sender, launch_address, tokenAmount);

        payable(feeTo).transfer(feeAmount);
        if (feeAmount < msg.value) {
            payable(msg.sender).transfer(msg.value - feeAmount);
        }
        
        emit LaunchCreated(msg.sender, _launchData.token, launch_address, _launchData.start_time, _launchData.end_time);
    }
    
    function _calcTokenAmount(FairlaunchData memory launchData) view internal returns(uint) {

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
        routers.push(_router);
    }

    function emitFinished(address _launch, address _token, uint _softcap) external {
        emit LaunchFinished(_launch, _token, _softcap);
    }

    function ownerLaunches(address owner) external view returns (address[] memory) {
        return ownerToLaunches[owner];
    }
}
