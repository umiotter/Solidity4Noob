// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import {IERC4626} from "./SimpleIERC4626.sol";
import {ERC20, IERC20Metadata} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract SimpleERC4626 is ERC20, IERC4626 {
    ERC20 private immutable _asset;
    uint8 private immutable _decimals;

    constructor(ERC20 asset_, string memory name_, string memory symbol_) ERC20(name_, symbol_){
        _asset = asset_;
        _decimals = asset_.decimals();
    }

    function asset()
        external
        view
        override
        returns (address assetTokenAddress)
    {
        return address(_asset);
    }

    function decimals() public view override(IERC20Metadata, ERC20) returns(uint8 decimals){
        return _decimals;
    }

    function deposit(
        uint256 assets,
        address receiver
    ) external override returns (uint256 shares) {}

    function mint(
        uint256 shares,
        address receiver
    ) external override returns (uint256 assets) {}

    function withdraw(
        uint256 assets,
        address receiver,
        address owner
    ) external override returns (uint256 shares) {}

    function redeem(
        uint256 shares,
        address receiver,
        address owner
    ) external override returns (uint256 assets) {}

    function totalAssets()
        external
        view
        override
        returns (uint256 totalManagedAssets)
    {}

    function convertToShares(
        uint256 assets
    ) external view override returns (uint256 shares) {}

    function convertToAssets(
        uint256 shares
    ) external view override returns (uint256 assets) {}

    function previewDeposit(
        uint256 assets
    ) external view override returns (uint256 shares) {}

    function previewMint(
        uint256 shares
    ) external view override returns (uint256 assets) {}

    function previewWithdraw(
        uint256 assets
    ) external view override returns (uint256 shares) {}

    function previewRedeem(
        uint256 shares
    ) external view override returns (uint256 assets) {}

    function maxDeposit(
        address receiver
    ) external view override returns (uint256 maxAssets) {}

    function maxMint(
        address receiver
    ) external view override returns (uint256 maxShares) {}

    function maxWithdraw(
        address owner
    ) external view override returns (uint256 maxAssets) {}

    function maxRedeem(
        address owner
    ) external view override returns (uint256 maxShares) {}
}