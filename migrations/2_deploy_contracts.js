var ListLib = artifacts.require("ListLib");

var DelegatedWallet = artifacts.require("DelegatedWallet");
var DelegatedWalletFactory = artifacts.require("DelegatedWalletFactory");
var DelegatedWalletManager = artifacts.require("DelegatedWalletManager");

var MiniMeTokenFactory = artifacts.require("MiniMeTokenFactory");
var MiniMeToken = artifacts.require("MiniMeToken");
var TokenGenerator = artifacts.require("TokenGenerator");

module.exports = function(deployer, network, accounts) {
    deployer.deploy(ListLib)
    .then(() => {
        deployer.link(ListLib, DelegatedWallet);
        deployer.link(ListLib, DelegatedWalletManager);
    })
    .then(() => deployer.deploy(DelegatedWallet))
    .then(() => deployer.deploy(DelegatedWalletFactory, DelegatedWallet.address))
    .then(() => deployer.deploy(DelegatedWalletManager))
    .then(() => deployer.deploy(MiniMeTokenFactory, {overwrite: false}))
    .then(() => deployer.deploy(MiniMeToken, 
        MiniMeTokenFactory.address,
        '0x0000000000000000000000000000000000000000', 
        0, 
        "Test ERC20 Token",
        18,
        "tkn",
        true
    ))
    .then(() => deployer.deploy(TokenGenerator, MiniMeToken.address))
    .then(() => MiniMeToken.deployed())
    .then(instance => {
        return instance.controller()
        .then(controller => {
            console.log(controller, TokenGenerator.address);
            if(controller != TokenGenerator.address)
                return instance.changeController(TokenGenerator.address, {from: controller})
            else
                return Promise.resolve()
        })
        .catch(err => {
            //console.log(err)
            //console.error(err)
        })
    })
    .then(() => {
        console.log("Finished deploying contracts")
    })
};
