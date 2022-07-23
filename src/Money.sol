// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155Receiver.sol";


import "forge-std/console.sol";

contract Money is ERC1155,IERC1155Receiver, Ownable {

    error WithoutSufficientFunds(address user, uint256 amount); 

    /// ============ Immutable storage ============
    uint256[] public denominations = new uint256[](6);
    
    using Counters for Counters.Counter;
    Counters.Counter private tokenIdCounter;  
    
    /// ============ Events =====================
    event ChangeStock(address indexed owner,  uint256[] amount);  

    event ConvertDenom(address indexed user, uint[] amount);     

    event OnERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes data
    );
    event OnERC1155BatchReceived(
        address operator,
        address from,
        uint256[] ids,
        uint256[] values,
        bytes data
    );

    constructor(      
    ) ERC1155("") {       

        denominations[0]=100;
        denominations[1]=50;
        denominations[2]=20;
        denominations[3]=10;
        denominations[4]=5;
        denominations[5]=1;

        uint256[] memory amount = new uint256[](6);
        amount[0]= 20;
        amount[1]= 2;
        amount[2]= 2;
        amount[3]= 0;
        amount[4]= 5;
        amount[5]= 50;

        _mintBatch(address(this),denominations, amount,"");            
    }
    
    function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes calldata data
    )
    public override 
    returns(bytes4){
        emit OnERC1155Received(operator, from, id, value, data);
        return bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"));
    }

    function onERC1155BatchReceived(
        address operator,
        address from,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    )
    public override
    returns(bytes4){
        emit OnERC1155BatchReceived(operator, from, ids, values, data);
        return bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"));
    }


    function exists(uint256 tokenId) internal view virtual returns (bool) {
        return tokenId > tokenIdCounter.current() ? false : true ;
    }
    function setURI(string memory newuri) public onlyOwner {
        _setURI(newuri);
    }
   
    function uri(uint256 _id) public view override returns (string memory) {
        require(exists(_id), "URI: nonexistent token");
        return string(abi.encodePacked(super.uri(_id), Strings.toString(_id), ".json"));
    }

    function minimumPerDenomination(
        uint256 amount, 
        uint256 denomination) 
        private pure returns (uint256 total){
            uint256 minPerDenomination = amount / denomination;
            return (minPerDenomination);
    }

    function tranferAmountNft(
        address user,
        uint256[] memory amount)  
        private {                 
           _safeBatchTransferFrom(address(this),user,denominations, amount,"");
    }


    //función que convierte un número en una 
    //lista de NFTs mínimos para entregar.
    function convertDenom(uint256 amount) public {  

        uint256 minPerDenominationTmp;
        uint256 amountTmp;
        uint256 initAmount = amount;
        uint256[] memory amountDenominations =  new uint256[](6);
     
        minPerDenominationTmp = minimumPerDenomination(amount, 100);
        if(balanceOf(address(this), 100) >= minPerDenominationTmp){
            amount = amount % 100;
            amountDenominations[0] = minPerDenominationTmp;
            amountTmp = minPerDenominationTmp * 100;
        }

        minPerDenominationTmp = minimumPerDenomination(amount, 50);
        if(balanceOf(address(this), 50) >= minPerDenominationTmp){
            amount = amount % 50;
            amountDenominations[1] = minPerDenominationTmp;
            amountTmp += minPerDenominationTmp * 50;
        }

        minPerDenominationTmp = minimumPerDenomination(amount, 20);
        if(balanceOf(address(this), 20) >= minPerDenominationTmp){
            amount = amount % 20;
            amountDenominations[2] = minPerDenominationTmp;
            amountTmp += minPerDenominationTmp * 20;
        }

        minPerDenominationTmp = minimumPerDenomination(amount, 10);
        if(balanceOf(address(this), 10) >= minPerDenominationTmp){
            amount = amount % 10;
            amountDenominations[3] = minPerDenominationTmp;
            amountTmp += minPerDenominationTmp * 10;
        }

        minPerDenominationTmp = minimumPerDenomination(amount, 5);
        if(balanceOf(address(this), 5) >= minPerDenominationTmp){
            amount = amount % 5;
            amountDenominations[4] = minPerDenominationTmp;
            amountTmp += minPerDenominationTmp * 5;
        }

        minPerDenominationTmp = minimumPerDenomination(amount, 1);
        if(balanceOf(address(this), 1) >= minPerDenominationTmp){
            amount = amount % 1;
            amountDenominations[5] = minPerDenominationTmp;
            amountTmp += minPerDenominationTmp * 1;
        }     

        if (amountTmp != initAmount){
            revert WithoutSufficientFunds(msg.sender, initAmount);
        }

        tranferAmountNft(msg.sender, amountDenominations); 

        emit ConvertDenom(msg.sender, amountDenominations);
        
    }

    //actualiza el stock disponible de cada denominación.
    //Solo debe ser accionable desde la cuenta admin.
    function changeStock(
        uint256[] memory amountPerDenomination
        ) public onlyOwner {        
        
        _mintBatch(address(this),denominations, amountPerDenomination,"");       

        emit ChangeStock(msg.sender, amountPerDenomination);
    }

}