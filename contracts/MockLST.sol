// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";

contract MockLST is ERC20Permit {
    constructor() ERC20("Mock LST", "mLST") ERC20Permit("Mock LST") {
        _mint(msg.sender, 10_000_000 ether);
    }
    function mint(address to, uint256 amt) external {
        _mint(to, amt);
    }
}
