# besu-setup.ps1

# 1. 디렉토리 생성
$besuDir = ".\"
$keyDir = "$besuDir\keys"
$dataDir = "$besuDir\data"
New-Item -ItemType Directory -Force -Path $keyDir, $dataDir | Out-Null

# 2. 프라이빗 키 생성 (랜덤 32바이트)
$privateKey = (openssl rand -hex 32).Trim()
$privateKeyHex = "0x$privateKey"

# 3. Node.js로 계정 주소 생성 (web3 필요)
$nodeScript = @"
const { Web3 } = require('web3');
const web3 = new Web3();
const account = web3.eth.accounts.privateKeyToAccount('$privateKeyHex');
console.log(account.address);
"@

# 결과 받아오기
$accountAddress = node -e $nodeScript

if (-not $accountAddress) {
    Write-Error "❌ validator address 생성 실패. Node.js 또는 web3 모듈 확인!"
    exit 1
}

Write-Host "`n🔐 Validator Address: $accountAddress"
Write-Host "🔑 Private Key: $privateKeyHex`n"

# 4. extraData 생성
$addressNoPrefix = $accountAddress.ToLower().Replace("0x", "")
$extraData = "0x" + ("0" * 64) + $addressNoPrefix + ("0" * 130)

# 5. genesis.json 생성
# alloc은 따로 빼서 처리
$alloc = @{}
$alloc[$accountAddress] = @{
    balance = "1000000000000000000000000000"
}

$genesis = @{
    config = @{
        chainId = 2025
        clique = @{
            blockperiodseconds = 5
            epochlength = 30000
        }
        eip155Block = 0
        eip158Block = 0
    }
    difficulty = "1"
    gasLimit = "0x1fffffffffffff"
    alloc = $alloc
    coinbase = "0x0000000000000000000000000000000000000000"
    extraData = $extraData
} | ConvertTo-Json -Depth 10

$genesis | Out-File "$besuDir\genesis.json" -Encoding utf8

# 6. docker-compose.yml 생성
$dockerCompose = @"
version: '3.8'

services:
  besu:
    image: hyperledger/besu:latest
    container_name: besu-node
    volumes:
      - ./data:/var/lib/besu
      - ./genesis.json:/config/genesis.json
    ports:
      - "8545:8545"
      - "8546:8546"
      - "30303:30303"
    command: >
      --genesis-file=/config/genesis.json
      --data-path=/var/lib/besu
      --network-id=2025
      --miner-enabled
      --miner-coinbase=$accountAddress
      --host-allowlist=*
      --rpc-http-enabled
      --rpc-http-api=ETH,NET,WEB3,CLIQUE,ADMIN
      --rpc-http-cors-origins=all
      --rpc-http-host=0.0.0.0
      --rpc-ws-enabled
      --rpc-ws-host=0.0.0.0
      --rpc-ws-api=ETH,NET,WEB3,CLIQUE
"@

$dockerCompose | Out-File "$besuDir\docker-compose.yml" -Encoding utf8

# 7. 실행 안내
Write-Host "`n✅ complete!"
Write-Host "📄 Genesis: $besuDir\genesis.json"
Write-Host "📄 Compose: $besuDir\docker-compose.yml"
Write-Host "`n➡️ docker-compose -f $besuDir\docker-compose.yml up -d`n"

# 8. 프라이빗 키 저장
$privateKeyHex | Out-File "$besuDir\validator.key" -Encoding utf8
Write-Host "🔑 Key saved: $besuDir\validator.key"
