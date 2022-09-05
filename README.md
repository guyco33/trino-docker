# trino-docker

##### Create `.env` file in the project root directory:
```
TRINO_VERSION=394
COORDINATOR_IS_WORKER=true
HADOOP_VERSION=3.1.2
HIVE_VERSION=3.1.2
```

##### Optionaly add AWS keys to access s3 bucket 
```
AWS_ACCESS_KEY_ID=<your access key>
AWS_SECRET_ACCESS_KEY=<your secret key>
```

##### Build images:
- `docker-compose build coordinator hms-thrift`

##### Run containers:
- `docker-compose up -d coordinator hms-thrift`
- (optionally run additional worker) `docker-compose up -d worker`
