#!/usr/bin/env bash
SPEC=bitwig-studio.spec

function get_download_url()
{
	if [ $# -eq 0 ]; then
		echo "Determining latest stable version..." 1>&2
		RELATIVE_URL=$(curl --silent -L bitwig.com/download/ | grep -Eo 'dl/Bitwig%20Studio/[0-9]+\.[0-9]+(\.[0-9]+)?/installer_linux' | head -n1)
	elif [ "$1" == "--beta" ]; then
		echo "Determining latest beta line..." 1>&2
		STABLE=$(curl --silent -L bitwig.com/download/ | grep -Eo 'dl/Bitwig%20Studio/[0-9]+\.[0-9]+(\.[0-9]+)?/installer_linux' | head -n1 | grep -Eo '[0-9]+\.[0-9]+')
		MAJOR=$(echo "$STABLE" | cut -d. -f1)
		MINOR=$(echo "$STABLE" | cut -d. -f2)

		while curl -s -o /dev/null -L --head -w '%{http_code}' "https://www.bitwig.com/dl/Bitwig%20Studio/${MAJOR}.$((MINOR+1))%20Beta%201/installer_linux" | grep -q 200; do
			MINOR=$((MINOR+1))
		done

		echo "Determining latest beta version..." 1>&2
		N=1
		while curl -s -o /dev/null -L --head -w '%{http_code}' "https://www.bitwig.com/dl/Bitwig%20Studio/${MAJOR}.${MINOR}%20Beta%20$((POINT+1))/installer_linux" | grep -q 200; do
			POINT=$((POINT+1))
		done
		RELATIVE_URL="dl/Bitwig%20Studio/${MAJOR}.${MINOR}%20Beta%20${POINT}/installer_linux"
	else
		echo "Finding version $1..." 1>&2
		RELATIVE_URL=dl/Bitwig%20Studio/$1/installer_linux
	fi
	FULL_URL=https://www.bitwig.com/$RELATIVE_URL
	curl -L --head -w '%{url_effective}' $FULL_URL 2>/dev/null | tail -n1
}

function download_bitwig()
{
	if [ $# -eq 0 ]; then
		DOWNLOAD_URL=$(get_download_url)
	else
		DOWNLOAD_URL=$(get_download_url $1)
	fi

	TARGET_PATH=rpmbuild/SOURCES
	FILENAME=$(basename $(echo $DOWNLOAD_URL | sed 's/?.*//'))
	VERSION=$(echo "$DOWNLOAD_URL" | grep -oP 'bitwig-studio-\K.*(?=\.deb)')
	
	echo -e "Downloading \e[1mBitwig Studio $(echo "${VERSION}\e[0m...\n${DOWNLOAD_URL}" | sed 's/?.*//')" 1>&2
	curl --create-dirs --output-dir $TARGET_PATH \
		--remote-name -C - $DOWNLOAD_URL

	echo $TARGET_PATH/$FILENAME
}

function rpm_basename()
{
	base=$(basename -s .deb $DEBIAN_PKG)
	fedora_release=$(cut -d ' ' -f 3 /etc/redhat-release)
	arch=$(uname -m)

	echo $base-1.fc$fedora_release.$arch.rpm
}

function check_if_already_built()
{
	rpm=$(rpm_basename)

	if [ -f $rpm ]; then
		echo RPM package already built 1>&2
		echo -n "Install using sudo dnf install " 1>&2
		echo $rpm
		exit 0
	fi
}

function extract_deb()
{
	echo Extracting $(basename $1)... 1>&2
	OUTPUT_DIRECTORY=rpmbuild/SOURCES
	rm -rf $OUTPUT_DIRECTORY/{*.xz,*.zst}
	mkdir -p $OUTPUT_DIRECTORY
	ar x --output $OUTPUT_DIRECTORY $1
}

function create_rpmspec()
{
	TARBALL_CONTROL=control.tar.xz
	TARBALL_DATA=data.tar.xz
	if [ ! -f $OUTPUT_DIRECTORY/$TARBALL_CONTROL ]; then
		TARBALL_CONTROL=control.tar.zst
		TARBALL_DATA=data.tar.zst
	fi

	CONTROL=$(mktemp)
	tar axf $OUTPUT_DIRECTORY/$TARBALL_CONTROL ./control -O > $CONTROL

	DEB_VERSION=$(grep '^Version:' $CONTROL | cut -d' ' -f2)
	VERSION_MAIN=$(echo "$DEB_VERSION" | cut -d'-' -f1)
	VERSION_SUFFIX=$(echo "$DEB_VERSION" | cut -d'-' -f2-)
	RELEASE=$(echo "$VERSION_SUFFIX" | tr '-' '_')

	echo "%global _topdir ./rpmbuild"
	echo "%global __brp_mangle_shebangs %{nil}"
	echo "%global __brp_check_rpaths %{nil}"
	echo "%global debug_package %{nil}"
	echo "%undefine _missing_build_ids_terminate_build"
	echo

	echo "Name:    bitwig-studio"
	echo "Version: $VERSION_MAIN"
	echo "Release: 0.$RELEASE%{?dist}"
	echo "Summary: Digital Audio Workstation"
	echo

	echo "License: Proprietary"
	echo "URL:   $(grep Homepage $CONTROL | sed 's/Homepage: //')"
	echo "Source0:  rpmbuild/SOURCES/$TARBALL_DATA"
	echo

	echo "%description"
	grep Descript -A1 $CONTROL | sed 's/Description: //'
	echo

	echo "%install"
	echo "mkdir -p %{buildroot}/"
	echo "tar axf %{SOURCE0} -C %{buildroot}"
	echo "find %{buildroot} -name '*.css' -exec chmod 0644 {} \;"
	echo "find %{buildroot} -name '*.html' -exec chmod 0644 {} \;"
	echo "find %{buildroot} -name '*.js' -exec chmod 0644 {} \;"
	echo "find %{buildroot} -name '*.nckk' -exec chmod 0644 {} \;"
	echo "find %{buildroot} -name '*.txt' -exec chmod 0644 {} \;"
	echo

	echo "%files"
	echo "/opt/bitwig-studio"
	LIST=$(tar tf rpmbuild/SOURCES/$TARBALL_DATA | grep /usr | sed s/^.//g)
	for x in $LIST; do
		[ ! -d $x ] && echo $x
	done

	rm $CONTROL
}

function build_rpm()
{
	echo "Building RPM..." 1>&2
	QA_RPATHS=$(( 0x0001|0x0002 )) rpmbuild --build-in-place -bb $SPEC &&
	RPM_FILE="$PWD/rpmbuild/RPMS/x86_64/"$(rpm_basename) &&
	mv $RPM_FILE "$PWD" &&
	echo 1>&2 &&
	echo RPM created. 1>&2 &&
	echo -n "Install using sudo dnf install " 1>&2 &&
	echo $(basename $RPM_FILE)
}

if [[ $1 =~ ".deb" ]]; then
	DEBIAN_PKG=$1
elif [ $# -eq 0 ]; then
	DEBIAN_PKG=$(download_bitwig)
elif [ "$1" == "--beta" ] || [[ $1 =~ [0-9]+\.[0-9]+\.[0-9]+ ]]; then
	DEBIAN_PKG=$(download_bitwig "$1")
fi

check_if_already_built $DEBIAN_PKG
extract_deb $DEBIAN_PKG
create_rpmspec $DEBIAN_PKG > $SPEC
build_rpm
