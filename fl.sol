// SPDX-License-Identifier: GPL-3.0-or-later Or MIT
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

interface IPancakePair {
    function transferFrom(address from, address to, uint value) external returns (bool);
}

library PancakeHelper {
    function getEthLPAddress(address token) internal pure returns (address) {
        address WETH = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
        address pair = address(uint160(uint(keccak256(abi.encodePacked(
            hex'ff',
            0xcA143Ce32Fe78f1f7019d7d551a6402fC5350c73,
            keccak256(abi.encodePacked(token, WETH)),
            hex'00fb7f630766e6a796048ea87d01acd3068e8ff67d078148a3fa3f4a84f69bd5' // init code hash
        )))));
        
        return pair;
    }
}

contract Presale is Ownable {

    address[] public contributors;
    mapping(address => uint) public contributes;
    uint public collected = 0;
    address public immutable pcsRouter = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    uint tokenDecimals;
    
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
        bool finished;
        bool unlocked;
        uint liquidity;
        uint collected;
    }
    
    PresaleData presaleData;

    constructor(PresaleData memory _presale) {
        presaleData = _presale;
        
        tokenDecimals = IERC20Metadata(presaleData.token).decimals();
    }

    modifier onlyCreator() {
        require (msg.sender == presaleData.creator, "Access denied");
        _;
    }
    
    receive() external payable {
        _contribute(msg.sender, msg.value);
    }

    function setMetaData(string memory others) external onlyCreator {
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
        
        presaleData.collected = collected;

        // payable(address(this)).transfer(contributeAmount);
        if (returnAmount > 0) {
            payable(user).transfer(returnAmount);
        }

        contributors.push(user);
        contributes[user] = contributeAmount;
    }

    function claim() external {
        require (contributes[msg.sender] > 0, "You have not contributed");
        require (block.timestamp >= presaleData.end_time, "The presale is still active");
        require (collected >= presaleData.softcap, "The presale failed");

        IERC20(presaleData.token).transfer(msg.sender, contributes[msg.sender] * presaleData.presale_rate / (10 ** (18 - tokenDecimals)));
        contributes[msg.sender] = 0;
    }

    function withdraw() external {
        require (contributes[msg.sender] > 0, "You have not contributed");
        require (block.timestamp >= presaleData.end_time, "The presale is still active");
        require (collected < presaleData.softcap, "You cannot withdraw now. Claim your tokens instead");

        payable(msg.sender).transfer(contributes[msg.sender]);
        contributes[msg.sender] = 0;
    }

    function finalize() external onlyCreator {
        require (collected >= presaleData.softcap, "Presale failed or not ended yet");

        uint bnbAmountToLock = collected * presaleData.pcs_liquidity / 100;
        lockLP(bnbAmountToLock);
        
        uint feeBnb = collected * presaleData.feeBnbPortion / 10000;
        payable(presaleData.feeAddress).transfer(feeBnb);
        payable(presaleData.creator).transfer(collected - bnbAmountToLock - feeBnb);
        
        presaleData.finished = true;
        
        IERC20(presaleData.token).transfer(presaleData.feeAddress, collected * presaleData.presale_rate * presaleData.feeTokenPortion / 10**(22-tokenDecimals) );
    }

    function lockLP(uint bnbAmount) internal {

        uint tokenAmount = bnbAmount * presaleData.pcs_rate;
        IERC20(presaleData.token).approve(address(pcsRouter), tokenAmount);
        
        uint amountToken;
        uint amountETH;
        uint liquidity;

        (amountToken, amountETH, liquidity) = IPancakeRouter02(pcsRouter).addLiquidityETH{value: bnbAmount}(
            presaleData.token,
            tokenAmount,
            0,
            0,
            address(this),
            block.timestamp
        );
        
        presaleData.liquidity = liquidity;
    }
    
    function unlockLP() external onlyCreator {
        
        require (block.timestamp > presaleData.unlock_time, "Unlock not allowed yet");
        require (presaleData.finished && presaleData.liquidity > 0, "No liquidity locked");
        
        address lp = PancakeHelper.getEthLPAddress(presaleData.token);
        
        IERC20(lp).transfer(presaleData.creator, presaleData.liquidity);
        
        presaleData.unlocked = true;
    }

    function getStatus() view external returns(uint) {
        if (collected >= presaleData.hardcap) return 3;
        /** if (block.timestamp > ) ; */
        return 1;
    }
    
    function getPresaleData() view public returns(PresaleData memory) {
        return presaleData;
    }
}

// File: Launcher.sol

pragma solidity ^0.8.0;




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
    mapping(address => address) public tokenToPresales;

    event PresaleCreated(address owner, address token, address presale);
    
    constructor() Ownable() {
        feeTo = msg.sender;
    }

    function createPresale(address token, uint presale_rate, uint softcap, uint hardcap, uint min, uint max, uint pcs_liquidity, uint pcs_rate, uint32 start_time, uint32 end_time, uint32 unlock_time, string memory metadata)
        payable external returns (address) {
        // require (msg.value >= feeAmount, "Insufficient payment!");
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
        presaleData.metadata = metadata;

        address presale = _createPresale(presaleData);
        
        return presale;
    }
    
    function fetchPresale(uint from, uint status) external view returns (Presale.PresaleData memory, uint, address) {
        uint i = from - 1;
        
        while (i >= 0) {
            Presale presale = Presale(payable(presales[i]));
            Presale.PresaleData memory presaleData = presale.getPresaleData();
        
            if (status == 1 && presaleData.start_time <= block.timestamp && block.timestamp < presaleData.end_time) {
                return ( getPresaleData(presales[i]), i, presales[i]);
            }
            
            if (block.timestamp > presaleData.end_time && status == 2 && presale.collected() >= presaleData.softcap) {
                return ( getPresaleData(presales[i]), i, presales[i]);
            }
            
            if (block.timestamp > presaleData.end_time && status == 3 && presale.collected() < presaleData.softcap) {
                return ( getPresaleData(presales[i]), i, presales[i]);
            }
            
            if (status == 0 && block.timestamp < presaleData.start_time) {
                return ( getPresaleData(presales[i]), i, presales[i]);
            }
            
            if (status == 10) {
                return ( getPresaleData(presales[i]), i, presales[i]);
            }
            
            i--;
        }
        
        return (getPresaleData(presales[0]), 0, presales[0]);
    }
    
    function presaleLength() external view returns (uint) {
        return presales.length;
    }
    
    function _createPresale(Presale.PresaleData memory data) internal returns (address) {
        address presale = address(new Presale(data));

        presales.push(presale);
        ownerToPresales[msg.sender].push(presale);
        tokenToPresales[data.token] = presale;
    
        uint tokenAmount = 0;
    
        tokenAmount = _calcTokenAmount(data);
    
        IERC20(data.token).transferFrom(msg.sender, presale, tokenAmount);

        payable(feeTo).transfer(feeAmount);
        if (feeAmount < msg.value) {
            payable(msg.sender).transfer(msg.value - feeAmount);
        }
        
        // _consolidatePresales();
        
        emit PresaleCreated(msg.sender, data.token, presale);
        
        return presale;
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
    
    function getPresaleData(address presaleAddress) public view returns(Presale.PresaleData memory) {
        Presale presale = Presale(payable(presaleAddress));
        Presale.PresaleData memory presaleData = presale.getPresaleData();
        
        return presaleData;
    }
    
    function _consolidatePresales() internal {
        for (uint i = 0; i < presales.length; i++) {
            Presale presale = Presale(payable(presales[i]));
            
            if (presales[i] == address(0)) continue;
            
            Presale.PresaleData memory presaleData = presale.getPresaleData();
            
            if (presaleData.end_time > block.timestamp) continue;
            
            if (presale.collected() < presaleData.softcap) {
                failedPresales.push(presales[i]);
            } else {
                succeededPresales.push(presales[i]);
            }
            
            delete presales[i];
        }
    }
    
}
