# truenas-upgrade-jails
Upgrade all jails from prior release

## Status

This script has be tested to  work with FreeNAS 11.3 upgrading to TrueNAS CORE 12.2.

## Usage

It will fetch the release matching the current truenas version.

Then it will upgrade each jail with a status of 'up' to that version.

If your jail is 'down' it will give an error msg and continue to the next jail in your system.

After you change the down jails to a status of up you can re run the script.

It will skip the jails that have already been upgraded and not fetch the current release if it has already done so.

**Does not work properly with plugins, must be a standard iocage jail**

## Installation

Download the repository to a convenient directory on your FreeNAS system by changing to that directory and running

`git clone https://github.com/NasKar2/truenas-upgrade-jails`.  Then change into the new truenas-upgrade-jails directory.

## Run

From the install directory run
`script upgrade.log ./upgrade.sh`

## Options

### test mode

Run with the argument test will do a test run and not fetch the current release or upgrade the jails

`script upgrade.log ./upgrade.sh test`

### exclude jails

Create a upgrade-config file with your favorite editor and add the variable SKIP_JAILS="plex sabnzbd"

```
SKIP_JAILS="plex sabnzbd"
```

## Disclaimer
It's your data. It's your responsibility. This resource is provided as a community service. Use it at your own risk.
