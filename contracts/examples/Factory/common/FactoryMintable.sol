// SPDX-License-Identifier: MIT
pragma solidity >=0.8.4;

import {Context} from "@openzeppelin/contracts/utils/Context.sol";
import {IFactoryMintable} from "./IFactoryMintable.sol";
import {TokenFactory} from "./TokenFactory.sol";

/**

A FactoryMintable contract is an NFT contract that deploys a TokenFactory contract along side it.
The TokenFactory contract itself is an NFT contract, which mints non-transferrable "option" NFTs to the dev.
These options can listed for sale and purchased, but when purchased, the TokenFactory option mints an NFT from
the FactoryMintable contract to the user. The option stays in the dev's wallet, and can be listed for sale multiple times.


              ┌──────────────────────────┐        ┌───────────────────────┐
              │FactoryMintableImpl       │        │TokenFactoryImpl       │
              │                          │        │                       │
  O           │   ┌ ─ ─ ─ ─ ─ ─ ┐        │        │  ┌ ─ ─ ─ ─ ─ ─ ┐      │
 /|\═══deploy═╬══▶ constructor() ════════╬═deploy═╬═▶ constructor() ══╗   │
 / \          │   └ ─ ─ ─ ─ ─ ─ ┘        │        │  └ ─ ─ ─ ─ ─ ─ ┘  ║   │
 Dev          │                          │        │                   ║   │
   ▲          └──────────────────────────┘        └───────────────────╬───┘
   ║                                                                  ║    
   ╚════════════emit N Transfer(0, dev, optionId) events══════════════╝    
           options appear as NFTs that can be listed for sale              
                                                                           
 */
abstract contract FactoryMintable is IFactoryMintable, Context {
    TokenFactory public immutable tokenFactory;

    // this abstract class needs its own constructor so tokenFactory can be marked immutable, saving gas when reading
    constructor(TokenFactory _tokenFactory) {
        tokenFactory = _tokenFactory;
    }

    error NotTokenFactory();
    error FactoryCannotMint();

    modifier onlyFactory() {
        if (_msgSender() != address(tokenFactory)) {
            revert NotTokenFactory();
        }
        _;
    }

    modifier canMint(uint256 _optionId) {
        if (!factoryCanMint(_optionId)) {
            revert FactoryCannotMint();
        }
        _;
    }

    /**
    @notice Mints the result of an option to the user, which can be multiple NFTs
    @param _optionId The optionId to mint (eg, mint 1, mint 3, mint 10, etc)
    @param _to The address to mint the option to

    Flow diagrams:

 Scenario 1:                                                                                 
 A user purchases a "Mint 1"                                                                 
 Factory Contract Option                                                                     
                                                                                             
            ╭───────────────────────────╮          ┌───────────┐   ┌──────────────┐          
  O         │ ◎ ○ ○ ░░░░░OpenSea.io░░░░░│  ┌──────▶│Marketplace│──▶│Seller's Proxy│──┐       
 /|\══════╗ ├───────────────────────────┤  │       └───────────┘   └──────────────┘  │       
 / \      ║ │┌──────┐                   │  │                                         │       
 User     ║ ││      │  Option 1: Mint 1 │  │                                         │       
   ▲      ║ ││  :)  │ ┌────────┐        │  │                                         │       
   ║      ║ ││      │ │Buy Now │────────┼──┘                                         │       
   ║      ║ │└──────┘ └────────┘        │                 from   : seller            │       
   ║      ║ │              ▲            │                 to     : user              │       
   ║      ║ └──────────────╬────────────┘    ┌────────────tokenId: 1 (optionId)──────┘       
   ║      ╚════════════════╝                 │                                               
   ║                                         │                                               
   ║                                         │         ┌───────────────────────────┐         
   ║   ┌─────────────────────────────────────┘         │NFT is FactoryMintable     │         
   ║   │    ┌────────────────────────┐                 │                           │         
   ║   │    │Factory Contract        │                 │    ┌ ─ ─ ─ ─ ─ ─ ─ ─      │         
   ║   │    │             ─ ─ ─ ─ ─ ─│─? optionId: 1 ?─│─ ─▶ factoryCanMint()│     │         
   ║   │    │            │           │                 │    └ ─ ─ ─ ─ ─ ─ ─ ─      │         
   ║   │    │    ┌ ─ ─ ─ ─ ─ ─ ─     │                 │    ┌ ─ ─ ─ ─ ─ ─ ┐        │         
   ║   └────┼───▶ transferFrom()│────┼───optionId: 1───┼───▶ factoryMint() ───x1┐  │         
   ║        │    └ ─ ─ ─ ─ ─ ─ ─     │                 │    └ ─ ─ ─ ─ ─ ─ ┘     │tokenId     
   ║        │                        │                 │    ┌ ─ ─ ─ ─ ─ ─ ─ ─   │to: user    
   ║        │                        │                 │     mint() internal │◀─┘  │         
   ║        │                        │                 │    └ ─ ─ ─ ─ ─ ─ ─ ─      │         
   ║        └────────────────────────┘                 │             ║             │         
   ║                                                   └─────────────╬─────────────┘         
   ║                                                                 ║                       
   ║                                                                 ║                       
   ╚═x1 NFT══════════════════════════════════════════════════════════╝                       
                                                                                             
                                                                                             
 Scenario 2:                                                                                 
 A user purchases a "Mint 3"                                                                 
 Factory Contract Option                                                                     
                                                                                             
            ╭───────────────────────────╮          ┌───────────┐   ┌──────────────┐          
  O         │ ◎ ○ ○ ░░░░░OpenSea.io░░░░░│  ┌──────▶│Marketplace│──▶│Seller's Proxy│──┐       
 /|\══════╗ ├───────────────────────────┤  │       └───────────┘   └──────────────┘  │       
 / \      ║ │┌──────┐                   │  │                                         │       
 User     ║ ││      │  Option 2: Mint 3 │  │                                         │       
   ▲      ║ ││:):):)│ ┌────────┐        │  │                                         │       
   ║      ║ ││      │ │Buy Now │────────┼──┘                                         │       
   ║      ║ │└──────┘ └────────┘        │                 from   : seller            │       
   ║      ║ │              ▲            │                 to     : user              │       
   ║      ║ └──────────────╬────────────┘    ┌────────────tokenId: 2 (optionId)──────┘       
   ║      ╚════════════════╝                 │                                               
   ║                                         │                                               
   ║                                         │         ┌───────────────────────────┐         
   ║   ┌─────────────────────────────────────┘         │NFT is FactoryMintable     │         
   ║   │    ┌────────────────────────┐                 │                           │         
   ║   │    │Factory Contract        │                 │    ┌ ─ ─ ─ ─ ─ ─ ─ ─      │         
   ║   │    │             ─ ─ ─ ─ ─ ─│─? optionId: 2 ?─│─ ─▶ factoryCanMint()│     │         
   ║   │    │            │           │                 │    └ ─ ─ ─ ─ ─ ─ ─ ─      │         
   ║   │    │    ┌ ─ ─ ─ ─ ─ ─ ─     │                 │    ┌ ─ ─ ─ ─ ─ ─ ┐        │         
   ║   └────┼───▶ transferFrom()│────┼───optionId: 2───┼───▶ factoryMint() ───x3┐  │         
   ║        │    └ ─ ─ ─ ─ ─ ─ ─     │                 │    └ ─ ─ ─ ─ ─ ─ ┘     │tokenId     
   ║        │                        │                 │    ┌ ─ ─ ─ ─ ─ ─ ─ ─   │to: user    
   ║        │                        │                 │     mint() internal │◀─┘  │         
   ║        │                        │                 │    └ ─ ─ ─ ─ ─ ─ ─ ─      │         
   ║        └────────────────────────┘                 │             ║             │         
   ║                                                   └─────────────╬─────────────┘         
   ║                                                                 ║                       
   ║                                                                 ║                       
   ╚═x3 NFTs (logic in factoryMint())════════════════════════════════╝                       
                                                                                         
 */
    function factoryMint(uint256 _optionId, address _to) external virtual;

    function factoryCanMint(uint256 _optionId)
        public
        view
        virtual
        returns (bool);
}
