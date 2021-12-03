const { ethers, overwriteArtifact } = require('hardhat')
const circomlib = require('circomlibjs')

const buildPoseidon = async (numInputs: number) => {
    await overwriteArtifact(
        `PoseidonT${numInputs + 1}`,
        circomlib.poseidon_gencontract.createCode(numInputs)
    )
}

const buildPoseidonT2 = () => buildPoseidon(1)
const buildPoseidonT3 = () => buildPoseidon(2)

if (require.main === module) {
    buildPoseidonT2()
    buildPoseidonT3()
}

export {
    buildPoseidonT2,
    buildPoseidonT3,
}
