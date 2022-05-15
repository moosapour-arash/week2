pragma circom 2.0.0;

include "../node_modules/circomlib/circuits/poseidon.circom";
include "../node_modules/circomlib/circuits/switcher.circom";

template CheckRoot(n) { // compute the root of a MerkleTree of n Levels
    signal input leaves[2**n];
    signal output root;

    //[assignment] insert your code here to calculate the Merkle root from 2^n leaves
    var startLevel = n - 1;
    component layers[n];
    for (var level= startLevel; level >= 0; level--) {
        layers[level] = CalculateLevel(level);
        for (var i = 0; i < 2 ** (level + 1); i++) {

            layers[level].nodes[i] <== level == startLevel ? leaves[i] : layers[level + 1].outNodes[i];
        }
    }
    root <== n == 0 ? leaves[0] : layers[0].outNodes[0];

}
template CalculateLevel(level) {
    var totalItems = 2**level;
    signal input nodes[totalItems * 2];
    signal output outNodes[totalItems];

    component hash[totalItems];

    for (var i = 0; i < totalItems ; i++) {
        hash[i] = Poseidon(2);
        hash[i].inputs[0] <== nodes[i * 2];
        hash[i].inputs[1] <== nodes[i * 2 + 1];
        outNodes[i] <== hash[i].out;
    }

}
template MerkleTreeInclusionProof(n) {
    signal input leaf;
    signal input path_elements[n];
    signal input path_index[n]; // path index are 0's and 1's indicating whether the current element is on the left or right
    signal output root; // note that this is an OUTPUT signal

    //[assignment] insert your code here to compute the root from a leaf and elements along the path

    component hash[n];
    component switcher[n];
    for (var i = 0; i < n; i++) {
        switcher[i] = Switcher();
        switcher[i].sel <== path_index[i];
        switcher[i].L <== i == 0 ? leaf : hash[i - 1].out;
        switcher[i].R <== path_elements[i];

        hash[i] = Poseidon(2);
        hash[i].inputs[0] <== switcher[i].outL;
        hash[i].inputs[1] <== switcher[i].outR;

    }
    root <== hash[n -1].out;
}