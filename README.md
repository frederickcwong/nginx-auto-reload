# Notes to Self

- built this because I am running cert renewal as a separate docker image
  (not using certbot integration with nginx)
- certbot with route53 is running as a separate docker image which updates
  the cert independent to the nginx
- need the nginx to reload when the cert is updated
- build.sh command is to build the image manually and push to docker

### Nginx with Auto-reload Monitor

- if certificates are renewed, nginx needs to be reloaded in order to serve
  new certificates (using command `nginx -s reload`)
- nginx uses `CMD ["nginx", "-g", "daemon off;"]` in the docker build. Shell
  script `/inotify-monitor/cmd.sh` is created to launch the monitor in the
  background, then run the nginx process
  - why use `exec` to run nginx process? Docker always monitor the `PID:1`
    where in this case, is the shell script `cmd.sh`. All signals will be
    sent to the script as well. Using `exec` will replace the content of the
    process from the shell script to the nginx process that are now running
    in the foreground using the "daemon off;" directive. The nginx process
    will now be monitored by docker, and receives all signals send by docker.
- a background process `/inotify-monitor/nginx-reloader.sh` is spawned
  to monitor changes to the certificates, and reload nginx after 30 seconds
  - why monitoring `/etc/letsencrypt/archive` directory? It is the directory
    where new certificates are stored with the existing one
  - why wait for 30 seconds? There are a number of files will be created by
    certbot during the renewal process. This is to make sure that we wait
    until all files are created before reloading nginx. The wait time should
    be longer if there are multiple site certificates could be renewed at the
    same time.
- Note that the background process `nginx-reloader.sh` is not monitored by
  docker and if it dies or encountering errors, we can only see it via
  docker logs, but that is better than nginx panic and docker does not know
  about it

### Note on Nginx Daemon on/off

- running `/usr/sbin/nginx` will spawn the master process and some workers, then exits
- the master process and workers will continue running as background processes and provide services
- when daemon mode is turned off using `/usr/sbin/nginx -g "daemon off;"`, the `nginx` process does not exit unless it is terminated explicitly
- this was intented to facilitate the internal development by nginx's engineers
- in docker environment, nginx image uses daemon off by default: `CMD: ["nginx", "-g", "daemon off;"]`
- this is because if daemon off is not given, the nginx command will exit, and docker will halt the container (no active foreground process is running in the container)
- hence the `daemon off;` is used to ensure nginx container will be running continuously
