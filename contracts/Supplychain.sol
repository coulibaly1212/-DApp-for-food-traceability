pragma solidity ^0.8.7;

import './Strings.sol';

interface Production_line_interface {
    function add_prod_model(bytes32 _prod_code, bytes32 _name, string memory _description) 
    external
    returns(bytes32);

    function add_field_prod(bytes32 _prod_code, bytes32 _name, bytes16 _type, bool _is_static, string memory _value) 
    external;

    function set_prod_model(bytes32 _prod_code, bytes32 _field_name, string memory _value)
    external;

    function add_product(bytes32 _prod_code, uint _amount) 
    external
    returns(string[] memory _serials);

    function set_prod_profile(string memory _serial, bytes32 _field_name, string memory _value) 
    external;

    function cover(string memory _serial, string[] memory _covers)
    external;





    function add_batch_model(bytes32 _batch_number, bytes32 _prod_code, uint _product_amount, bytes32 _name, string memory _description) 
    external returns(bytes32);

    function add_field_batch(bytes32 _prod_code, bytes32 _name, bytes16 _type, bool _is_static, string memory _value) 
    external;

    function set_batch_model(bytes32 _prod_code, bytes32 _field_name, string memory _value)
    external;

    function add_batch(bytes32 _prod_code, uint _amount) 
    external;

    function set_batch_profile(string memory _serial, bytes32 _field_name, string memory _value) 
    external;
}

contract Production_line{

    // Les types de valeur possible 
    enum Field_type { FORBIDDEN, STRING, UINT, DATE }

    struct Stack_holder{
        bytes pass_word;
        string[] serials;
        string[] batch_serials;
        uint[] prod_codes;
    }

    // L'entete de champ
    struct Field_header{
        bytes32 name;
        Field_type field_type; 
        bool is_static;
    }

    // Profil 
    struct Profile{
        Field_header[] field_heads;
        mapping(bytes32 => string) strings;
        mapping(bytes32 => uint) uints;
        mapping(bytes32 => uint) dates;
    }

    // Maquette de produit
    struct Model{
        address owner;
        bytes32 prod_code;
        bytes32 name;
        string description;
        Field_header[] field_headers;
        mapping(bytes32 => string) static_values;
    }

    // Produit
    struct Product{
        address owner;
        string serial;
        bytes32 prod_code;
        string batch_number;
        bool is_done;
        bool is_recalled;
    }

    // Lot de produit
    struct Batch{
        address owner;
        string serial;
        bytes32 prod_code;
        bytes32 batch_number;
        uint product_amount;
        string[] products;
        bool is_done;
        bool is_recalled;
    }
    

    
    
    event added_product_mockup(bytes32 _prod_code, bytes32 _name, string _description);
    
    event added_product_mockup_field(bytes32 _prod_code, bytes32 _name, bytes16 _type, bool _is_static, string _value);
    
    event added_product(string[] _serials);

    event changed_string_value_product_profil(string _serial, bytes32 _field_name, string _value);

    event changed_uint_value_product_profil(string _serial, bytes32 _field_name, uint _value);

    event changed_date_value_product_profil(string _serial, bytes32 _field_name, uint _value);



    // Creation Model
    function add_prod_model(bytes32 _prod_code, bytes32 _name, string memory _description) 
    external
    returns(bytes32){
        // Verifier si le un modele de produit existe deja avec le meme code produit
        require(prod_model_list[_prod_code].prod_code == toBytes32(""), "Code produit est deja en service !!!");
        return add_model(_prod_code, _name, _description, true);
    }

    function add_model(bytes32 _prod_code, bytes32  _name, string memory _description, bool _is_product)
    internal
    returns(bytes32){
        mapping(bytes32 => Model) storage model_list = batch_model_list;
        if(_is_product) model_list = prod_model_list;

        model_list[_prod_code].owner = msg.sender;
        model_list[_prod_code].prod_code = _prod_code;
        model_list[_prod_code].name = _name;
        model_list[_prod_code].description = _description;

        add_model_field(_prod_code, toBytes32("entreprise de production"), toBytes16("STRING"), false, "", _is_product);
        add_model_field(_prod_code, toBytes32("etape de fabrication"), toBytes16("STRING"), false, "", _is_product);
        add_model_field(_prod_code, toBytes32("date de fabrication"), toBytes16("DATE"), false, "", _is_product);
        add_model_field(_prod_code, toBytes32("date d'expiration"), toBytes16("DATE"), false, "", _is_product);
        
        emit added_product_mockup(_prod_code, _name, _description);

        return _prod_code;
    }

    


    // Ajout du champs a un model de produit
    function add_field_prod(bytes32 _prod_code, bytes32 _name, bytes16 _type, bool _is_static, string memory _value) 
    external{
        add_model_field(_prod_code, _name, _type, _is_static, _value, true);
    }


    function add_model_field(bytes32 _prod_code, bytes32 _name, bytes16 _type, bool _is_static, string memory _value, bool _is_product)
    internal{

        // Choisir la bonne liste de model
        mapping(bytes32 => Model) storage model_list = batch_model_list;
        if(_is_product) model_list = prod_model_list;

        // Verifier que c'est bien le proprietaire qui tente de modifier le maquette
        require(model_list[_prod_code].owner == msg.sender, "Titre proprietaire Model requit pour cette action !!!");
        
        // Verifier si le type entré existe dans notre contract
        require(field_type_list[_type] == Field_type.STRING || field_type_list[_type] == Field_type.UINT || field_type_list[_type] == Field_type.DATE, "Type de donnees non autorise !!!");

        // Verifier si le champs existe
        if(_is_product) require(!is_field_already_create_on_prod(_prod_code, _name), "Champ existant !");
        else require(!is_field_already_create_on_batch(_prod_code, _name), "Champ existant !");

        // Ajout dans la liste des entetes de la maquette
        model_list[_prod_code].field_headers.push(Field_header(_name, field_type_list[_type], _is_static));

        if(_is_static){
            model_list[_prod_code].static_values[_name] = _value;
        }

        emit added_product_mockup_field(_prod_code, _name, _type, _is_static, _value);
    }


    function set_prod_model(bytes32 _prod_code, bytes32 _field_name, string memory _value)
    external{
        set_model_field(_prod_code, _field_name, _value, true);
    }


    function set_model_field(bytes32 _prod_code, bytes32 _field_name, string memory _value, bool _is_product)
    internal{
        mapping(bytes32 => Model) storage model_list = batch_model_list;
        if(_is_product) model_list = prod_model_list;
        require(model_list[_prod_code].owner == msg.sender, "Titre proprietaire Model requit pour cette action !!!");
        
        for(uint index = 0; index < model_list[_prod_code].field_headers.length; index++){
            if(model_list[_prod_code].field_headers[index].name == _field_name){
                require(model_list[_prod_code].field_headers[index].is_static, "Ce champs n'est pas static !!!");
                model_list[_prod_code].static_values[_field_name] = _value;
                return;
            }
        }
    }


    function is_field_already_create_on_prod(bytes32 _prod_code, bytes32 _name) 
    internal view returns(bool){
        for(uint index = 0; index < prod_model_list[_prod_code].field_headers.length; index++)
        if(prod_model_list[_prod_code].field_headers[index].name == _name) return true;
        return false;
    }

    function is_field_already_create_on_batch(bytes32 _prod_code, bytes32 _name) 
    internal view returns(bool){
        for(uint index = 0; index < batch_model_list[_prod_code].field_headers.length; index++) 
        if(batch_model_list[_prod_code].field_headers[index].name == _name) return true;
        return false;
    }


    function add_product(bytes32 _prod_code, uint _amount) 
    external
    returns(string[] memory _serials){
        _serials = new string[](_amount);
        for(uint index = 0; index < _amount; index++) _serials[index] = safe_product(_prod_code, msg.sender);
        emit added_product(_serials);
        return _serials;
    }

    function safe_product(bytes32 _prod_code, address _to) 
    internal 
    returns (string memory new_serial){
        require(prod_model_list[_prod_code].prod_code != toBytes32(""), "Code produit non reconnue !!!");
        new_serial = string(
            abi.encodePacked(_prod_code, 
            "_", 
            Strings.toString(prod_counter_by_code[_prod_code] +1), 
            "_", 
            Strings.address_to_string(_to))); 
        
        product_list[new_serial].owner = _to;
        product_list[new_serial].serial = new_serial;
        product_list[new_serial].prod_code = _prod_code;
        
        prod_counter_by_code[_prod_code] += 1;
        prod_serial_list.push(new_serial);

        // Creation du profile du produit
        join_prod_profile(_prod_code, new_serial);
    }

    function join_prod_profile(bytes32 _prod_code, string memory _serial) 
    internal {
        join_article_profil(_prod_code, _serial, true);
    }

    function join_article_profil(bytes32 _prod_code, string memory _serial, bool _is_product)
    internal{
        Model storage model = batch_model_list[_prod_code];
        Profile storage profile = batch_profile_list[_serial];
        if(_is_product){
            model = prod_model_list[_prod_code];
            profile = prod_profile_list[_serial];
        } 

        for(uint index = 0; index < model.field_headers.length; index++){
            profile.field_heads.push(Field_header(model.field_headers[index].name, model.field_headers[index].field_type, model.field_headers[index].is_static));
            if(model.field_headers[index].is_static) set_profile(_serial, model.field_headers[index].name, model.static_values[model.field_headers[index].name], _is_product);
        }
    }

    function set_prod_profile(string memory _serial, bytes32 _field_name, string memory _value) 
    external{
        require(bytes(product_list[_serial].serial).length != 0, "Produit inexistant !!!");
        require(product_list[_serial].owner == msg.sender, "Titre proprietaire requit pour cette action !!!");
        set_profile(_serial, _field_name, _value, true);
    }

    function set_profile(string memory _serial, bytes32 _field_name, string memory _value, bool _is_product)
    internal{
        
        mapping(string => Profile) storage profiles = batch_profile_list;
        if(_is_product) profiles = prod_profile_list;
        Field_type field_type = get_field_head_type(_serial, _field_name, _is_product);
        
        if(field_type == Field_type.STRING){
            profiles[_serial].strings[_field_name] = _value;
            emit changed_string_value_product_profil(_serial, _field_name, _value);

        }else if(field_type == Field_type.UINT){
            profiles[_serial].uints[_field_name] = Strings.parseInt(_value);
            emit changed_uint_value_product_profil(_serial, _field_name, Strings.parseInt(_value));

        }else if(field_type == Field_type.DATE){
            profiles[_serial].dates[_field_name] = Strings.parseInt(_value);
            emit changed_date_value_product_profil(_serial, _field_name, Strings.parseInt(_value));

        }else require (false, "Champs inexistant !");
    }

    function get_field_head_type(string memory _serial, bytes32 _field_name, bool _is_product)
    internal view returns (Field_type){
        Profile storage profile = batch_profile_list[_serial]; 
        if(_is_product) profile = prod_profile_list[_serial];

        for(uint index = 0; index < profile.field_heads.length; index++){
            if(profile.field_heads[index].name == bytes32(_field_name)) return profile.field_heads[index].field_type;
        }
        return Field_type.FORBIDDEN;
    }

    function cover(string memory _serial, string[] memory _covers)
    external{
        for(uint index = 0; index < _covers.length; index++) require(can_cover(_serial, _covers[index]), "Echec de liaison des produits");
        for(uint index = 0; index < _covers.length; index++) cover(_serial, _covers[index]);
    }


    function cover(string memory _serial, string memory _cover)
    internal{
        covers_list[_serial].push(_cover);
        if(is_already_create(_serial, true)){
            product_list[_cover].is_done = true;
            return;
        }else{
            batch_list[_cover].is_done = true;
            return;
        }
    }


    function can_cover(string memory _serial, string memory _cover)
    internal
    returns(bool){
        if(is_already_create(_serial, true)){
            if(is_already_create(_cover, true)){
                require(product_list[_serial].owner == product_list[_cover].owner, "Vous n'etes pas le proprietaire d'un produit de couverture");
                require(product_list[_serial].prod_code == product_list[_cover].prod_code, "Vous essayer de couvrir un produit avec un autre du meme type !!!");
        
            }else if(is_already_create(_cover, false)){
                require(product_list[_serial].owner == batch_list[_cover].owner, "Vous n'etes pas le proprietaire d'un lot de couverture");
                require(product_list[_serial].prod_code == batch_list[_cover].prod_code, "Vous essayer de couvrir un produit avec un lot du meme autre du meme type !!!");

            }else require(false, "Identifiant de produit de couverture non reconnu !!!");
        
        }else if(is_already_create(_serial, false)){
            if(is_already_create(_cover, false)){
                require(batch_list[_serial].owner == product_list[_cover].owner, "Vous n'etes pas le proprietaire d'un produit de couverture");
                require(batch_list[_serial].prod_code == product_list[_cover].prod_code, "Vous essayer de couvrir un lot de produit avec un produit de meme type que ceux dans le lot !!!");
            
            }else if(is_already_create(_cover, false)){
                require(batch_list[_serial].owner == batch_list[_cover].owner, "Vous n'etes pas le proprietaire d'un lot de couverture");
                require(batch_list[_serial].prod_code == batch_list[_cover].prod_code, "Vous essayer de couvrir un lot de produit avec un autre lot de produit du meme type !!!");

            }else require(false, "Identifiant de produit de couverture non reconnu !!!");
        }else require(false, "Le produit ou le lot de produit que vous asseyez de couvrir n'existe pas !!!");
        return true;
    }


    function is_already_create(string memory _serial, bool _is_product)
    internal view returns(bool){
        if(_is_product) return bytes(product_list[_serial].serial).length != 0;
        else return bytes(batch_list[_serial].serial).length != 0;
    }

    

    function recall(string memory _serial)
    external{
        if(is_already_create(_serial, true)){
            product_list[_serial].is_recalled = true;
        }else if(is_already_create(_serial, false)){
            batch_list[_serial].is_recalled = true;
        }else require(false, "Le produit ou lot de produit que vous assezez de rappeler n'existe pas");
    }







    function add_batch_model(bytes32 _batch_number, bytes32 _prod_code, uint _product_amount, bytes32 _name, string memory _description) 
    external
    returns(bytes32){
        require(batch_model_list[_batch_number].name == toBytes32(""), "Ce lot existe deja !!!");
        add_model(_batch_number, _name, _description, false);
        batch_model_list[_batch_number].prod_code = _prod_code;
        add_model_field(_prod_code, toBytes32("Produit par lot"), toBytes16("UINT"), true, Strings.toString(_product_amount), false);
        return _batch_number;
    }


    function add_field_batch(bytes32 _batch_number, bytes32 _name, bytes16 _type, bool _is_static, string memory _value) 
    external{
        add_model_field(_batch_number, _name, _type, _is_static, _value, false);
    }

    function set_batch_model(bytes32 _prod_code, bytes32 _field_name, string memory _value)
    external{
        set_model_field(_prod_code, _field_name, _value, false);
    }


    function add_batch(bytes32 _prod_code, uint _amount) 
    external{
        for(uint index = 0; index < _amount; index++) safe_batch(_prod_code, msg.sender);
    }


    function safe_batch(bytes32 _batch_number, address _to) 
    internal returns (string memory){
        require(batch_model_list[_batch_number].name != toBytes32(""), "Ce lot de produit n'existe pas !!!");
        string memory new_batch_serial = Strings.upper(string(
            abi.encodePacked("LOT ",
            _batch_number, 
            "-#", 
            Strings.toString(batch_counter_by_code[_batch_number] +1), 
            "-", 
            Strings.address_to_string(_to)))); 
        
        batch_list[new_batch_serial].owner = _to;
        batch_list[new_batch_serial].serial = new_batch_serial;
        batch_list[new_batch_serial].serial = new_batch_serial;

        batch_counter_by_code[_batch_number] += 1;
        batch_serial_list.push(new_batch_serial);

        // Creation du profile du produit
        join_batch_profile(_batch_number, new_batch_serial);

        // mint_product(_prod_code, new_batch_serial, _product_amount);

        return new_batch_serial;
    }


    function set_batch_profile(string memory _serial, bytes32 _field_name, string memory _value) 
    external{
        require(bytes(batch_list[_serial].serial).length != 0, "Ce lot de produit n'existe pas !!!");
        require(batch_list[_serial].owner == msg.sender, "Titre proprietaire requit pour cette action !!!");
        set_profile(_serial, _field_name, _value, false);
    }



    function join_batch_profile(bytes32 _batch_number, string memory _serial) 
    internal {
        join_article_profil(_batch_number, _serial, false);
    }







    


















    // Liste des couvertures
    mapping(string => string[]) covers_list;

    // Liste des series de produits
    string[] prod_serial_list;
    string[] batch_serial_list;


    // Liste des produits
    mapping(string => Product) product_list;

    // Liste des lots de produit
    mapping(string => Batch) batch_list;

    // Liste des profils de produits
    mapping(string => Profile) prod_profile_list;

    // Liste des profils de lots de produits
    mapping(string => Profile) batch_profile_list;

    // Liste des maquettes de produits
    mapping(bytes32 => Model) prod_model_list;

    // Liste des maquettes de lots de produit
    mapping(bytes32 => Model) batch_model_list;

    // Liste des types de valeurs autorisés
    mapping(bytes16 => Field_type) field_type_list;
    mapping(Field_type => bytes16) string_type_list;

    // Liste des compteurs de produit par code produit
    mapping(bytes32 => uint) prod_counter_by_code;
    mapping(bytes32 => uint) batch_counter_by_code;


    // Constructeur
    constructor(){
        field_type_list[toBytes16("STRING")] = Field_type.STRING;
        field_type_list[toBytes16("UINT")] = Field_type.UINT;
        field_type_list[toBytes16("DATE")] = Field_type.DATE;

        string_type_list[Field_type.STRING] = toBytes16("STRING");
        string_type_list[Field_type.UINT] = toBytes16("UINT");
        string_type_list[Field_type.DATE] = toBytes16("DATE");
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






    function get_products_id_list() public view returns(string memory){
        string memory _list = "";
        for(uint index = 0; index < prod_serial_list.length; index++){
            _list = string(abi.encodePacked(prod_serial_list[index], " ___ ", _list));
        }
        return _list;
    }

    function get_product_profil(string memory _serial)
    external view returns(string memory _info){

        Product memory product = product_list[_serial];
        _info = string(abi.encodePacked("Proprietaire: ", Strings.address_to_string(product.owner), " ___ Code produit: ", product.prod_code," ___ Numero de lot: ", product.batch_number, " ___ "));
 
        Profile storage profile = prod_profile_list[_serial];
        for(uint index = 0; index < profile.field_heads.length; index++){
            _info = string(abi.encodePacked(" ___ ",_info, profile.field_heads[index].name, ": "));
            if(profile.field_heads[index].field_type == Field_type.STRING) 
                _info = string(abi.encodePacked(_info, profile.strings[profile.field_heads[index].name]));

            else if(profile.field_heads[index].field_type == Field_type.UINT) 
                _info = string(abi.encodePacked(_info, Strings.toString(profile.uints[profile.field_heads[index].name])));

            else if(profile.field_heads[index].field_type == Field_type.DATE) 
                _info = string(abi.encodePacked(_info, Strings.toString(profile.dates[profile.field_heads[index].name])));
        }

       /* _info = string(abi.encodePacked(_info, " ___ Produits pere", ": "));
        for(uint index = 0; index < product.covers.length; index++){
            _info = string(abi.encodePacked(_info, product.covers[index], ", "));
        }
        */

    }

}