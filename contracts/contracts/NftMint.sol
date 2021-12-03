// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { IVerifier } from "./verifier.sol";
import { ERC721 } from "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract NftMint is ERC721 {
    uint256 public hash = uint256(1121645852825515626345503741442177404306361956507933536148868635850297893661);
    uint256 public nextTokenId;
    IVerifier public verifier;

    mapping (uint256 => bool) public nullifiers;

    constructor
    (
        IVerifier _verifier
    )
    ERC721("ZkNftMint", "ZK")
    {
        verifier = _verifier;
    }

    function mintWithProof(
        uint256 _nullifier,
        uint256[8] memory _proof
    )
    public
    {
        require(
            nullifiers[_nullifier] == false,
            "NftMint: nullifier seen"
        );

        uint256[3] memory publicInputs = [
            _nullifier,
            hash,
            uint256(uint160(address(msg.sender)))
        ];

        require(
            verifier.verify(_proof, publicInputs),
            "NftMint: invalid proof"
        );

        nullifiers[_nullifier] = true;

        _safeMint(msg.sender, nextTokenId);
        nextTokenId ++;
    }
}
