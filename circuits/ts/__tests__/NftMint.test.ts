jest.setTimeout(90000)
import * as fs from 'fs'
const circomlib = require('circomlibjs')

const ff = require('ffjavascript')
const stringifyBigInts: (obj: object) => any = ff.utils.stringifyBigInts

import {
    callGenWitness as genWitness,
    callGetSignalByName as getSignalByName,
} from 'circom-helper'

describe('NFT mint test', () => {
    const circuit = 'NftMint_test'
    let poseidon

    beforeAll(async () => {
        poseidon = await circomlib.buildPoseidon()
    })

    it('should produce a witness and correct nullifier', async () => {
        const preimage = BigInt(1234)

        // Hash the preimage
        const hash = poseidon([preimage])
        const address = BigInt('0x1111111111111111111111111111111111111111')

        // Construct the circut inputs
        const circuitInputs = stringifyBigInts({
            // Converts the buffer to a BigInt
            hash: poseidon.F.toObject(hash),
            address,
            preimage,
        })

        // Generate the witness
        const witness = await genWitness(circuit, circuitInputs)

        // Get the nullifier from the witness
        const nullifier = await getSignalByName(circuit, witness, 'main.nullifier')

        // Check that the nullifier is correct
        const expectedNullifier = poseidon.F.toObject(
            poseidon([address, preimage]),
        )
        expect(nullifier.toString()).toEqual(expectedNullifier.toString())
    })
})
