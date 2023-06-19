# govern
Linux process governer: a simple shell script to manage multiple processes

## What govern.sh is

This shell script executes multiple processes specified in ``~/local/`` directory as a Linux user. We can start multple processes described in the configuration files in ``~/local/*.conf.sh`` by using cron command.

```sh
$ crontab -e
@reboot cd /home/pi/bin; ./govern.sh start
```

## Usage

To start all processes listed in ``~/local/`` directory, type ``govern.sh start`` and the process name as well as process ID (PID) is shown.

To stop the all processes, type ``govern.sh stop``.

To show process status, type ``govern.sh status`` or simply ``govern.sh`` to list status of all processes with PID like:
```sh
pi@rpi3b:~ $ govern.sh
clas.conf.sh running at pid 30185
f9p.conf.sh running at pid 2879
lora.conf.sh running at pid 450
madoca.conf.sh running at pid 455
sf9p.conf.sh running at pid 2897
pi@rpi3b:~ $
```

To start, stop, or show a specific process, say, type ``govern.sh sample.conf.sh start`` to start a process described in sample.conf.sh.

The configration file requires setting the environmental variables of CMD, ARGS, and MARK. Please see ``local/sample.conf.sh`` for more details.

## License

govern.sh is released under 2-Cluse BSD License.  
Copyright (c) 2023 Satoshi Takahashi, all rights reserved.
