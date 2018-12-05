const DelegatedWallet = artifacts.require("DelegatedWallet");
const DelegatedWalletFactory = artifacts.require("DelegatedWalletFactory");
const DelegatedWalletManager = artifacts.require("DelegatedWalletManager");

contract('Delegated Wallet Manager', accounts => {

    var Wallet;
    var WalletFactory;
    var WalletManager;

    var CreatedWallet;
    var AddedWallet;
    var RemovedWallet;

    var owner = null;
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
            //console.log(tx.logs[0].args);
            assert(tx.logs[0].event == "AddWallet_event", "Did not detect addition of new wallet");
            CreatedWallet = tx.logs[0].args.wallet;
            owner = tx.logs[0].args.owner;
            return WalletManager.getWallets(owner)
        })
    });

    it("add a wallet", () => {
        return WalletFactory.createWallet(owner, [delegate])
        .then(tx => {
            //console.log(tx.logs[0].args)
            assert(tx.logs[0].event == "CreateWallet_event", "Did not detect addition of new wallet");
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
            //console.log(tx.logs[0].args);
            assert(tx.logs[0].event == "AddWallet_event", "Did not detect addition of new wallet");
            RemovedWallet = tx.logs[0].args.wallet;
            owner = tx.logs[0].args.owner;

            return WalletManager.removeWallet(RemovedWallet);
        })
        .then(tx => {
            assert(tx.logs[0].event == "RemoveWallet_event", "Did not detect removal of new wallet");
            return WalletManager.removeWallet(tx.logs[0].args.wallet);
        })
    });

    it("verify accuracy of getters", () => {
        return Promise.all([
            WalletManager.getWallets(owner),
            WalletManager.totalWallets(owner),
            WalletManager.contains(owner, CreatedWallet),
            WalletManager.contains(owner, AddedWallet),
            WalletManager.contains(owner, RemovedWallet),
            WalletManager.index(owner, 0),
            WalletManager.index(owner, 1),
            WalletManager.indexOf(owner, CreatedWallet),
            WalletManager.indexOf(owner, AddedWallet),
        ])
        .then(promises => {
            var walletArray = promises[0];
            var totalWallets = promises[1];
            var walletArrayContainsCreatedWallet = promises[2];
            var walletArrayContainsAddedWallet = promises[3];
            var walletArrayContainsRemovedWallet = promises[4];
            var walletAtIndex0 = promises[5];
            var walletAtIndex1 = promises[6];
            var indexOfCreatedWallet = promises[7];
            var indexOfAddedWallet = promises[8];

            assert(walletArray[0] == CreatedWallet, "wallet array [0] does not match expected");
            assert(walletArray[1] == AddedWallet, "wallet array [1] does not match expected");
            assert(walletArray.length == totalWallets, "total wallets does not equal wallet array length");
            assert(walletArrayContainsCreatedWallet == true, "wallet array should contain created wallet");
            assert(walletArrayContainsAddedWallet == true, "wallet array should contain added wallet");
            assert(walletArrayContainsRemovedWallet == false, "wallet should not contain the blueprint wallet");
            assert(walletAtIndex0 == CreatedWallet, "the wallet at index 0 should be the created wallet");
            assert(walletAtIndex1 == AddedWallet, "the wallet at index 1 should be the created wallet");
            assert(indexOfCreatedWallet == 0, "the index of the created wallet should equal 0");
            assert(indexOfAddedWallet == 1, "the index of the added wallet should equal 1");
        })
    });

});
