# Keypair Sharing between Servers (Import & Export)

source https://montemazuma.wordpress.com/2010/03/01/moving-a-gpg-key-privately/

The source machine (it will ask you for a passcode to encrypt the private key with; don't be silly)
```bash
chris@source$ gpg --list-secret-keys
/home/apt/.gnupg/secring.gpg
----------------------------
sec   4096R/BB2128D2 2017-04-04 [expires: 2018-03-30]
uid                  APT repositories from 64 Studio Ltd. <apt@64studio.com>

chris@source$ gpg --output pubkey.gpg --export BB2128D2
chris@source$ gpg --output - --export-secret-key BB2128D2 | cat pubkey.gpg - | gpg --armor --output keys.asc --symmetric --cipher-algo AES256

```
`scp` keys.asc to your local machine, then scp it to the remote machine.

Destination machine (it will ask for the passcode):
chris@destination$ gpg --no-use-agent --output - keys.asc | gpg --import 
