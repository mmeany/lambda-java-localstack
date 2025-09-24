

```shell
pushd /e/docker/localstack-v4/ > /dev/null
docker-compose down -v

docker-compose up -d

popd > /dev/null

./gradlew clean build

cd scripts/

./create-role.sh localstack
./deploy-zip.sh localstack json-processor
./invoke.sh localstack ./simple-payload.json  json-processor
./view-logs.sh localstack json-processor 
```
