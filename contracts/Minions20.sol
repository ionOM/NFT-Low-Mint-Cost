// SPDX-License-Identifier: MIT

pragma solidity 0.8.19;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Minions20 is ERC721, Ownable {
    using Strings for uint256;
    using Counters for Counters.Counter;

    Counters.Counter private supply;

    // Defining string variables for the prefix and suffix of the token URI.
    string public uriPrefix = "";
    string public uriSuffix = ".json";

    // A string variable to store the URI for hidden metadata.
    string public hiddenMetadataUri;

    // The cost in ether to mint one token.
    uint256 public cost = 0.001 ether;
    // The maximum number of tokens that can be minted.
    uint256 public maxSupply = 20;
    // The maximum number of tokens that can be minted per transaction.
    uint256 public maxMintAmountPerTx = 3;

    // A boolean to indicate whether the contract is paused.
    bool public paused = true;
    // A boolean to indicate whether the metadata has been revealed.
    bool public revealed = false;

    // Constructor function that sets the initial value for the hidden metadata URI.
    constructor() ERC721("Minions20", "MNS") {
        setHiddenMetadataUri(
            "ipfs://QmQHaueutqR4M59pHUYL6FAVEFWPJYrn2zzc4avAfCQcR6/hidden.json"
        );
    }

    // Modifier function to check the minting compliance.
    modifier mintCompliance(uint256 _mintAmount) {
        require(
            _mintAmount > 0 && _mintAmount <= maxMintAmountPerTx,
            "Invalid mint amount!"
        );
        require(
            supply.current() + _mintAmount <= maxSupply,
            "Max supply exceeded!"
        );
        _;
    }

    // Function to get the total number of tokens that have been minted.
    function totalSupply() public view returns (uint256) {
        return supply.current();
    }

    // Function to mint tokens.
    function mint(
        uint256 _mintAmount
    ) public payable mintCompliance(_mintAmount) {
        require(!paused, "The contract is paused!");
        require(msg.value >= cost * _mintAmount, "Insufficient funds!");

        _mintLoop(msg.sender, _mintAmount);
    }

    // Function to mint tokens for a specific address.
    function mintForAddress(
        uint256 _mintAmount,
        address _receiver
    ) public mintCompliance(_mintAmount) onlyOwner {
        _mintLoop(_receiver, _mintAmount);
    }

    // Function to get the token IDs owned by an address. Returns an array of the token ids that someone owns.
    function walletOfOwner(
        address _owner
    ) public view returns (uint256[] memory) {
        uint256 ownerTokenCount = balanceOf(_owner);
        uint256[] memory ownedTokenIds = new uint256[](ownerTokenCount);
        uint256 currentTokenId = 1;
        uint256 ownedTokenIndex = 0;

        while (
            ownedTokenIndex < ownerTokenCount && currentTokenId <= maxSupply
        ) {
            address currentTokenOwner = ownerOf(currentTokenId);

            if (currentTokenOwner == _owner) {
                ownedTokenIds[ownedTokenIndex] = currentTokenId;

                ownedTokenIndex++;
            }

            currentTokenId++;
        }

        return ownedTokenIds;
    }

    // Function to get the URI for a token.
    function tokenURI(
        uint256 _tokenId
    ) public view virtual override returns (string memory) {
        require(
            _exists(_tokenId),
            "ERC721Metadata: URI query for nonexistent token"
        );

        if (revealed == false) {
            return hiddenMetadataUri;
        }

        string memory currentBaseURI = _baseURI();
        return
            bytes(currentBaseURI).length > 0
                ? string(
                    abi.encodePacked(
                        currentBaseURI,
                        _tokenId.toString(),
                        uriSuffix
                    )
                )
                : "";
    }

    // This function allows the owner to set the revealed state of the contract
    function setRevealed(bool _state) public onlyOwner {
        revealed = _state;
    }

    // This function allows the owner to set the cost of minting a token. Provide _cost in wei amount.
    function setCost(uint256 _cost) public onlyOwner {
        cost = _cost;
    }

    // This function allows the owner to set the maximum mint amount per transaction
    function setMaxMintAmountPerTx(
        uint256 _maxMintAmountPerTx
    ) public onlyOwner {
        maxMintAmountPerTx = _maxMintAmountPerTx;
    }

    // This function allows the owner to set the hidden metadata URI for the contract
    function setHiddenMetadataUri(
        string memory _hiddenMetadataUri
    ) public onlyOwner {
        hiddenMetadataUri = _hiddenMetadataUri;
    }

    // This function allows the owner to set the URI prefix for the tokens.
    function setUriPrefix(string memory _uriPrefix) public onlyOwner {
        uriPrefix = _uriPrefix;
    }

    // This function allows the owner to set the URI suffix for the tokens.
    function setUriSuffix(string memory _uriSuffix) public onlyOwner {
        uriSuffix = _uriSuffix;
    }

    // This function allows the owner to pause or unpause the contract.
    function setPaused(bool _state) public onlyOwner {
        paused = _state;
    }

    // This function allows the owner to withdraw the remaining contract balance.
    function withdraw() public onlyOwner {
        // This will transfer the remaining contract balance to the owner.
        (bool os, ) = payable(owner()).call{value: address(this).balance}("");
        require(os);
    }

    // This function is an internal function to mint a specified number of tokens to a specified address
    function _mintLoop(address _receiver, uint256 _mintAmount) internal {
        for (uint256 i = 0; i < _mintAmount; i++) {
            supply.increment();
            _safeMint(_receiver, supply.current());
        }
    }

    // This function is an internal function to return the base URI for the tokens.
    function _baseURI() internal view virtual override returns (string memory) {
        return uriPrefix;
    }
}
