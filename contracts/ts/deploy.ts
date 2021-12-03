import {
    getDefaultSigner,
    deployVerifier,
    deployNftMint,
} from './'

const main = async () => {
    const signer = await getDefaultSigner()

    const verifierContract = await deployVerifier()
    await verifierContract.deployTransaction.wait()

    const nftMintContract = await deployNftMint(
        verifierContract.address
    )
    await nftMintContract.deployTransaction.wait()
}

main()
