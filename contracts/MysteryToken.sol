pragma solidity >=0.5.0;

import "./ERC20.sol";

contract MysteryToken {
    ERC20 erc20Contract;
    address owner;
    
    constructor() public {
        ERC20 e = new ERC20();
        erc20Contract = e;
        owner = msg.sender;
    }

    event creditChecked(uint256 credit);

    function getCredit() public payable {
        uint256 amt = msg.value / 10000000000000000; // no. of mystery token
        erc20Contract.mint(msg.sender, amt);
        
    }

    function checkCredit() public returns(uint256) {
        uint256 credit = erc20Contract.balanceOf(msg.sender);
        emit creditChecked(credit);
        return credit;
    }

    function transferCredit(address receipt, uint256 amt) public {
        erc20Contract.transfer(receipt, amt);
    }

    function transferCreditFrom(address from, address to, uint256 amt) public {
        erc20Contract.transferFrom(from, to, amt);
    }

}