const Players = artifacts.require('../contracts/Players.sol');
const truffleAssert = require('truffle-assertions');
const Web3 = require('web3');
contract('Players', function (accounts) {
    const user1 = accounts[0];
    const user2 = accounts[1];
    let players;
    beforeEach('Setup', async function () {
        players = await Players.new(10000);

    });
    it('Contract has minted 10000 Btt', async function () {
        assert.equal(await players.getBalance(players.address), 10000);
    });
    it('Addresses have a balance of 0 Btt', async function () {
        let bal1 = await players.getBalance(user1);
        let bal2 = await players.getBalance(user2);
        assert.equal(bal1.toNumber(), 0);
        assert.equal(bal2.toNumber(), 0);
    });

    describe('User registration, airdrop and transfer', function () {
        it('Both users are not yet registered', async function () {

            assert.equal(await players.isRegistered(user1), false);
            assert.equal(await players.isRegistered(user2), false);

        });
        it('Addresses are not yet registered', async function () {

            assert.equal(await players.isRegistered(user1), false);
            assert.equal(await players.isRegistered(user2), false);
        });
        it('Succesfully registeres user1 and user2.', async function () {

            await players.register({from: user1});
            await players.register({from: user2});
            assert.equal(await players.isRegistered(user1), true);
            assert.equal(await players.isRegistered(user2), true);

        });

        it('Airdrops 20 tokens to user1 and user2. ', async function () {

            await players.register({from: user1});
            await players.register({from: user2});
            let bal1 = await players.getBalance(user1);
            let bal2 = await players.getBalance(user2);
            assert.equal(bal1.toNumber(), 20);
            assert.equal(bal2.toNumber(), 20);
        });
        it('Succesfully transfers 10 tokens from user1 to user2. ', async function () {

            await players.register({from: user1});
            await players.register({from: user2});
            await players.transfer(user2, Web3.utils.toWei('10', 'ether'));
            let bal1_ = await players.getBalance(user1);
            let bal2_ = await players.getBalance(user2);
            assert.equal(bal1_.toNumber(), 10);
            assert.equal(bal2_.toNumber(), 30);
        });

        it('transferFrom test', async function () {
            await players.register({from: user1});
            await players.register({from: user2});
            assert.equal(await players.isRegistered(user1), true);
            assert.equal(await players.isRegistered(user2), true);
            await players.approve(user2, Web3.utils.toWei('10', 'ether')); // user2 can now spend 10 of user1's tokens
            await players.transferFrom(user1, user2, Web3.utils.toWei('10', 'ether'), {from: user2});
            let bal1_ = await players.getBalance(user1);
            let bal2_ = await players.getBalance(user2);
            assert.equal(bal1_.toNumber(), 10);
            assert.equal(bal2_.toNumber(), 30);
        });
    });
    describe('Register Service, registerCoach, submit_service', function () {

        it('Registering service works',async function(){
            await players.register({from: user1});

            await truffleAssert.passes(
                players.register_service({from:user1})
            );
        });
        it('registerCoach() works',async function(){
            await players.register({from: user1});

            await truffleAssert.passes(
                players.registerCoach(user2,{from:user1})
            );
        });
        it('submit_service() works',async function(){

            await players.registerCoach(user1,{from:user1});
            await truffleAssert.passes(
                players.submit_service({from:user1})
            );
        });
    });
    describe('Negative tests', function () {
        it('airdrop() reversts if caller is already registered',async function(){
            await players.register({from: user1});

            await truffleAssert.fails(
                players.airdrop(20,{from:user1}),
                truffleAssert.ErrorType.REVERT,
                null,
                null
            );
        });

        it('register() reverts if user is already registered', async function(){
            await players.register({from: user1});
            await truffleAssert.fails(
                players.register({from:user1}),
                truffleAssert.ErrorType.REVERT,
                null,
                null
            );
        });
        it('register_service() should revert if user not registered', async function(){
            await truffleAssert.fails(
                players.register_service({from:user1}),
                truffleAssert.ErrorType.REVERT,
                null,
                null
            );
        });
        it('submit_service() should revert if user not a coach', async function(){
            await players.register({from: user2});
            await truffleAssert.fails(
                players.submit_service({from:user2}),
                truffleAssert.ErrorType.REVERT,
                null,
                null
            );
        });
        it('registerCoach() reverts if not chairperson',async function(){
            await players.register({from: user2});
            await truffleAssert.fails(
                players.registerCoach(user2,{from:user2}),
                truffleAssert.ErrorType.REVERT,
                null,
                null
            );

        });

    });
});