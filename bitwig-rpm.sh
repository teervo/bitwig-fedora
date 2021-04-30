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
	DEBIAN_PKG=rpmbuild/SOURCES/$(basename $DOWNLOAD_URL)

	echo "Downloading $(basename $DEBIAN_PKG)..." 1>&2
	if [ ! -f $DEBIAN_PKG ] ; then
	    curl --create-dirs --output $DEBIAN_PKG $DOWNLOAD_URL
	fi

	echo $DEBIAN_PKG
}

# Arguments: $1: path to debian package
function extract_deb()
{
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
    tar tf rpmbuild/SOURCES/data.tar.xz | sed s/^.// | sed 's/.*/"\0"/g'

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
extract_deb $DEBIAN_PKG
create_rpmspec $DEBIAN_PKG > $SPEC
build_rpm
