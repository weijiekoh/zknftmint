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
    const circuit = 'NFTMint_test'
    let poseidon

    beforeAll(async () => {
        poseidon = await circomlib.buildPoseidon()
    })

    it('should work', async () => {
        const preimage = BigInt(1234)
        const hash = poseidon([preimage])
        console.log(poseidon.F.toObject(hash))
        //const circuitInputs = stringifyBigInts({
            //hash,
            //address,
            //preimage,
        //})

        //fs.writeFileSync('input.json', JSON.stringify(circuitInputs))
        //const witness = await genWitness(circuit, circuitInputs)
        //const result = await getSignalByName(circuit, witness, 'main.result')
        //expect(result).toEqual(hashOnion.toString())
    })
})
