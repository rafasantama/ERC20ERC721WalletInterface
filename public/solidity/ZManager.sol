// SPDX-License-Identifier: MIT

pragma solidity >=0.7.0 <0.9.0;


import "./ZERC721.sol";


interface IERC20 {
    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    //function transfer(address to, uint256 amount) external returns (bool);       // to avoid any risk of illegal burning

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
    function manager_mint(address receiver_,uint amount_) external;
    function burn(address _redeemAddress, uint256 _amount) external;
}

contract OW3NFTs is ERC721Enumerable {

    uint public totalMinted; //Cantidad total Minteada

    string InitName = "OW3 NFTs"; //Nombre en el estandar ERC721
    string InitSymbol = "ZNFT";  //Simbolo disponible en el estandar ERC721
    IERC20 public ERC20Contract; //Instancia de la interfaz ERC20
    mapping (address => bool) public autorized; //Relación de direcciones de administración autorizadas
    mapping (address => bool) public whitelist; //Relación de direcciones de usuarios autenticados
    mapping (address => mapping (uint => bool)) address_propertyID2state; //Relación entre una dirección y una medalla devuelve true si la tiene o false si no
    mapping (address => mapping (uint => bool)) public address_prizeID2state; //Relación entre una dirección y un premio devuelve true si la tiene o false si no
    mapping (uint => uint) public NFTID2propertyID; //Cada NFT va enumerado y se asigna un numero de medalla para relacionar su metadata
    mapping (uint => uint) public propertyID2tokenAmount; //mapeo para relacionar la medalla con el premio a entregar
    struct prize{
        string name;
        uint tokens_to_redeem_prize;
        uint[] properties_required;
    }

    prize[] public prizes;
    string[] public properties;

    constructor() ERC721(InitName, InitSymbol) {
        autorized[msg.sender]=true;
    }

    function autorizeAddress(address _address) public onlyAutorized{
        autorized[_address]=true;
    }
    function removeAddressFromAutorized(address _address) public onlyAutorized{
        autorized[_address]=false;
    }
    function whitelistAddress(address _address) public onlyAutorized{
        whitelist[_address]=true;
    }
    function removeAddressFromWhitelist(address _address) public onlyAutorized{
        whitelist[_address]=false;
    }

    modifier onlyAutorized(){
        require(autorized[msg.sender],"Only autorized");
        _;
    }

    function setup_ERC20(address _ERC20_add) public onlyAutorized{
        ERC20Contract=IERC20(_ERC20_add);
    }

    function create_property(string memory _propertyURI) public onlyAutorized{
        properties.push(_propertyURI);
    }
    function mintproperty(address receiver_,uint _property_ID) public onlyAutorized {
        uint256 supply = totalSupply();
        _safeMint(receiver_, supply + 1);   // ERC721


        totalMinted++;              // ERC721
        NFTID2propertyID[supply+1]=_property_ID;  // ERC721
        address_propertyID2state[receiver_][_property_ID]=true; // ERC721
    }
    function mint_tokens(address receiver_,uint amount_) public onlyAutorized{
        ERC20Contract.manager_mint(receiver_,amount_);   // ERC20
    }
    function walletOfOwner(address _address)
        public
        view
        returns (uint256[] memory)
    {
        // returns the NFTids that belongs to an address
        uint256 ownerTokenCount = balanceOf(_address);
        uint256[] memory nftIds = new uint256[](ownerTokenCount);
        for (uint256 i; i < ownerTokenCount; i++) {
            nftIds[i] = tokenOfOwnerByIndex(_address, i);
        }
        return nftIds;
    }     

    function tokenURI(uint256 _property_ID)
        public
        view
        virtual
        override
        returns (string memory)
    {
        require(
        _exists(_property_ID),
        "ERC721Metadata: URI query for nonexistent token"
        );
        return properties[NFTID2propertyID[_property_ID]];
    }
    function change_propertyID_URI(uint256 property_Id, string memory _newURI) public onlyAutorized{
        properties[property_Id]=_newURI;
    }
}
