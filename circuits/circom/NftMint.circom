include "../node_modules/circomlib/circuits/poseidon.circom";

template NftMint() {
    // The public inputs
    signal output nullifier;
    signal input hash;
    signal input address;

    // The private inputs
    signal private input preimage;

    // Hash the preimage and check if the result matches the hash.
    component hasher = Poseidon(1);
    hasher.inputs[0] <== preimage;

    hasher.out === hash;

    // The contract should keep track of seen nullifiers so as to prevent
    // double-spends.
    component nullifierHasher = Poseidon(2);
    nullifierHasher.inputs[0] <== address;
    nullifierHasher.inputs[1] <== preimage;

    nullifier <== nullifierHasher.out;
}
