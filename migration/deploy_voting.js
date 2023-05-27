var Voting = artifacts.require("../conract/voting.sol");

module.exports = function(deployer){
    deployer.deploy(Voing, [
        web3.utils.utf8ToHex('Shopping'),
        web3.utils.utf8ToHex('Sleeping'),
        web3.utils.utf8ToHex('Hiking')
    ]);
}