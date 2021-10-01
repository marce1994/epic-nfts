// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

// We need some util functions for strings.
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "hardhat/console.sol";
import {Base64} from "./libraries/Base64.sol";

contract MyEpicNFT is ERC721URIStorage {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    // This is our SVG code. All we need to change is the word that's displayed. Everything else stays the same.
    // So, we make a baseSvg variable here that all our NFTs can use.
    string baseSvg =
        "<svg xmlns='http://www.w3.org/2000/svg' preserveAspectRatio='xMinYMin meet' viewBox='0 0 350 350'><defs><linearGradient id='b' x1='0%' y1='0%' x2='100%' y2='0%'><stop offset='0%' style='stop-color:#ff0;stop-opacity:1'/><stop offset='100%' style='stop-color:#96100e;stop-opacity:1'/></linearGradient></defs><defs><linearGradient id='a' x1='0%' y1='0%' x2='100%' y2='0%'><stop offset='0%' style='stop-color:#e30d09;stop-opacity:1'/><stop offset='100%' style='stop-color:#369ae3;stop-opacity:1'/></linearGradient></defs><rect width='100%' height='100%' fill='url(#a)'/><text x='50%' y='50%' dominant-baseline='middle' text-anchor='middle' style='fill:url(#b);font-family:Inter,Helvetica,Apple Color Emoji,Segoe UI Emoji,NotoColorEmoji,Noto Color Emoji,Segoe UI Symbol,Android Emoji,EmojiSymbols,-apple-system,BlinkMacSystemFont,Segoe UI,Roboto,Helvetica Neue,Noto Sans,sans-serif;font-size:20px;font-weight:700;paint-order:stroke;stroke:navy;stroke-width:1px;stroke-linecap:butt;stroke-linejoin:miter'>";

    // I create three arrays, each with their own theme of random words.
    // Pick some random funny words, names of anime characters, foods you like, whatever!
    string[] reincarnations = [
        "Kumoko",
        "Shun",
        "Katia",
        "Fei",
        "Filimos",
        "Yuri",
        "Hugo",
        "Sajin",
        "Ogi",
        "Kunihiko",
        "Asaka",
        "Sophia",
        "Wrath"
    ];
    string[] natives = [
        "Ariel",
        "Meiges",
        "Julius",
        "Cylis",
        "Ronandt",
        "Sue",
        "Potimas",
        "Merazophis",
        "Ael",
        "Sael",
        "Fiel",
        "Hyrince",
        "Yaana",
        "Jeskan",
        "Hawkin",
        "Aurel",
        "Dustin",
        "Balto",
        "Bloe",
        "Agner",
        "Felmina",
        "Anna",
        "Klevea",
        "Wald",
        "Sanatoria",
        "Kogou",
        "Huey",
        "Darad",
        "Buirimus",
        "Goyef",
        "Basgath"
    ];
    string[] gods = ["Guliedistodiez", "Shiraori", "Sariel", "D", "Meido"];
    
    event NewEpicNFTMinted(address sender, uint256 tokenId);

    constructor() ERC721("CoolImaSpiderSoWhatNFTNames", "ImASpiderSoWhat") {
        console.log("This is my NFT contract. Woah!");
    }

    // I create a function to randomly pick a word from each array.
    function pickRandomFirstWord(uint256 tokenId)
        public
        view
        returns (string memory)
    {
        // I seed the random generator. More on this in the lesson.
        uint256 rand = random(
            string(
                abi.encodePacked("reincarnations", Strings.toString(tokenId))
            )
        );
        // Squash the # between 0 and the length of the array to avoid going out of bounds.
        rand = rand % reincarnations.length;
        return reincarnations[rand];
    }

    function pickRandomSecondWord(uint256 tokenId)
        public
        view
        returns (string memory)
    {
        uint256 rand = random(
            string(abi.encodePacked("natives", Strings.toString(tokenId)))
        );
        rand = rand % natives.length;
        return natives[rand];
    }

    function pickRandomThirdWord(uint256 tokenId)
        public
        view
        returns (string memory)
    {
        uint256 rand = random(
            string(abi.encodePacked("gods", Strings.toString(tokenId)))
        );
        rand = rand % gods.length;
        return gods[rand];
    }

    function random(string memory input) internal pure returns (uint256) {
        return uint256(keccak256(abi.encodePacked(input)));
    }

    function makeAnEpicNFT() public {
        uint256 newItemId = _tokenIds.current();
        require(newItemId < 50);

        string memory first = pickRandomFirstWord(newItemId);
        string memory second = pickRandomSecondWord(newItemId);
        string memory third = pickRandomThirdWord(newItemId);
        string memory combinedWord = string(
            abi.encodePacked(first, second, third)
        );

        string memory finalSvg = string(
            abi.encodePacked(baseSvg, combinedWord, "</text></svg>")
        );

        // Get all the JSON metadata in place and base64 encode it.
        string memory json = Base64.encode(
            bytes(
                string(
                    abi.encodePacked(
                        '{"name": "',
                        // We set the title of our NFT as the generated word.
                        combinedWord,
                        '", "description": "A highly acclaimed collection of squares.", "image": "data:image/svg+xml;base64,',
                        // We add data:image/svg+xml;base64 and then append our base64 encode our svg.
                        Base64.encode(bytes(finalSvg)),
                        '"}'
                    )
                )
            )
        );

        // Just like before, we prepend data:application/json;base64, to our data.
        string memory finalTokenUri = string(
            abi.encodePacked("data:application/json;base64,", json)
        );

        console.log("\n--------------------");
        console.log(finalTokenUri);
        console.log("--------------------\n");

        _safeMint(msg.sender, newItemId);

        // Update your URI!!!
        _setTokenURI(newItemId, finalTokenUri);

        _tokenIds.increment();
        console.log(
            "An NFT w/ ID %s has been minted to %s",
            newItemId,
            msg.sender
        );

        emit NewEpicNFTMinted(msg.sender, newItemId);
    }

    function getTotalMintedNFT() view public returns (uint) {
        uint count = _tokenIds.current();
        console.log("We have %d minted NFTs", count);
        return count;
    }
}
