#!/usr/bin/env bash

if ! command -v vboxmanage >/dev/null 2>&1; then
  echo 'ERROR: vboxmanage command not found.'
  exit 1
fi

VM_NAME="$1"
VM_DISPLAY_RESOLUTION="1920x1080"
VM_FOLDER="$(vboxmanage list systemproperties | grep 'Default machine folder:' | tr -s ' ' | cut -d ' ' -f 4)/${VM_NAME}"

if vboxmanage showvminfo "${VM_NAME}" >/dev/null 2>&1; then
  echo "VM already exists: ${VM_NAME}"
  exit 1
fi

# Create VM
vboxmanage createvm --name "${VM_NAME}" --ostype MacOS_64 --register
vboxmanage storagectl "${VM_NAME}" --name SATA --add sata --controller IntelAhci --portcount 2
vboxmanage createmedium disk --format VMDK --size 524288 --filename "${VM_FOLDER}/${VM_NAME}.vmdk" --variant Split2G
vboxmanage storageattach "${VM_NAME}" --storagectl SATA --port 0 --device 0 --type hdd --medium "${VM_FOLDER}/${VM_NAME}.vmdk"
vboxmanage storageattach "${VM_NAME}" --storagectl SATA --port 1 --device 0 --type dvddrive --medium emptydrive
vboxmanage modifyvm "${VM_NAME}" \
  --cpus "$(("$(nproc)" / 2))" --memory 16384 \
  --chipset ich9 --firmware efi --rtcuseutc on --nested-hw-virt on \
  --boot1 dvd --boot2 disk --boot3 none --boot4 none \
  --vram 128 --accelerate3d on \
  --audio pulse --audiocontroller hda --audioout on \
  --usb on --usbohci off --usbehci off --usbxhci on \
  --mouse usbtablet --keyboard usb

# Display resolution
vboxmanage setextradata "${VM_NAME}" "CustomVideoMode1" "${VM_DISPLAY_RESOLUTION}x32"
vboxmanage setextradata "${VM_NAME}" "VBoxInternal2/EfiGraphicsResolution" "${VM_DISPLAY_RESOLUTION}"

# macOS specific settings
vboxmanage modifyvm "${VM_NAME}" --cpuid-set 00000001 000106e5 00100800 0098e3fd bfebfbff
vboxmanage setextradata "${VM_NAME}" "VBoxInternal/Devices/efi/0/Config/DmiSystemProduct" "iMac11,3"
vboxmanage setextradata "${VM_NAME}" "VBoxInternal/Devices/efi/0/Config/DmiSystemVersion" "1.0"
vboxmanage setextradata "${VM_NAME}" "VBoxInternal/Devices/efi/0/Config/DmiBoardProduct" "Iloveapple"
vboxmanage setextradata "${VM_NAME}" "VBoxInternal/Devices/smc/0/Config/DeviceKey" "ourhardworkbythesewordsguardedpleasedontsteal(c)AppleComputerInc"
vboxmanage setextradata "${VM_NAME}" "VBoxInternal/Devices/smc/0/Config/GetKeyFromRealSMC" 1
