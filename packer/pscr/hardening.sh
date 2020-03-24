#!/usr/bin/env bash

sudo cat << 'EOF' > /home/sdg/.bash_profile
[ -f ~/.bashrc ] && . ~/.bashrc
export PATH=$PATH:/sbin:/usr/sbin:$HOME/bin
EOF

## Prevent entering interactive boot
sudo sed -i 's/PROMPT=yes/PROMPT=no/g' /etc/sysconfig/init
echo "Interactive Boot disabled"

## LNX00580
echo "Locking down LNX00580"
sudo sed -i 's/ca::ctrlaltdel:\/bin\/shutdown/#ca::ctrlaltdel:\/bin\/shutdown/' /etc/inittab
echo "LNX00580 Complete"

readonly P_FSTAB=/etc/fstab
readonly D_MOUNTS_NSUID=("\/home" "\/sys" "\/boot" "\/usr" )
readonly D_MOUNTS_NDEV=("\/home" "\/usr\/local" "\/tmp" "\/var\/tmp" "\/var")
readonly D_MOUNTS_NEXEC=("\/tmp" "\/var\/tmp")

M_TYPE="nosuid"
for D_MOUNT in ${D_MOUNTS_NSUID[*]}; do
    if ex=$(sudo grep "[[:blank:]]${D_MOUNT}[[:blank:]]" ${P_FSTAB}); then
        if [[ $(echo "${ex}" | grep -c "${M_TYPE}") -eq 0 ]]; then
            MNT_OPTS=$(echo ${ex} | awk '{print $4}')
            sudo sed -i "s/\([[:blank:]]${D_MOUNT}.*${MNT_OPTS}\)/\1,${M_TYPE}/" ${P_FSTAB}
        fi
    fi
done

M_TYPE="nodev"
for D_MOUNT in ${D_MOUNTS_NDEV[*]}; do
    if ex=$(sudo grep "[[:blank:]]${D_MOUNT}[[:blank:]]" ${P_FSTAB}); then
        if [[ $(echo "${ex}" | grep -c "${M_TYPE}") -eq 0 ]]; then
            MNT_OPTS=$(echo ${ex} | awk '{print $4}')
            sudo sed -i "s/\([[:blank:]]${D_MOUNT}.*${MNT_OPTS}\)/\1,${M_TYPE}/" ${P_FSTAB}
        fi
    fi
done

M_TYPE="noexec"
for D_MOUNT in ${D_MOUNTS_NEXEC[*]}; do
    if ex=$(sudo grep "[[:blank:]]${D_MOUNT}[[:blank:]]" ${P_FSTAB}); then
        if [[ $(echo "${ex}" | grep -c "${M_TYPE}") -eq 0 ]]; then
            MNT_OPTS=$(echo ${ex} | awk '{print $4}')
            sudo sed -i "s/\([[:blank:]]${D_MOUNT}.*${MNT_OPTS}\)/\1,${M_TYPE}/" ${P_FSTAB}
        fi
    fi
done

# GEN000920
echo "Locking down GEN000920"
sudo chmod 700 /root
echo "GEN000920 Complete"

sudo cat << 'EOF' >> ./sysctl.conf
net.ipv4.ip_forward = 0
net.ipv4.conf.all.send_redirects = 0
net.ipv4.conf.default.send_redirects = 0
net.ipv4.tcp_max_syn_backlog = 1280
net.ipv4.icmp_echo_ignore_broadcasts = 1
net.ipv4.conf.all.accept_source_route = 0
net.ipv4.conf.all.accept_redirects = 0
net.ipv4.conf.all.secure_redirects = 0
net.ipv4.conf.all.log_martians = 1
net.ipv4.conf.default.accept_source_route = 0
net.ipv4.conf.default.accept_redirects = 0
net.ipv4.conf.default.secure_redirects = 0
net.ipv4.icmp_echo_ignore_broadcasts = 1
net.ipv4.icmp_ignore_bogus_error_responses = 1
net.ipv4.tcp_syncookies = 1
net.ipv4.conf.all.rp_filter = 1
net.ipv4.conf.default.rp_filter = 1
net.ipv4.tcp_timestamps = 0
kernel.exec-shield = 1
kernel.randomize_va_space = 1
EOF
sudo rm -f /etc/sysctl.d/99-sysctl.conf
sudo rm -f /etc/sysctl.conf
sudo mv ./sysctl.conf /etc/sysctl.conf
sudo restorecon -Rv /etc/sysctl.conf

echo "Disabling THP"
sudo cat << 'EOF' >> ./disable-thp.service
[Unit]
Description=Disable Transparent Huge Pages (THP)

[Service]
Type=simple
ExecStart=/bin/sh -c "echo 'never' > /sys/kernel/mm/transparent_hugepage/enabled && echo 'never' > /sys/kernel/mm/transparent_hugepage/defrag"

[Install]
WantedBy=multi-user.target
EOF
sudo mv ./disable-thp.service /lib/systemd/system/
sudo chmod 644 /lib/systemd/system/disable-thp.service
sudo systemctl daemon-reload
sudo systemctl enable disable-thp.service
echo "Disabling THP Complete"

exec /bin/bash -c "sleep 4; rm -f $(basename $0);"