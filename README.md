Run with the ***PASS*** environment variable set to 6 or more characters to set the VNC password else it will default to ***armitage***.

The VNC server port is 59000.

From Docker Index
```
docker pull usertaken/armitage-vnc
```

Build Yourself
```
docker build --rm -t usertaken/armitage-vnc github.com/UserTaken/docker-armitage-vnc
```

Run Example
```
docker run -d --net host usertaken/armitage-vnc
```
