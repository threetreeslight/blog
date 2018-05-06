# Blog


## Getting started

```
# To work enable assets link via docker
export DOCKER_HOST_IP=$(echo $DOCKER_HOST | sed 's/tcp:\/\///g' | sed 's/:.*//g')

$ docker-compose build
$ docker-compose up blog
```


## Deploy

```
hugo
gsutil rsync -r ./public gs://blog.threetreeslight.com
gsutil acl ch -r -u AllUsers:R gs://blog.threetreeslight.com/
```

