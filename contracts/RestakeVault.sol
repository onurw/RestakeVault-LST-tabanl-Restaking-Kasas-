// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC20/extensions/ERC4626.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

/**
 * @title RestakeVault (rstLST)
 * @notice LST (asset) kabul eden ERC-4626 kasa. Getiriler donate() ile kasaya akar,
 *         pay başına değer artar. Basit, denetlenebilir restaking iskeleti.
 *
 * Notlar:
 * - Slashing/ceza mekanizması bu iskelette yoktur (modüler olarak eklenebilir).
 * - Üretimde timelock, governor, oracle kontrolleri, limit/guard'lar önerilir.
 */
contract RestakeVault is ERC4626, ERC20Permit, Ownable, ReentrancyGuard {
    mapping(address => bool) public isOperator; // donate yetkisi

    event OperatorSet(address indexed op, bool allowed);
    event Donated(address indexed op, uint256 amount);

    constructor(IERC20 asset_)
        ERC20("Restake Vault Share", "rstLST")
        ERC20Permit("Restake Vault Share")
        ERC4626(asset_)
    {
        // deployer varsayılan operatör
        isOperator[msg.sender] = true;
    }

    // -------- Operator management --------
    function setOperator(address op, bool allowed) external onlyOwner {
        isOperator[op] = allowed;
        emit OperatorSet(op, allowed);
    }

    /**
     * @notice Kasaya LST bağışı (getiri). Pay basılmaz; mevcut pay sahiplerine oransal değer artışı sağlar.
     * @dev asset.transferFrom gerektirir. Çağırmadan önce approve verilmeli.
     */
    function donate(uint256 amount) external nonReentrant {
        require(isOperator[msg.sender], "not operator");
        require(amount > 0, "amount=0");
        IERC20(asset()).transferFrom(msg.sender, address(this), amount);
        // ERC4626 totalAssets() artar; share supply sabit → exchangeRate yükselir
        emit Donated(msg.sender, amount);
    }

    // -------- Convenience: view helpers --------
    function pricePerShare() external view returns (uint256) {
        uint256 s = totalSupply();
        return s == 0 ? 1e18 : convertToAssets(1e18);
    }
}
