#!/bin/bash

# exit script if return code != 0
set -e

if [[ ! -z "${arc_packages}" ]]; then

	# split space seperated string of packages into list
	IFS=' ' read -ra arc_package_list <<< "${arc_packages}"

	# process each package in the list
	for arc_package_name_version in "${arc_package_list[@]}"; do

		arc_package_name=$(echo $arc_package_name_version | cut -d '~' -f 1)
		arc_package_name_first_letter="${arc_package_name:0:1}"
		arc_package_version=$(echo $arc_package_name_version | cut -d '~' -f 2)

		echo "[info] Removing previous download '/tmp/${arc_package_name}.tar.xz' (if it exists)..."
		rm -f "/tmp/${arc_package_name}.tar.xz"

		echo "[info] Attempting download for archive package '${arc_package_name}' ver ${arc_package_version}"
		
		echo "[info] /root/curly.sh -rc 6 -rw 10 -of /tmp/${arc_package_name}.tar.xz -url https://archive.archlinux.org/packages/${arc_package_name_first_letter}/${arc_package_name}/${arc_package_name}-${arc_package_version}-x86_64.pkg.tar.xz"
		/root/curly.sh -rc 6 -rw 10 -of "/tmp/${arc_package_name}.tar.xz" -url "https://archive.archlinux.org/packages/${arc_package_name_first_letter}/${arc_package_name}/${arc_package_name}-${arc_package_version}-x86_64.pkg.tar.xz"
		pacman -U "/tmp/${arc_package_name}.tar.xz" --noconfirm

	done

fi
