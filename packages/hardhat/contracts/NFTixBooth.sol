pragma solidity >=0.8.0 <0.9.0;
//SPDX-License-Identifier: MIT

import "hardhat/console.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./Base64.sol";

contract NFTixBooth is ERC721URIStorage, Ownable {
  using Counters for Counters.Counter;
  Counters.Counter private currentId;

  bool public saleIstActive = false;
  uint256 public totalTickets = 10;
  uint256 public availableTickets = 10;
  uint256 public mintPrice = 80000000000000000;

  mapping(address => uint256[]) public holderTokenIDs;
  mapping(address => bool) public checkIns;

  constructor() ERC721("NFTix", "NFTX") {
    currentId.increment();
    console.log(currentId.current());
  }

  // to support receiving ETH by default
  // receive() external payable {}
  // fallback() external payable {}

  function checkIn(address addy) public {
    checkIns[addy] = true;
    uint256 tokenId = holderTokenIDs[addy][0];

    string memory json = Base64.encode(bytes(string(abi.encodePacked(
      '{ "name": "NFTix #',
      Strings.toString(tokenId),
      '", "description": "A NFT-powered ticketing system", ',
      '"traits": [{ "trait_type": "Checked In", "value": "true" }, { "trait_type": "Purchased", "value": "true" }], ',
      '"image": "ipfs://QmTBy8yfV6CbPJkYKYDE8ba82r4DpQZMyoJikn93chdJ3Q" }'
    ))));

    string memory tokenURI = string(abi.encodePacked("data:application/json;base64,", json));
    _setTokenURI(tokenId, tokenURI);
  }

  function mint() public payable {
    require(availableTickets > 0, "Not enough tickets");
    require(msg.value >= mintPrice, "Not enough ETH!");
    require(saleIstActive, "Tickets are not on sale!");

    // string[3] memory svg;
    // svg[0] = '<svg viewBox="0 0 100 100" xmlns="http://www.w3.org/2000/svg"><text y="50">';
    // svg[1] = Strings.toString(currentId.current());
    // svg[2] = '</text></svg>';

    // string memory image = string(abi.encodePacked(svg[0], svg[1], svg[2]));

    // string memory encodedImage = Base64.encode(bytes(image));
    // console.log(encodedImage);

    string memory json = Base64.encode(bytes(string(abi.encodePacked(
      '{ "name": "NFTix #',
      Strings.toString(currentId.current()),
      '", "description": "A NFT-powered ticketing system", ',
      '"traits": [{ "trait_type": "Checked In", "value": "false" }, { "trait_type": "Purchased", "value": "true" }], ',
      '"image": "ipfs://QmfGyJMp1owt9XuLFcnDBywBKWm5RnHFMqEuM5qdos88Yz" }'
    ))));

    string memory tokenURI = string(abi.encodePacked("data:application/json;base64,", json));
    console.log(tokenURI);

    _safeMint(msg.sender, currentId.current());
    _setTokenURI(currentId.current(), tokenURI);

    holderTokenIDs[msg.sender].push(currentId.current());
    currentId.increment();
    availableTickets = availableTickets - 1;
  }

  function availableTicketsCount() public view returns (uint256) {
    return availableTickets;
  }

  function totalTicketsCount() public view returns (uint256) {
    return totalTickets;
  }

  function openSale() public onlyOwner {
    saleIstActive = true;
  }

  function closeSale() public onlyOwner {
    saleIstActive = false;
  }

  function confirmOwnership(address addy) public view returns (bool) {
    return holderTokenIDs[addy].length > 0;
  }

}
