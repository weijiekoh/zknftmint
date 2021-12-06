import { builder } from './witness_calculator'
import { groth16 } from 'snarkjs'

const zkeyPath = 'http://127.0.0.1:8000/NftMint__prod.0.zkey'
const wasmPath = 'http://127.0.0.1:8000/NftMint__prod.wasm'
const vkPath = 'http://127.0.0.1:8000/verification_key.json'

const calculateProof = async (
    address: string,
    secret: string
) => {
    // Fetch the zkey and wasm files, and convert them into array buffers
    let resp = await fetch(wasmPath)
    const wasmBuff = await resp.arrayBuffer()
    resp = await fetch(zkeyPath)
    const zkeyBuff = await resp.arrayBuffer()

    const circuitInputs = {
        hash: BigInt('1121645852825515626345503741442177404306361956507933536148868635850297893661'),
        address: BigInt(address),
        preimage: BigInt(secret),
    }

    const witnessCalculator = await builder(wasmBuff)

    const wtnsBuff = await witnessCalculator.calculateWTNSBin(circuitInputs, 0)

    const start = Date.now()
    const { proof, publicSignals } =
        await groth16.prove(new Uint8Array(zkeyBuff), wtnsBuff, null)
    const end = Date.now()
    const timeTaken = ((end - start) / 1000).toString() + ' seconds'

    const timeComponent = document.getElementById('time')
    timeComponent.innerHTML = timeTaken

    const proofForTx = [
        proof.pi_a[0],
        proof.pi_a[1],
        proof.pi_b[0][1],
        proof.pi_b[0][0],
        proof.pi_b[1][1],
        proof.pi_b[1][0],
        proof.pi_c[0],
        proof.pi_c[1],
    ];

      const proofAsStr = JSON.stringify(
            proofForTx.map((x) => BigInt(x).toString(10)),
      ).split('\n').join().replaceAll('"', '')

    const proofCompnent = document.getElementById('proof')
    proofCompnent.innerHTML = proofAsStr

    const nullifier = document.getElementById("nullifier")
    nullifier.innerHTML = BigInt(publicSignals[0]).toString()

    // Verify the proof
    resp = await fetch(vkPath)
    const vkey = await resp.json()

    const res = await groth16.verify(vkey, publicSignals, proof);

    const resultComponent = document.getElementById('result')
    resultComponent.innerHTML = res;
}

const main = async () => {
    const bGenProof = document.getElementById("bGenProof")

    bGenProof.addEventListener("click", () => {
        const secret = document.getElementById("secret")
        const address = document.getElementById("address")
        calculateProof(
            address.value,
            secret.value
        )
    })
}


main()
