![showcase](https://github.com/user-attachments/assets/af930e0a-a710-4c26-828e-6daea7854654)

## installation:

To auto-install the latest stable version, run the one command below in terminal:
```sh
curl -s https://raw.githubusercontent.com/teervo/bitwig-fedora/main/bitwig-rpm.sh | bash -s --
```

Otherwise, to store & install locally:
```sh
wget https://raw.githubusercontent.com/teervo/bitwig-fedora/main/bitwig-rpm.sh &&
chmod +x bitwig-rpm.sh && ./bitwig-rpm.sh
```

#### optional flags:

Add the suffixes below at the very end of the commands above.

For example, to install:
- the latest beta: `.../teervo/bitwig-fedora/main/bitwig-rpm.sh | bash -- --beta`
- an existing .deb package: `./bitwig-rpm.sh ~/Downloads/bitwig-studio-6.0.11.deb`
- an older version: `./bitwig-rpm.sh 5.1.1`

### aliases:

You can manage easier future installations via aliases in `.bashrc`.

Install straight from the latest Github update, run in Terminal:
```sh
echo 'alias bitwig-update="curl -s https://raw.githubusercontent.com/teervo/bitwig-fedora/main/bitwig-rpm.sh | bash -s --"' >> $HOME/.bashrc
```
Install from a locally stored download (edit the file path), run in Terminal:
```sh
echo 'alias bitwig-update="/path/to/bitwig-rpm.sh"' >> $HOME/.bashrc
```

And then simply use as (for example):
```sh
user@linux:~$ bitwig-update --beta
```

