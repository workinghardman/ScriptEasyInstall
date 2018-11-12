cd ../Crowdcoin_command_line_binaries_linux_2.0.0/
echo $PWD
echo  "Restarting Daemon"
./crowdcoind -daemon 
echo "Now waiting Masternode Sync and collateral confirmation"
echo "Checking every 5 seconds ..."
spin='-\|/'
while [ ${#masternodeOutputs} -le 3 ]; do
        i=$(( (i+1) %4 ))
        block=`./crowdcoin-cli getinfo | grep block | tr -d ,`
        balance=`./crowdcoin-cli getbalance`
        printf "\r$block | Balance : $balance ${spin:$i:1}"
        sleep 5
        masternodeOutputs=`./crowdcoin-cli masternode outputs | tr -d "{}:\""`
done
echo "OK, Transaction ID found :  $masternodeOutputs"
echo "Stopping CrowdCoin daemon to update Masternode configuration file..."
./crowdcoin-cli stop
sleep 10
locateMasternode=~/.crowdcoinbrain/masternode.conf
masternodeConfSample="mn1 127.0.0.1:8585 $masternodeGenKey $masternodeOutputs"
echo $masternodeConfSample >> $locateMasternode
echo "Masternode configuration updated. Waiting 60 seconds before restarting..."
sleep 60
./crowdcoind -daemon
sleep 10
masternodeStartOutput=$(./crowdcoin-cli masternode start)
echo $masternodeStartOutput
while [[ ! ($masternodeStartOutput = *"started"*) ]]; do
        i=$(( (i+1) %4 ))
        block=`./crowdcoin-cli getinfo | grep block | tr -d ,`
        balance=`./crowdcoin-cli getbalance`
        masternodeStartOutput=$(./crowdcoin-cli masternode start)
        printf "\r$block | Balance : $balance ${spin:$i:1} : $masternodeStartOutput                "
        sleep 5
done
echo ""
echo "Add sentinelLinux in crontab"
(crontab -l 2>/dev/null; echo "* * * * * cd ~/sentinelLinux && ./venv/bin/python bin/sentinel.py 2>&1 >> sentinel-cron.log") | crontab -
echo ""
echo "Add check MN Status in crontab"
(crontab -l 2>/dev/null; echo "* * * * * cd ~/Crowdcoin_command_line_binaries_linux_2.0.0 &  ./check_status.sh 2>&1 >> mn-check-cron.log") | crontab -
sudo service cron reload
echo "$masternodeStartOutput"
sudo apt-get autoremove -y
sudo apt-get clean -y
