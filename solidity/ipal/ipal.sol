pragma solidity 0.6.0;
// using SafeMath for uint256;

contract Ipal {
    // using SafeMath for uint256;
    
    /////////////////////////////////////////// IPAL /////////////////////////////////////////// 
    address adminAddress    = 0xdCad3a6d3569DF655070DEd06cb7A1b2Ccd1D3AF;
    uint64 minBond          = 1000000;
    
    enum UnApproveReason {
        NONE,
        BOND_NOT_ENOUGH,
        UNCLAIM
    }
    
    struct IpalItem {
        string ipalDeclaration;
        uint256 bond;
        bool isApproved;
        UnApproveReason unApproveReason;
    }
    
    mapping(address=>IpalItem) public ipals;
    address[] public ipalKeys;
    
    function ipalClaim(string memory ipalDeclaration) public payable {
        IpalItem memory v;
        IpalItem memory existItem = ipals[msg.sender];
        
        uint256 targetBond = existItem.bond + msg.value; //TODO CHECK overflow
        require (targetBond >= minBond);
        
        v.ipalDeclaration = ipalDeclaration;
        v.bond = targetBond;
        v.isApproved = false;
        v.unApproveReason = UnApproveReason.NONE;
        
        ipals[msg.sender] = v;
        ipalKeys.push(msg.sender);
    }
    
    function ipalUnClaim() public {
        IpalItem memory ipal = ipals[msg.sender];
        
        require(ipal.bond != 0);
        
        msg.sender.transfer(ipal.bond);
        
        ipal.bond = 0;
        ipal.isApproved = false;
        ipal.unApproveReason = UnApproveReason.UNCLAIM;
        
        ipals[msg.sender] = ipal;
    }
    
    function ipalApprove(address addr) public {
        assert (msg.sender == adminAddress);
        
        IpalItem memory ipal = ipals[addr];
        require (ipal.bond >= minBond);
        
        ipal.isApproved = true;
        ipals[addr] = ipal;
    }
    
    function ipalUnApprove(address addr, UnApproveReason reason) public {
        assert (msg.sender == adminAddress);
        
        IpalItem memory ipal = ipals[addr];
        require (ipal.bond > 0);
        
        ipal.isApproved = false;
        ipal.unApproveReason = reason;
        ipals[addr] = ipal;
    }
    
    function getIpalKeys() public view returns(address[] memory v) {
        return ipalKeys;
    }
    
    
    /////////////////////////////////////////// CIPAL ///////////////////////////////////////////
}


