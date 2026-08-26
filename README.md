> [!IMPORTANT]
> <b>[teervo](https://github.com/teervo) (the original author) transferred ownership to me, therefore development will continue here. Thank you!</b>

----

![showcase](https://github.com/user-attachments/assets/af930e0a-a710-4c26-828e-6daea7854654)

#### auto-installation:
```sh
curl -s https://raw.githubusercontent.com/yioannides/bitwig-fedora/main/bitwig-rpm.sh | bash -s --
```
#### manual installation:
```sh
wget https://raw.githubusercontent.com/yioannides/bitwig-fedora/main/bitwig-rpm.sh &&
chmod +x bitwig-rpm.sh && ./bitwig-rpm.sh
```

> [!NOTE]
> The script always defaults to the <b>latest stable version</b>.

#### optional arguments:

Both installation methods accept additional arguments at the end, for example:
- the latest beta: `.../yioannides/bitwig-fedora/main/bitwig-rpm.sh | bash -s -- --beta`
- an existing .deb package: `./bitwig-rpm.sh ~/Downloads/bitwig-studio-6.0.11.deb`
- an older version: `./bitwig-rpm.sh 5.1.1`

#### aliases:

You can manage easier future installations via aliases in `.bashrc` by running the commands below only once:

##### alias for auto-installation:
```sh
echo 'alias bitwig-update="curl -s https://raw.githubusercontent.com/yioannides/bitwig-fedora/main/bitwig-rpm.sh | bash -s --"' >> $HOME/.bashrc
```
##### alias for manual installation (change the script's path!):
```sh
echo 'alias bitwig-update="/path/to/bitwig-rpm.sh"' >> $HOME/.bashrc
```

Then simply use as:
```sh
user@linux:~$ bitwig-update
```
<sup>NOTE: Optional arguments still work with aliases!

#### acknowledgements:

[teervo](https://github.com/teervo): author of the original script / repo
