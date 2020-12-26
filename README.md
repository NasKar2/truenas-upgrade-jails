# truenas-upgrade-jails
Upgrade all jails from prior release or Update and Upgrade all jails

## Status

This script has be tested to  work with FreeNAS 11.3 upgrading to TrueNAS CORE 12.2.

## Usage

You will get a menu with 4 options

Output will be in Green if script is making a change, Yellow for information, Red if needs user input and Cyan if test mode.

**Does not work properly with plugins, must be a standard iocage jail**

### Option 1

Upgrade Jail Release : Will fetch the latest release matching the current truenas version if it doesn't already exist.  

Then it will upgrade each jail with a status of 'up' to that version.

If your jail is 'down' it will give an error msg and continue to the next jail in your system.

After you change the down jails to a status of up you can re run the script.

It will skip the jails that have already been upgraded and not fetch the current release if it has already done so.

### Option 2

Update && Upgrade : Will upgrade the software in all jails with the `pkg update && pkg upgrade` command

### Option 3

Test Release Upgrade : Will run Option 1 in a test mode so you can see what it will do to your current iocage jails

Output will be in cyan to indicate test mode.

### Option 4

Quit : Will exit the script

## Installation

Download the repository to a convenient directory on your FreeNAS system by changing to that directory and running

`git clone https://github.com/NasKar2/truenas-upgrade-jails`.  Then change into the new truenas-upgrade-jails directory.

## Run

From the install directory run
`script upgrade.log ./upgrade.sh`

## Exclude Jails

Create a upgrade-config file with your favorite editor and add the variable SKIP_JAILS="plex sabnzbd"

This will skip the jails named plex and sabnzbd.

```
SKIP_JAILS="plex sabnzbd"
```

## Disclaimer
It's your data. It's your responsibility. This resource is provided as a community service. Use it at your own risk.
