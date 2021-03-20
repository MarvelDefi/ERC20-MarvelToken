pragma solidity >=0.4.25 <0.7.0;

import 'https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v3.4.0/contracts/token/ERC20/IERC20.sol';
import 'https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v3.4.0/contracts/math/SafeMath.sol';
import './Token.sol';

contract ICO {
    using SafeMath for uint;
    struct Sale {
        address investor;
        uint amount;
        bool tokensWithdrawn;
    }
    mapping(address => Sale) public sales;
    address public admin;
    uint public end;
    uint public duration;
    uint public price;
    uint public availableTokens;
    uint public minPurchase;
    uint public maxPurchase;
    Token public token;
    IERC20 public busd = IERC20(0xe9e7cea3dedca5984780bafc599bd69add087d56);
    
    constructor(
        address tokenAddress,
        uint _duration,
        uint _price,
        uint _availableTokens,
        uint _minPurchase,
        uint _maxPurchase) {
        token = Token(tokenAddress);
        
        require(_duration > 0, 'duration should be > 0');
        require(
          _availableTokens > 0 && _availableTokens <= token.maxTotalSupply(), 
          '_availableTokens should be > 0 and <= maxTotalSupply'
        );
        require(_minPurchase > 0, '_minPurchase should > 0');
        require(
          _maxPurchase > 0 && _maxPurchase <= _availableTokens, 
          '_maxPurchase should be > 0 and <= _availableTokens'
        );

        admin = msg.sender;
        duration = _duration;
        price = _price;
        availableTokens = _availableTokens;
        minPurchase = _minPurchase;
        maxPurchase = _maxPurchase;
    }
    
    function start()
        external
        onlyAdmin() 
        icoNotActive() {
        end = block.timestamp + duration;
    }
    
    function buy(uint busdAmount)
        external
        icoActive() {
        require(
          busdAmount >= minPurchase && busdAmount <= maxPurchase, 
          'have to buy between minPurchase and maxPurchase'
        );
        uint tokenAmount = busdAmount.div(price);
        require(
          tokenAmount <= availableTokens, 
          'Not enough tokens left for sale'
        );
        busd.transferFrom(msg.sender, address(this), busdAmount);
        token.mint(address(this), tokenAmount);
        sales[msg.sender] = Sale(
            msg.sender,
            tokenAmount,
            false
        );
    }
    
    function withdrawTokens()
        external
        icoEnded() {
        Sale storage sale = sales[msg.sender];
        require(sale.amount > 0, 'only investors');
        require(sale.tokensWithdrawn == false, 'tokens were already withdrawn');
        sale.tokensWithdrawn = true;
        token.transfer(sale.investor, sale.amount);
    }
    
    function withdrawBusd(uint amount)
        external
        onlyAdmin()
        icoEnded() {
        busd.transfer(admin, amount);
    }
    
    modifier icoActive() {
        require(
          end > 0 && block.timestamp < end && availableTokens > 0, 
          'ICO must be active'
        );
        _;
    }
    
    modifier icoNotActive() {
        require(end == 0, 'ICO should not be active');
        _;
    }
    
    modifier icoEnded() {
        require(
          end > 0 && (block.timestamp >= end || availableTokens == 0), 
          'ICO must have ended'
        );
        _;
    }
    
    modifier onlyAdmin() {
        require(msg.sender == admin, 'only admin');
        _;
    }
}
