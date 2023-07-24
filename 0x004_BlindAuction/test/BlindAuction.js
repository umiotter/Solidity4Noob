const {
  time,
  loadFixture,
} = require("@nomicfoundation/hardhat-toolbox/network-helpers");
const { anyValue } = require("@nomicfoundation/hardhat-chai-matchers/withArgs");
const { expect } = require("chai");
const hre = require("hardhat");
const provider = hre.ethers.provider;

describe("BlindAuctionOfUmiotterToken", function () {
  async function deployUmiotterNFTFixture() {
    const NFTName = "UmiotterNFT";
    const NFTSymbol = "UONFT";

    // Contracts are deployed using the first signer/account by default
    const [owner, addr1, addr2, addr3] = await ethers.getSigners();

    const umiotterNFT = await ethers.deployContract("UmiotterNFT", [
      NFTName,
      NFTSymbol,
    ]);
    return { umiotterNFT, NFTName, NFTSymbol, owner, addr1, addr2, addr3 };
  }

  async function deployBlindAuctionFixture() {
    const { umiotterNFT, owner, addr1, addr2, addr3 } = await loadFixture(
      deployUmiotterNFTFixture
    );

    const biddingTime = 60 * 30;
    const revealTime = 60 * 3;

    const blindAuction = await ethers.deployContract("BlindAuction", [
      biddingTime,
      revealTime,
      owner.address,
      umiotterNFT.target,
    ]);

    return {
      blindAuction,
      umiotterNFT,
      biddingTime,
      revealTime,
      owner,
      addr1,
      addr2,
    };
  }

  it("should deploy UmiotterNFT and mint 1 token to each address successfully.", async () => {
    const { umiotterNFT, owner, addr1, addr2, addr3 } = await loadFixture(
      deployUmiotterNFTFixture
    );
    // console.log("umiotterNFT Method", umiotterNFT);
    await umiotterNFT.mint(owner.address, 0);
    await umiotterNFT.mint(addr1.address, 1);
    await umiotterNFT.mint(addr2.address, 2);
    await umiotterNFT.mint(addr3.address, 3);

    expect(await umiotterNFT.balanceOf(owner.address)).to.equal(1);
    expect(await umiotterNFT.balanceOf(addr1.address)).to.equal(1);
    expect(await umiotterNFT.balanceOf(addr2.address)).to.equal(1);
    expect(await umiotterNFT.balanceOf(addr3.address)).to.equal(1);
  });

  it("should deploy BlindAuction and approve auction contract control the NFT.", async () => {
    // const { umiotterNFT, owner, addr1, addr2, addr3 } = await loadFixture(
    //   deployUmiotterNFTFixture
    // );
    const {
      blindAuction,
      umiotterNFT,
      biddingTime,
      revealTime,
      owner,
      addr1,
      addr2,
    } = await loadFixture(deployBlindAuctionFixture);

    // mint 1 NFT to owner
    await umiotterNFT.mint(owner.address, 0);
    // approve blindAuction contrast control the NFT
    await umiotterNFT.approve(blindAuction.target, 0);

    expect(await umiotterNFT.balanceOf(owner.address)).to.equal(1);
    expect(await umiotterNFT.getApproved(0)).to.equal(blindAuction.target);
  });

  it("addr1 should be the highest bidder with bid price 1.", async () => {
    const {
      blindAuction,
      umiotterNFT,
      biddingTime,
      revealTime,
      owner,
      addr1,
      addr2,
    } = await loadFixture(deployBlindAuctionFixture);

    // mint 1 NFT to owner
    await umiotterNFT.mint(owner.address, 0);
    // approve blindAuction contrast control the NFT
    await umiotterNFT.approve(blindAuction.target, 0);

    // onstruct bid msg for addr1
    const nounce1 = ethers.encodeBytes32String("addr1");

    // addr1 bid once
    await blindAuction
      .connect(addr1)
      .bid(
        ethers.solidityPackedKeccak256(
          ["uint", "bool", "bytes32"],
          ["1", false, nounce1]
        ),
        {
          value: ethers.parseEther("2.0"),
        }
      );

    // bid end, reveal time
    await time.increase(biddingTime);

    // revealing the price
    await blindAuction
      .connect(addr1)
      .reveal(["1"], [false], [nounce1]);

    let highestBidder = await blindAuction.highestBidder();
    let highestPrice = await blindAuction.highestBidPrice();

    expect(highestBidder).to.equal(addr1.address);
    expect(highestPrice).to.equal(1);
  });

  it("addr2 should exceed addr1 to the highest bidder with highest price 4.", async () => {
    const {
      blindAuction,
      umiotterNFT,
      biddingTime,
      revealTime,
      owner,
      addr1,
      addr2,
    } = await loadFixture(deployBlindAuctionFixture);

    // mint 1 NFT to owner
    await umiotterNFT.mint(owner.address, 0);
    // approve blindAuction contrast control the NFT
    await umiotterNFT.approve(blindAuction.target, 0);

    // onstruct bid msg for addr1
    const nounce1 = ethers.encodeBytes32String("addr1");

    // addr1 bid two times
    await blindAuction
      .connect(addr1)
      .bid(
        ethers.solidityPackedKeccak256(
          ["uint", "bool", "bytes32"],
          ["1", false, nounce1]
        ),
        {
          value: ethers.parseEther("2.0"),
        }
      );
    await blindAuction
      .connect(addr1)
      .bid(
        ethers.solidityPackedKeccak256(
          ["uint", "bool", "bytes32"],
          ["3", true, nounce1]
        ),
        {
          value: ethers.parseEther("4.0"),
        }
      );

    // construct bid msg for addr2
    const nounce2 = ethers.encodeBytes32String("addr2");

    // addr2 bid once
    await blindAuction
      .connect(addr2)
      .bid(
        ethers.solidityPackedKeccak256(
          ["uint", "bool", "bytes32"],
          ["4", false, nounce2]
        ),
        {
          value: ethers.parseEther("4.0"),
        }
      );

    // bid end, reveal time
    await time.increase(biddingTime);

    // revealing the price
    await blindAuction
      .connect(addr1)
      .reveal(["1", "3"], [false, true], [nounce1, nounce1]);
    await blindAuction.connect(addr2).reveal(["4"], [false], [nounce2]);

    // const returns4addr1 = await blindAuction.connect(addr1).getPendingReturns();
    let highestBidder = await blindAuction.highestBidder();
    let highestPrice = await blindAuction.highestBidPrice();
    expect(highestBidder).to.equal(addr2.address);
    expect(highestPrice).to.equal(4);
  });

  it("addr1 should successfully refunded.", async () => {
    const {
      blindAuction,
      umiotterNFT,
      biddingTime,
      revealTime,
      owner,
      addr1,
      addr2,
    } = await loadFixture(deployBlindAuctionFixture);

    // mint 1 NFT to owner
    await umiotterNFT.mint(owner.address, 0);
    // approve blindAuction contrast control the NFT
    await umiotterNFT.approve(blindAuction.target, 0);

    // onstruct bid msg for addr1
    const nounce1 = ethers.encodeBytes32String("addr1");

    // addr1 bid two times
    await blindAuction
      .connect(addr1)
      .bid(
        ethers.solidityPackedKeccak256(
          ["uint", "bool", "bytes32"],
          ["30", false, nounce1]
        ),
        {
          value: ethers.parseEther("40.0"),
        }
      );
    await blindAuction
      .connect(addr1)
      .bid(
        ethers.solidityPackedKeccak256(
          ["uint", "bool", "bytes32"],
          ["30", true, nounce1]
        ),
        {
          value: ethers.parseEther("40.0"),
        }
      );
    // beforeWithdraw = ethers.formatEther(await provider.getBalance(addr1.address));
    // console.log(beforeWithdraw);
    // construct bid msg for addr2
    const nounce2 = ethers.encodeBytes32String("addr2");

    // addr2 bid once
    await blindAuction
      .connect(addr2)
      .bid(
        ethers.solidityPackedKeccak256(
          ["uint", "bool", "bytes32"],
          ["40", false, nounce2]
        ),
        {
          value: ethers.parseEther("40.0"),
        }
      );

    // bid end, reveal time
    await time.increase(biddingTime);

    // revealing the price
    await blindAuction
      .connect(addr1)
      .reveal(["30", "40"], [false, true], [nounce1, nounce1]);
    await blindAuction.connect(addr2).reveal(["40"], [false], [nounce2]);

    var returns4addr1 = await blindAuction.connect(addr1).getPendingReturns();
    expect(returns4addr1).to.equal(30);
   
    await blindAuction.connect(addr1).withdraw();
    returns4addr1 = await blindAuction.connect(addr1).getPendingReturns();
    expect(returns4addr1).to.equal(0);

  });

  it("addr1 should get the NFT.", async () => {
    const {
      blindAuction,
      umiotterNFT,
      biddingTime,
      revealTime,
      owner,
      addr1,
      addr2,
    } = await loadFixture(deployBlindAuctionFixture);

    // mint 1 NFT to owner
    await umiotterNFT.mint(owner.address, 0);
    // approve blindAuction contrast control the NFT
    await umiotterNFT.approve(blindAuction.target, 0);

    // onstruct bid msg for addr1
    const nounce1 = ethers.encodeBytes32String("addr1");

    // addr1 bid two times
    await blindAuction
      .connect(addr1)
      .bid(
        ethers.solidityPackedKeccak256(
          ["uint", "bool", "bytes32"],
          ["30", false, nounce1]
        ),
        {
          value: ethers.parseEther("40.0"),
        }
      );

    // bid end, reveal time
    await time.increase(biddingTime);

    // revealing the price
    await blindAuction
      .connect(addr1)
      .reveal(["30"], [false], [nounce1]);
    // withdraw rest value
    await blindAuction.connect(addr1).withdraw(); 
    
    // reveal end, transfer benefit
    await time.increase(revealTime);
    await blindAuction.auctionEnd();

    expect(await umiotterNFT.ownerOf(0)).to.equal(addr1.address);

  });
});
