if [ "${BASH_SOURCE[0]}" -ef "$0" ]; then
    echo 'This should should be sourced, not executed.'
    exit 1
fi

# converts iso to qcow2
img::convert() {
    local src_img=$1
    local dest_img=$2

    if [ -z "${src_img}" ]; then
          echo '[ERR] Source image is not defined.'
          exit 1
    fi

    if [ -z "${dest_img}" ]; then
        echo '[ERR] Dest image is not defined.'
        exit 1
    fi

    qemu-img convert -O qcow2 $src_img $dest_img
}

# create an empty qcow2 file
img::create_disk() {
    local disk_path=$1
    local disk_size=$2

    if [ -z "${disk_path}" ]; then
        echo '[ERR] Disk path is not defined.'
        exit 1
    fi

    if [ -z "${disk_size}" ]; then
        echo '[ERR] Disk size is not defined.'
    fi

    if [ -f "${disk_path}" ]; then 
        rm -f ${disk_path}
    fi
   
    qemu-img create -f qcow2 ${disk_path} ${disk_size}
}


img::install() {
    local installer_img=$1
    local disk_img=$2

    if [ -z "${installer_img}" ]; then
        echo '[ERR] Installer image not defined.'
        exit 1
    fi

    if [ -z "${disk_img}" ]; then
        echo '[ERR] Disk image not defined.'
        exit 1
    fi
    
    /usr/bin/qemu-system-x86_64 \
        -machine pc \
        -enable-kvm \
        -cpu host \
        -smp 1 \
        -m 3072 \
        -drive file=${disk_img},format=qcow2,readonly=off,if=virtio \
        -drive file=${installer_img},media=disk,format=qcow2,if=virtio,snapshot=off \
        -device virtio-net-pci,netdev=n0 \
        -netdev user,id=n0,net=10.0.2.0/24,hostfwd=tcp::2222-:22 \
        -fw_cfg name=opt/com.coreos/config,file=files/sample.ign.json \
        -drive file=/usr/share/OVMF/OVMF_CODE.fd,if=pflash,format=raw,unit=0,readonly=on \
        -drive file=/usr/share/OVMF/OVMF_VARS.fd,if=pflash,format=raw,unit=1,snapshot=on,readonly=off
}

img::run() {
    local disk_img=$1

    if [ -z "${disk_img}" ]; then
        echo '[ERR] Disk image not defined.'
        exit 1
    fi

    /usr/bin/qemu-system-x86_64 \
        -machine pc \
        -enable-kvm \
        -cpu host \
        -smp 1 \
        -m 3072 \
        -drive file=${disk_img},format=qcow2,readonly=off,if=virtio \
        -device virtio-net-pci,netdev=n0 \
        -netdev user,id=n0,net=10.0.2.0/24,hostfwd=tcp::2222-:22 \
        -fw_cfg name=opt/com.coreos/config,file=files/sample.ign.json \
        -drive file=/usr/share/OVMF/OVMF_CODE.fd,if=pflash,format=raw,unit=0,readonly=on \
        -drive file=/usr/share/OVMF/OVMF_VARS.fd,if=pflash,format=raw,unit=1,snapshot=on,readonly=off
}
