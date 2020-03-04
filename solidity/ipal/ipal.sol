pragma solidity 0.6.0;
// using SafeMath for uint256;

contract Ipal {
    // using SafeMath for uint256;
    
    /////////////////////////////////////////// IPAL /////////////////////////////////////////// 
    address adminAddress    = 0xdCad3a6d3569DF655070DEd06cb7A1b2Ccd1D3AF;
    uint256 minBond         = 1000000;
    
    enum UnApproveReason {
        NONE,
        BOND_NOT_ENOUGH,
        UNCLAIM,
        UPDATE
    }
    
    struct IpalItem {
        string moniker;
        string ipalDeclaration;
        uint256 bond;
        bool isApproved;
        UnApproveReason unApproveReason;
    }
    
    mapping(address=>IpalItem) public ipals;
    mapping(string=>bool) public monikerExistChecker;
    address[] public ipalKeys;
    
    
    /*
    *param @ipalDeclaration: '{"website":"netcloth.org","details":"netcloth-offical","endpoints":[{"type":1,"endpoint":"http://47.104.189.5"}]}'
    */
    function ipalClaim(string memory moniker, string memory ipalDeclaration) public payable {
        require (0 == ipals[msg.sender].bond);
        require (msg.value >= minBond);
        require (false == monikerExistChecker[moniker]);
        
        IpalItem memory ipal;
        ipal.moniker = moniker;
        ipal.ipalDeclaration = ipalDeclaration;
        ipal.bond = msg.value;
        ipal.isApproved = false;
        ipal.unApproveReason = UnApproveReason.NONE;
        
        ipals[msg.sender] = ipal;
        monikerExistChecker[moniker] = true;
        ipalKeys.push(msg.sender);
    }
    
    function ipalUpdate(string memory moniker, string memory ipalDeclaration) public payable {
        IpalItem memory ipal = ipals[msg.sender];
        
        require (ipal.bond > 0);
        require (bytes(moniker).length > 0);
        
        bytes memory d1 = abi.encodePacked(moniker);
        bytes memory d2 = abi.encodePacked(ipal.moniker);
        bytes32 hash1 = sha256(d1);
        bytes32 hash2 = sha256(d2);
        require (hash1 != hash2 && monikerExistChecker[moniker] == false);
        
        uint256 targetBond = ipal.bond + msg.value; //TODO CHECK overflow
        require (targetBond >= minBond);
        
        ipal.moniker = moniker;
        ipal.ipalDeclaration = ipalDeclaration;
        ipal.bond = targetBond;
        ipal.isApproved = false;
        ipal.unApproveReason = UnApproveReason.UPDATE;
        
        ipals[msg.sender] = ipal;
        monikerExistChecker[moniker] = true;
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
    
    function auth(address newAdminAccountAddress) public {
        assert (msg.sender == adminAddress);
        assert (msg.sender != newAdminAccountAddress);
        adminAddress = newAdminAccountAddress; // Warning: newAdminAccountAddress should be valid
    }
    
    function updateMinBond(uint256 newMinBond) public {
        assert (msg.sender == adminAddress);
        minBond = newMinBond;
    }
    
    function getIpalKeys() public view returns(address[] memory v) {
        return ipalKeys;
    }
    
    
    /////////////////////////////////////////// CIPAL implemet1 ///////////////////////////////////////////
    mapping(address=>string) public cipals;
    
    /*
    *param @cipalDeclaration: '{"ipals":[{"type":1,"address":0}]}'
    */
    
    function cipalClaim(string memory cipalDeclaration, address userAddr, bytes32 R, bytes32 S, uint8 V) public {
        bytes memory d = abi.encodePacked(cipalDeclaration, userAddr);
        bytes32 hash = sha256(d);
        address expected_addr = ecrecover(hash, V, R, S);
        require (expected_addr == userAddr);
        
        cipals[userAddr] = cipalDeclaration;
    }
    
    // /////////////////////////////////////////// CIPAL implemet2 ///////////////////////////////////////////
    // struct IpalIndex {
    //     address ipalAddr;
    //     uint16 ipalType;
    // }
    
    // struct CIpalItem {
    //     bool exist;
    //     IpalIndex[] ipals;
    // }
    
    // mapping(address=>CIpalItem) public cipals2;
    
    // function cipalClaim2(address ipalAddr, uint16 ipalType, address userAddr, bytes32 R, bytes32 S, uint8 V) public {
    //     bytes memory d = abi.encodePacked(ipalAddr, ipalType, userAddr);
    //     bytes32 hash = sha256(d);
    //     address expected_addr = ecrecover(hash, V, R, S);
    //     require (expected_addr == userAddr);
        
    //     CIpalItem memory cipal = cipals[userAddr];
    //     if (cipal.exist == true) {
            
    //     } else {
    //         cipal.exist = true;
    //     }
    // }
}


