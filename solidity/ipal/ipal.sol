pragma solidity 0.6.0;

contract Ipal {
    uint16 constant MAX_IPALS = 1024;
    
    address adminAddress    = 0xdCad3a6d3569DF655070DEd06cb7A1b2Ccd1D3AF;
    uint64 minBond          = 1000000000;
    
    struct IpalItem {
        string ipalDeclaration;
        uint256 bond;
        bool isApproved;
    }
    
    mapping(address=>IpalItem) public ipals;
    address[] public keys = new address[](MAX_IPALS);
    
    function ipalClaim(string memory ipalDeclaration) public payable {
        IpalItem memory existItem = ipals[msg.sender];
        if (0 == existItem.bond) {
            IpalItem memory v;
            v.ipalDeclaration = ipalDeclaration;
            v.bond = msg.value;
            v.isApproved = false;
            
            ipals[msg.sender] = v;
            
            keys.push(msg.sender);
        } else {
            
        }
    }
    
    function getIpalKeys() public view returns(address[] memory v) {
        return keys;
    }
}

