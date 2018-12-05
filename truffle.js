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
            from: '0xf09a88478c48a59Ae925BcC4C5d5024C47C5CbCd',
            gas: 4700000,
            gasPrice: 10000000000
        },
    }
};
