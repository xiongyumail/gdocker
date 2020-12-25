# gdocker

gdocker provides a basic docker environment to support X11 GUI.

1. Add gdocker to your project

```bash
git submodule add https://github.com/xiongyumail/gdocker.git
```

2. Create a new script to enable gdocker to install the tools you need

```bash
vim tools.sh
...
#sudo apt update
#sudo apt install -y xarclock
...
```

## Install

```bash
./gdocker/gdocker.sh install --help
./gdocker.sh install [-h --help] [-n name] [-v version] [-t tool]
  -h, --help            Show help
  -n, --name            image name
  -v, --version         image version
  -t, --tool            install tools
```

```bash
./gdocker/gdocker.sh install -n test -v 1.0.0 -t tools.sh 
```

## Start

```bash
./gdocker/gdocker.sh start --help
./gdocker.sh start [-h --help] [-n name] [-v version] [-u update] [-c command]
  -h, --help            Show help
  -n, --name            image name
  -v, --version         image version
  -u, --update          image update
  -c, --command         image start commad
```

```bash
./gdocker.sh start -n test -v 1.0.0 -c xarclock
```

## Clean

```bash
./gdocker/gdocker.sh clean --help
./gdocker.sh clean [-h --help] [-n name] [-v version]
  -h, --help            Show help
  -n, --name            image name
  -v, --version         image version
```

```bash
./gdocker.sh clean -n test -v 1.0.0
```