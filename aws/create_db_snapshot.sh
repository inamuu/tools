#!/bin/bash

CLUSTER_LIST=''

for i in ${CLUSTER_LIST};do
  echo "create db snapshot: $i\n---"
  sleep 1
  aws rds create-db-cluster-snapshot \
    --db-cluster-identifier ${i} \
    --db-cluster-snapshot-identifier ${i}-$(date +%Y%m%d%H%M)
done

