pragma solidity >=0.4.22 <0.6.0;

contract MartianAuction {
    address deployer;
    
    address payable public beneficiary;
    address public highestBidder;
    uint public highestBid;
    
    mapping(address => uint) pendingReturns;
    
    bool public ended;
    
    event highestBidIncreased(address bidder, uint amount);
    event AucionEnded(address winner, uint amount);


    constructor(
        address payable _beneficiary
    ) public {
        beneficiary = _beneficiary;
    }

    function bid(address payable sender) public payable {
        require(
            msg.value > highestBid,
            "There already is a higher bid.");
            
        require(!ended, "auctionEnd has already been called.");
        if (highestBid != 0) {
            pendingReturns[highestBidder] += highestBid;
        }
    
        highestBidder = sender;
        highestBid = msg.value;
        emit highestBidIncreased(sender, msg.value);
        
    }

    function withdraw() public returns (bool) {
        uint amount = pendingReturns[msg.sender];
        if (amount > 0) {
            pendingReturns[msg.sender] = 0;
            if (!msg.sender.send(amount)) {
                pendingReturns[msg.sender] = amount;
                return false;
            }
        }
        return true;

    }

    function pendingReturn(address sender) public view returns (uint) {
        return pendingReturns[sender];
    }

    function auctionEnd() public {
        // 1. Conditions
        require(!ended, "auctionEnd has already been called.");
        require(msg.sender == deployer, "You are not the auction deployer!");
        
        // 2. Effects
        ended = true;
        emit AucionEnded(highestBidder, highestBid);
        
        // 3. Interaction
        beneficiary.transfer(highestBid);
        
    }
}
