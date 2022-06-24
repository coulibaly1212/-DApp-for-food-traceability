pragma solidity ^0.8.7;

import './Strings.sol';

interface Authentification_pl{

}

interface Authentification_sh{

}

contract Authentification{

    struct Stack_holder{
        bytes32 id;
        bytes32 pass;
        string email;
        address s_address;
        Business business;
        mapping(address => Stack_holder) sub_stack_holder;
    }

    struct Business{
        bytes2 country_code;
        bytes11 business_number;
        string name;
        string description;
        Section root_section;
    }

    struct Section{
        bytes32 id; 
        bytes32 over_section;
        string name;
        string description;
        uint level;
        mapping(bytes32 => Section) sub_sections;
    }

    mapping(address => Stack_holder) stack_holder_list;
    mapping(address => uint) connection_timeout;



    function authentify(address _address, string memory _pass) external{
        require(is_already_exist(_address), "Cet adresse n'existe pas !!!");
        require(stack_holder_list[_address].pass == keccak256(abi.encodePacked(_pass)), "Mot de passe incoherent !!!");
        refresh_session(_address);
    }

    function refresh_session(address _address) internal{
        connection_timeout[_address] = block.timestamp + 1200;
    }

    function has_on_time(address _address) external view returns(bool){
        require(is_already_exist(_address), "Partie prenante non reconnue !!!");
        return connection_timeout[_address] > block.timestamp;
    }



    function add_stack_holder(string memory _email, string memory _pass) 
    external returns(bytes32){
        require(!is_already_exist(msg.sender), "Cette partie prenante existe deja !!!");
        Stack_holder storage stack_holder = stack_holder_list[msg.sender];
        stack_holder.pass = keccak256(abi.encodePacked(_pass));
        stack_holder.email = _email;
        stack_holder.id = keccak256(abi.encodePacked(Strings.address_to_string(msg.sender),_pass, Strings.toString(block.timestamp))); 
        return stack_holder.id;
    }



    function is_already_exist(address _address)
    internal view returns(bool){
        return stack_holder_list[_address].id != toBytes32(""); 
    }















    function toBytes32(string memory source) public pure returns (bytes32 result) {
        bytes memory tempEmptyStringTest = bytes(source);
        if (tempEmptyStringTest.length == 0) {
            return 0x0;
        }assembly {result := mload(add(source, 32))}
    }

    function toBytes16(string memory source) public pure returns (bytes16 result) {
        bytes memory tempEmptyStringTest = bytes(source);
        if (tempEmptyStringTest.length == 0) {
            return 0x0;
        }assembly {result := mload(add(source, 32))}
    }

}