#!/usr/bin/env bash
readonly P_FSTAB=./test.log
readonly P_SED=/bin/sed
readonly D_MOUNTS_NSUID=("\/home" "\/sys" "\/boot" "\/usr" )
readonly D_MOUNTS_NDEV=("\/home" "\/usr\/local" "\/tmp" "\/var\/tmp" "\/var")

M_TYPE="nosuid"
for D_MOUNT in ${D_MOUNTS_NSUID[*]}; do
    if ex=$(grep "[[:blank:]]${D_MOUNT}[[:blank:]]" ${P_FSTAB}); then
        if [ $(echo "${ex}" | grep -c "${M_TYPE}") -eq 0 ]; then
            MNT_OPTS=$(echo ${ex} | awk '{print $4}')
            sed -i "s/\([[:blank:]]${D_MOUNT}.*${MNT_OPTS}\)/\1,${M_TYPE}/" ${P_FSTAB}
        fi
    fi
done

M_TYPE="nodev"
for D_MOUNT in ${D_MOUNTS_NDEV[*]}; do
    if ex=$(grep "[[:blank:]]${D_MOUNT}[[:blank:]]" ${P_FSTAB}); then
        if [ $(echo "${ex}" | grep -c "${M_TYPE}") -eq 0 ]; then
            MNT_OPTS=$(echo ${ex} | awk '{print $4}')
            sed -i "s/\([[:blank:]]${D_MOUNT}.*${MNT_OPTS}\)/\1,${M_TYPE}/" ${P_FSTAB}
        fi
    fi
done

