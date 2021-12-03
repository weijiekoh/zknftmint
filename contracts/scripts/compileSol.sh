#!/bin/bash
set -o pipefail

cd "$(dirname "$0")"
cd ..

# Delete old files
rm -rf ./artifacts/*
rm -rf ./cache/*
rm -rf ./dist/*
rm -rf ./typechain/*

echo 'Building contracts with Hardhat'
npx hardhat compile

# Build the Poseidon contract from bytecode
#npm run build
#node build/buildPoseidon.js
