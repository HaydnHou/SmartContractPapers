pragma solidity >=0.4.22 <0.7.0;

/**
 * @title Billboard
 * @dev Billboard
 */
contract Billboard {

 struct App {
        string name; 
        address owner;
        uint8[] stars;   
        mapping(address => uint) star0f;
        uint totalStar;
    }
    
    App[] public apps;
    
        // event for EVM logging
    event Publish(string indexed name, address indexed owner, uint appId);
    event Star(address indexed user, uint indexed appId, uint8 num);
    
    
    
    /**
     * @dev publish
     * 
     */
    function publish(string memory name) public {
        require(bytes(name).length>0, "name empty error");
        apps.push(App(name,msg.sender,new uint8[](0),0));
        emit Publish(name,msg.sender,apps.length-1);
    }

  /**
     * @dev star
     * 10,5 4,4 5,3 6,2 2,1
     */
    function star(uint appId, uint8 num) public {
        require(appId < apps.length,"app id error");
        require(num <= 5 && num >= 1, "star num error");
        require(apps[appId].star0f[msg.sender] == 0,"user error");
        App storage app =  apps[appId];
        app.stars.push(num);
        app.totalStar += num;
        app.star0f[msg.sender] = app.stars.length-1;
        emit Star(msg.sender,appId,num);
    }
    /**
     * @dev Return value 
     * @return value of 'number'
     */
    function top() public view returns (uint[] memory topIds){
        topIds = new uint[](10);
        for(uint appId = 1; appId < apps.length ; appId++){
            uint topLast = appId < topIds.length? appId:topIds.length-1;
            if(appId >= topIds.length&&apps[appId].totalStar <= apps[topIds[topLast]].totalStar){
                continue;
            }
            topIds[topLast] = appId;
            for(uint i = topLast; i > 0 ; i--){
                if(apps[topIds[i]].totalStar > apps[topIds[i-1]].totalStar){
                    uint tempAppId = topIds[i];
                    topIds[i] = topIds[i-1];
                    topIds[i-1] = tempAppId;
                }else{
                    continue;
                }
            }
        }
    }
  }