pragma solidity >=0.4.22 <0.7.0;

import "github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/math/SafeMath.sol";

contract TriToken {
    
    // Price of token
    uint256 public tokenPrice;
    // Supply (total tokens of token)
    uint256 private totalSupply = 100;
    // Owner of contract
    address private owner;
    // Tokens which are currently bought
    uint256 private tokensBought;
    // Value stored in contract
    uint256 private value;
    // Balances of all users using this token 
    mapping(address=>uint256) private balances;
    
    // Events of contract
    event Purchase(address buyer, uint256 amount);
    event Transfer(address sender, address receiver, uint256 amount);
    event Sell(address seller, uint256 amount);
    event Price(uint256 price);
    
    using SafeMath for uint256;
    
    // Constructor of custom token
    constructor(uint256 price) public {
        tokenPrice = price;
        owner = msg.sender;
        emit Transfer(address(0),address(this),totalSupply);
    }

    // Buy specific amount of tokens
    function buyToken(uint256 amount) public payable returns (bool success) {
        
        require(amount <= totalSupply.sub(tokensBought), "Insufficient amount to buy. .");
        require(msg.value == amount.mul(tokenPrice).mul(1 wei),
                "Please pay the required amount of wei to buy tokens.");
                
        balances[msg.sender] = balances[msg.sender].add(amount);
        tokensBought = tokensBought.add(amount);
        value = value.add(amount.mul(tokenPrice));
        
        emit Purchase(msg.sender, amount);
        
        return true;
    }
    
    // Transfer specific amount of tokens from msg.sender to recepient address
    function transfer(address recepient, uint256 amount) public returns (bool success) {
        
         // Check if user has the amount to transfer
        require(amount <= balances[msg.sender], "Insufficient amount to transfer. Please check your balance.");
        
        // Subtract amount from sender's balance
        balances[msg.sender] = balances[msg.sender].sub(amount);
        // Add amount to recepient's balance
        balances[recepient] = balances[recepient].add(amount);
        
        emit Transfer(msg.sender, recepient, amount);
        
        return true;
    }
    
    // Sell specific amount of tokens
    function sellToken(uint256 amount) public returns (bool success) {
        
        // Check if user has the amount to sell
        require(amount <= balances[msg.sender], "Insufficient amount to sell. Please check your balance.");
        
        balances[msg.sender] = balances[msg.sender].sub(amount);
        tokensBought = tokensBought.sub(amount);
        // Destroy tokens sold
        totalSupply = totalSupply.sub(amount);
        
        // Transfer value to user
        msg.sender.transfer(amount.mul(tokenPrice).mul(1 wei));
        emit Sell(msg.sender, amount);
        
        return true;
    }
    
    // Change price of token
    function changePrice(uint256 price) public payable returns (bool success) {
        require(msg.sender == owner, "Only the owner can change the price");
        require(price != tokenPrice, "Please give a different price as this is equal to current token price.");
        
        // If new price is greater add value to contract,
        // so users can sell tokens to get their "crypto money" back.
        if (price > tokenPrice) {
            require(msg.value == price.sub(tokenPrice).mul(tokensBought).mul(1 wei),
                    "Please pay the required amount of wei to change price.");
            value = value.add(price.sub(tokenPrice).mul(tokensBought));
        // Else the owner gets the value left
        } else if (price < tokenPrice) {
            value = value.sub(tokenPrice.sub(price).mul(tokensBought));
            msg.sender.transfer(tokenPrice.sub(price).mul(tokensBought).mul(1 wei));
        }
        
        // Change price of token
        tokenPrice = price;
        emit Price(tokenPrice);
        
        return true;
    }
    
    // Get balance of user
    function getBalance() public view returns (uint256 balance) {
        return balances[msg.sender];
    }
}
