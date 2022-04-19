// SPDX-License-Identifier: MIT
pragma solidity >=0.8.4;

import {AllowsProxyFromRegistry} from "../lib/AllowsProxyFromRegistry.sol";
import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {IFactoryMintable} from "./IFactoryMintable.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ReentrancyGuard} from "@rari-capital/solmate/src/utils/ReentrancyGuard.sol";
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";

/// @author emo.eth
contract TokenFactory is
    ERC721,
    Ownable,
    AllowsProxyFromRegistry,
    ReentrancyGuard
{
    using Strings for uint256;

    /// @dev immutable+constant state variables don't use storage slots; are cheap to read
    uint16 public immutable NUM_OPTIONS;
    /// @notice Contract that deployed this factory.
    IFactoryMintable public immutable token;
    // bit field that tracks live optionIds
    uint256 internal liveOptions;
    /// @notice Base URI for constructing tokenURI for options.
    string public baseOptionURI;

    error NotOwnerOrProxy();
    error InvalidOptionId();
    error InactiveOptionId();

    constructor(
        string memory _name,
        string memory _symbol,
        string memory _baseOptionURI,
        address _owner,
        uint16 _numOptions,
        address _proxyAddress
    ) ERC721(_name, _symbol) AllowsProxyFromRegistry(_proxyAddress) {
        token = IFactoryMintable(msg.sender);
        baseOptionURI = _baseOptionURI;
        NUM_OPTIONS = _numOptions;
        // first owner will be the token that deploys the contract, transfer it to the real owner
        transferOwnership(_owner);
        createOptionsAndEmitTransfers();
        // mark each option as currently live - 2 ** n - 1 is n 1s in binary
        liveOptions = (1 << NUM_OPTIONS) - 1;
    }

    modifier onlyOwnerOrProxy() {
        if (_msgSender() != owner() && !isProxyOfOwner(owner(), _msgSender())) {
            revert NotOwnerOrProxy();
        }
        _;
    }

    modifier checkValidOptionId(uint256 _optionId) {
        // options are 0-indexed so check should be inclusive
        if (_optionId >= NUM_OPTIONS) {
            revert InvalidOptionId();
        }
        _;
    }

    modifier checkOptionLive(uint256 _optionId) {
        // check if option is live
        if (_optionIsBurned(liveOptions, _optionId)) {
            revert InactiveOptionId();
        }
        _;
    }

    modifier interactBurnInvalidOptionId(uint256 _optionId) {
        _;
        _burnInvalidOptions();
    }

    /**
    @notice Emits standard ERC721.Transfer events for each option so NFT indexers pick them up.
    Does not need to fire on contract ownership transfer because once the tokens exist, the `ownerOf`
    check will always pass for contract owner.
     */
    function createOptionsAndEmitTransfers() internal {
        // load from storage, read from memory
        address _owner = owner();
        for (uint256 i = 0; i < NUM_OPTIONS; ) {
            emit Transfer(address(0), _owner, i);
            unchecked {
                ++i;
            }
        }
    }

    /// @notice Sets the base URI for constructing tokenURI values for options.
    function setBaseOptionURI(string memory _baseOptionURI) public onlyOwner {
        baseOptionURI = _baseOptionURI;
    }

    /**
    @notice hack: transferFrom is called on sale – this method mints the real token
     */
    function transferFrom(
        address,
        address _to,
        uint256 _optionId
    )
        public
        override
        nonReentrant
        onlyOwnerOrProxy
        checkValidOptionId(_optionId)
        checkOptionLive(_optionId)
        interactBurnInvalidOptionId(_optionId)
    {
        token.factoryMint(_optionId, _to);
    }

    function safeTransferFrom(
        address,
        address _to,
        uint256 _optionId
    )
        public
        override
        nonReentrant
        onlyOwnerOrProxy
        checkValidOptionId(_optionId)
        checkOptionLive(_optionId)
        interactBurnInvalidOptionId(_optionId)
    {
        token.factoryMint(_optionId, _to);
    }

    /**
    @dev Return true if operator is an approved proxy of Owner
     */
    function isApprovedForAll(address _owner, address _operator)
        public
        view
        virtual
        override
        returns (bool)
    {
        return isProxyOfOwner(_owner, _operator);
    }

    /**
    @notice Returns owner if _optionId is valid so posted orders pass validation
     */
    function ownerOf(uint256 _optionId) public view override returns (address) {
        return token.factoryCanMint(_optionId) ? owner() : address(0);
    }

    /**
    @notice Returns a URL specifying option metadata, conforming to standard
    ERC721 metadata format.
     */
    function tokenURI(uint256 _optionId)
        public
        view
        override
        returns (string memory)
    {
        return string.concat(baseOptionURI, _optionId.toString());
    }

    ///@notice public facing method for _burnInvalidOptions in case state of tokenContract changes
    function burnInvalidOptions() public onlyOwner {
        _burnInvalidOptions();
    }

    /**
    @notice "burn" options by sending them to 0 address. This will hide all active listings. Called as part of interactBurnInvalidOptionIds
    
    Flow diagram:
    
┌────────────────────────────────┐              ┌────────────────────────┐
│Factory Contract                │              │NFT is FactoryMintable  │
│                                │              │                        │
│ ┌ ─ ─ ─ ─ ─ ─ ─                │              │    ┌ ─ ─ ─ ─ ─ ─ ┐     │
│  transferFrom()│────────────┬──┼──────────────┼───▶ factoryMint()      │
│ └ ─ ─ ─ ─ ─ ─ ─             │  │              │    └ ─ ─ ─ ─ ─ ─ ┘     │
│                             │  │              │    ┌ ─ ─ ─ ─ ─ ─ ─ ─   │
│ ┌ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ┐ │post-mint      ┌ ┼ ─ ▶ factoryCanMint()│  │
│   _burnInvalidOptionIds()  ◀┘  │              │    └ ─ ─ ─ ─ ─ ─ ─ ─   │
│ └ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ┘    │            │ └────────────────────────┘
│              ║                 │                                        
│              ║─ ─ ─ ─ each optionId ─ ─ ─ ─ ┘                           
└──────────────╬─────────────────┘                                        
               ║                                                          
               ║                                                          
               ║                                                          
               ║                                                          
               ║                                                          
               ╚══emit Transfer(dev, 0, optionId) events══▶0x0            
                          for invalid option IDs           (null address) 
    */
    function _burnInvalidOptions() internal {
        // load vars from storage, read from memory
        uint256 numOptions = NUM_OPTIONS;

        // get a copy of liveOptions in memory to update before writing to storage
        uint256 _liveOptions = liveOptions;
        // it's slightly cheaper to grab a second copy to compare against before writing to storage,
        // even if the value stays the same
        uint256 liveOptionsCopy = _liveOptions;

        address _owner = owner();
        for (uint256 i; i < numOptions; ) {
            if (!_optionIsBurned(_liveOptions, i) && !token.factoryCanMint(i)) {
                _liveOptions = _markOptionBurned(_liveOptions, i);
                _burnOption(_owner, i);
            }
            unchecked {
                ++i;
            }
        }
        if (_liveOptions != liveOptionsCopy) {
            liveOptions = _liveOptions;
        }
    }

    function burnOption(uint256 _optionId) public onlyOwner {
        _burnOption(owner(), _optionId);
    }

    function _burnOption(address _from, uint256 _optionId) internal {
        emit Transfer(_from, address(0), _optionId);
    }

    /// @notice determine if an option is still live by checking its bit is 1 in the liveOptions bit field
    function _optionIsBurned(uint256 _bitField, uint256 _optionId)
        internal
        pure
        returns (bool)
    {
        return (_bitField & (1 << _optionId)) == 0;
    }

    function _markOptionBurned(uint256 _bitField, uint256 _optionId)
        internal
        pure
        returns (uint256)
    {
        return _bitField & ~(1 << _optionId);
    }

    function _markOptionLive(uint256 _bitField, uint256 _optionId)
        internal
        pure
        returns (uint256)
    {
        return _bitField | (1 << _optionId);
    }

    /**
    @notice emit a transfer event for a "burnt" option back to the owner if factoryCanMint the optionId
    @dev will re-validate listings on OpenSea frontend if an option becomes eligible to mint again
    eg, if max supply is increased
    */
    function restoreOption(uint256 _optionId) public onlyOwner {
        if (_optionId >= NUM_OPTIONS) {
            revert InvalidOptionId();
        }
        if (token.factoryCanMint(_optionId)) {
            _restoreOption(_optionId, owner());
            liveOptions = _markOptionLive(liveOptions, _optionId);
        }
    }

    /**
    @notice iterate over all options and restore all that are mintable
     */
    function restoreMintableOptions() external onlyOwner {
        uint256 _liveOptions = liveOptions;
        address _owner = owner();
        for (uint256 i = 0; i < NUM_OPTIONS; ) {
            if (token.factoryCanMint(i)) {
                _restoreOption(i, _owner);
                _liveOptions = _markOptionLive(_liveOptions, i);
            }
            unchecked {
                ++i;
            }
        }
        liveOptions = _liveOptions;
    }

    function _restoreOption(uint256 _optionId, address _to) internal {
        emit Transfer(address(0), _to, _optionId);
    }

    function supportsFactoryInterface() external pure returns (bool) {
        return true;
    }
}
