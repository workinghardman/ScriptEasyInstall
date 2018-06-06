#check if free memory is at least 4GB
# Add swap if needed
    if [[ ("$add_swap" == "y" || "$add_swap" == "Y" || "$add_swap" == "") ]]; then
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

#prechecks
sudo apt-get -y upgrade
sudo apt-get -y dist-upgrade

#ufw
echo && echo "Installing UFW..."
sleep 3
sudo apt-get -y install ufw
echo && echo "Configuring UFW..."
sleep 3
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow ssh
sudo ufw limit ssh/tcp
sudo ufw allow 12875/tcp
sudo ufw logging on
echo "y" | sudo ufw enable
echo && echo "Firewall installed and enabled!"


#find a method to shadow all apart from the echo of the address to send the coin to
#sentinelinstall
sudo apt-get update
sudo apt-get install git -y
sudo apt-get -y install python-virtualenv
git clone https://github.com/crowdcoinChain/sentinelLinux.git && cd sentinelLinux
export LC_ALL=C
virtualenv ./venv
./venv/bin/pip install -r requirements.txt

#change line of sentinelconf with correct path
rpl dash_conf=/home/YOURUSERNAME/.crowdcoincore/crowdcoin.conf dash_conf=~/.crowdcoincore/crowdcoin.conf sentinel.conf

#masternodeinstall
sudo apt-get install libzmq4-dev libminiupnpc-dev libssl-dev libevent-dev -y
sudo apt-get install build-essential libtool autotools-dev automake pkg-config -y
sudo apt-get install libssl-dev libevent-dev bsdmainutils software-properties-common -y
sudo apt-get install libboost-all-dev -y
sudo add-apt-repository ppa:bitcoin/bitcoin -y
sudo apt-get update 
sudo apt-get install libdb4.8-dev libdb4.8++-dev wget -y
wget./
tar -xf Crowdcoin_command_line_binaries_linux_1.0.tar.gz
cd Crowdcoin_command_line_binaries_linux_1.0

echo -n "Insert rpcusername and press [ENTER]: "
read rpcUsername
echo -n "Insert password and press [ENTER]: "
read -s rpcPassword

./crowdcoind -daemon

#watch ./crowdcoin-cli getinfo
## now on you have too  get the privatekeY and the address 0
echo -n  "Your PRIVATEKEY at address 0 is: " $(./crowdcoin-cli getaccountaddress 0)

masternodePrivKEY = $(./crowdcoin-cli masternode genkey)

#stop crowdcoin daemon
./crowdcoin-cli stop

#write all data into ../crowdcoind
echo -e "rpcuser=$rpcUsername \nrpcpassword=$rpcPassword \nrpcallowip=127.0.0.1 \nrpcthreads=8
listen=1 \nserver=1 \ndaemon=1 \nstaking=0 \ndiscover=1 \nexternalip=85.55.22.33:12875 masternode=1
masternodeprivkey=$masternodePrivKEY \naddnode=84.17.23.43:12875 \naddnode=18.220.138.90:12875 \naddnode=86.57.164.166:12875 \naddnode=86.57.164.146:12875
 \naddnode=18.217.78.145:12875 \naddnode=23.92.30.230:12875 \naddnode=35.190.182.68:12875 \naddnode=80.209.236.4:12875 \naddnode=91.201.40.89:12875 \nrpcport=11998" >> ~/.crowdcoincore/crowdcoind.conf


#TODO Check SUCCESS from ./crowdcoin-cli master outputs then
#wrote the first one as alias mns1 and 4 alphanumeric random nmber, ip of the machine, port 12875, masternode priv key and other two parameters that come from outputs

#watch -n 60 



#Start CrowdCoin Daemon
./crowdcoind -daemon

#cheeck if response of ./crowdcoin-cli masternode outputs is SUCCESS
sleep 60
cd ~
  echo && echo && echo
  echo "CrowdCoin installation completed successfully.  Please wait 15 minutes and then start your masternode from your local wallet"	
echo -n "Send 1000 CRC to this address: " $(./crowdcoin-cli masternode outputs)

## then send the coin to the address o and store the informations in
# crowdcoin.conf adding the nodelist as well and masternodes.conf
# with 2 crowntab entries you have to download the resync script as well