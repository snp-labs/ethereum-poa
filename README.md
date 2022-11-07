# ethereum-poa

Construct BootStrap 1 and 3 Validators

Start bootstrap
```
bash script.sh start boot
```
<br/>

Generate account
```
bash script.sh account peer [0~2]
```

Remember the password and write it in the password file of the project.

If the peer's password is different, split the password file and save it and change the PWDPATH option in the config.json file.


ex)
``` 
$ echo "yourpassword" > password
$ echo "yourpassword" > password1
$ echo "yourpassword" > password2
```
in projectroot/config.json, check "PEER[0~n].PWDPATH"

"PWDPATH":"PasswordFilePath"

<br/>
<br/>
<br/>

Generate genesis.json
(In remote, You only need to run it once on a single computer, not all computer)
```
./release/puppeth
```

```
Please specify a network name to administer (no spaces, hyphens or capital letters please)
> geth_poa
```
```
What would you like to do? (default = stats)
 1. Show network stats
 2. Configure new genesis
 3. Track new remote server
 4. Deploy network components
> 2
```
```
What would you like to do? (default = create)
 1. Create new genesis from scratch
 2. Import already existing genesis
> 1
```
```
Which consensus engine to use? (default = clique)
 1. Ethash - proof-of-work
 2. Clique - proof-of-authority
> 2
```
```
How many seconds should blocks take? (default = 15)
> 5
```

```
Which accounts are allowed to seal? (mandatory at least one)
> 0x{Peer 0 accountaddress}
> 0x
```

```
Which accounts should be pre-funded? (advisable at least one)
> 0x{Peer 0 accountaddress}
> 0x
```
```
Should the precompile-addresses (0x1 .. 0xff) be pre-funded with 1 wei? (advisable yes)
> 
```
```
Specify your chain/network ID if you want an explicit one (default = random)
> 111
```
```
What would you like to do? (default = stats)
 1. Show network stats
 2. Manage existing genesis
 3. Track new remote server
 4. Deploy network components
> 2
```
```
 1. Modify existing configurations
 2. Export genesis configurations
 3. Remove genesis configuration
> 2
```
```
Which folder to save the genesis spec into? (default = current)
  Will create geth_poa.json
> 
INFO [11-07|15:45:46.194] Saved native genesis chain spec          path=geth_poa.json

console exit : Ctrl + D
```

<br/>
If you run Ethereum network by remote (other PC) you must have TODO: 

Copy geth_poa.json file to all peer computers except bootstrap node

<br/><br/><br/>

Init Genesis Block
```
bash script.sh init peer [0~2]
```


Start Peer 0 and Add Validater Peer 1
```
bash script.sh start peer
bash script.sh attach peer
> clique.propose('0x{peer1 node's Address},true)
> clique.getSigners()           // Check the list of validators
> exit
```

Start Peer 0 and Add Validater Peer 2
```
bash script.sh start peer 1
bash script.sh attach peer
> clique.propose('0x{peer2 node's Address},true)
> clique.getSigners()           // Check the list of validators
> exit
```

```
bash script.sh attach peer
> clique.propose('0x{peer2 node's Address},true)
> clique.getSigners()           // Check the list of validators
> exit
```

Start Peer 2
```
bash script.sh start peer 2
> clique.getSigners()           // Check the list of validators
> exit
```