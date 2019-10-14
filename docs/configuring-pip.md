# Configuring pip
In order to download internal VIAA packages it's necessary to add the correct URLs to your pip configuration. You do so by adding the following code block in your pip-config. The repository is a group that contains both a proxy to the original PyPI and the internal PyPI, this means that both internal and external packages can be installed using the repository.

```ini
[global]
index = http://do-prd-mvn-01.do.viaa.be:8081/repository/pypi-all/pypi
index-url = http://do-prd-mvn-01.do.viaa.be:8081/repository/pypi-all/simple
trusted-host = do-prd-mvn-01.do.viaa.be
```

The following section is a slightly edited version of [the official pip documentation](https://pip.pypa.io/en/latest/user_guide/#configuration).

The names and locations of the configuration files vary slightly across platforms. You may have per-user, per-virtualenv or site-wide (shared amongst all users) configuration:

## Per-user:

- On Unix the default configuration file is: `$HOME/.config/pip/pip.conf` which respects the `XDG_CONFIG_HOME` environment variable.
- On macOS the configuration file is `$HOME/Library/Application Support/pip/pip.conf` if directory `$HOME/Library/Application Support/pip` exists else `$HOME/.config/pip/pip.conf`.
- On Windows the configuration file is `%APPDATA%\pip\pip.ini`.

You can set a custom path location for this config file using the environment variable `PIP_CONFIG_FILE`.

## Inside a virtualenv:

- On Unix and macOS the file is `$VIRTUAL_ENV/pip.conf`
- On Windows the file is: `%VIRTUAL_ENV%\pip.ini`

## Site-wide:

- On Unix the file may be located in `/etc/pip.conf`. Alternatively it may be in a “pip” subdirectory of any of the paths set in the environment variable XDG_CONFIG_DIRS (if it exists), for example /etc/xdg/pip/pip.conf.
- On macOS the file is: `/Library/Application Support/pip/pip.conf`
- On Windows the is: `C:\ProgramData\pip\pip.ini`

If multiple configuration files are found by pip then they are combined in the following order:

- The site-wide file is read
- The per-user file is read
- The virtualenv-specific file is read

Each file read overrides any values read from previous files, so if the global timeout is specified in both the site-wide file and the per-user file then the latter value will be used.
