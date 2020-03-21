if [ $EUID != 0 ]; then
	sudo "$0" "$@"
	exit $?
fi

case $1 in
	start)
		echo "fd798828-3180-4c19-a634-b88ddea27abe" > "/sys/devices/pci0000:00/0000:00:02.0/mdev_supported_types/i915-GVTg_V5_4/create"
		;;
	stop)
		echo 1 > "/sys/devices/pci0000:00/0000:00:02.0/fd798828-3180-4c19-a634-b88ddea27abe/remove"
		;;
	*)
		echo "Usage $0 start|stop"
		;;
esac

