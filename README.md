# ScriptEasyInstall 1.0

This nice script do the full install of a Crowdcoin masternode
adding as well the resync script and the sentinel

## INSTALL HOW WALLET

Log in your vps and then run the following commands

```
sudo apt-get install git
git clone https://github.com/crowdcoinChain/ScriptEasyInstall
cd ScriptEasyInstall
bash linux_easyinstall.sh
```

or One line

```
sudo apt-get install git -y;git clone https://github.com/crowdcoinChain/ScriptEasyInstall;cd ScriptEasyInstall;bash linux_easyinstall.sh

```


## INSTALL COLD WALLET

From your Windows wallet debug console

create a new address
```
getnewaddress MN1000
```

And send 1000 to this address.
Wait for few confirmations then type the following command in the Windows wallet debug console

```
masternode genkey
masternode outputs
```

keep note of the 2 ouputs

Log in your vps and then run the following commands
```
sudo apt-get install git
git clone https://github.com/crowdcoinChain/ScriptEasyInstall
cd ScriptEasyInstall
bash cold_linux_easyinstall.sh
```

Enter genkey output when promted to.
Setup the masternode.conf file on your windows wallet and restart it
Wait for full sync of VPS and Windows wallet, then start the MN from the Masternode Tab of the Windows wallet
