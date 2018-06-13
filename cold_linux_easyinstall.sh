#!/bin/bash
# linux_easyinstall.sh
# Version 0.1
# Date : 12.06.2018
# This script will install a CRC Cold Wallet Masternode in the default folder location

if [ -f /etc/os-release ]; then
    # freedesktop.org and systemd
    . /etc/os-release
    OS=$NAME
    VER=$VERSION_ID
elif type lsb_release >/dev/null 2>&1; then
    # linuxbase.org
    OS=$(lsb_release -si)
    VER=$(lsb_release -sr)
elif [ -f /etc/lsb-release ]; then
    # For some versions of Debian/Ubuntu without lsb_release command
    . /etc/lsb-release
    OS=$DISTRIB_ID
    VER=$DISTRIB_RELEASE
elif [ -f /etc/debian_version ]; then
    # Older Debian/Ubuntu/etc.
    OS=Debian
    VER=$(cat /etc/debian_version)
elif [ -f /etc/SuSe-release ]; then
    # Older SuSE/etc.
    ...
elif [ -f /etc/redhat-release ]; then
    # Older Red Hat, CentOS, etc.
    ...
else
    # Fall back to uname, e.g. "Linux <version>", also works for BSD, etc.
    OS=$(uname -s)
    VER=$(uname -r)
fi

if [ "$OS" == "Ubuntu" ] && [ "$VER" == "16.04" ]; then
  echo "$OS $VER : OK"
else
  echo "This script should be run on Ubuntu 16.04 only"
  exit 1
fi


ADD_SWAP=N
TARFILE=Crowdcoin_command_line_binaries_linux_1.2.1.tar.gz
BINDIR=~/Crowdcoin_command_line_binaries_linux_1.2.1
GITHUB_DL=https://github.com/crowdcoinChain/Crowdcoin/releases/download/1.2.0/$TARFILE

RPCPORT=11998
CRCPORT=12875

NONE='\033[00m'
YELLOW='\033[01;33m'
clear
cd ~
echo $PWD

echo -e "${YELLOW}
            ***************
        (*********************/
      ****************,  *,  ****
    (*********.  .       *.  *****/
   ********    ..            *******
  *******.    ..******.      ********
  ******     ,***********     *******%
 ******.    **************************
 ******    .**************************
 ******    ,**************************
 ******.    **************************
  ******     ,***********,,,,,*******
  *******.     .******.      ********
   ********     ...          *******
    ,*********.   ..     *.  ******
      ****************,  *.  ****
        ,*********************,
            ***************

${NONE}
"
echo "--------------------------------------------------------------"
echo "This script will setup a CRC Masternode in a Cold Wallet Setup"
echo "--------------------------------------------------------------"
echo ""
echo "Before going further, you need :"
echo "A Windows wallet Synced "
echo "The Genkey generated from your windows Wallet"
echo "You can have all this information from the Windows Wallet Console "
echo "By typing following commands :"
echo " getnewaddress MN1500"
echo "Then send the exact collateral amount to this address"
echo "Then type in Windows Wallet console"
echo " masternode genkey"
echo " masternode outputs"
echo "--------------------------------------------------------------"
read -p "Do you want to continue ? (Y/N)? " -n 1 -r
echo 
if [[ ! $REPLY =~ ^[Yy]$ ]]
 then
        echo "End of the script, nothing has been change."
    [[ "$0" = "$BASH_SOURCE" ]] && exit 1 || return 1
fi

#Check if current user is allowd to sudo
sudo -v
A=$(sudo -n -v 2>&1);test -z "$A" || echo $A|grep -q asswor
if [[ "$A" == "" ]]; then
        echo "user allowed to run Sudo"
else
        echo "current user is not member of Sudo users"
        echo "correct the problem and restart the script"
        exit 1
fi

# Add swap if needed
read -p "Do you want to add memory swap file to your system (Y/n) ?" -n 1 -r -s ADD_SWAP
if [[ ("$ADD_SWAP" == "y" || "$ADD_SWAP" == "Y" || "$ADD_SWAP" == "") ]]; then
        if [ ! -f /swapfile ]; then
            echo && echo "Adding swap space..."
            sleep 3
            sudo fallocate -l $swap_size /swapfile
            sudo chmod 600 /swapfile
            sudo mkswap /swapfile
            sudo swapon /swapfile
            echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
            sudo sysctl vm.swappiness=10
            sudo sysctl vm.vfs_cache_pressure=50
            echo 'vm.swappiness=10' | sudo tee -a /etc/sysctl.conf
            echo 'vm.vfs_cache_pressure=50' | sudo tee -a /etc/sysctl.conf
        else
            echo && echo "WARNING: Swap file detected, skipping add swap!"
            sleep 3
        fi
fi
echo
echo "updating system, please wait..."
sudo apt-get -y -q update
sudo apt-get -y -q upgrade
sudo apt-get -y -q dist-upgrade
echo && echo "Installing UFW..."
sleep 3
sudo apt-get -y install ufw
echo && echo "Configuring UFW..."
sleep 3
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow ssh
sudo ufw limit ssh/tcp
sudo ufw allow $CRCPORT/tcp
sudo ufw logging on
echo "y" | sudo ufw enable
echo && echo "Firewall installed and enabled!"

echo "installing sentinel"
sudo apt-get update
sudo apt-get install git -y
sudo apt-get -y install python-virtualenv
cd ~
git clone https://github.com/crowdcoinChain/sentinelLinux.git && cd sentinelLinux
export LC_ALL=C
virtualenv ./venv
./venv/bin/pip install -r requirements.txt
#change line of sentinelconf with correct path
sed -i -e 's/dash_conf=\/home\/YOURUSERNAME\/\.crowdcoincore\/crowdcoin\.conf/dash_conf=~\/\.crowdcoincore\/crowdcoin.conf/g' sentinel.conf

cd ~
sudo apt-get install pwgen
sudo apt-get install libzmq3-dev libminiupnpc-dev libssl-dev libevent-dev -y
sudo apt-get install build-essential libtool autotools-dev automake pkg-config -y
sudo apt-get install libssl-dev libevent-dev bsdmainutils software-properties-common -y
sudo apt-get install libboost-all-dev -y
sudo add-apt-repository ppa:bitcoin/bitcoin -y
sudo apt-get update
sudo apt-get install libdb4.8-dev libdb4.8++-dev wget -y

wget $GITHUB_DL
tar -zxvf ./$TARFILE

echo ""
echo "==============================================="
echo " Installation finished, starting configuration"
echo "==============================================="
echo "" 
if pgrep -x "crowdcoind" > /dev/null
then
    cd $BINDIR
    echo "Found crowdcoind is running, stopping it..."
    ./crowdcoin-cli stop
    echo "Waiting 60 seconds before continuing..." 
    sleep 60
fi
echo "-----------------------------------------------"
echo "Setting up crowdcoin.conf RPC user and password"
echo "-----------------------------------------------"
echo ""
cd ~
mkdir -p .crowdcoincore
cd .crowdcoincore
rpcuser=`cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1`
rpcpass=`pwgen -1 20 -n`
echo "rpcuser=${rpcuser}
rpcpassword=${rpcpass}" >> crowdcoin.conf

cd $BINDIR
echo "Starting Crowdcoind from $PWD"
./crowdcoind -daemon
sleep 10
crowdcoinGetInfoOutput=$(./crowdcoin-cli getinfo)
while [[ ! ($crowdcoinGetInfoOutput = *"version"*) ]]; do
	sleep 10
	$crowdcoinGetInfoOutput
done
read -p 'Enter the Genkey : ' masternodeGenKey	
echo "----------------------------------------------------------------------"
echo "masternodeGenKey : $masternodeGenKey"
echo "----------------------------------------------------------------------"
echo ""
echo "Stopping CrowdCoin daemon to update configuration file..."
./crowdcoin-cli stop
sleep 10
#write all data into ../crowdcoind
locateCrowdCoinConf=~/.crowdcoincore/crowdcoin.conf
cat >> $locateCrowdCoinConf <<EOF
rpcallowip=127.0.0.1
rpcport=$RPCPORT
rpcthreads=8
listen=1
server=1
daemon=1
staking=0
discover=1
masternode=1
masternodeprivkey=$masternodeGenKey
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
EOF

echo "Configuration $locateCrowdCoinConf updated."
echo " Waiting 60 seconds before restarting..."
sleep 60
./crowdcoind -daemon
sleep 10
echo "Add sentinelLinux in crontab"
(crontab -l 2>/dev/null; echo "* * * * * cd ~/sentinelLinux && ./venv/bin/python bin/sentinel.py 2>&1 >> sentinel-cron.log") | crontab -
sudo service cron reload
echo "VPS Cold Wallet is now done."
echo "run the following command to check your masternode is in sync"
echo "$BINDIR/crowdcoin-cli mnsync status"
echo "When snyced, on your Windows wallet, create masternode.conf file"
echo "Enter the following line : "
echo "MN1500 <IP Of YOUR VPS>:12875 $masternodeGenKey <Transaction> <id>"
echo "Then restart your Windows Wallet, you should see your MN1500 masternode in the masternode tab"
echo "Select the line and hit Start-Alias button"
echo ""
echo "To monitor, run the following command on your vps :"
echo "$BINDIR/crowdcoin-cli  masternode status"
echo "and check you have the Masternode remote activation message"
echo "you can also run :"
echo "tail -f ~/.crowdcoincore/debug.log"

 