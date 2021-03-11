#!/bin/sh

if [ $EUID != 0 ]; then
	sudo "$0" "$@"
	exit $?
fi

export BORG_REPO=/backup/borg

# add --list to view files as they're added to the backup
borg create \
	 --verbose \
	 --stats \
	 --compression zstd,22 \
	 --one-file-system \
	 --exclude-caches \
	 --exclude /var/cache \
	 --exclude /backup \
	 \
	 ::"$(date +%F)" \
	 /

BACKUP_EXIT=$?

borg prune \
	 --list \
	 --keep-daily 7 \
	 --keep-monthly 2

PRUNE_EXIT=$?

GLOBAL_EXIT=$(( BACKUP_EXIT > PRUNE_EXIT ? BACKUP_EXIT : PRUNE_EXIT ))

if [ $GLOBAL_EXIT -eq 0 ]; then
	echo "Backup and Prune finished with successfully"
elif [ $GLOBAL_EXIT -eq 1 ]; then
	echo "Backup and/or Prune finshed with warnings"
else
	echo "Backup and/or Prune finished with errors"
fi

exit $GLOBAL_EXIT
