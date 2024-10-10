# We are going to initialize and unseal the Vault server 
# using PGP keys from our admins!

#Install GnuPG and rng-tools
sudo apt install gnupg rng-tools -y
sudo rngd -r /dev/urandom

# Configure GPG_TTY
GPG_TTY=$(tty)
export GPG_TTY

#First we have to generate our pgp keys using gpg
gpg --batch --gen-key vaultadmin1
gpg --batch --gen-key vaultadmin2
gpg --batch --gen-key vaultadmin3

gpg --list-keys

#Now we need the base64 encoded public keys to use with Vault
gpg --export vaultadmin1 | base64 > vaultadmin1.asc
gpg --export vaultadmin2 | base64 > vaultadmin2.asc
gpg --export vaultadmin3 | base64 > vaultadmin3.asc

#Now we can initialize the seal with our gpg keys
export VAULT_ADDR="https://YOUR_VAULT_FQDN:8200"
vault operator init -key-shares=3 -key-threshold=2 -pgp-keys="vaultadmin1.asc,vaultadmin2.asc,vaultadmin3.asc"

#Copy out the key values to seal_keys.txt

# Next up, we are going to unseal our Vault server

#Decrypt the first two keys
echo "UNSEAL_KEY_1" | base64 --decode | gpg -u vaultadmin1 -dq
echo "UNSEAL_KEY_2" | base64 --decode | gpg -u vaultadmin2 -dq

#Unseal the vault
vault operator unseal

# Login into Vault
vault login