+++
date = "2017-12-10"
draft = false

categories = ["Cryptocurrency"]

title = "PART 1: How to setup a Bitcoin TestNet3 Full Node on Arch linux"
description = "Setup a Bitcoin node connected to TestNet3. This is part of a series on how to get your node up and running, then in later posts, developing against it"
+++
# Intro

If you are starting out in learning to program with/in the Bitcoin network, setting up a TestNet full node is a good place to start, and also provides some learning opportunities.

For this exercise I used Linode to create a new Arch linux VM, but any [Arch Linux VPS provider](https://wiki.archlinux.org/index.php/Virtual_Private_Server) will provide the same experience.

<sub>
NOTE: This article was originally written for setting up a Raspberry PI 2, although the Bitcoin daemon ran, every hour or so the PI would crash/lock-up. and I wasn't able to find the cause. It was not overheating as I was monitoring the temperature at around 50 degree C (which seems normal).
If you want to try this yourself on a RPi, you first need to load Arch linux on an SD card:
</sub>

[Arch linux ARM setup](https://archlinuxarm.org/platforms/armv7/broadcom/raspberry-pi-2)

---

# Instructions

Begin by SSH-ing to the server - as root:

``` bash
# where xxx.xxx.xxx.xxx is the IP address or host name of the server
ssh root@xxx.xxx.xxx.xxx
```

update all packages, and install the Bitcoin daemon and CLI:

``` bash
pacman -Syu
pacman -S bitcoin-daemon bitcoin-cli
```

Create a service account which we'll use to run the Bitcoin daemon. Running your daemon with root credentials, which will have public TCP/UDP ports open to the internet is not advisable.

``` bash
useradd btc
passwd btc
# enter password twice

# create a home directory
mkhomedir_helper btc
```

Next we'll need somewhere for the Bitcoin daemon to store the blockchain and other data:

``` bash
# Create directory /btc
mkdir /btc
# Change owner of directory /btc to btc (user)
chown btc: /btc
# Modify permission of directory /btc for owner to have write access
sudo chmod u+w /btc
```

Now, we'll switch to the btc user and setup the daemon configuration and setup some bash aliases:

``` bash
# switch to btc service account
su - btc
# Create the directory that the Bitcoin daemon searches for a configuration file (if not specified)
mkdir .bitcoin

nano ~/.bitcoin/bitcoin.conf
# paste config [See below]
nano ~/.bashrc
# paste aliases [See below]
```

That's all we need to do with the btc user.

``` bash
# exit back to root
exit
```

We now want to create a new systemd service, that starts automatically when the VM starts:

``` bash
# the btc.service file doesn't exist yet, but nano will create it with the contents we paste into it
nano /etc/systemd/system/btc.service
# paste btc service definition [See below]

# enable at system startup
systemctl enable btc
# start the Bitcoin service now
systemctl start btc

# Check it's running
systemctl status btc
```

The Bitcoin daemon is running now, so let's query it with the CLI:

``` bash
# switch to btc service account
su - btc
# Display network details
btc-net
# Display block details (index, blocks, ..)
btc-block
```

NOTE: It may take up to a minute before the daemon will allow requests on startup, whether it's the first time or after it's been running for days. This message indicates it's loading the index, try again in a few moments:

``` bash
error code: -28
error message:
Loading block index...
```

NOTE: It took about 2 hours for the node to catchup to the current height. And you'll need about 14GB of storage (as of the 10th December 2017):

``` bash
[btc@localhost ~]$ du /btc -h
898M    /btc/testnet3/chainstate
369M    /btc/testnet3/blocks/index
13G     /btc/testnet3/blocks
14G     /btc/testnet3
14G     /btc
```

Congratulations! You've just setup a Bitcoin full node on TestNet3.

Part 2 (coming soon) security and exposing an API for querying.

Also: If you're interested in setting up RegTest node (local network with instant block mining) - see these [instructions](https://bitcoin.org/en/developer-examples#regtest-mode)

---

# Contents of files

## ~/.bitcoin/bitcoin.conf

All bitcoind configuration options are defined: [here](https://en.bitcoin.it/wiki/Running_Bitcoin)

``` ini
##
## bitcoin.conf configuration file. Lines beginning with # are comments.
##

# IMPORTANT: do not use the daemon's wallet
disablewallet=1

datadir=/btc

# Network-related settings:

# Run on the test network instead of the real bitcoin network.
testnet=1

# Listening mode, enabled by default except when 'connect' is being used. Port 18332 (TestNet3)
listen=1

#
# JSON-RPC options (for controlling a running Bitcoin/bitcoind process)
#

# server=1 tells bitcoind to accept JSON-RPC commands
server=1
# Accept public REST requests (default: 0)
rest=0
# RPC username or password is not specified, so a cookie is written to the /btc/testnet3 directory for the CLI to use for auth
```

---

## ~/.bashrc

All bitcoin-cli options are defined: [here](https://bitcoin.org/en/developer-reference#rpc-quick-reference)

``` bash
alias btc-start='bitcoind -daemon'
alias btc-stop='bitcoin-cli stop'
alias btc-block='bitcoin-cli getblockchaininfo'
alias btc-net='bitcoin-cli getnetworkinfo'
alias btc-mempool='bitcoin-cli getrawmempool'
alias btc-mempoolall='bitcoin-cli getrawmempool true'
```

---

## /etc/systemd/system/btc.service

``` ini
# To edit use:
# $ systemctl edit bitcoind.service
# See "man systemd.service" for details.

[Unit]
Description=Bitcoin TestNet daemon
After=network.target

[Service]
ExecStart=/bin/bitcoind -daemon
# Creates /run/bitcoind owned by btc
RuntimeDirectory=bitcoind
# user can be a service account
User=btc
Type=forking
PIDFile=/btc/testnet3/bitcoind.pid
Restart=on-failure
PrivateTmp=true

[Install]
WantedBy=multi-user.target
```
