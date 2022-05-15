//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import { PoseidonT3 } from "./Poseidon.sol"; //an existing library to perform Poseidon hash on solidity
import "./verifier.sol"; //inherits with the MerkleTreeInclusionProof verifier contract
import "hardhat/console.sol";
contract MerkleTree is Verifier {

    uint256[] public hashes; // the Merkle tree in flattened array form
    uint256 public index = 0; // the current index of the first unfilled leaf
    uint256 public root; // the current Merkle root
    constructor() {
            // [assignment] initialize a Merkle tree of 8 with blank leaves
        for (uint8 iter = 4; iter > 0 ; iter--) {
            uint8 level = iter - 1;
        for (uint8 i = 0; i < 2**level ; i++) {
                hashes.push(_zeros(level));
            }
        }
        root = hashes[14];
    }
    function _zeros(uint256 level) public pure returns (uint256) {
        if (level == 3) return uint256(0);
        else if (level == 2) return uint256(14744269619966411208579211824598458697587494354926760081771325075741142829156);
        else if (level == 1) return uint256(7423237065226347324353380772367382631490014989348495481811164164159255474657);
        else if (level == 0) return uint256(11286972368698509976183087595462810875513684078608517520839298933882497716792);
        else revert("Index out of bounds");
    }

    function insertLeaf(uint256 hashedLeaf) public returns (uint256) {
        // [assignment] insert a hashed leaf into the Merkle tree
        uint256 _index = index;
        uint256 _index_offset = 0;
        uint256 _hash;
        uint256 left;
        uint256 right;
        hashes[_index] = hashedLeaf;
        for (uint16 i = 3; i > 0 ; i--) {
            //TODO : refactor this
        if ( _index % 2 == 0) {
                //input in on left , we should get next one for hash
            left = hashes[_index + _index_offset];
            right = hashes[(_index + 1) + _index_offset];

            } else {
                // input is on right, get the previous element for hash
            left = hashes[(_index - 1) + _index_offset];
            right = hashes[_index + _index_offset];
            }
            // compute the hash
            _hash = PoseidonT3.poseidon([left, right]);
            // update index element in the array with input

            _index = _index / 2;
            _index_offset += (2 ** i);
            hashes[_index + _index_offset] = _hash;
        }
        index += 1;

    root = hashes[14];
        return root;
    }

    function verify(
            uint[2] memory a,
            uint[2][2] memory b,
            uint[2] memory c,
            uint[1] memory input
        ) public view returns (bool) {
        // [assignment] verify an inclusion proof and check that the proof root matches current root
        bool _verifyProof = verifyProof(a,b,c,input);
        return _verifyProof ? input[0] == root : false;
    }
}
