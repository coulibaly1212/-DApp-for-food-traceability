pragma solidity ^0.8.7;
import './Strings.sol';
import './Production_line.sol';

contract Tracability{


/*

    // Declaration Batch de produit
    struct Batch{
        address owner;
        string serial;
        bytes13 prod_code;
        string[] covers;
        bool is_done;
        string[] products;
    }

    // Declaration production
    struct Product{
        address owner;
        string serial;
        bytes13 prod_code;
        string batch_number;
        bool is_done;
        string[] covers;
    }

    // Declaration profile
    struct Profile{
        Field_header[] field_heads;
        mapping(bytes16 => string) strings;
        mapping(bytes16 => uint) uints;
        mapping(bytes16 => uint) dates;
    }

    // Declaration de la maquette de produit
    struct Model{
        address owner;
        bytes13 prod_code;
        bytes16 name;
        string desc;
        Field_header[] field_headers;
        mapping(bytes16 => string) static_values;
    }

    // Declaration de entete de champs
    struct Field_header{
        bytes16 name;
        Field_header_type type_of_field; 
        bool is_static;
    }

    // Declaration des types de champs
    enum Field_header_type {
        FORBIDDEN,
        STRING,
        UINT,
        DATE
    }


    mapping(string => Product) product_list;
    mapping(string => Batch) batch_list;

    mapping(string => Profile) prod_profile_list;
    mapping(string => Profile) batch_profile_list;

    mapping(bytes13 => Model) prod_model_list;
    mapping(bytes13 => Model) batch_model_list;

    mapping(bytes16 => Field_header_type) field_header_type_list;
    mapping(Field_header_type => bytes16) string_type_list;

    mapping(string => uint) prod_counter_by_code;
    mapping(string => uint) batch_counter_by_code;

    

    string[] serial_list;
    string[] batch_number_list;


    */

    




    // Declaration Batch de produit
    struct Batch{
        address owner;
        string serial;
        string prod_code;
        string[] covers;
        bool is_done;
        string[] products;
    }

    // Declaration production
    struct Product{
        address owner;
        string serial;
        string prod_code;
        string batch_number;
        bool is_done;
        string[] covers;
    }

    // Declaration profile
    struct Profile{
        Field_header[] field_heads;
        mapping(string => string) strings;
        mapping(string => uint) uints;
        mapping(string => uint) dates;
    }

    // Declaration de la maquette de produit
    struct Model{
        address owner;
        string prod_code;
        string name;
        string desc;
        Field_header[] field_headers;
        mapping(string => string) static_values;
    }

    // Declaration de entete de champs
    struct Field_header{
        string name;
        Field_header_type type_of_field; 
        bool is_static;
    }

    // Declaration des types de champs
    enum Field_header_type {
        FORBIDDEN,
        STRING,
        UINT,
        DATE
    }


    mapping(string => Product) product_list;
    mapping(string => Batch) batch_list;

    mapping(string => Profile) prod_profile_list;
    mapping(string => Profile) batch_profile_list;

    mapping(string => Model) prod_model_list;
    mapping(string => Model) batch_model_list;

    mapping(string => Field_header_type) field_header_type_list;
    mapping(Field_header_type => string) string_type_list;

    mapping(string => uint) prod_counter_by_code;
    mapping(string => uint) batch_counter_by_code;

    

    string[] serial_list;
    string[] batch_number_list;
    

}