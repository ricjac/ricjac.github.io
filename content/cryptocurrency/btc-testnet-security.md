+++
date = "2017-12-11"
draft = false

categories = ["Cryptocurrency"]

title = "PART 2: How to secure your Bitcoin TestNet3 Full Node on Arch linux"
description = "Some steps you can take to prevent your server getting hacked"
+++
# Intro

This is Part 2 in the Cryptocurrency series:

* [PART 1]({{< ref "btc-testnet.md" >}}) - We look at setting up a **Bitcoin** full node connected to TestNet3
* [PART 2]({{< ref "btc-testnet-security.md" >}}) We put in place some harden strategies to protect against attack
* [PART 2]({{< ref "ltc-testnet.md" >}}) - We look at setting up a **Litecoin** full node connected to TestNet3

Begin by SSH-ing to the server - as root:

``` bash
# where xxx.xxx.xxx.xxx is the IP address or host name of the server
ssh root@xxx.xxx.xxx.xxx
```

# Setup a firewall - Uncomplicated Firewall (UFW)

Let's first lock down all incoming ports except those we want to receive, being:

* SSH (Port 22)
* Bitcoin TestNet3 (Port 18332)

``` bash
# install Uncomplicated Firewall
pacman -S ufw

# start by blocking all inbound traffic
ufw default deny incoming
ufw default allow outgoing
# Allow SSH - so we can remote to our server
ufw allow SSH
# Allow incoming traffic on the default TestNet3 port
ufw allow 18333
```

Next we will start UFW, and the rules will be applied - if you use a different port for SSH (default: 22), ensure you allow that port, or you will be disconnected.

``` bash
# start UFW manually - one off
ufw enable

# SystemD will start UFW automatically if the server is ever restarted
systemctl enable ufw

# Ensure the rules you added are reflected in the current UFW status
ufw status
```

# Securing SSH

**IMPORTANT**: If you are going to use a password for authentication on SSH, ensure it's at least 20+ characters long. The safest way is to use an RSA priv/pub key. But I'm sticking to a very long password, so that I can still remote in even if I don't have the SSH key on me, but have access to my password manager.

## SSHGuard

Install SSHGuard, it's similar to `fail2ban` (but simpler). It will protect SSH (can be used for other services too) against brute-force attacks.

``` bash
# Install SSHGuard
pacman -S sshguard

# enable SSHGuard on system startup, and start now
systemctl enable sshguard
systemctl start sshguard

# Ensure there were no issues
systemctl status sshguard
```

## Further hardening

You can take a few further step to harden your server:

* Forbid root SSH access
* Only allow SSH keys (no passwords) 
* Restrict users/group that can SSH (AllowUser/AllowGroup)
* Restrict SSH access by either IP, Country or City