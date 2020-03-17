update-slack-status
===================

Bash script to update slack status based on network info

Usage
-----

First you need to open it in your favorite editor and replace the configuration variables with your own values.

### Launch manually
Simply running `./update-slack-status.sh`

### Launch on startup
run `crontab -e` and at the end of the crontab file add a line like this:

`@reboot ( sleep 30 ; sh /location/update-slack-status.sh )`

### Launch on network connection
```bash
sudo cp update-slack-status.sh /etc/network/if-up.d
sudo chown root:root /etc/network/if-up.d/update-slack-status.sh
sudo chmod 755 /etc/network/if-up.d/update-slack-status.sh
```

Improvements
------------
Possible future improvements

* Change status based on current country (using geoip?)
* Change status for ethernet only connections (using mac address of gateway?)
