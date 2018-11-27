const DelegatedWallet = artifacts.require("DelegatedWallet");
const DelegatedWalletFactory = artifacts.require("DelegatedWalletFactory");
const DelegatedWalletManager = artifacts.require("DelegatedWalletManager");

contract('Delegated Wallet Manager', accounts => {

    var Wallet;
    var WalletFactory;
    var WalletManager;

    var CreatedWallet;
    var AddedWallet;

    var owner = accounts[0];
    var delegate = accounts[1];

    it("deploy the delegated wallet manager", () => {
        return DelegatedWallet.new()
        .then(instance => {
            Wallet = instance;
            return DelegatedWalletFactory.new(Wallet.address)
        })
        .then(instance => {
            WalletFactory = instance;
            return DelegatedWalletManager.new()
        })
        .then(instance => {
            WalletManager = instance;
            
            return Promise.all([
                web3.eth.getTransactionReceipt(WalletManager.transactionHash),
                WalletManager.blockCreated(),
            ]);
        })
        .then(promises => {
            var receipt = promises[0];
            var blockCreated = promises[1];

            assert(blockCreated == receipt.blockNumber, "block created was not set correctly");
        })
    });

    it("create a new wallet", () => {
        return WalletManager.createWallet(WalletFactory.address, [delegate])
        .then(tx => {
            assert(tx.logs[0].event == "CreateWallet_event", "Did not detect creation of new wallet");
            CreatedWallet = tx.logs[0].args.wallet;
        })
        .catch(err => {
            assert(false, "Failed to create a new wallet");
        })
    });

    it("add a wallet", () => {
        var walletToBeAdded;
        return WalletFactory.createWallet(owner, [delegate])
        .then(tx => {
            assert(tx.logs[0].event == "CreateWallet_event", "Did not detect creation of new wallet");
            AddedWallet = tx.logs[0].args.wallet;
            return WalletManager.addWallet(AddedWallet);
        })
        .then(tx => {
            assert(tx.logs[0].event == "AddWallet_event", "Did not detect addition of wallet");
        })
    });

    it("removes a wallet", () => {
        return WalletManager.createWallet(WalletFactory.address, [delegate])
        .then(tx => {
            assert(tx.logs[0].event == "CreateWallet_event", "Did not detect creation of new wallet");
            return WalletManager.removeWallet(tx.logs[0].args.wallet);
        })
        .then(tx => {
            assert(tx.logs[0].event == "RemoveWallet_event", "Did not detect removal of wallet");
        })
    });

    it("verify accuracy of getters", () => {
        return Promise.all([
            WalletManager.getWallets(owner),
            WalletManager.totalWallets(owner),
            WalletManager.contains(owner, Wallet.address),
            WalletManager.contains(owner, CreatedWallet),
            WalletManager.contains(owner, AddedWallet),
            WalletManager.index(owner, 0),
            WalletManager.index(owner, 1),
            WalletManager.indexOf(owner, CreatedWallet),
            WalletManager.indexOf(owner, AddedWallet),
        ])
        .then(promises => {
            var walletArray = promises[0];
            var totalWallets = promises[1];
            var walletArrayContainsWallet = promises[2];
            var walletArrayContainsCreatedWallet = promises[3];
            var walletArrayContainsAddedWallet = promises[4];
            var walletAtIndex0 = promises[5];
            var walletAtIndex1 = promises[6];
            var indexOfCreatedWallet = promises[7];
            var indexOfAddedWallet = promises[8];

            assert(walletArray[0] == CreatedWallet, "wallet array does not match expected");
            assert(walletArray[1] == AddedWallet, "wallet array does not match expected");
            assert(totalWallets == walletArray.length, "total wallets does not equal wallet array length");
            assert(walletArrayContainsWallet == false, "wallet should not contain the blueprint wallet");
            assert(walletArrayContainsCreatedWallet == true, "wallet array should contain created wallet");
            assert(walletArrayContainsAddedWallet == true, "wallet array should contain added wallet");
            assert(walletAtIndex0 == CreatedWallet, "the wallet at index 0 should be the created wallet");
            assert(walletAtIndex1 == AddedWallet, "the wallet at index 1 should be the created wallet");
            assert(indexOfCreatedWallet == 0, "the index of the created wallet should equal 0");
            assert(indexOfAddedWallet == 1, "the index of the added wallet should equal 1");
        })
    });

});
