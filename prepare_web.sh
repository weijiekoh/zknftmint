#!/bin/bash

set -o pipefail

cd "$(dirname "$0")"

npm i
npm run bootstrap
npm run build

cd circuits

npx zkey-manager compile -c ./zkeys.config.yml
npx zkey-manager downloadPtau -c ./zkeys.config.yml
npx zkey-manager genZkeys -c ./zkeys.config.yml
npx snarkjs zkev ./zkeys/NftMint__prod.0.zkey ./zkeys/verification_key.json

cd ../web
mkdir -p zkeys

cp ../circuits/zkeys/NftMint__prod_js/NftMint__prod.wasm ./zkeys/
cp ../circuits/zkeys/NftMint__prod.0.zkey ./zkeys/
cp ../circuits/zkeys/verification_key.json ./zkeys/
