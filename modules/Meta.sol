/* 
 *  Ticket 1.0
 *  VERSION: 1.0
 *
 */

pragma solidity ^0.6.0;


contract ERC20{
    function allowance(address owner, address spender) external view returns (uint256){}
    function transfer(address recipient, uint256 amount) external returns (bool){}
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool){}
    function balanceOf(address account) external view returns (uint256){}
}


contract HappyBox{
    
    uint public code=2;
    
    event Shipped(address shipped);
    
    address[] public modules_list;
    mapping(address => bool)public modules;
    address public master;
    
    constructor() public{
        master=msg.sender;
    }
    
    function ship(address tkn,uint amount,address destination) public returns(bool){
        require(modules[msg.sender]);
        require(ERC20(tkn).transfer(destination, amount));
        emit Shipped(tkn);
        return true;
    } 
    
    //mode 1 = install module
    //mode 2 = set master
    //mode 3 = enable module
    //mode 4 = pull token
    function set(address tkn,bool what,uint mode)public returns(bool){
         require((msg.sender==master)||(modules[msg.sender]));
        if(mode==1){
            require(MVMCertList(0xf3101b99D8BD86F0d358bc9F062B0ff658590C9e).isModule(tkn));
            modules[tkn]=true;
            modules_list.push(tkn);
        }else if(mode==2){
                master=tkn;
        }else if(mode==3){
                modules[tkn]=what;
        }else if(mode==4){
              ERC20 token=ERC20(tkn);
                token.transfer(master,token.balanceOf(address(this)));
        }
        return true;
    }
    
}

contract priceList {
    
    uint public code=5;
    
    event priceSet(address token);
    
    address public master;
    mapping(address => uint)public price;
    address[] list;
    

    constructor(address mstr) public {
        master=mstr;
    }
    
    function priceListing(uint index)view public returns(address,uint,uint){
        return (list[index],price[list[index]],list.length);
    }
    
    function setPrice(address tkn,uint prc)public returns(bool){
        require(msg.sender==master);
        require(prc > 0, "Price > 0 please");
        if(price[tkn]==0)list.push(tkn);
        price[tkn]=prc;
        emit priceSet(tkn);
        return true;
    }
    
}




contract Meta {

    mapping(address => string)public meta;

    function setBoxMeta(address _contract,string memory val)public returns(bool){
        HappyBox box=HappyBox(_contract);
        if(box.master()==msg.sender)
        meta[_contract]=val;
        return true;
    }
    
    function setModuleMeta(address _contract,string memory val)public returns(bool){
        Ticket module=Ticket(_contract);
        HappyBox box=HappyBox(module.box());
        if(box.master()==msg.sender)
        meta[_contract]=val;
        return true;
    }
    
    function setWalletMeta(string memory val)public returns(bool){
        meta[msg.sender]=val;
        return true;
    }
    
}






contract Ticket {
    
    uint8 public code=4;
    address public vault;
    HappyBox public box;
    priceList public prices;
    
    constructor(address vlt, address prcs, address gftr) public{
        vault=vlt;
        prices=priceList(prcs);
        box=HappyBox(gftr);
    }
    
    function buy(address tkn,address ref) payable public returns(bool){
        require(box.ship(tkn,msg.value*1000/prices.price(tkn),msg.sender));
        payable(ref).transfer(msg.value/5);
        return true;
    } 
    
    function pull() public {
       payable(vault).transfer(address(this).balance);
    }
    
}
