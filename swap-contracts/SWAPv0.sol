// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";

interface IERC20 {
    function totalSupply() external view returns (uint);

    function balanceOf(address account) external view returns (uint);

    function transfer(address recipient, uint amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
}


contract ExcelciumSwap is Ownable {

    uint public fee;

    uint256 public ratio;

    address private tokenAddress = 0x9e6969254D73Eda498375B079D8bE540FB42fea7;

    IERC20 private excelcium = IERC20(tokenAddress);

    function swapETHtoEXC(uint256 amount) external payable {
        require(msg.value >= amount, "Promised amount and invoked are different ");
        uint256 excValue = (100/ratio) * amount;
        require(excelcium.transfer(msg.sender, excValue), "Transfer is not executed");
    }


    function swapEXCtoETH(uint256 amount) external payable {
        require(excelcium.transferFrom(msg.sender,address(this),amount));
        uint256 ethValue = (ratio/100) * amount * (1 - (fee/100));
        payable(address(this)).transfer(ethValue);
    }

    function receiveEXC(uint256 amount) external {
        require(excelcium.transferFrom(msg.sender, address(this), amount));
    }

    constructor(uint _fee, uint256 _ratio) Ownable(msg.sender) {
        fee = _fee;
        ratio= _ratio;
    }
}