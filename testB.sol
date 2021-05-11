pragma solidity >=0.6.0 <=0.8.3;
pragma experimental ABIEncoderV2;

contract Owned{
    address payable private owner;
    
    constructor() public {
        owner = payable(msg.sender);
    }
    
    modifier OnlyOwner{
        require(
            msg.sender == owner,
            'Only owner can run this function!'
            );
        _;
    }
    
    function ChangeOwner(address payable newOwner) public OnlyOwner{
        owner = newOwner;
    }
    
    function GetOwner() public returns (address){
        return owner;
    }
}

contract ROSReestr is Owned{
    enum RequestType {NewHome, EditHome}
    enum OwnerOperation {Add, Edit, Delete}
    
    struct Ownership
    {
        string homeAddress;
        address owner;
        uint p;
    }
    
    struct Owner
    {
        string name;
        uint passSer;
        uint passNum;
        uint256 date;
        string phoneNumber;
        bool isset;
    }
    
    struct Home
    {
        string homeAddress;
        uint area;
        uint cost;
        bool isset;
    }
    
    struct Request
    {
        RequestType requestType;
        OwnerOperation operation;
        string homeAddress;
        uint area;
        uint cost;
        uint result;
        address adr;
        bool isProcessed;
    }
    
    struct Employee
    {
        string name;
        string position;
        string phoneNumber;
        bool isset;
    }
    
    mapping(address => Employee) private employees;
    mapping(address => Owner) private owners;
    //key is request initiator
    mapping(address => Request) private requests;
    address[] requestInitiator;
    address[] ownersArray;
    mapping(string => Home) private homes;
    string[] addresses;
    mapping(string => Ownership[]) private ownerships;
    
    uint private amount;
    
    modifier OnlyEmployee {
        require(
            employees[msg.sender].isset != false,
            'Only Employee can run this function!'
            );
        _;
    }
    
    modifier Costs(uint value){
        require(
            msg.value >= value,
            'Not enough funds!!'
            );
        _;
    }
    
    function AddHome(string memory _adr, uint _area, uint _cost) public {
        Home memory h;
        h.homeAddress = _adr;
        h.area = _area;
        h.cost = _cost;
        homes[_adr] = h;
        addresses.push(_adr);
    }
    
    function GetHome(string memory adr) public returns (uint _area, uint _cost){
        return (homes[adr].area, homes[adr].cost);
    }
    
    function AddEmployee(address empl, string memory _name, string memory _pos, string memory _phone) public OnlyOwner{
        Employee memory e;
        e.name = _name;
        e.position = _pos;
        e.phoneNumber = _phone;
        e.isset = true;
        employees[empl] = e;
    }
    
    function EditEmployee(address empl, string memory _name, string memory _pos, string memory _phone) public OnlyOwner{
        employees[empl].name = _name;
        employees[empl].position = _pos;
        employees[empl].phoneNumber = _phone;
    }
    
    function GetEmployee(address empl) public OnlyOwner returns (string memory _name, string memory _pos, string memory _phone){
        return (employees[empl].name, employees[empl].position, employees[empl].phoneNumber);
    }
    
    function DeleteEmployee(address empl) public OnlyOwner returns (bool)
    {
        if (employees[empl].isset == true){
            delete employees[empl];
            return true;
        }
        return false;
    }
    
    function AddRequest(uint rType, string memory adr, uint area, uint cost, address newOwner) public Costs(1e12) payable returns (bool)
    {
        Request memory r;
        r.requestType = rType == 0? RequestType.NewHome: RequestType.EditHome;
        r.homeAddress = adr;
        r.area = area;
        r.cost = cost;
        r.result = 0;
        r.adr = rType==0?address(0):newOwner;
        r.isProcessed = false;
        requests[msg.sender] = r;
        requestInitiator.push(msg.sender);
        amount += msg.value;
        return true;
    }
    
    function GetRequest() public OnlyEmployee returns (uint[] memory, uint[] memory, string[] memory)
    {
        uint[] memory ids = new uint[](requestInitiator.length);
        uint[] memory types = new uint[](requestInitiator.length);
        string[] memory homeAddresses = new string[](requestInitiator.length);
        for(uint i=0;i!=requestInitiator.length;i++){
            ids[i] = i;
            types[i] = requests[requestInitiator[i]].requestType == RequestType.NewHome ? 0: 1;
            homeAddresses[i] = requests[requestInitiator[i]].homeAddress;
        }
        return (ids, types, homeAddresses);
    }
    
    function ProcessRequest(uint Id) public OnlyEmployee returns (uint){
        if(Id<0 || Id>=requestInitiator.length) return 1;
        Request memory r = requests[requestInitiator[Id]];
        if(r.requestType == RequestType.NewHome && homes[r.homeAddress].isset){
            delete requests[requestInitiator[Id]];
            delete requestInitiator[Id];
            return 2;
        } 
        if(r.requestType == RequestType.NewHome){
            //add new Home
            AddHome(r.homeAddress, r.area, r.cost);
            //set ownership
            Ownership memory ownership;
            ownership.homeAddress = r.homeAddress;
            ownership.owner = requestInitiator[Id];
            ownership.p = 1;
            ownerships[r.homeAddress].push(ownership);
        } else {
            //edit home
            //change ownership
        }
        delete requests[requestInitiator[Id]];
        delete requestInitiator[Id];
        return 0;
    }
}