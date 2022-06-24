pragma solidity ^0.8.7;

import './Production_line.sol';

contract Stack_holder{

    Production_line_interface pl_interface;
    address pl_interface_address;
    
    mapping(string => string[]) serials_by_code;
    bytes32[] prod_models;

    constructor(){

    }

    
    function add_prod_model(string memory _prod_code, string memory _name, string memory _description)
    external{
        pl_interface.add_prod_model(toBytes32(_prod_code), toBytes32(_name), _description);
    }

    function add_field_prod(string memory _prod_code, string memory _name, string memory _type, bool _is_static, string memory _value)
    external{
        pl_interface.add_field_prod(toBytes32(_prod_code), toBytes32(_name), toBytes16(_type), _is_static, _value);
    }

    function add_product(string memory _prod_code, uint _amount) 
    external{
        pl_interface.add_product(toBytes32(_prod_code), _amount);
    }

    function set_prod_profile(string memory _serial, string memory _field_name, string memory _value) 
    external{
        pl_interface.set_prod_profile(_serial, toBytes32(_field_name), _value);
    }

    function cover(string memory _serial, string[] memory _covers)
    external{
        pl_interface.cover(_serial, _covers); 
    }



    function add_batch_model(string memory _batch_number, string memory _prod_code, uint _product_amount, string memory _name, string memory _description) 
    external returns(bytes32){
        pl_interface.add_batch_model(toBytes32(_batch_number), toBytes32(_prod_code), _product_amount, toBytes32(_name), _description);
    }

    function add_field_batch(string memory _prod_code, string memory _name, string memory _type, bool _is_static, string memory _value) 
    external{
        pl_interface.add_field_batch(toBytes32(_prod_code), toBytes32(_name), toBytes16(_type), _is_static, _value);
    }

    function set_batch_model(string memory _prod_code, string memory _field_name, string memory _value)
    external{
        pl_interface.set_batch_model(toBytes32(_prod_code), toBytes32(_field_name), _value);
    }

    function add_batch(string memory _prod_code, uint _amount) 
    external{
        pl_interface.add_batch(toBytes32(_prod_code), _amount);
    }

    function set_batch_profile(string memory _serial, string memory _field_name, string memory _value) 
    external{
        pl_interface.set_batch_profile(_serial, toBytes32(_field_name), _value);
    }




















    function get_all_serials(string memory _prod_code)
    external
    view
    returns(string[] memory){
        return serials_by_code[_prod_code];
    }


    function aaddress(address _address) 
    external{
        pl_interface_address = _address;
        pl_interface = Production_line_interface(pl_interface_address);
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