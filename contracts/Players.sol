// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.4.22 <0.9.0;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";



contract Players is ERC20{
   // Set the address of the chairperson here
   /*
   "chairperson” is the only address that has the ability to register a coach.

   */
     
     address  chairperson;
     /*
   “member” is a mapping from address to uint that determines whether a certain address is 
registered or not. 0 means the address is not registered. 1 means the address is registered. We use 
it for example to check whether an address can even create a service or not
   */
      mapping(address =>uint) member;
      /*
   "isCoach” is a mapping from address to uint that determines whether a certain address is a coach 
or not. Only coaches can admit services.
*/


    mapping(address=>uint) isCoach;
     /*
   “players” is a mapping from address to uint that maps the address to its balance.
*/
    mapping(address=>uint) players;
/*tokenAddr is the address of the Btt token contract*/
    address tokenAddr;

  
 /*
   “onlyMember” is a modifier to determine whether the sender address is a member or not. It uses 
the member mapping above.*/
      modifier onlyMember{ 
         require(member[msg.sender]==1);
            _;
      }
       /*
   “onlyMemberTo” is a modifier to determine whether the “to address” for sending money is also 
a member. It should not be allowed to send money to an address that is not registered. It uses a 
parameter which is the address to check.
*/
modifier onlyMemberTo(address payable toAddress){ 
         require(member[toAddress]==1);
            _;
      }
  
 /*
   “onlyCoach” is a modifier to determine whether the sender address is a coach or not. It is used 
for the admit service function.

*/
    modifier onlyCoach{
        require(isCoach[msg.sender]==1);
        _;
    }
 /*
  “onlyChairperson” is a modifier to determine whether the sender address is the chairperson or 
not. It is used to register a coach.

*/
    modifier onlyChairperson{
        require(msg.sender == chairperson);
        _;
    }
    /*
    "notRegistered" is a modifier to determine whether the sender is not registered. It is used to limit access to airdrop, so that only addresses who are not registered can get the starting money
    */
    modifier notRegistered{
        require(member[msg.sender]==0);
        _;
    }
    /*
    "notRegistered" is a modifier to determine whether the address a is not registered. It is used to limit access to airdrop, so that only addresses who are not registered can get the starting money
    */
    modifier notRegisteredTo(address a){
        require(member[a]==0);
        _;
    }
    
  

        /*constructor creates new erc20 contract and mints initialSupply tokens to the contract*/
    constructor (uint256 initialSupply) public ERC20("Btt", "Btt") payable { 
		chairperson = msg.sender;
            _mint(address(this), initialSupply*10** uint(decimals()));
        }
        /*“register()” is the function to register an address as a player. It can be used by anyone. It also airdrops each newly registered player 20 Btt.*/
     function register () notRegistered public payable{ 
        address payable ad = payable(msg.sender);
        airdrop(20*10**uint(decimals()));
        member[ad] = 1;
         isCoach[ad]=0;
     }
     /*0
     “airdrop()” is to airdrop tokens to newly registered users. Registered users cannot use it.
     */
     function airdrop( uint256 amount) notRegistered public virtual returns (bool) {
        address owner = address(this);
        _transfer(owner, msg.sender, amount);
        return true;
    }
    function airdrop2( address to, uint256 amount) notRegistered public virtual returns (bool) {
        address owner = address(this);
        _transfer(owner, to, amount*10**uint(decimals()));
        return true;
    }
     /*0
     “registerCoach()” is the function to register an address as a coach. It can only be used by the 
chairperson.

     */
    function registerCoach (address payable toRegister) onlyChairperson public payable{
//        players[toRegister] = msg.sender.balance;
        member[toRegister] = 1;
        isCoach[toRegister]=1;
    }
    
    /*
    “unRegister” is the function to unregister an address.
    */
     function unRegister() public payable{
         address payable ad = payable(msg.sender);
         member[ad] = 0;
         isCoach[ad]=0;
     }
  /*
  “register_service()” is the function to request to register a service. It can only be used by 
members. The reason why it is empty is because there is no datastructure for services in the 
smartcontract. This is all handled offchain on a database. We still use this function for 
verification.

  */
     function register_service() onlyMember public{
        // We will only verify whether the sender address can register a service. Only modifier onlyMember() is necessary for that
     }
     /*
     “submit_service” is the function to admit a service that a player has registered. It can only be 
used by coaches. It is also empty because it is only used for verification.

     */
    function submit_service() onlyCoach public {

    }


     /*
     transferBttFromSc() is used to transfer Btt from the smartcontract to the newly registered users
     */

     

/*
“isRegistered” is a view bool function that returns whether a given address is registered or not. It 
is used in the frontend for certain UI elements so that UI elements that are only meant for 
registered users are not getting displayed.
*/
   function isRegistered (address a) public view returns(bool){
         return (member[a] == 1);
   }
   /*
   isCoachView” is a view bool function that returns whether a given address is registered as a 
coach or not. It serves the same function as “isRegistered.”
   */
    function isCoachView (address a) public view returns(bool){
        return (isCoach[a]==1);
    }
    /*
    “isChairperson” is a view bool function that returns whether a given address is the chairperson or 
not. It is necessary to check whether the account using the webapp is the chairperson or not.
    */
    function isChairperson (address a) public view returns(bool){
        return (payable(a) == chairperson);
    }
    /*
    Returns token contract address 
    */
    function getTokenAddress() public view returns(address) {
            return tokenAddr;
    }
    /*Returns Btt balance of address from if he is a member. It is converted from wei to either.*/
    function getBalance(address from) public view returns(uint256) {
            return balanceOf(from)/(10**uint(decimals()));
    }
    function getChairperson () public view returns(address){
        return chairperson;
    }
    
}