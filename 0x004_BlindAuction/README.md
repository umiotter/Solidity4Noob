# A BlindAuction for NFT

This project demonstrates a simple BlindAuction for NFT. It mainly comes with a BlindAuciton contract, a Simple NFT contract, and a test for these contracts.

Try running the UnitTest of the demo:

```shell
npm init
npm install --save-dev hardhat
npx hardhat compile
npx hardhat test
```

Following is the output log of UnitTest:
```shell
BlindAuctionOfUmiotterToken
    ✔ should deploy UmiotterNFT and mint 1 token to each address successfully. (684ms)
    ✔ should deploy BlindAuction and approve auction contract control the NFT. (39ms)
    ✔ addr1 should be the highest bidder with bid price 1.
    ✔ addr2 should exceed addr1 to the highest bidder with highest price 4. (52ms)
    ✔ addr1 should successfully refunded. (48ms)
    ✔ owner should get the benefit.
```
