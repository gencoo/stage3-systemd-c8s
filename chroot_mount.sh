#!/bin/bash

start() {
	echo "Mounting chroot directories"
	mount --types proc /proc /mnt/proc
	mount --rbind /sys /mnt/sys
	mount --make-rslave /mnt/sys
	mount --rbind /dev /mnt/dev
	mount --make-rslave /mnt/dev
	chroot /mnt/ /bin/bash
}

stop() {
	echo "Unmounting chroot directories"
	umount -f /mnt/dev > /dev/null &
	umount -f /mnt/proc > /dev/null &
	umount -f /mnt/sys > /dev/null &
}

	if [[ $1 == stop ]]; then
		stop
	else
		start
	fi
