#!/bin/bash
# This script downloads github soure releases in zipped format, it also has basic support for binary releases.

# exit script if return code != 0
#set -e

# setup default values
readonly ourScriptName=$(basename -- "$0")
readonly defaultDownloadFilename="github-source.zip"
readonly defaultDownloadPath="/tmp"
readonly defaultExtractPath="/tmp/extracted"
readonly defaultReleaseType="source"

download_filename="${defaultDownloadFilename}"
download_path="${defaultDownloadPath}"
extract_path="${defaultExtractPath}"
release_type="${defaultReleaseType}"

function github_downloader() {

	echo -e "[info] Running script to download latest release from GitHub..."

	github_release_tags_url="https://github.com/${github_owner}/${github_repo}/releases"
	download_full_path="${download_path}/${download_filename}"

	filename=$(basename "${download_filename}")
	download_filename_ext="${filename##*.}"

	echo -e "[info] Removing previous run release tag html webpage ${download_path}/release_tag ..."
	rm -f "${download_path}/release_tag"

	echo -e "[info] Identifying GitHub release tags..."
	mkdir -p "${download_path}"
	/root/curly.sh -rc 6 -rw 10 -of "${download_path}/release_tag" -url "${github_release_tags_url}"

	if [[ -z "${release_tag}" ]]; then
		release_tag=$(cat "${download_path}/release_tag" | grep -P -o -m 1 "(?<=/${github_owner}/${github_repo}/releases/tag/)[^\"]+")
	fi

	echo -e "[info] GitHub Release tag is ${release_tag}"

	if [ "${release_type}" == "source" ]; then
		github_release_url="https://github.com/${github_owner}/${github_repo}/archive/${release_tag}.zip"
	else
		github_release_url="https://github.com/${github_owner}/${github_repo}/releases/download/${release_tag}/${download_filename}"
	fi

	echo -e "[info] Downloading release from GitHub..."
	/root/curly.sh -rc 6 -rw 10 -of "${download_full_path}" -url "${github_release_url}"

	if [ "${download_filename_ext}" == "zip" ]; then

		echo -e "[info] Removing previous extract path ${extract_path} ..."
		rm -rf "${extract_path}/"

		echo -e "[info] Extracting to ${extract_path} ..."
		mkdir -p "${extract_path}"
		unzip -o "${download_full_path}" -d "${extract_path}"

		echo -e "[info] Moving from extraction path ${extract_path}/${github_repo} to install path ${install_path} ..."
		mkdir -p "${install_path}"
		mv -f "${extract_path}/${github_repo}"*/* "${install_path}/"

		echo -e "[info] Removing source archive from ${download_full_path} ..."
		rm -f "${download_full_path}"

		echo -e "[info] Removing extract path ${download_full_path} ..."
		rm -rf "${extract_path}/"

	else

		echo -e "[info] Moving from download path ${download_full_path} to install path ${install_path} ..."
		mkdir -p "${install_path}"
		mv -f "${download_full_path}" "${install_path}/${download_filename}"

	fi
}

function show_help() {
	cat <<ENDHELP
Description:
	Script to download GitHub releases.
Syntax:
	${ourScriptName} [args]
Where:
	-h or --help
		Displays this text.

	-df or --download-filename <filename.ext>
		Define name of the downloaded file
		Defaults to '${defaultDownloadFilename}'.

	-dp or --download-path <path>
		Define path to download to.
		Defaults to '${defaultDownloadPath}'.

	-ep or --extract-path <path>
		Define path to extract the download to.
		Defaults to '${defaultExtractPath}'.

	-ip or --install-path <path>
		Define path to install to.
		No default.

	-go or --github-owner <owner>
		Define GitHub owners name.
		No default.

	-rt or --release-type <binary|source>
		Define whether to download binary artifacts or source from GitHub.
		Default to '${defaultReleaseType}'.

	-gr or --github-repo <repo>
		Define GitHub repository name.
		No default.

	-gt or --github-tag <tag name>
		Define GitHub release tag name.
		If not defined then latest tag will be used.

Example:
	./github.sh -df github-download.zip -dp /tmp -ep /tmp/extracted -ip /opt/binhex/deluge -go binhex -rt source -gr arch-deluge
ENDHELP
}

while [ "$#" != "0" ]
do
	case "$1"
	in
		-df|--download-filename)
			download_filename=$2
			shift
			;;
		-dp| --download-path)
			download_path=$2
			shift
			;;
		-ep|extract-path)
			extract_path=$2
			shift
			;;
		-ip|--install-path)
			install_path=$2
			shift
			;;
		-go|--github-owner)
			github_owner=$2
			shift
			;;
		-gr|--github-repo)
			github_repo=$2
			shift
			;;
		-gt|--github-tag)
			github_tag=$2
			shift
			;;
		-rt|--release-type)
			release_type=$2
			shift
			;;
		-h|--help)
			show_help
			exit 0
			;;
		*)
			echo "${ourScriptName}: ERROR: Unrecognised argument '$1'." >&2
			show_help
			 exit 1
			 ;;
	 esac
	 shift
done

# check we have mandatory parameters, else exit with warning
if [[ -z "${install_path}" ]]; then
	echo "[warning] Install path not defined via parameter -ip or --install-path, displaying help..."
	show_help
	exit 1
fi

if [[ -z "${github_owner}" ]]; then
	echo "[warning] GitHub owner's name not defined via parameter -go or --github-owner, displaying help..."
	show_help
	exit 1
fi

if [[ -z "${github_repo}" ]]; then
	echo "[warning] GitHub repo name not defined via parameter -gr --github-repo, displaying help..."
	show_help
	exit 1
fi

github_downloader "$Pdownload_filename}" "${download_path}" "${extract_path}" "${install_path}" "${github_owner}" "${github_repo}" "${github_tag}"
