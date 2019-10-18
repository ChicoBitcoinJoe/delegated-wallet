var AddressListLib = artifacts.require("AddressListLib");
var DelegatedWallet = artifacts.require("DelegatedWallet");
var DelegatedWalletFactory = artifacts.require("DelegatedWalletFactory");
var DelegatedWalletManager = artifacts.require("DelegatedWalletManager");

module.exports = async (deployer, network, accounts) => {
    await deployer.deploy(AddressListLib, {overwrite: false});
    deployer.link(AddressListLib, DelegatedWallet);
    deployer.link(AddressListLib, DelegatedWalletManager);
    await deployer.deploy(DelegatedWallet);
    let Blueprint = await DelegatedWallet.deployed();
    await Blueprint.initialize('0x0000000000000000000000000000000000000000');
    deployer.deploy(DelegatedWalletFactory, DelegatedWallet.address);
    deployer.deploy(DelegatedWalletManager);
};
