// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import { SnarkConstants } from "./SnarkConstants.sol";

library PoseidonT2 {
    function poseidon(uint256[1] memory input) public pure returns (uint256) {}
}

library PoseidonT3 {
    function poseidon(uint256[2] memory input) public pure returns (uint256) {}
}

/*
 * A SHA256 hash function for any number of input elements, and Poseidon hash
 * functions for 2, 3, 4, 5, and 12 input elements.
 */
contract Hasher is SnarkConstants {
    function hash1(uint256[1] memory array) public pure returns (uint256) {
        return PoseidonT2.poseidon(array);
    }

    function hash2(uint256[2] memory array) public pure returns (uint256) {
        return PoseidonT3.poseidon(array);
    }
}
