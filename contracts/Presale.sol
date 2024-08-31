// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

// Uncomment this line to use console.log
// import "hardhat/console.sol";
// mainnet usdc address 0xdAC17F958D2ee523a2206206994597C13D831ec7

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";


// address constant MAINNET_USDC = 0x8AC76a51cc950d9822D68b83fE1Ad97B32Cd580d; // USDC address in BSC
address constant MAINNET_USDC = 0x861ba873553dB46feEe3b2A028A8d9dF80fc403f; // USDC address in BSC Testnet
address constant MAINNET_USDT = 0x1C3ebb1C5Fba593b8D84c703Cf63F470fA7a3655; // USDT address in BSC Testnet
address constant MAINNET_BUSD = 0x4480c754cc7c00Fe1f27b92e96C8F6D6b02aCEc2; // BUSD address in BSC Testnet
address constant MAINNET_DAI = 0x7DCcEc6B254D01f5a2B5D7104a973D99A3A061F0; // DAI address in BSC Testnet

// address constant MAINNET_TOKEN = 0xc50D5CC75D839F005161fdB5a2B8702FdCDDb553; // Token Address in BSC
address constant MAINNET_TOKEN = 0x15Eb95Afe163A654E83Dd874CF3e70D12A8b7a79; // Token Address in BSC Testnet

// mainnet router
// address constant PANCAKESWAPV2_ROUTER_ADDRESS = address(
//     0x10ED43C718714eb63d5aA57B78B54704E256024E
// );

// BSC testnet router
address constant PANCAKESWAPV2_ROUTER_ADDRESS = address(
    0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3
);

contract Presale is Ownable {
    bool public presaleStarted;
    uint256 public startTimeStamp; // presale start time
    uint256 public endTimeStamp; // presale end time
    uint256 public fundsRaised; // funds raised by presale
    uint256 public soldAmount;
    uint256 public presaleAmount = 5 * 10 ** (8 + 18);
    uint256 public minBuy = 500 * 10 ** 18;
    uint256 public maxBuy = 850000 * 10 ** 18;
    uint256 public maxWallet = 850000 * 10 ** 18;
    mapping(address => uint256) public buyerBalance;
    IUniswapV2Router02 public router =
        IUniswapV2Router02(address(PANCAKESWAPV2_ROUTER_ADDRESS));
    IERC20 usdc = IERC20(MAINNET_USDC); // USDC contract address
    IERC20 usdt = IERC20(MAINNET_USDT); // USDT contract address
    IERC20 busd = IERC20(MAINNET_BUSD); // BUSD contract address
    IERC20 dai = IERC20(MAINNET_DAI); // DAI contract address
    IERC20 token = IERC20(MAINNET_TOKEN);
    address public feeWallet = address(0x94FEA968D67d6Ff5E4b344C20B2fa965EE7dCA69);
    receive() external payable {}
    constructor() Ownable(msg.sender) {
        fundsRaised = 0;
        presaleStarted = false;
    }
    /**
     * @dev get current token price for presale
     * @return uint256
     */
    function getCurrentTokenPrice() public view returns (uint256) {
        if(presaleStarted){
            if(block.timestamp - startTimeStamp >= 3600 * 24 * 30) return 28;
            else return 20;
        }
        return 0;
    }   
    /**
     * @dev start the presale
     */
    function startPresale() public onlyOwner {
        require(
            token.balanceOf(address(this)) == presaleAmount,
            "Token not charged fully"
        );
        require(
            presaleStarted == false,
            "Already started"
        );
        startTimeStamp = block.timestamp;
        endTimeStamp = startTimeStamp + 3600 * 24 * 30 * 2;
        presaleStarted = true;
    }
    /**
     * @dev buy with USDC
     * @param amount tokenAmount
     */
    function buyWithUSDC(uint256 amount) external {
        _buyWithCoin(usdc, amount, msg.sender);
    }
    /**
     * @dev buy with USDT
     * @param amount tokenAmount
     */
    function buyWithUSDT(uint256 amount) external {
        _buyWithCoin(usdt, amount, msg.sender);
    }
    /**
     * @dev buy with BUSD
     * @param amount tokenAmount
     */
    function buyWithBUSD(uint256 amount) external {
        _buyWithCoin(busd, amount, msg.sender);
    }
    /**
     * @dev buy with DAI
     * @param amount tokenAmount
     */
    function buyWithDAI(uint256 amount) external {
        _buyWithCoin(dai, amount, msg.sender);
    }
    /**
     * @dev purchase Spica token using Stable Coin
     */
    function _buyWithCoin(IERC20 coin, uint256 amount, address from) internal {
        if (block.timestamp >= endTimeStamp) presaleStarted = false;
        require(block.timestamp > startTimeStamp, "Presale is not started");
        require(presaleStarted == true, "Presale is ended");
        require(amount >= minBuy && amount <= maxBuy && buyerBalance[from] + amount <= maxWallet && soldAmount + amount <= presaleAmount, "Invalid amount of token to buy");
        uint256 currentTokenPrice = getCurrentTokenPrice();
        uint256 _coinAmount = amount * currentTokenPrice / (10 ** (18 - 6 + 4));
        fundsRaised = fundsRaised + _coinAmount;
        coin.transferFrom(from, address(this), _coinAmount);
        buyerBalance[from] += amount;
        soldAmount += amount;
    }
    /**
     * @dev purchase Spica token using ETH
     */
    function buyTokenWithETH() external payable {
        if (block.timestamp >= endTimeStamp) presaleStarted = false;
        require(block.timestamp > startTimeStamp, "Presale is not started");
        require(presaleStarted == true, "Presale is ended");
        require(msg.value > 0, "Unavailable amount of token to buy");
        uint256 _estimateTokenAmount = buyEstimationWithEth(msg.value);
        require(_estimateTokenAmount >= minBuy && _estimateTokenAmount <= maxBuy && buyerBalance[msg.sender] + _estimateTokenAmount <= maxWallet && soldAmount + _estimateTokenAmount <= presaleAmount, "Invalid amount of token to buy");
        address WETH = router.WETH();
        address[] memory path = new address[](2);
        path[0] = WETH;
        path[1] = MAINNET_USDC;
        uint256[] memory amounts = router.swapExactETHForTokens{
            value: msg.value
        }(0, path, address(this), block.timestamp + 15 minutes);
        uint256 usdAmount = amounts[1];
        uint256 currentTokenPrice = getCurrentTokenPrice();
        uint256 tokenAmount = (usdAmount * 10 ** (18 - 6 + 4)) / currentTokenPrice;
        fundsRaised += usdAmount;
        buyerBalance[msg.sender] += tokenAmount;
        soldAmount += tokenAmount;
    }
    /**
     * @dev get total token amount for presale
     * @return
     */
    function sale() public view returns (uint256) {
        return token.balanceOf(address(this));
    }
    /**
     * @dev get purchase available Spica token amount by ETH
     * @param _amount Eth amount
     * @return tokenAmount
     */
    function buyEstimationWithEth(
        uint256 _amount
    ) public view returns (uint256) {
        uint256 currentTokenPrice = getCurrentTokenPrice();
        address WETH = router.WETH();
        address[] memory path = new address[](2);
        path[0] = WETH;
        path[1] = MAINNET_USDC;
        uint256[] memory _usdcAmount = router.getAmountsOut(_amount, path);
        uint256 tokenAmount = (_usdcAmount[1] * 10 ** (18 - 6 + 4)) / currentTokenPrice;
        return tokenAmount;
    }
    /**
     * @dev get ETH amount from purchase available Spica token amount 
     * @param _amount Token amount
     * @return ETH amount
     */
    function ethEstimationWithToken(
        uint256 _amount
    ) public view returns (uint256) {
        uint256 currentTokenPrice = getCurrentTokenPrice();
        uint256 _coinAmount = _amount * currentTokenPrice / (10 ** (18 - 6 + 4));
        address WETH = router.WETH();
        address[] memory path = new address[](2);
        path[0] = WETH;
        path[1] = MAINNET_USDC;
        uint256[] memory ethAmount = router.getAmountsIn(_coinAmount, path);
        return ethAmount[0];
    }
    /**
     * @dev get purchase available Spica token amount by ETH
     * @param _amount Coin amount
     * @return tokenAmount
     */
    function buyEstimationWithCoin(
        uint256 _amount
    ) public view returns (uint256) {
        uint256 currentTokenPrice = getCurrentTokenPrice();
        uint256 tokenAmount = (_amount * 10 ** (18 - 6 + 4)) / currentTokenPrice;
        return tokenAmount;
    }
    /**
     * @dev get Coin amount from purchase available Spica token amount 
     * @param _amount Token amount
     * @return CoinAmount
     */
    function coinEstimationWithToken(
        uint256 _amount
    ) public view returns (uint256) {
        uint256 currentTokenPrice = getCurrentTokenPrice();
        uint256 coinAmount = _amount * currentTokenPrice / (10 ** (18 - 6 + 4));
        return coinAmount;
    }

    /**
     * @dev withdraw fundsRaised to fee wallet
     */
    function withdraw() public {
        require(msg.sender == feeWallet, "Only feeWallet can withdraw");
        usdc.transfer(msg.sender, usdc.balanceOf(address(this)));
        usdt.transfer(msg.sender, usdt.balanceOf(address(this)));
        busd.transfer(msg.sender, busd.balanceOf(address(this)));
        dai.transfer(msg.sender, dai.balanceOf(address(this)));
        token.transfer(msg.sender, presaleAmount - soldAmount);
        (bool success, ) = payable(msg.sender).call{value: address(this).balance}("");
    }
    /**
     * @dev claim Spica tokens after presale is finished
     */
    function claim() external {
        require(block.timestamp > endTimeStamp, "presale did not finished");
        require(buyerBalance[msg.sender] > 0, "No balane to claim");
        uint256 amount = buyerBalance[msg.sender];
        buyerBalance[msg.sender] = 0;
        token.transfer(msg.sender, amount);
    }
    /**
     * @dev calculate remaining time for presale
     * @return uint256
     */
    function calculateRemainingTime() public view returns (uint256) {
        require(block.timestamp < endTimeStamp, "Presale is ended");
        return (endTimeStamp - block.timestamp);
    }
}
