# System Repo
My collection of utilities used on servers.

## Bin
Scripts and binaries that can be used in PATH for making life easier.

## Lib
All libaries("modules") that can be used for creating your system utility scripts like backups and etc.

### Script.sh
The base library of each script. Containing several useful functions.

##### load {LIB_NAME}
Loads a library from the lib folder.
```bash
load "use-env"
```

##### is_root
Will check if the executing user is a root user.
```bash
is_root
```

##### rid
Generates a random string with 8 characters on default.
```bash
RANDOM_SIZE=8 # Default in script.sh. Add to script to override

MY_ID=$(rid)
```

##### tz
Spits out the current timestamp based on the `DATE_FORMAT`
```bash
BACKUP_TIME=$(tz)
```

## Scripts
All the scripts are assumed to be living in the root directory of the repository. Therefore you could also fork this repo to add your own scripts. If you want scripts not to be public(added to repo), prefix them with `private-`.