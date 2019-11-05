# presto-docker

##### Create `.env` file in the project root directory:
```
COMPOSE_PROJECT_NAME=presto
PRESTO_VERSION=324
COORDINATOR_IS_WORKER=true
```

##### Optionaly add AWS keys to access s3 bucket 
```
AWS_ACCESS_KEY_ID=<your access key>
AWS_SECRET_ACCESS_KEY=<your secret key>
```

##### Build images:
- `docker-compose build`
- Optional build for additional worker: `docker-compose -f docker-compose.yml -f worker.yml build`
- Optional build for coordinator not acting as worker: `COORDINATOR_IS_WORKER=false docker-compose -f docker-compose.yml -f worker.yml build`

##### Run containers:
- `docker-compose up -d`
- Optional run for additional worker: `docker-compose -f docker-compose.yml -f worker.yml up`
- Optional run for adding more workers: `docker-compose -f worker.yml up`
