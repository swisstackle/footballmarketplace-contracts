const Players = artifacts.require("Players");
const fs = require('fs');
module.exports = function (deployer) {
    deployer.deploy(Players,10000000).then(function() {
        fs.writeFile('../football_marketplace-app/address.txt', Players.address, function (err) {
            if (err) throw err;
            console.log('Saved!');
        });
    });
};
