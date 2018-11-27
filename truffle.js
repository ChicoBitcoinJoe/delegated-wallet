module.exports = {
    networks: {
        'development': {
            host: "localhost",
            port: 8545,
            network_id: "*" // Match any network id
        },
        'kovan': {
            host: "localhost",
            port: 8545,
            network_id: 42,
            from: '0x0170C8C0365a788b0679e76ED56d60054260ff7d',
            gas: 4700000,
            gasPrice: 10000000000
        },
    }
};
