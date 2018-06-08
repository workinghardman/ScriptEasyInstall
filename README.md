- Linux_easyinstall_rev.sh is the old version of the scrypt where from line 0 to 62 are to be added to the current script (linux_easyinstall.sh). Lines 63, 64, update link with last binaries (tar.gz) here https://github.com/crowdcoinChain/Crowdcoin/releases

- Linux_easyinstall.sh is the current version of the script.

- remove_all.sh is the script that remove all folders/files that have to be removed to start a clean installation

#INSTALL

Log in your vps and then run the following commands

```
sudo apt-get install git
git clone https://github.com/crowdcoinChain/ScriptEasyInstall
cd ScriptEasyInstall
bash linux_easyinstall.sh
```
