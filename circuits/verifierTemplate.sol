// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
pragma experimental ABIEncoderV2;


abstract contract IVerifier {
    function verify(
        uint256[8] memory,
        uint256[<%vk_input_length%>] memory
    ) virtual public view returns (bool);
}

library Pairing {

    uint256 constant PRIME_Q = 21888242871839275222246405745257275088696311157297823662689037894645226208583;

    struct G1Point {
        uint256 x;
        uint256 y;
    }

    // Encoding of field elements is: X[0] * z + X[1]
    struct G2Point {
        uint256[2] x;
        uint256[2] y;
    }

    /*
     * @return The negation of p, i.e. p.plus(p.negate()) should be zero. 
     */
    function negate(G1Point memory p) internal pure returns (G1Point memory) {

        // The prime q in the base field F_q for G1
        if (p.x == 0 && p.y == 0) {
            return G1Point(0, 0);
        } else {
            return G1Point(p.x, PRIME_Q - (p.y % PRIME_Q));
        }
    }

    /*
     * @return The sum of two points of G1
     */
    function plus(
        G1Point memory p1,
        G1Point memory p2
    ) internal view returns (G1Point memory r) {

        uint256[4] memory input;
        input[0] = p1.x;
        input[1] = p1.y;
        input[2] = p2.x;
        input[3] = p2.y;
        bool success;

        // solium-disable-next-line security/no-inline-assembly
        assembly {
            success := staticcall(sub(gas(), 2000), 6, input, 0xc0, r, 0x60)
            // Use "invalid" to make gas estimation work
            switch success case 0 { invalid() }
        }

        require(success,"pairing-add-failed");
    }

    /*
     * @return The product of a point on G1 and a scalar, i.e.
     *         p == p.scalar_mul(1) and p.plus(p) == p.scalar_mul(2) for all
     *         points p.
     */
    function scalar_mul(G1Point memory p, uint256 s) internal view returns (G1Point memory r) {

        uint256[3] memory input;
        input[0] = p.x;
        input[1] = p.y;
        input[2] = s;
        bool success;
        // solium-disable-next-line security/no-inline-assembly
        assembly {
            success := staticcall(sub(gas(), 2000), 7, input, 0x80, r, 0x60)
            // Use "invalid" to make gas estimation work
            switch success case 0 { invalid() }
        }
        require (success,"pairing-mul-failed");
    }

    /* @return The result of computing the pairing check
     *         e(p1[0], p2[0]) *  .... * e(p1[n], p2[n]) == 1
     *         For example,
     *         pairing([P1(), P1().negate()], [P2(), P2()]) should return true.
     */
    function pairing(
        G1Point memory a1,
        G2Point memory a2,
        G1Point memory b1,
        G2Point memory b2,
        G1Point memory c1,
        G2Point memory c2,
        G1Point memory d1,
        G2Point memory d2
    ) internal view returns (bool) {

        G1Point[4] memory p1 = [a1, b1, c1, d1];
        G2Point[4] memory p2 = [a2, b2, c2, d2];

        uint256 inputSize = 24;
        uint256[] memory input = new uint256[](inputSize);

        for (uint256 i = 0; i < 4; i++) {
            uint256 j = i * 6;
            input[j + 0] = p1[i].x;
            input[j + 1] = p1[i].y;
            input[j + 2] = p2[i].x[0];
            input[j + 3] = p2[i].x[1];
            input[j + 4] = p2[i].y[0];
            input[j + 5] = p2[i].y[1];
        }

        uint256[1] memory out;
        bool success;

        // solium-disable-next-line security/no-inline-assembly
        assembly {
            success := staticcall(sub(gas(), 2000), 8, add(input, 0x20), mul(inputSize, 0x20), out, 0x20)
            // Use "invalid" to make gas estimation work
            switch success case 0 { invalid() }
        }

        require(success, "pairing-opcode-failed");

        return out[0] != 0;
    }
}

contract Verifier is IVerifier {
    struct Proof {
        Pairing.G1Point a;
        Pairing.G2Point b;
        Pairing.G1Point c;
    }

    struct VerifyingKey {
        Pairing.G1Point alpha1;
        Pairing.G2Point beta2;
        Pairing.G2Point gamma2;
        Pairing.G2Point delta2;
        Pairing.G1Point[<%vk_ic_length%>] IC;
    }

    using Pairing for *;

    uint256 constant PRIME_Q = 21888242871839275222246405745257275088696311157297823662689037894645226208583;
    string constant ERROR_PROOF_Q = "VE1";
    string constant ERROR_INPUT_VAL = "VE2";

    function verifyingKey() internal pure returns (VerifyingKey memory vk) {
        vk.alpha1 = Pairing.G1Point(<%vk_alpha1%>);
        vk.beta2 = Pairing.G2Point(<%vk_beta2%>);
        vk.gamma2 = Pairing.G2Point(<%vk_gamma2%>);
        vk.delta2 = Pairing.G2Point(<%vk_delta2%>);
        <%vk_ic_pts%>
    }

    /*
     * @returns Whether the proof is valid given the verifying key and public
     *          input. Note that this function only supports one public input.
     *          Refer to the Semaphore source code for a verifier that supports
     *          multiple public inputs.
     */
    function verify(
        uint256[8] memory _proof,
        uint256[<%vk_input_length%>] memory input
    ) override public view returns (bool) {
        VerifyingKey memory vk = verifyingKey();
        Proof memory proof;
        proof.a = Pairing.G1Point(_proof[0], _proof[1]);
        proof.b = Pairing.G2Point(
            [_proof[2], _proof[3]],
            [_proof[4], _proof[5]]
        );
        proof.c = Pairing.G1Point(_proof[6], _proof[7]);

        // Make sure that proof.A, B, and C are each less than the prime q
        require(proof.a.x < PRIME_Q, ERROR_PROOF_Q);
        require(proof.a.y < PRIME_Q, ERROR_PROOF_Q);

        require(proof.b.x[0] < PRIME_Q, ERROR_PROOF_Q);
        require(proof.b.y[0] < PRIME_Q, ERROR_PROOF_Q);

        require(proof.b.x[1] < PRIME_Q, ERROR_PROOF_Q);
        require(proof.b.y[1] < PRIME_Q, ERROR_PROOF_Q);

        require(proof.c.x < PRIME_Q, ERROR_PROOF_Q);
        require(proof.c.y < PRIME_Q, ERROR_PROOF_Q);

        uint256 SNARK_SCALAR_FIELD = 21888242871839275222246405745257275088548364400416034343698204186575808495617;

        // Compute the linear combination vk_x
        Pairing.G1Point memory vk_x = Pairing.G1Point(0, 0);

        for (uint256 i = 0; i < <%vk_input_length%>; i++) {
            // Make sure that every input is less than the snark scalar field
            require(input[i] < SNARK_SCALAR_FIELD,"verifier-gte-snark-scalar-field");

            vk_x = Pairing.plus(vk_x, Pairing.scalar_mul(vk.IC[i + 1], input[i]));
        }

        vk_x = Pairing.plus(vk_x, vk.IC[0]);

        return Pairing.pairing(
            Pairing.negate(proof.a),
            proof.b,
            vk.alpha1,
            vk.beta2,
            vk_x,
            vk.gamma2,
            proof.c,
            vk.delta2
        );
    }
}


