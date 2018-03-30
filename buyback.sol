pragma solidity ^0.4.18;

import './erc20.sol';

contract Buyback {
  // CPro token contract address
  address public cProAddress;
  // ERC20 standard interface
  ERC20Interface CProContract;

  // Amount of ether on the contract
  uint256 public totalFundsAvailable;
  // The price of one token unit in WEI (not atto cPRO a.k.a. cPro / 10^18)
  uint256 public currentPrice;

  // This creates an array of authorized addresses
  mapping (address => bool) public authorizedAddresses;

  // Checks whether msg.sender is authorized for certain action
  modifier onlyAuthorized() {
      require(authorizedAddresses[msg.sender]);
      _;
  }

  /*
   * Authorize address.
   * Can be called only by authorized addresses.
   */
  function authorize(address _address) public onlyAuthorized {
      authorizedAddresses[_address] = true;
  }

  /*
   * Unauthorize address.
   * Can be called only by authorized addresses.
   */
  function unauthorize(address _address) public onlyAuthorized {
      authorizedAddresses[_address] = false;
  }


  /*
   *  Constructor function.
   *  Authorizes the initial input address.
   */
  function Buyback(
    address _cProAddress,
    address initialAuthorizedAddress
  ) public {
    CProContract = ERC20Interface(_cProAddress);
    authorizedAddresses[initialAuthorizedAddress] = true;
  }

  /*
   *  Fallback function.
   *  Stores sent ether.
   */
  function () public payable {
    totalFundsAvailable += msg.value;
  }

  /*
   *  Function that withdraws strayed tokens from the contract.
   *  Only authorized addresses can call this function.
   */
  function withdrawTokens(address tokenContractAddress) public onlyAuthorized {
    require(tokenContractAddress != cProAddress);
    ERC20Interface OtherTokenContract = ERC20Interface(tokenContractAddress);
    uint256 balance = OtherTokenContract.balanceOf(address(this));
    OtherTokenContract.transfer(msg.sender, balance);
  }

  /*
   *  Exchange tokens for ether.
   */
  function buyback(uint256 amount) public payable {
    uint256 forTransfer = (amount * currentPrice) / (10 ** 18);
    require(totalFundsAvailable > forTransfer);
    // Check for overflows
    require(totalFundsAvailable + forTransfer > totalFundsAvailable);
    uint256 previousTotalFundsAvailable = totalFundsAvailable;
    uint256 previousBalances = totalFundsAvailable + msg.sender.balance;
    CProContract.burnFrom(msg.sender, amount);
    msg.sender.transfer(forTransfer);
    totalFundsAvailable -= forTransfer;
    // Asserts are used to use static analysis to find bugs in your code. They should never fail
    assert(totalFundsAvailable + forTransfer == previousTotalFundsAvailable);
    assert(totalFundsAvailable + msg.sender.balance == previousBalances);
  }

  /*
   * Sets new token price in WEI.
   * Can only be called only by authorized addresses.
   */
  function setPrice(uint256 newPrice) public onlyAuthorized {
      currentPrice = newPrice;
  }
}
