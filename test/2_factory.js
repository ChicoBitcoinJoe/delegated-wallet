const DelegatedWallet = artifacts.require("DelegatedWallet");
const DelegatedWalletFactory = artifacts.require("DelegatedWalletFactory");

contract('Delegated Wallet Factory', accounts => {
    
    var Wallet;
    var WalletFactory;

    var owner = accounts[0];
    var delegate = accounts[1];

    it("deploy the delegated wallet factory", () => {
        return DelegatedWallet.new()
        .then(instance => {
            Wallet = instance;
            return DelegatedWalletFactory.new(Wallet.address)
        })
        .then(instance => {
            WalletFactory = instance;
            
            return Promise.all([
                web3.eth.getTransactionReceipt(WalletFactory.transactionHash),
                WalletFactory.blockCreated(),
                WalletFactory.blueprint(),
            ]);
        })
        .then(promises => {
            var receipt = promises[0];
            var blockCreated = promises[1];
            var blueprint = promises[2];

            assert(blockCreated == receipt.blockNumber, "block created was not set correctly");
            assert(blueprint == Wallet.address, "blueprint address was not set correctly");
        })
    });

    it("create a new wallet", () => {
        return WalletFactory.createWallet(owner, [delegate])
        .then(tx => {
            assert(tx.logs[0].event == "CreateWallet_event", "Did not detect creation of new wallet");
        })
        .catch(err => {
            assert(false, "Failed to create a new wallet");
        })
    })

});
