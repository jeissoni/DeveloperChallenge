// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155Receiver.sol";

///@title Money
///@author Jeisson Niño
///@notice Technical Test for deviants factions
contract Money is ERC1155,IERC1155Receiver, Ownable {

    ///===================================================
    ///============= Custom errors =======================
    ///@notice There are not enough funds for the exchange
    ///@param user Caller address 
    ///@param amount User NFT balance
    error WithoutSufficientFunds(address user, uint256 amount); 

    ///@notice Array size is wrong
    ///@param user Caller address
    ///@param arraySize Sent array size
    error WrongArraySize(address user, uint256 arraySize);


    /// ============ Immutable storage ==================
    ///@notice List of available denominations
    uint256[] public denominations = new uint256[](6);
      
    ///@notice in the constructor the data of the denomination 
    ///and the balances are initialized
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

        _setURI("ipfs://QmaLJyHmDqfEaCAPRjEWYuNAoF6kbX2yqa9K41jBV4mXNa/");   
           
    }


    /// ========================================================
    /// ==================== Events ============================
    
    /// @notice Emitted after a successful the denominations are changed
    /// @param owner Address of owner 
    /// @param amount List of new balances
    event ChangeStock(address indexed owner,  uint256[] amount); 


    /// @notice Emitted after a successful Withdraw Proceeds
    /// @param user Address of owner 
    /// @param amount Amount of proceeds claimed by owner
    event ConvertDenom(address indexed user, uint[] amount);  

   
    ///@param operator The address which initiated the transfer (i.e. msg.sender)
    ///@param from The address which previously owned the token
    ///@param id The ID of the token being transferred
    ///@param value The amount of tokens being transferred
    ///@param data Additional data with no specified format    
    event OnERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes data
    );

    
    ///@param operator The address which initiated the batch transfer (i.e. msg.sender)
    ///@param from The address which previously owned the token
    ///@param ids An array containing ids of each token being transferred (order and length must match values array)
    ///@param values An array containing amounts of each token being transferred (order and length must match ids array)
    ///@param data Additional data with no specified format
    event OnERC1155BatchReceived(
        address operator,
        address from,
        uint256[] ids,
        uint256[] values,
        bytes data
    );
    

    /// =========================================================
    /// ============ Functions ==================================  

    ///@dev Handles the receipt of a single ERC1155 token type. This function is
    ///called at the end of a `safeTransferFrom` after the balance has been updated.
    ///@param operator The address which initiated the transfer (i.e. msg.sender)
    ///@param from The address which previously owned the token
    ///@param id The ID of the token being transferred
    ///@param value The amount of tokens being transferred
    ///@param data Additional data with no specified format
    ///@return `bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"))` if transfer is allowed
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


    ///@dev Handles the receipt of a multiple ERC1155 token types. This function
    ///is called at the end of a `safeBatchTransferFrom` after the balances have
    ///been updated.
    ///@param operator The address which initiated the batch transfer (i.e. msg.sender)
    ///@param from The address which previously owned the token
    ///@param ids An array containing ids of each token being transferred (order and length must match values array)
    ///@param values An array containing amounts of each token being transferred (order and length must match ids array)
    ///@param data Additional data with no specified format
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


    ///@notice Change the URI, only by the owner
    function setURI(string memory newuri) public onlyOwner {
        _setURI(newuri);
    }

   
   ///@notice Returns the URI for each Id token
    function uri(uint256 id) public view override returns (string memory) {
        return string(abi.encodePacked(super.uri(id), Strings.toString(id), ".json"));
    }


    ///@notice returns the minimum integer value that can be divided by the denomination
    ///@param amount integer value to be divided
    ///@param denomination value with which you want to divide
    function minimumPerDenomination(
        uint256 amount, 
        uint256 denomination) 
        private pure returns (uint256 total){
            uint256 minPerDenomination = amount / denomination;
            return (minPerDenomination);
    }


    ///@notice from an integer get the minimum value per 
    ///denomination and return NFT representing each of the denominations
    ///@param amount integer value for division
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

        _safeBatchTransferFrom(address(this),msg.sender,denominations, amountDenominations,"");
        
        emit ConvertDenom(msg.sender, amountDenominations);
        
    }

    ///@notice change balances by denomination only by the owner
    ///@param amountPerDenomination arrangement with new balances
    function changeStock(
        uint256[] memory amountPerDenomination
        ) public onlyOwner {        
        
        if (amountPerDenomination.length != denominations.length){
            revert WrongArraySize(msg.sender, amountPerDenomination.length);
        }

        _mintBatch(address(this),denominations, amountPerDenomination,"");       

        emit ChangeStock(msg.sender, amountPerDenomination);
    }

}