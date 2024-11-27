#!/bin/bash

# Create a text file of at least 56 bytes on PC2
echo "This is a sample text file with more than 56 bytes for encryption purposes." > /data/sample.txt

# Encrypt the file with AES cipher in CTR mode
openssl enc -aes-256-ctr -in /data/sample.txt -out /data/sample_ctr.enc -k secretpassword

# Encrypt the file with AES cipher in OFB mode
openssl enc -aes-256-ofb -in /data/sample.txt -out /data/sample_ofb.enc -k secretpassword

# Simulate file transfer to PC0 (already in shared volume)

# Verify the received files on PC0
openssl enc -d -aes-256-ctr -in /data/sample_ctr.enc -out /data/decrypted_ctr.txt -k secretpassword
openssl enc -d -aes-256-ofb -in /data/sample_ofb.enc -out /data/decrypted_ofb.txt -k secretpassword

# Corrupt the 6th bit in the ciphered file (CTR mode)
dd if=/data/sample_ctr.enc of=/data/sample_ctr_corrupted.enc bs=1 count=5
printf "\x01" >> /data/sample_ctr_corrupted.enc
dd if=/data/sample_ctr.enc of=/data/sample_ctr_corrupted.enc bs=1 skip=6 seek=6

# Corrupt the 6th bit in the ciphered file (OFB mode)
dd if=/data/sample_ofb.enc of=/data/sample_ofb_corrupted.enc bs=1 count=5
printf "\x01" >> /data/sample_ofb_corrupted.enc
dd if=/data/sample_ofb.enc of=/data/sample_ofb_corrupted.enc bs=1 skip=6 seek=6

# Decrypt corrupted files on PC0
openssl enc -d -aes-256-ctr -in /data/sample_ctr_corrupted.enc -out /data/decrypted_ctr_corrupted.txt -k secretpassword
openssl enc -d -aes-256-ofb -in /data/sample_ofb_corrupted.enc -out /data/decrypted_ofb_corrupted.txt -k secretpassword