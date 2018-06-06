#!/usr/bin/env bash
#/bvin/bash
clear
cd ~
echo $PWD
#cd ..
mkdir .crowdcoincore
cd .crowdcoincore
rpcuser=`cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1`
rpcpass=`pwgen -1 20 -n`
echo "rpcuser=${rpcuser}
rpcpassword=${rpcpass}" >> crowdcoin.conf
echo $PWD
cd ..
cd Crowdcoin_command_line_binaries_linux_1.1
echo $PWD
./crowdcoin-cli stop
sleep 10
./crowdcoind -daemon
sleep 5
crowdcoinGetInfoOutput=$(./crowdcoin-cli getinfo)
while [[ ! ($crowdcoinGetInfoOutput = *"version"*) ]]; do
	sleep 60
	$crowdcoinGetInfoOutput
done	
echo "Testing"  masterNodeAccountAddress=$(./crowdcoin-cli getaccountaddress 0)
echo "Testing" masternodeGenKey=$(./crowdcoin-cli masternode genkey)
echo "Send the collateral to the following address: ".$masterNodeAccountAddress
./crowdcoin-cli stop
sleep 10
#write all data into ../crowdcoind
locateCrowdCoinConf=~/.crowdcoincore/crowdcoin.conf
echo "rpcallowip=127.0.0.1
rpcport=19470
rpcthreads=8
listen=1
server=1
daemon=1
taking=0
discover=1
addnode=96.126.124.245
addnode=121.200.4.203
addnode=188.165.52.69
addnode=207.148.121.239
addnode=84.17.23.43:12875
addnode=18.220.138.90:12875
addnode=86.57.164.166:12875
addnode=86.57.164.146:12875
addnode=18.217.78.145:12875
addnode=23.92.30.230:12875
addnode=35.190.182.68:12875
addnode=80.209.236.4:12875
addnode=91.201.40.89:12875
masternode=1
masternodeprivkey=$masternodeGenKey" >> $locateCrowdCoinConf
./crowdcoind -daemon
## now on you have to get the privatekeY and the address 0
echo "Testing"  masternodeOutputs=$(./crowdcoin-cli masternode outputs) | tr -d "{}:\""
exit
while [[ $masternodeOutputs -ge 3 ]]; do
        sleep 60
        masternodeOutputs=$(./crowdcoin-cli masternode outputs) | tr -d "{}:\""
done
#cd Crowdcoin_command_line_binaries_linux_1.1
./crowdcoin-cli stop
sleep 10
locateMasternode=~/.crowdcoincore/masternode.conf
masternodeConfSample="mn1 127.0.0.1:12875".$masternodeGenKey.$masternodeOutputs
echo $masternodeConfSample >> $locateMasternode
./crowdcoind -daemon -reindex
masternodeStartOutput=$(./crowdcoin-cli masternode start)
while [[ ! ($masternodeStartOutput = *"started"*) ]]; do
        sleep 60
        $masternodeStartOutput
done
echo "$masternodeStartOutput"
