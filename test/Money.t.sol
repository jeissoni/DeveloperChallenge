// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.4;

import "forge-std/Test.sol";
import {console} from "forge-std/console.sol";
import "../src/Money.sol";

interface CheatCodes {

    function addr(uint256) external returns (address);
}
contract MoneyTest is Test {
    
    CheatCodes cheats = CheatCodes(HEVM_ADDRESS);
    Money public testMoney;
    address public owner;
    address public addr1;   

    function setUp() public {
        owner = address(this); 
        addr1 = cheats.addr(1);
        testMoney = new Money();
    }    

    function denominationAndInitialValue() public pure returns(
        uint256[] memory denominations , 
        uint256[] memory value ){

        uint256[] memory denominationsInitial = new uint256[](6);
        uint256[] memory valueInitial = new uint256[](6);

        denominationsInitial[0]=100;
        denominationsInitial[1]=50;
        denominationsInitial[2]=20;
        denominationsInitial[3]=10;
        denominationsInitial[4]=5;
        denominationsInitial[5]=1;

        valueInitial[0]= 20;    //100
        valueInitial[1]= 2;     //50
        valueInitial[2]= 2;     //20     
        valueInitial[3]= 0;     //10
        valueInitial[4]= 5;     //5
        valueInitial[5]= 50;    //1        

        return(denominationsInitial, valueInitial);
    }

    function testStartingInitials() public {

        (uint256[] memory denomination, uint256[] memory value) = denominationAndInitialValue();

        assertEq(testMoney.balanceOf(address(testMoney), denomination[0]) , value[0]);
        assertEq(testMoney.balanceOf(address(testMoney), denomination[1]) , value[1]);
        assertEq(testMoney.balanceOf(address(testMoney), denomination[2]) , value[2]);
        assertEq(testMoney.balanceOf(address(testMoney), denomination[3]) , value[3]);
        assertEq(testMoney.balanceOf(address(testMoney), denomination[4]) , value[4]);
        assertEq(testMoney.balanceOf(address(testMoney), denomination[5]) , value[5]);
    }

    function testConvertDenom() public {
        uint256[] memory denomination;
        uint256[] memory value;

        (denomination, value) = denominationAndInitialValue();     

        vm.prank(addr1);
        testMoney.convertDenom(65);

        assertEq(testMoney.balanceOf(addr1, denomination[0]) , 0);  //100
        assertEq(testMoney.balanceOf(addr1, denomination[1]) , 1);  //50
        assertEq(testMoney.balanceOf(addr1, denomination[2]) , 0);  //20
        assertEq(testMoney.balanceOf(addr1, denomination[3]) , 0);  //10
        assertEq(testMoney.balanceOf(addr1, denomination[4]) , 3);  //5
        assertEq(testMoney.balanceOf(addr1, denomination[5]) , 0);  //1

        assertEq(testMoney.balanceOf(address(testMoney), denomination[0]) , value[0]);      //100
        assertEq(testMoney.balanceOf(address(testMoney), denomination[1]) , value[1] - 1);  //50
        assertEq(testMoney.balanceOf(address(testMoney), denomination[2]) , value[2]);      //20          
        assertEq(testMoney.balanceOf(address(testMoney), denomination[3]) , value[3]);      //10
        assertEq(testMoney.balanceOf(address(testMoney), denomination[4]) , value[4] - 3);  //5
        assertEq(testMoney.balanceOf(address(testMoney), denomination[5]) , value[5]);      //1  


        setUp();    
        (denomination, value) = denominationAndInitialValue();     

        vm.prank(addr1);
        testMoney.convertDenom(98);

        assertEq(testMoney.balanceOf(addr1, denomination[0]) , 0);//100
        assertEq(testMoney.balanceOf(addr1, denomination[1]) , 1);//50
        assertEq(testMoney.balanceOf(addr1, denomination[2]) , 2);//20
        assertEq(testMoney.balanceOf(addr1, denomination[3]) , 0);//10
        assertEq(testMoney.balanceOf(addr1, denomination[4]) , 1);//5
        assertEq(testMoney.balanceOf(addr1, denomination[5]) , 3);//1      

        assertEq(testMoney.balanceOf(address(testMoney), denomination[0]) , value[0]);      //100
        assertEq(testMoney.balanceOf(address(testMoney), denomination[1]) , value[1] - 1);  //50
        assertEq(testMoney.balanceOf(address(testMoney), denomination[2]) , value[2] - 2);   //20          
        assertEq(testMoney.balanceOf(address(testMoney), denomination[3]) , value[3]);      //10
        assertEq(testMoney.balanceOf(address(testMoney), denomination[4]) , value[4] - 1);  //5
        assertEq(testMoney.balanceOf(address(testMoney), denomination[5]) , value[5] - 3);  //1

        setUp();    
        (denomination, value) = denominationAndInitialValue();     

        vm.prank(addr1);
        testMoney.convertDenom(341);

        assertEq(testMoney.balanceOf(addr1, denomination[0]) , 3);//100
        assertEq(testMoney.balanceOf(addr1, denomination[1]) , 0);//50
        assertEq(testMoney.balanceOf(addr1, denomination[2]) , 2);//20
        assertEq(testMoney.balanceOf(addr1, denomination[3]) , 0);//10
        assertEq(testMoney.balanceOf(addr1, denomination[4]) , 0);//5
        assertEq(testMoney.balanceOf(addr1, denomination[5]) , 1);//1      

        assertEq(testMoney.balanceOf(address(testMoney), denomination[0]) , value[0] - 3);  //100
        assertEq(testMoney.balanceOf(address(testMoney), denomination[1]) , value[1]);      //50
        assertEq(testMoney.balanceOf(address(testMoney), denomination[2]) , value[2] - 2);  //20          
        assertEq(testMoney.balanceOf(address(testMoney), denomination[3]) , value[3]);      //10
        assertEq(testMoney.balanceOf(address(testMoney), denomination[4]) , value[4]);      //5
        assertEq(testMoney.balanceOf(address(testMoney), denomination[5]) , value[5] - 1);  //1  
    }

      

    function testReverseInsufficientFunds() public {

        uint256 amount = 5000;
        vm.expectRevert(
            abi.encodeWithSelector(
                Money.WithoutSufficientFunds.selector, addr1, amount
        ));        
        vm.prank(addr1);
        testMoney.convertDenom(amount);
    }


    function testReverseButOwnerChangeStock() public {
        vm.expectRevert("Ownable: caller is not the owner");
        vm.prank(addr1);
        uint256[] memory newAmount =  new uint256[](6);
        newAmount[0] = 10;
        newAmount[1] = 6;
        newAmount[2] = 8;
        newAmount[3] = 15;
        newAmount[4] = 20;
        newAmount[5] = 100;
        testMoney.changeStock(newAmount);
    }

    function testRevertButWrongArraySize() public {
        uint256[] memory newAmount =  new uint256[](5);
        newAmount[0] = 10;
        newAmount[1] = 6;
        newAmount[2] = 8;
        newAmount[3] = 15;
        newAmount[4] = 20;
      
        vm.expectRevert(
            abi.encodeWithSelector(
                Money.WrongArraySize.selector, owner, newAmount.length
        ));        
        vm.prank(owner);
        testMoney.changeStock(newAmount);
    }

    function testChangeStock() public {
        (uint256[] memory denomination, uint256[] memory value) = denominationAndInitialValue();

        uint256[] memory newAmount =  new uint256[](6);
        newAmount[0] = 10;
        newAmount[1] = 6;
        newAmount[2] = 8;
        newAmount[3] = 15;
        newAmount[4] = 20;
        newAmount[5] = 100;
        vm.prank(owner);
        testMoney.changeStock(newAmount);

        assertEq(testMoney.balanceOf(address(testMoney), denomination[0]) , value[0] + newAmount[0]);
        assertEq(testMoney.balanceOf(address(testMoney), denomination[1]) , value[1] + newAmount[1]);
        assertEq(testMoney.balanceOf(address(testMoney), denomination[2]) , value[2] + newAmount[2]);
        assertEq(testMoney.balanceOf(address(testMoney), denomination[3]) , value[3] + newAmount[3]);
        assertEq(testMoney.balanceOf(address(testMoney), denomination[4]) , value[4] + newAmount[4]);
        assertEq(testMoney.balanceOf(address(testMoney), denomination[5]) , value[5] + newAmount[5]);
    }

    function testSetURI () public{
        string memory uri = "https://deviantsfactions.com/";
        vm.prank(owner);
        testMoney.setURI(uri);

        string memory uriReturn = testMoney.uri(0);
        assertEq(uriReturn, string(abi.encodePacked(uri, Strings.toString(0), ".json")));        

    }
}
