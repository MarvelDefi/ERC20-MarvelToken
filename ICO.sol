pragma solidity ^0.7.0;

import 'https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v3.4.0/contracts/token/ERC20/ERC20.sol';
import 'https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v3.4.0/contracts/math/SafeMath.sol';

contract ICO is ERC20 {
  using SafeMath for uint;
  address public admin;
  uint public bonusEnds;
  uint public icoEnds;
  uint public icoStarts;
  uint public duration = 2368800; //4 weeks (592200 seconds per week)

  constructor() public ERC20("AVENGER Token", "AVENGER") {
    admin = msg.sender;
    icoStarts = block.timestamp;
    icoEnds = icoStarts + duration;
    _mint(msg.sender, 10000);
  }

  function updateAdmin(address newAdmin) external {
    require(msg.sender == admin, 'only admin');
    admin = newAdmin;
  }

  function mint(address account, uint256 amount) external {
    require(msg.sender == admin, 'only admin');
    uint totalSupply = totalSupply();
    _mint(account, amount);
  }
  
  function buyTokens() public payable {
      uint tokens;
      tokens = msg.value.mul(200);  //1 BNB + 200 tokens
      _mint(msg.sender, tokens);
  }
  
  function collect() public {
      require(msg.sender == admin, 'only admin');
      admin.transfer(address(this).balance)
  }
    
}
