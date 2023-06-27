// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import {IERC4626} from "./SimpleIERC4626.sol";
import {ERC20, IERC20Metadata} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract SimpleERC4626 is ERC20, IERC4626 {
    ERC20 private immutable _asset;
    uint8 private immutable _decimals;

    constructor(
        ERC20 asset_,
        string memory name_,
        string memory symbol_
    ) ERC20(name_, symbol_) {
        _asset = asset_;
        _decimals = asset_.decimals();
    }

    function asset()
        external
        view
        virtual
        override
        returns (address assetTokenAddress)
    {
        return address(_asset);
    }

    function decimals()
        public
        view
        virtual
        override(IERC20Metadata, ERC20)
        returns (uint8)
    {
        return _decimals;
    }

    function deposit(
        uint256 assets,
        address receiver
    ) external override returns (uint256 shares) {
        // estimate the vault shares based on deposit assets
        shares = previewDeposit(assets);

        // first transfer then mint, preventing replay attack
        _asset.transferFrom(msg.sender, address(this), assets);
        _mint(receiver, shares);

        // release Deposit event
        emit Deposit(msg.sender, receiver, assets, shares);
    }

    function mint(
        uint256 shares,
        address receiver
    ) public override returns (uint256 assets) {
        // estimate the vault assets based on deposit shares
        assets = previewMint(shares);

        // first transfer then mint, preventing replay attack
        _asset.transferFrom(msg.sender, address(this), assets);
        _mint(receiver, shares);

        // release Deposit event
        emit Deposit(msg.sender, receiver, assets, shares);
    }

    function withdraw(
        uint256 assets,
        address receiver,
        address owner
    ) public virtual override returns (uint256 shares) {
        // estimate the vault shares based on withdraw assets
        shares = previewWithdraw(assets);

        // check the allowance if not owner operation
        if (msg.sender != owner) {
            _spendAllowance(owner, msg.sender, shares);
        }

        // first burn then transfer for preventing replay attack
        _burn(owner, shares);
        _asset.transfer(receiver, assets);
        emit Withdraw(msg.sender, receiver, owner, assets, shares);
    }

    function redeem(
        uint256 shares,
        address receiver,
        address owner
    ) external override returns (uint256 assets) {
        // estimate the vault shares based on redeem shares
        assets = previewRedeem(shares);

        // check the allowance if not owner operation
        if (msg.sender != owner) {
            _spendAllowance(owner, msg.sender, shares);
        }

        // first burn then transfer for preventing replay attack
        _burn(owner, shares);
        _asset.transfer(receiver, assets);
        emit Withdraw(msg.sender, receiver, owner, assets, shares);
    }

    function totalAssets()
        public
        view
        virtual
        override
        returns (uint256 totalManagedAssets)
    {
        return _asset.balanceOf(address(this));
    }

    function convertToShares(
        uint256 assets
    ) public view override returns (uint256 shares) {
        uint256 supply = totalSupply();
        return supply == 0 ? assets : (assets * supply) / totalAssets();
    }

    function convertToAssets(
        uint256 shares
    ) public view override returns (uint256 assets) {
        uint256 supply = totalSupply();
        return supply == 0 ? shares : shares * totalAssets() / supply;
    }

    function previewDeposit(
        uint256 assets
    ) public view override returns (uint256 shares) {
        return convertToShares(assets);
    }

    function previewMint(
        uint256 shares
    ) public view override returns (uint256 assets) {
        return convertToAssets(shares);
    }

    function previewWithdraw(
        uint256 assets
    ) public view virtual override returns (uint256 shares) {
        return convertToShares(assets);
    }

    function previewRedeem(
        uint256 shares
    ) public view virtual override returns (uint256 assets) {
        return convertToAssets(shares);
    }

    function maxDeposit(
        address
    ) external pure override returns (uint256 maxAssets) {
        return type(uint256).max;
    }

    function maxMint(
        address
    ) external pure override returns (uint256 maxShares) {
        return type(uint256).max;
    }

    function maxWithdraw(
        address owner
    ) external view override returns (uint256 maxAssets) {
        return convertToAssets(balanceOf(owner));
    }

    function maxRedeem(
        address owner
    ) external view override returns (uint256 maxShares) {
        return convertToAssets(balanceOf(owner));
    }
}
