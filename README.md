# README v1.0 * 2018.03.19.

# CPRO ERC20 token distribution & buyback 

# Introduction
Initial distribution of cPRO tokens conducted through distribution.sol contract.  
buyback.sol is the contract that repurchases cPRO tokens distributed to participants through initial token distribution.  
The price at which the tokens will be repurchased will be periodically updated by Oracle service.

## Table of Contents (TOC) 
1. Usage
2. Requirements and installation
3. Deployment
4. Running the tests
5. Credits (authors)
6. Contact

# Usage (getting started)
All functionalities of contracts are well described in the code itself.  
Sending investments to distribution.sol contract is possible through fallback function (standard transaction where recipient’s address is the address of distribution contract).
After the completion of distribution, investors will be able to claim their cPRO tokens by calling the "claim" function!  
In order to exchange cPRO tokens for ether, one must call buyback function of the contract. Transaction will occur if there is enough ether inside the contract and revert otherwise.
Ethers can be sent to the contract in standard way which activates the fallback function.

# Requirements (prerequest) and installation
The contracts don't have any requirements and no additional software should be installed. On the other hand, an oracle that provides the contract with price implements web3 library (https://web3js.readthedocs.io/en/latest/), but that is not the part of this repository.


# Deployment
In order to deploy both token.sol and distribution.sol, one must have enough ether.  
distribution.sol must be deployed before token.sol, as token.sol takes distribution's address as a constructor parameter:

    function cPro(address distributionContract) public { ... }
In order to deploy distribution.sol, one must provide the constructor with the initial address that is going to be authorized for certain actions (withdrawing ether from the contract, authorizing/unauthorizing other addresses, starting distribution):

    function Distribution(address _initialAuthorizedAddress) public { ... }
Distribution will not start immediately after deployment of distribution.sol (in that moment, token.sol will not yet be deployed, hence cPRO will not yet be on-chain).
After deployment of token.sol, one must call StartDistribution function in order to start distribution, and define necessary parameters:

    function StartDistribution(address tokenContractAddress, uint256 _endTimestamp) public isAuthorized { ... }

In order to deploy buyback.sol one must have enough ether. Also, one must provide the constructor with the address of cPRO token and the initial address that is going to be authorized for certain actions (authorizing/unauthorizing other addresses, withdrawing strayed tokens from the contract, setting the price).

    function Buyback(address _cProAddress, address initialAuthorizedAddress) public { ... }
After deployment, the price of 1 cPRO in WEI will be equal to 0. That will change the first time an oracle calls the function setPrice:

    function setPrice(uint256 newPrice) public onlyAuthorized {
        currentPrice = newPrice;
    }


### Running the tests
Testing may be performed on Kovan, or any other testnet. The easiest way to test all contracts's functions is to deploy them to the testnet using some injected web3 (Metamask: https://metamask.io/) through Remix Solidity IDE (https://remix.ethereum.org/).
Remix will display all functions after deployment.

### Credits (authors)
GVISP1 TEAM

### Contact
GVISP1 Ltd
web: https://www.gvisp.com
mail: office@gvisp.com

# License
This project is licensed under GPL3, https://www.gnu.org/licenses/gpl-3.0.en.html 
The license should be in a separate file called LICENSE.
