# Dockerfile for [Cloudlog](http://www.cloudlog.co.uk)

Take note, the docker-compose script is an example script for running this on localhost.

If you want to use this in production you need to use this behind an ssl enabled proxy (like [docker-letsencrypt-nginx-proxy-companion](https://github.com/JrCs/docker-letsencrypt-nginx-proxy-companion))
and remove the port from the compose file.

## running
### docker-compose
Copy docker.app.sample.env to docker.app.env and edit where needed
Like `WEB_BASE_URL`

Copy docker.db.sample.env to docker.db.env
and change the passwords before running the first time, 
to make sure your setup is secure.

make the storage directory:

`mkdir -p storage/{backup,logs,updates,uploads}`

to start: `docker-compose up -d`
