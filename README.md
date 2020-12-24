# gdocker

gdocker provides a basic docker environment to support X11 GUI.

git clone https://github.com/xiongyumail/gdocker.git

## Install

```bash
./gdocker.sh install [-h --help] [-n name] [-v version] [-t tool]
  -h, --help            Show help
  -n, --name            image name
  -v, --version         image version
  -t, --tool            install tools(must)
```

```bash
./gdocker.sh install -n test -v 1.0.0 -t ../tool.sh 
```

## Start

```bash
./gdocker.sh start [-h --help] [-n name] [-v version] [-c command]
  -h, --help            Show help
  -n, --name            image name
  -v, --version         image version
  -c, --command         image start commad
```

```bash
./gdocker.sh start -n test -v 1.0.0 -c bash
```

## Clean

```bash
./gdocker.sh clean [-h --help] [-n name] [-v version]
  -h, --help            Show help
  -n, --name            image name
  -v, --version         image version
```

```bash
./gdocker.sh clean -n test -v 1.0.0
```