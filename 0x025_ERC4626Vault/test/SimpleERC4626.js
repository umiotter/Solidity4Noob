const zeroAddress = "0x0000000000000000000000000000000000000000";

const { expect } = require("chai");
const { ethers } = require("hardhat");
const {
  loadFixture,
  helpers,
  time,
} = require("@nomicfoundation/hardhat-toolbox/network-helpers");

describe("vUmiToken Contract", () => {
  async function deployUmiERC20Fixture() {
    const [owner, addr1, addr2] = await ethers.getSigners();
    const umiToken = await ethers.deployContract("UmiToken");
    const simpleERC4626 = await ethers.deployContract("SimpleERC4626", [
      umiToken,
      "vUmiToken",
      "vUmiToken",
    ]);

    return { umiToken, simpleERC4626, owner, addr1, addr2 };
  }

  // Test case
  describe("UmiToken && vUmiToken Deployment", () => {
    it("should mint 10000 UmiToken to owner.", async () => {
      const { umiToken, simpleERC4626, owner, addr1, addr2 } =
        await loadFixture(deployUmiERC20Fixture);

      expect(await umiToken.balanceOf(owner)).to.equal(10000);
    });

    it("should set the vUmiToken asset to UmiToken address.", async () => {
      const { umiToken, simpleERC4626, owner, addr1, addr2 } =
        await loadFixture(deployUmiERC20Fixture);

      expect(await simpleERC4626.asset()).to.equal(umiToken.target);
    });
  });

  describe("Rumtime", () => {
    it("should approve 10000 UmiToken to vUmiToken contract.", async () => {
      const { umiToken, simpleERC4626, owner, addr1, addr2 } =
        await loadFixture(deployUmiERC20Fixture);

      await umiToken.approve(simpleERC4626.target, 10000);

      expect(await simpleERC4626.asset()).to.equal(umiToken.target);
      expect(await umiToken.allowance(owner, simpleERC4626.target)).to.equal(
        10000
      );
    });

    it("should deposit 1000 UmiToken to vUmiToken vault after owner call deposit(1000).", async () => {
      const { umiToken, simpleERC4626, owner, addr1, addr2 } =
        await loadFixture(deployUmiERC20Fixture);

        await umiToken.approve(simpleERC4626.target, 10000);
        await simpleERC4626.deposit(1000, owner);

      expect(await simpleERC4626.balanceOf(owner)).to.equal(1000);
      expect(await umiToken.balanceOf(owner)).to.equal(9000);
    });

    it("should mint 1000 vUmiToken after owner call mint(1000).", async () => {
        const { umiToken, simpleERC4626, owner, addr1, addr2 } =
          await loadFixture(deployUmiERC20Fixture);
  
          await umiToken.approve(simpleERC4626.target, 10000);
          await simpleERC4626.mint(1000, owner);
  
        expect(await simpleERC4626.balanceOf(owner)).to.equal(1000);
        expect(await umiToken.balanceOf(owner)).to.equal(9000);
      });

      it("should withdraw 1000 UmiToken after owner call withdraw(1000).", async () => {
        const { umiToken, simpleERC4626, owner, addr1, addr2 } =
          await loadFixture(deployUmiERC20Fixture);
  
          await umiToken.approve(simpleERC4626.target, 10000);
          await simpleERC4626.deposit(1000, owner);
          await simpleERC4626.withdraw(1000, owner, owner);

        expect(await simpleERC4626.balanceOf(owner)).to.equal(0);
        expect(await umiToken.balanceOf(owner)).to.equal(10000);
      });

      it("should redeem 1000 vUmiToken in simpleERC4626 vault after owner call withdraw(1000).", async () => {
        const { umiToken, simpleERC4626, owner, addr1, addr2 } =
          await loadFixture(deployUmiERC20Fixture);
  
          await umiToken.approve(simpleERC4626.target, 10000);
          await simpleERC4626.deposit(1000, owner);
          await simpleERC4626.withdraw(1000, owner, owner);

        expect(await simpleERC4626.balanceOf(owner)).to.equal(0);
        expect(await umiToken.balanceOf(owner)).to.equal(10000);
      });
  });
});
