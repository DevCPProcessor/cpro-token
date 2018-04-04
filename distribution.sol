pragma solidity ^0.4.18;

import "./token.sol";

contract Distribution {
  // Instantiates the CPro contract
  CPro public TokenContract;
  // Distribution creator
  address public creator;

  // Total amount of tokens to distribute
  uint256 public totalTokens;

  // Total amount of ether invested
  uint256 public totalInvested;

  // Mapps addresses to amount invested
  mapping (address => uint256) public invested;
  // Mapps addresses to whether tokens were claimed or not
  mapping (address => bool) public claimed;
  // Mapps addresses to whether they are authorized or not
  mapping (address => bool) public authorized;

  // Timestamp of the distribution end
  uint256 public endTimestamp;
  // True if distribution has started, false othervise
  bool public started;

  // Checks whether distribution is on
  modifier isOn() {
    require(started);
    require(now < endTimestamp);
    _;
  }

  // Checks whether distribution has ended
  modifier isOver() {
    require(started);
    require(now >= endTimestamp);
    _;
  }

  // Checks whether msg.sender is authorized
  modifier isAuthorized() {
    require(authorized[msg.sender]);
    _;
  }

  /*
   *  Authorizes '_address'
   *  Only authorized addresses can call this function
   */
  function authorize(address _address) public isAuthorized {
    authorized[_address] = true;
  }

  /*
   *  Unauthorizes '_address'
   *  Only authorized addresses can call this function
   */
  function unauthorize(address _address) public isAuthorized {
    authorized[_address] = false;
  }

  /*
   *  Distribution constructor. Sets initial authorized address.
   */
  function Distribution(address initialAuthorizedAddress) public {
    authorized[initialAuthorizedAddress] = true;
  }


  /*
   *  Starts distribution and sets the end moment.
   */
  function StartDistribution(
    address tokenContractAddress,
    uint256 _endTimestamp
  ) public isAuthorized {
    // Function shouldn't be called again after distribution had started
    // Hence "require(!started)"
    require(!started);
    TokenContract = CPro(tokenContractAddress);
    totalTokens = TokenContract.balanceOf(address(this));
    creator = msg.sender;
    endTimestamp = _endTimestamp;
    started = true;
  }

  /*
   *  Fallback function. Mapps investments to addresses.
   */
  function () public payable isOn {
    invested[msg.sender] += msg.value;
    totalInvested += msg.value;
  }

  /*
   *  Claim tokens.
   *  Mints bought tokens to msg.sender's address.
   */
  function claim() public {
    proxyClaim(msg.sender);
  }

  /*
   *  Claim tokens for someone else.
   *  Mints bought tokens to the input address.
   */
  function proxyClaim(address _address) public isOver {
    require(!claimed[_address]);
    uint256 amount = totalTokens * invested[_address] / totalInvested;
    // Check for overflows
    // require(totalTokens + amount > totalTokens);
    // uint256 previousTotalTokens = totalTokens;
    // uint256 previousSendersBalance = TokenContract.balanceOf(msg.sender);
    TokenContract.transfer(_address, amount);
    
    claimed[_address] = true;
    // Asserts are used to use static analysis to find bugs in your code. They should never fail
    // assert(totalTokens + TokenContract.balanceOf(msg.sender) == previousTotalTokens + previousSendersBalance);
    // assert(totalTokens + amount == previousTotalTokens);
  }

  /*
   *  Withdraw ether from the contract.
   *  Only authorized address can call this function.
   *  In order to transfer ether, distribution must be over.
   */
  function withdrawEther() public payable isAuthorized {
      msg.sender.transfer(this.balance);
  }

}
