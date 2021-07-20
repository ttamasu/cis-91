# Simple Backup Server

This Python program creates a tar file from a chosen path and copies it to a GCS bucket. It's a helper for CIS-91

## Installation 

To install the program executables use `pip` from this directory: 

```
$ sudo pip install . 
``` 

Copy the systemd service file and reload systemd:

```
sudo cp backup-server.service /etc/systemd/system
sudo systemctl daemon-reload 
```

Enable and start the service: 

```
sudo systemctl enable backup-server 
sudo systemctl start backup-server 
```

Check that it's started: 

```
sudo systemctl status backup-server
```

## Testing 

You can use `curl` to test the service: 

```
curl --header "Content-Type: application/json" --data '{"source": "/var/www/html", "target": "your-bucket-id"}'  localhost:5000/backup
```