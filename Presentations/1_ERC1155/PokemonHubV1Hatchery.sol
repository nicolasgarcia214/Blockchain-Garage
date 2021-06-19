// SPDX-License-Identifier: MIT
pragma solidity 0.8.5;

contract PokemonHubV1Hatchery{
    
    mapping(uint256 => mapping(address => uint256)) private balances;
    mapping(address => mapping(address => bool)) private operatorApprovals;
    
    uint256 public constant CHARMANDER = 0;
    uint256 public constant BULBASAUR = 1;
    uint256 public constant SQUIRTLE = 2;
    
    string private _uri;

    constructor(string memory uri_) {
        _setURI(uri_);
        _mint(msg.sender, CHARMANDER, 120, "");
        _mint(msg.sender, BULBASAUR, 120, "");
        _mint(msg.sender, SQUIRTLE, 120, "");
    }
    
    event TransferSingle(address indexed _operator, address indexed _from, address indexed _to, uint256 _id, uint256 _value);

    event TransferBatch(address indexed _operator, address indexed _from, address indexed _to, uint256[] _ids, uint256[] _values);

    event ApprovalForAll(address indexed _owner, address indexed _operator, bool _approved);

    event URI(string _value, uint256 indexed _id);

    function safeTransferFrom(address _from, address _to, uint256 _id, uint256 _value, bytes calldata _data) external{
        require(_from == msg.sender || operatorApprovals[_from][msg.sender] == true, "Need operator approval for 3rd party transfers.");
        require(balances[_id][_from] >= _value, "ERC1155: insufficient balance for transfer");
        
        unchecked {
            balances[_id][_from] -= _value;
        }
        balances[_id][_to] += _value;

        emit TransferSingle(msg.sender, _from, _to, _id, _value);
    }

    function safeBatchTransferFrom(address _from, address _to, uint256[] calldata _ids, uint256[] calldata _values, bytes calldata _data) external{
        require(_ids.length == _values.length, "_ids and _values array length must match.");
        require(_from == msg.sender || operatorApprovals[_from][msg.sender] == true, "Need operator approval for 3rd party transfers.");
        
        for (uint256 i = 0; i < _ids.length; ++i) {
            uint256 id = _ids[i];
            uint256 amount = _values[i];

            uint256 fromBalance = balances[id][_from];
            require(fromBalance >= amount, "ERC1155: insufficient balance for transfer");
            unchecked {
                balances[id][_from] = fromBalance - amount;
            }
            balances[id][_to] +=  amount;
        }

        emit TransferBatch(msg.sender, _from, _to, _ids, _values);
    }

    function balanceOf(address _owner, uint256 _id) external view returns (uint256){
        return balances[_id][_owner];
    }

    function balanceOfBatch(address[] calldata _owners, uint256[] calldata _ids) external view returns (uint256[] memory){
        require(_owners.length == _ids.length, "Accounts and ids length mismatch");
        
        uint256[] memory balances_ = new uint256[](_owners.length);

        for (uint256 i = 0; i < _owners.length; ++i) {
            balances_[i] = balances[_ids[i]][_owners[i]];
        }

        return balances_;
    }

    function setApprovalForAll(address _operator, bool _approved) external{
        operatorApprovals[msg.sender][_operator] = _approved;
        emit ApprovalForAll(msg.sender, _operator, _approved);
    }

    function isApprovedForAll(address _owner, address _operator) external view returns (bool){
        return operatorApprovals[_owner][_operator];
    }
    
    ////ADDITIONAL FUNCTIONS////
    
    function _mint(
        address account,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) internal {
        address operator = msg.sender;

        balances[id][account] += amount;
        emit TransferSingle(operator, address(0), account, id, amount);
    }
    
    function _setURI(string memory newuri) internal {
        _uri = newuri;
    }
    
}