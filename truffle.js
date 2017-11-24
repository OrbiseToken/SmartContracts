module.exports = {
  networks: {
    local: {
      host: "localhost",
      port: 8545,
      network_id: "*", // Match any network id
      gas: 4712388,
    },
    development: {
      host: "192.168.1.106",
      port: 8545,
      network_id: "*", // Match any network id
      gas: 4712388
    }
  }
};
