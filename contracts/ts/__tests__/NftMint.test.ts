import * as fs from 'fs'
import * as path from 'path'
const { ethers } = require('hardhat')
jest.setTimeout(90000)

import {
    hash,
    hash2,
    genNftMintCircuitInputs,
    genProof,
} from 'zknftmint-circuits'

import {
    deployNftMint,
    deployVerifier,
    getDefaultSigner,
} from '../'

let nftMintContract
let verifierContract
let preimage = BigInt(1234)
let hashedVal
let signer

describe('NftMint', () => {
    beforeAll(async () => {
        signer = await getDefaultSigner()
        hashedVal = await hash([preimage])

        verifierContract = await deployVerifier()
        await verifierContract.deployTransaction.wait()

        nftMintContract = await deployNftMint(
            verifierContract.address
        )
        await nftMintContract.deployTransaction.wait()
    })

    it('should mint an NFT', async () => {
        // Generate inputs
        const nullifier = await hash([BigInt(signer.address), preimage])
        const circuitInputs = genNftMintCircuitInputs(
            hashedVal,
            BigInt(signer.address),
            preimage,
        )

        const rapidsnarkExePath = path.resolve(process.argv[3])
        const witnessExePath = path.resolve(process.argv[4])
        const zkeyPath = path.resolve(process.argv[5])

        // Generate the proof
        const r = genProof(
            circuitInputs,
            rapidsnarkExePath,
            witnessExePath,
            zkeyPath,
        )

        // Arrange the proof elements for the contract
        const proofForTx: any = [
            r.proof.pi_a[0],
            r.proof.pi_a[1],
            r.proof.pi_b[0][1],
            r.proof.pi_b[0][0],
            r.proof.pi_b[1][1],
            r.proof.pi_b[1][0],
            r.proof.pi_c[0],
            r.proof.pi_c[1],
        ]

        const balanceBefore = await nftMintContract.balanceOf(signer.address)

        // Mint the token
        await nftMintContract.mintWithProof(
            nullifier,
            proofForTx,
        )

        const balanceAfter = await nftMintContract.balanceOf(signer.address)

        // The NFT should have been minted
        expect(balanceAfter - balanceBefore).toEqual(1)
    })
})
