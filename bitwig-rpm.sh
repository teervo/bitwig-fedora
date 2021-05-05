#!/bin/bash
SPEC=bitwig-studio.spec

function get_download_url()
{
	echo "Determining latest stable version..." 1>&2
	RELATIVE_URL=$(curl --silent -L bitwig.com | grep -Eo 'dl[^"]*installer_linux')
	FULL_URL=https://www.bitwig.com/$RELATIVE_URL
	curl -L --head -w '%{url_effective}' $FULL_URL 2>/dev/null | tail -n1
}

# Returns the path to the downloaded archive
function download_bitwig()
{
	DOWNLOAD_URL=$(get_download_url)
	TARGET_PATH=rpmbuild/SOURCES/$(basename $DOWNLOAD_URL)

	echo "Downloading $(basename $TARGET_PATH)..." 1>&2
 	curl --create-dirs --output $TARGET_PATH -C - $DOWNLOAD_URL

	echo $TARGET_PATH
}

# Checks if the downloaded Debian package has already been converted to RPM
# Arguments: $1: path to debian package
function check_if_already_built()
{
    base=$(basename -s .deb $1)
    fedora_release=$(cut -d ' ' -f 3 /etc/redhat-release)
    arch=$(uname -m)
    rpm=$base-1.fc$fedora_release.$arch.rpm

    if [ -f $rpm ]; then
        echo RPM package already built
   		echo Install using sudo dnf install $rpm
        exit 0
    fi
}

# Arguments: $1: path to debian package
function extract_deb()
{
    echo Extracting $(basename $1)...
    OUTPUT_DIRECTORY=rpmbuild/SOURCES
    mkdir -p $OUTPUT_DIRECTORY
    ar x --output $OUTPUT_DIRECTORY $1
}

function create_rpmspec()
{
	CONTROL=$(mktemp)
    tar xJf $OUTPUT_DIRECTORY/control.tar.xz ./control -O > $CONTROL

	echo "%global _topdir $PWD/rpmbuild"
	echo "%global __brp_mangle_shebangs %{nil}"
	echo

	echo "Name:    bitwig-studio"
	grep Version $CONTROL
	echo "Release: 1%{?dist}"
	echo "Summary: Digital Audio Workstation"
	echo

	echo "License: Proprietary"
	echo "URL:   $(grep Homepage $CONTROL | sed 's/Homepage: //')"
	echo "SOURCE:  rpmbuild/SOURCES/data.tar.xz"
	echo

	echo "%description"
	grep Descript -A1 $CONTROL | sed 's/Description: //'
	echo

	echo "%install"
	echo "tar xJf %{SOURCE0} -C %{buildroot}"
	echo "find %{buildroot} -name '*.css' -exec chmod 0644 {} \;"
	echo "find %{buildroot} -name '*.html' -exec chmod 0644 {} \;"
	echo "find %{buildroot} -name '*.js' -exec chmod 0644 {} \;"
	echo "find %{buildroot} -name '*.nckk' -exec chmod 0644 {} \;"
	echo "find %{buildroot} -name '*.txt' -exec chmod 0644 {} \;"
	echo

	echo "%files"
	echo /opt/bitwig-studio
    LIST=$(tar tf rpmbuild/SOURCES/data.tar.xz | grep /usr | sed s/^.//g)
    for x in $LIST; do # Filter existing system directories
        [ ! -d $x ] && echo $x;
    done

	rm $CONTROL
}

function build_rpm()
{
	echo "Building RPM..."
	QA_RPATHS=$(( 0x0001|0x0002 )) \
		rpmbuild --buildroot $PWD/build -bb $SPEC &&
	RPM_FILE=rpmbuild/RPMS/x86_64/*rpm &&
	mv $RPM_FILE $PWD &&
	echo &&
	echo RPM created. &&
	echo Install using sudo dnf install $(basename $RPM_FILE)
}

DEBIAN_PKG=$(download_bitwig)
check_if_already_built $DEBIAN_PKG
extract_deb $DEBIAN_PKG
create_rpmspec $DEBIAN_PKG > $SPEC
build_rpm
