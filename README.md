# Mint an NFT if you know a secret

Developed for 0xPARC.

Contract on Goerli: [`0xc4490d6407f81378c8d3620eA11092B2FC429Df2`](https://goerli.etherscan.io/address/0xc4490d6407f81378c8d3620eA11092B2FC429Df2)

## Getting started

Clone this repository:

```bash
git clone git@github.com:weijiekoh/zknftmint.git
cd zknftmint
```

In a separate terminal, run a HTTP server in `web/zkeys`:

```bash
cd web/zkeys
npx http-server --cors
```

In another terminal, run the web application:

```bash
cd web
npm run serve
```

Get Goerli ETH: https://faucet.paradigm.xyz/

To generate a proof and nullifier, first navigate to:

http://127.0.0.1:8080

Next, paste your ETH address from Metamask and enter the secret (currently
hardcoded to `1234`). Click "Create proof".

Navigate to the Write Contract page for the NftMint contract on Etherscan,
click on "Connect to Web3", and select `mintWithProof`. Copy and paste the
nullifier and the proof, and click "Write".

https://goerli.etherscan.io/address/0xc4490d6407f81378c8d3620eA11092B2FC429Df2#writeContract

If the proof is valid and you have not previously used this address to mint an
NFT on this contract, the transaction will execute and mint an NFT to your
address.

## Development

To install NPM dependencies, run this in the project's root directory:

```
npm i && npm run bootstrap
```

To compile the Typescript code for tests, run:

```
npm run build
```

To compile the circuits, generate its zkey file, and export its verification
key for off-chain proof verification:

```
cd circuits
npx zkey-manager compile -c ./zkeys.config.yml
npx zkey-manager downloadPtau -c ./zkeys.config.yml
npx zkey-manager genZkeys -c ./zkeys.config.yml
npx snarkjs zkev ./NftMint__prod.0.zkey ./zkeys/verification_key.json
node build/exportVerifier.js ./zkeys/NftMint__prod.0.zkey ../contracts/contracts/verifier.sol
```

Note that no phase 2 trusted setup is performed, so do not use this in
production unless you perform one.

Next, compile the contracts:

```
cd ../contracts
npm run compileSol
```

Deploy the contracts to a testnet:

```bash
npx hardhat run build/deploy.js --network goerli
```

Verify the contracts on Etherscan:

1. Update `contracts/hardhat.config.js` with your Etherscan API key.
2. Run:

```bash
npx hardhat verify --network goerli <NftMint address> "<verifier address>"
```
