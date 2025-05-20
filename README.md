# bitwig-fedora
Downloads the latest Bitwig Studio and creates an RPM for it.

Only depends on rpm-build, not on Debian tools.

Bitwig depends on the v8 implementation of JPEG, i.e. libjpeg.so.8. The
implementation shipping with Fedora is v6, so you need to first enable an additional COPR repository by running
```
$ sudo dnf copr enable aflyhorse/libjpeg
```

To create the RPM package for the latest stable release, run
```
$ ./bitwig-rpm.sh
Determining latest stable version...
Downloading bitwig-studio-4.4.8.deb...
[...]
RPM created.
Install using sudo dnf install bitwig-studio-4.4.8-1.fc37.x86_64.rpm
```

If you already have downloaded the .deb package (e.g. for a beta pre-release), supply the path as the first argument:
```
$ ./bitwig-rpm.sh ~/Downloads/bitwig-studio-9.1beta1.deb
Extracting bitwig-studio-9.1beta1.deb...
Building RPM...
[...]
RPM created.
Install using sudo dnf install bitwig-studio-9.1beta1-1.fc62.x86_64.rpm
```
