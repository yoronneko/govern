# govern
Linux process governor: a simple shell script to manage multiple processes

## What govern.sh is

This shell script manages multiple processes defined in the configuration files located at ``~/local/*.conf.sh``. The shell script has released as an open source software and is publicly accessible on GitHub.

This govern.sh script can be executed from ether an interactive shell or through a cron job. Here's how you would initiate it from a cron job:

```sh
$ crontab -e
@reboot cd /home/pi/bin; ./govern.sh start
```

## Repository Overview for New Contributors

### Structure
- **`govern.sh`** – central Bash script that starts, stops, and checks the status of processes.
- **`local/*.conf.sh`** – configuration files describing each process via `CMD`, `ARGS`, and `MARK`.
- **`README.md`** – documentation including usage, testing, and licensing information.

### Important Notes
- `govern.sh` expects the `~/local` directory to exist and exits if it is missing.
- Run `govern.sh start` to launch all processes, `stop` to halt them, and `status` or no argument to view their state.
- Arguments containing spaces cannot be passed as a single string through environment variables; consider quoting or extending the script when needed.

### Suggested Next Steps
1. Study `local/sample.conf.sh` and create your own configuration, ensuring the `MARK` uniquely identifies each process.
2. Trace functions such as `get_pid` and `do_cmd` in `govern.sh` to understand how process management works.
3. Explore ways to handle arguments with spaces—advanced quoting techniques or script enhancements may be required.
4. Try automating execution, for example with a `cron` entry using `@reboot`.

## Usage

To initiate all processes specified in the ``~/local/`` directory, enter ``govern.sh start``. The name and process ID (PID) of each process will be displayed.

To terminate all processes, type ``govern.sh stop``.

To view the status of processes, type ``govern.sh status``. Alternatively, you can simply enter ``govern.sh`` to list status and PID of all processes, as show below:
```sh
pi@rpi3b:~ $ govern.sh
clas.conf.sh running at pid 30185
f9p.conf.sh running at pid 2879
lora.conf.sh running at pid 450
madoca.conf.sh running at pid 455
sf9p.conf.sh running at pid 2897
pi@rpi3b:~ $
```

If you want to start, stop, or display a specific process, for example, use ``govern.sh sample.conf.sh start`` to initiate the process defined in sample.conf.sh.

The configuration file necessitates the definition of environment variables of CMD, ARGS, and MARK. ARGS must be declared using Bash array syntax (`ARGS=(...)`) so that each parameter is passed separately. Because this syntax is specific to Bash, both `govern.sh` and its configuration files must be executed with Bash; POSIX `sh` does not support arrays. This approach allows arguments containing spaces to be quoted individually. For example:

```bash
MARK="serial://ttyF9P:230400"
CMD=$HOME/exec/str2str
ARGS=(-in "$MARK" -a "JAVGRANT_G5T NONE" -out "tcpsvr://:$LPORT" -b 1)
```
Here `ARGS` is a Bash array, so ensure you invoke the script with Bash rather than `sh`.

When this configuration is loaded, ``govern.sh`` executes ``$CMD" "${ARGS[@]}``, ensuring that ``JAVGRANT_G5T NONE`` is treated as a single argument. For further details, please refer to ``local/sample.conf.sh``.

## Testing

Run the test suite with [Bats](https://github.com/bats-core/bats-core):

```sh
bats tests/
```

## License

govern.sh is released under 2-Cluse BSD License.  
Copyright (c) 2023 Satoshi Takahashi, all rights reserved.
