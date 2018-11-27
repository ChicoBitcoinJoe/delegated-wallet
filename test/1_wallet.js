const DelegatedWalletBlueprint = artifacts.require("DelegatedWallet");
const MiniMeToken = artifacts.require("MiniMeToken");
const TokenGenerator = artifacts.require("TokenGenerator");

contract('Delegated Wallet Blueprint', accounts => {
    
    const ETHER = '0x0000000000000000000000000000000000000000';

    function ether (valueInEther) {
        return web3.utils.toWei(valueInEther.toString(), 'ether');
    }

    // Contracts
    var DelegatedWallet;
    var TokenDespenser;
    var Token;

    // Accounts
    var defaultCaller = accounts[0];
    var owner = accounts[1];
    var recipient = accounts[2];
    var attacker = accounts[3];
    var delegate0 = accounts[4];
    var delegate1 = accounts[5];
    var delegate2 = accounts[6];

    // Receipts
    var initTx;

    it("initialize the delegated wallet blueprint", () => {
        return DelegatedWalletBlueprint.new()
        .then(instance => {
            DelegatedWallet = instance;
            return DelegatedWallet.initialize(owner, {from: defaultCaller});
        })
        .then(tx => {
            initTx = tx;
            return TokenGenerator.deployed()
        })
        .then(instance => {
            TokenDespenser = instance;
            
            return Promise.all([
                TokenDespenser.token(),
                web3.eth.sendTransaction({to: DelegatedWallet.address, from: defaultCaller, value: ether(1)}),
                TokenDespenser.generateTokens(DelegatedWallet.address, ether(1), {from: defaultCaller}),
            ]);
        })
        .then(promises => {
            token = promises[0];
            return MiniMeToken.at(token)
        })
        .then(instance => {
            Token = instance;
            
            return Promise.all([
                web3.eth.getBalance(DelegatedWallet.address),
                Token.balanceOf(DelegatedWallet.address),
                DelegatedWallet.owner(),
                DelegatedWallet.blockCreated(),
            ]);
        })
        .then(promises => {
            var etherBalance = promises[0];
            var tokenBalance = promises[1];
            var walletOwner = promises[2];
            var blockCreated = promises[3];

            assert(etherBalance == ether(1), "wallet ether balance should equal one ether");
            assert(tokenBalance == ether(1), "wallet erc20 token balance should equal 10^18 (one ether)");
            assert(owner == walletOwner, "wallet owner failed to set properly");
            assert(blockCreated == initTx.receipt.blockNumber, "delegated wallet should be initialized");
        })
    });

    it("have the owner add delegates", () => {
        return Promise.all([
            DelegatedWallet.addDelegate(delegate0, {from: owner}),
            DelegatedWallet.addDelegate(delegate1, {from: owner}),
            DelegatedWallet.addDelegate(delegate2, {from: owner}),
        ]).then(txs => {
            return DelegatedWallet.getDelegates();
        })
        .then(delegates => {
            assert(delegates[0] == delegate0, "delegates[0] should be set to delegate0");
            assert(delegates[1] == delegate1, "delegates[1] should be set to delegate1");
            assert(delegates[2] == delegate2, "delegates[2] should be set to delegate2");
        })
    });

    it("have the owner remove a delegate", () => {
        return DelegatedWallet.removeDelegate(delegate0, {from: owner})
        .then(txs => {
            return DelegatedWallet.getDelegates();
        })
        .then(delegates => {
            assert(delegates[0] == delegate2, "delegates[0] should be set to delegate2");
            assert(delegates[1] == delegate1, "delegates[1] should be set to delegate1");
        })
    });

    it("have a delegate transfer ether from the wallet", () => {
        var recipientStartBalance;
        
        return web3.eth.getBalance(recipient)
        .then(recipientBalance => {
            recipientStartBalance = Number(web3.utils.fromWei(recipientBalance, "ether"));
            return DelegatedWallet.transfer(ETHER, recipient, ether(.5), {from: delegate1})
        })
        .then(tx => {
            return Promise.all([
                web3.eth.getBalance(DelegatedWallet.address),
                web3.eth.getBalance(recipient)
            ]);
        })
        .then(balances => {
            var walletBalance = balances[0];
            var walletBalance = balances[0];

            var recipientBalance = balances[1];
            var recipientBalanceInEther = Number(web3.utils.fromWei(recipientBalance, "ether"));
            assert(walletBalance == ether(.5), "wallet ether balance should equal half an ether");
            assert(recipientBalanceInEther == recipientStartBalance + .5, "recipient ether balance should be half an ether more");
        })
    });

    it("have a delegate transfer erc20 tokens from the wallet", () => {
        var oldBalance;

        return Token.balanceOf(recipient)
        .then(tokenBalance => {
            oldBalance = tokenBalance;
            return DelegatedWallet.transfer(Token.address, recipient, ether(.5), {from: delegate1})
        })
        .then(tx => Promise.all([
            Token.balanceOf(DelegatedWallet.address),
            Token.balanceOf(recipient),
        ]))
        .then(balances => {
            var walletBalance = balances[0];
            var newRecipientBalance = web3.utils.fromWei(balances[1], "ether");
            var expectedBalance = Number(web3.utils.fromWei(oldBalance, "ether")) + .5;
            assert(walletBalance == ether(.5), "wallet token balance should equal half an ether");
            assert(newRecipientBalance == expectedBalance, "wallet token balance should equal old balance plus half an ether");
        })
    });

    it("fail to re-initialize the wallet", () => {
        console.log("    ! An attacker appears")
        return DelegatedWallet.initialize(attacker, {from: attacker})
        .then(() => {
            assert(false, "the delegated wallet should only be able to be initialized once");
        })
        .catch(err => assert(true))
    });

    it("fail to transfer ether from the delegated wallet", () => {
        return DelegatedWallet.transfer(ETHER, attacker, ether(.25), {from: attacker})
        .then(tx => {
            assert(false, "attacker should not be able to send ether")
        })
        .catch(err => web3.eth.getBalance(DelegatedWallet.address))
        .then(etherBalance => {
            assert(etherBalance == ether(.5), "wallet ether balance should equal half an ether");
        })
    });

    it("fail to transfer erc20 tokens from the delegated wallet", () => {
        return DelegatedWallet.transfer(Token.address, attacker, ether(.25), {from: attacker})
        .then(tx => {
            assert(false, "attacker should not be able to send erc20 tokens")
        })
        .catch(err => Token.balanceOf(DelegatedWallet.address))
        .then(tokenBalance => {
            assert(tokenBalance == ether(.5), "wallet token balance should equal half an ether");
        })
    });

    it("fail to add a delegate", () => {
        return DelegatedWallet.addDelegate(attacker, {from: attacker})
        .then(tx => {
            assert(false, "a non-owner should never be allowed to add an address")
        })
        .catch(() => {
            // expected outcome
        })
    });

    it("fail to remove a delegate", () => {
        return DelegatedWallet.removeDelegate(attacker, {from: attacker})
        .then(tx => {
            assert(false, "a non-owner should never be allowed to remove an address")
        })
        .catch(() => {
            // expected outcome
        })
    });
    
    it("fail to transfer wallet ownership", () => {
        return DelegatedWallet.removeDelegate(attacker, {from: attacker})
        .then(tx => {
            assert(false, "a non-owner should never be allowed to remove an address")
        })
        .catch(() => {
            // expected outcome
        })
    });

});
