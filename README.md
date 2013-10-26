# DNSimple Updater

A simple node.js app to check if your IP is up to date and change the appropriate records with DNSimple if it's not.

## Usage

1. Copy config.example.json to config.json and add your current IP address and records you'd like to update.
2. Run `npm install` to get `request` working.
3. Set appropriate paths for your apps in dnsimplecron.plist and feed the file to launchctl.

## Requires

* coffeescript
* node
* npm
* dnsimple
* relies on icanhazip.com
* osx (for launchctl)
