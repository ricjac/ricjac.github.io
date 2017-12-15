+++
date = "2017-12-13"
draft = false

categories = ["Cryptocurrency"]

title = "PART 3: How to setup a Litecoin TestNet Full Node on Arch linux"
description = "Setup a Litecoin node connected to TestNet. This is the continuation of the server that was setup for our Bitcoin TestNet3 setup"
+++

This is Part 3 in the Cryptocurrency series:

* [PART 1]({{< ref "btc-testnet.md" >}}) - We look at setting up a **Bitcoin** full node connected to TestNet3
* [PART 2]({{< ref "btc-testnet-security.md" >}}) - We put in place some hardening strategies to protect against common attack
* [PART 3]({{< ref "ltc-testnet.md" >}}) - We look at setting up a **Litecoin** full node connected to TestNet

Since this article is a continuation from Part 1 and 2, it is assumed that you have a Bitcoin TestNet node (Part 1) running already and you've made your server secure (Part 2).

Setting up a Litecoin full node connected to TestNet is pretty much the same as setting up a BTC node, so if you've been through Part 1, this will all look very familiar.

# Instructions

Begin by SSH-ing to the server - as root:

``` bash
# where xxx.xxx.xxx.xxx is the IP address or host name of the server
ssh root@xxx.xxx.xxx.xxx
```

Make sure all packages are up to date:

``` bash
pacman -Syu
```

This next step differs from the Bitcoin node setup, we are not going to use the official Litecoin package from an Arch Linux mirror - that's because, one does not exist. We can either install the Litecoin daemon manually or because we are using Arch Linux, the Arch Linux User Repository (AUR) might have a package we can use.

**Arch Linux User Repository (AUR)**

The closest AUR I could find was [bitcoin-bin (AUR)](https://aur.archlinux.org/packages/litecoin-bin) but this AUR included all the QT (Cross platform UI framework) dependencies. We don't need or want the QT dependencies as we are running a headless server. So I repurposed an out-of-date and abandoned AUR to our needs, meet [bitcoin-daemon (AUR)](https://aur.archlinux.org/packages/litecoin-daemon/)

**WARNING** Do NOT TRUST AURs - check out the PKGBUILD file before installing, and make sure it does what the label says it does, even though this AUR is authored by me - so check it out!

The easiest way to install/update/remove AURs is to use yaourt. If you don't have yaourt installed, he's how to do it:

``` bash
# Check it's not already installed
# If it's not installed you should get this message: "yaourt: command not found"
yaourt

# edit the pacman configuration file
nano /etc/pacman.conf
# paste '[archlinuxfr]' block, at the end of the file  - [see below]
```

Add this at the end of /etc/pacman.conf

``` ini
[archlinuxfr]
 SigLevel = Never
 Server = http://repo.archlinux.fr/$arch
```

Now we can install yaourt:

``` bash
# Force update the package databases
pacman -Syyu
# install yaourt
pacman -S yaourt
```

**Note:** Yaourt does not allow installation of packages when you are root, so this is a good time to create our LTC service user.

Let's now create the user account that our litecoin daemon will use:

``` bash
useradd ltc
passwd ltc
# enter password twice

# create a home directory
mkhomedir_helper ltc
```

Next we'll need somewhere for the Litecoin daemon to store the blockchain and other data:

``` bash
# Create directory /ltc
mkdir /ltc
# Change owner of directory /ltc to ltc (user)
chown ltc: /ltc
# Modify permission of directory /ltc for owner to have write access
sudo chmod u+w /ltc
```

Now, we'll switch to the ltc user and setup the daemon configuration and setup some bash aliases:

``` bash
# switch to ltc service account
su - ltc
# Create the directory that the Litecoin daemon searches for a configuration file (if not specified)
mkdir .litecoin

nano ~/.litecoin/litecoin.conf
# paste config [See below]
nano ~/.bashrc
# paste aliases [See below]
```

That's all we need to do with the ltc user.

``` bash
# exit back to root
exit
```

Open Litecoin TestNet port on UFW (See Part 2 of this series if you don't know what this means)

``` bash
ufw allow 19335
ufw status
```

We now want to create a new systemd service, that starts automatically when the VM starts:

``` bash
# the ltc.service file doesn't exist yet, but nano will create it with the contents we paste into it
nano /etc/systemd/system/ltc.service
# paste ltc service definition [See below]

# enable at system startup
systemctl enable ltc
# start the Litecoin service now
systemctl start ltc

# Check it's running
systemctl status ltc
```

The Litecoin daemon is running now, so let's query it with the CLI:

``` bash
# switch to ltc service account
su - ltc
# Display network details
ltc-net
# Display block details (index, blocks, ..)
ltc-block
```

NOTE: It may take up to a minute before the daemon will allow requests on startup, whether it's the first time or after it's been running for days. This message indicates it's loading the index, try again in a few moments:

``` bash
error code: -28
error message:
Loading block index...
```

NOTE: It took about 30 minutes for the node to catchup to the current height. And you'll need about 500MB of storage (as of the 15th December 2017):

``` bash
[ltc@localhost ~]$ du /ltc -h
16M     /ltc/testnet4/chainstate
70M     /ltc/testnet4/blocks/index
409M    /ltc/testnet4/blocks
455M    /ltc/testnet4
455M    /ltc
```


---

# Contents of files

## ~/.litecoin/litecoin.conf

All litecoind configuration options are defined (same as bitcoind): [here](https://en.bitcoin.it/wiki/Running_Bitcoin)

``` ini
##
## litecoin.conf configuration file. Lines beginning with # are comments.
##

# IMPORTANT: do not use the daemon's wallet
disablewallet=1

datadir=/ltc

# Network-related settings:

# Run on the test network instead of the real lite network.
testnet=1

# Listening mode, enabled by default except when 'connect' is being used. Port 19335 (TestNet4)
listen=1

#
# JSON-RPC options (for controlling a running Litecoin/litecoind process)
#

# server=1 tells litecoind to accept JSON-RPC commands
server=1
# Accept public REST requests (default: 0)
rest=0
# RPC username or password is not specified, so a cookie is written to the /ltc/testnet4 directory for the CLI to use for auth
```

---

## ~/.bashrc

All litecoin-cli options are the same as the bitcoin-cli, defined: [here](https://bitcoin.org/en/developer-reference#rpc-quick-reference)

``` bash
alias ltc-start='litecoind -daemon'
alias ltc-stop='litecoin-cli stop'
alias ltc-block='litecoin-cli getblockchaininfo'
alias ltc-net='litecoin-cli getnetworkinfo'
alias ltc-mempool='litecoin-cli getrawmempool'
alias ltc-mempoolall='litecoin-cli getrawmempool true'
```

---

## /etc/systemd/system/ltc.service

``` ini
# To edit use:
# $ systemctl edit litecoind.service
# See "man systemd.service" for details.

[Unit]
Description=Litecoin TestNet daemon
After=network.target

[Service]
ExecStart=/bin/litecoind -daemon
# Creates /run/litecoind owned by ltc
RuntimeDirectory=litecoind
# user can be a service account
User=ltc
Type=forking
PIDFile=/ltc/testnet4/litecoin.pid
Restart=on-failure
PrivateTmp=true

[Install]
WantedBy=multi-user.target
```
