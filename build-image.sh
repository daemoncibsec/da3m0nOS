#!/usr/bin/env sh

# Append the preseeding file into initrd
chmod +w -R isofiles/install.amd/
gunzip isofiles/install.amd/initrd.gz
echo preseed.cfg | cpio -H newc -o -A -F isofiles/install.amd/initrd
gzip isofiles/install.amd/initrd
chmod -w -R isofiles/install.amd/

if ! grep -q "file=/preseed.cfg" isofiles/boot/grub/grub.cfg; then
    sed -i '/linux / s|$| auto=true priority=critical file=/preseed.cfg|' isofiles/boot/grub/grub.cfg
fi

# Regenerate the md5sum
cd isofiles
chmod +w md5sum.txt
find -follow -type f ! -name md5sum.txt -print0 | xargs -0 md5sum > md5sum.txt
chmod -w md5sum.txt
cd ..

xorriso -as mkisofs -r -J -joliet-long -o da3m0nOS-1.0.0-amd64-uefi.iso -eltorito-alt-boot -e boot/grub/efi.img -no-emul-boot -isohybrid-gpt-basdat isofiles
