#!/bin/bash

DIR="/backup/$(date -I)"
mkdir -p ${DIR}
cd ${DIR}
mongodump ${MONGODB}

