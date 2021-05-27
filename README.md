# bitwig-fedora
Downloads the latest Bitwig Studio and creates an RPM for it

Only depends on rpm-build, not on Debian tools.

To create the RPM package for the latest stable release, run
```
$ ./bitwig-rpm.sh
Determining latest stable version...
Downloading bitwig-studio-3.3.7.deb...
[...]
RPM created.
Install using sudo dnf install bitwig-studio-3.3.7-1.fc34.x86_64.rpm
```

If you already have downloaded the .deb package (e.g. for a beta pre-release), supply the path as the first argument:
```
$ ./bitwig.rpm.sh ~/Downloads/bitwig-studio-4.0beta1.deb
Extracting bitwig-studio-4.0beta1.deb...
Building RPM...
[...]
RPM created.
Install using sudo dnf install bitwig-studio-4.0beta1-1.fc34.x86_64.rpm
```
