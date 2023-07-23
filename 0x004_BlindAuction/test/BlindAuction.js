const {
    time,
    loadFixture,
  } = require("@nomicfoundation/hardhat-toolbox/network-helpers");
  const { anyValue } = require("@nomicfoundation/hardhat-chai-matchers/withArgs");
  const { expect } = require("chai");

  describe("BlindAuctionOfUmiotterToken", () => {
    async function deployUmiotterTokenFixture() {
      const tokenName = "UmiotterToken";
      const tokenSymbol = "UOT";
  
      // Contracts are deployed using the first signer/account by default
      const [owner, addr1, addr2, addr3] = await ethers.getSigners();
  
      const umiottertoken = ether.ethers.deployContract("SimpleToken",{tokenName, tokenSymbol});
  
      return { umiottertoken, tokenName, tokenSymbol, owner, addr1, addr2, addr3 };
    }

    async function deployBlindAuctionFixture() {

    }

    it("should deploy successfully.", async () => {
      const { umiottertoken, owner, addr1, addr2, addr3 } = await loadFixture(
        deployUmiotterTokenFixture
      );
      async umiottertoken.mint(11)
      expect(await acution.beneficiary()).to.equal(owner.address);
    });
    
  });