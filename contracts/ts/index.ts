const { ethers } = require('hardhat')

const getDefaultSigner = async () => {
	const signers = await ethers.getSigners()
	const signer = signers[0]

	return signer
}

const deployVerifier = async () => {
    const signer = await getDefaultSigner()
    const cf = await ethers.getContractFactory('Verifier', signer)
    return await cf.deploy()
}

const deployNftMint = async (
    verifierAddress: string
) => {
    const signer = await getDefaultSigner()

    //const PoseidonT2 = await ethers.getContractFactory(
        //"PoseidonT2",
        //signer,
    //)
    //const poseidonT2Contract = await PoseidonT2.deploy()
    //await poseidonT2Contract.deployed()

    //const PoseidonT3 = await ethers.getContractFactory(
        //"PoseidonT3",
        //signer,
    //)
    //const poseidonT3Contract = await PoseidonT3.deploy()
    //await poseidonT3Contract.deployed()

    const cf = await ethers.getContractFactory('NftMint', signer)
    return await cf.deploy(
        verifierAddress,
        //{
            //libraries: {
                //PoseidonT2: poseidonT2Contract.address,
                //PoseidonT3: poseidonT3Contract.address,
            //}
        //}
    )
}

export {
    deployNftMint,
    deployVerifier,
    getDefaultSigner,
}
