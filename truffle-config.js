const HDWalletProvider = require("@truffle/hdwallet-provider");
let mnemonic = require("./secrets.js").mnemonic;
let endpoint = require("./secrets.js").endpoint;

module.exports = {
    // See <http://truffleframework.com/docs/advanced/configuration>
    // for more about customizing your Truffle configuration!
    networks: {
        kovan: {
            provider: function() {
                return new HDWalletProvider(mnemonic, endpoint);
            },
            network_id: '42',
            gas: 4700000,
            gasPrice: 1000000000
        }
    }
};
