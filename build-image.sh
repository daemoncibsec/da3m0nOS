#!/usr/bin/env sh

# Copy the files from the original debian iso
debian_iso="$(ls debian-* | grep amd64 | tail -n1)"
mkdir /tmp/iso
sudo mount -o loop $debian_iso /tmp/iso
sudo cp -r /tmp/iso isofiles
sudo umount /tmp/iso

# Append the preseeding file into initrd
#chmod +w -R isofiles/install.amd/
#gunzip isofiles/install.amd/initrd.gz
#echo preseed.cfg | cpio -H newc -o -A -F isofiles/install.amd/initrd
#gzip isofiles/install.amd/initrd
#chmod -w -R isofiles/install.amd/
cd isofiles/install.amd
gunzip initrd.gz
find ../../preseed.cfg | cpio -H newc -o -A -F initrd
gzip initrd
cd ../..

if ! grep -q "file=/preseed.cfg" isofiles/boot/grub/grub.cfg; then
    sed -i '/linux / s|$| auto=true priority=critical file=/preseed.cfg|' isofiles/boot/grub/grub.cfg
fi

# Regenerate the md5sum
cd isofiles
chmod +w md5sum.txt
find -follow -type f ! -name md5sum.txt -print0 | xargs -0 md5sum > md5sum.txt
chmod -w md5sum.txt
cd ..

# Use the original Debian label to
# be able to install the system
label="DEBIAN_13_1_0_AMD64"

# Build the image using xorriso
xorriso -as mkisofs -V $label -r -J -joliet-long -o da3m0nOS-1.0.0-amd64-netinstall.iso -eltorito-alt-boot -e boot/grub/efi.img -no-emul-boot -isohybrid-gpt-basdat isofiles
