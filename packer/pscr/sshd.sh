#!/bin/sh
set -e

install -v -o sdg -g sdg -m 0700 -d /home/sdg/.ssh
mv /home/sdg/sdg.pub /home/sdg/.ssh/authorized_keys
chown sdg:sdg /home/sdg/.ssh
chown sdg:sdg /home/sdg/.ssh/authorized_keys
chmod 700 /home/sdg/.ssh
chmod 600 /home/sdg/.ssh/*

readonly P_SSHD_CONF="/etc/ssh/sshd_config"
sed -i 's/PasswordAuthentication yes/PasswordAuthentication no/g' "${P_SSHD_CONF}"
sed -i 's/ChallengeResponseAuthentication yes/ChallengeResponseAuthentication no/g' "${P_SSHD_CONF}"
sed -i 's/#PubkeyAuthentication yes/PubkeyAuthentication yes/g' "${P_SSHD_CONF}"
sed -i 's/#PermitRootLogin yes/PermitRootLogin no/g' "${P_SSHD_CONF}"
sed -i 's/#IgnoreRhosts yes/IgnoreRhosts yes/g' "${P_SSHD_CONF}"
sed -i 's/#PermitEmptyPasswords no/PermitEmptyPasswords no/g' "${P_SSHD_CONF}"
sed -i 's/#StrictModes yes/StrictModes yes/g' "${P_SSHD_CONF}"
sed -i 's/GSSAPIAuthentication yes/GSSAPIAuthentication no/g' "${P_SSHD_CONF}"
sed -i 's/#KerberosAuthentication no/KerberosAuthentication no/g' "${P_SSHD_CONF}"
sed -i 's/X11Forwarding yes/X11Forwarding no/g' "${P_SSHD_CONF}"
sed -i 's/#PrintLastLog yes/PrintLastLog yes/g' "${P_SSHD_CONF}"
sed -i 's/HostKey \/etc\/ssh\/ssh_host_ecdsa_key/#HostKey \/etc\/ssh\/ssh_host_ecdsa_key/g' "${P_SSHD_CONF}"
echo "KexAlgorithms curve25519-sha256@libssh.org" >> "${P_SSHD_CONF}"
echo "Ciphers aes128-ctr,aes192-ctr,aes256-ctr,aes128-gcm@openssh.com,aes256-gcm@openssh.com,chacha20-poly1305@openssh.com" >> "${P_SSHD_CONF}"
echo "MACs hmac-ripemd160,hmac-ripemd160-etm@openssh.com,hmac-sha2-256,hmac-sha2-512,hmac-sha2-256-etm@openssh.com,hmac-sha2-512-etm@openssh.com,umac-128@openssh.com,umac-128-etm@openssh.com" >> "${P_SSHD_CONF}"
echo "AllowUsers sdg" >> "${P_SSHD_CONF}"
echo "Protocol 2" >> "${P_SSHD_CONF}"

rm -f .vbox_version
exec /bin/bash -c "sleep 4; rm -f $(basename $0); systemctl restart sshd"