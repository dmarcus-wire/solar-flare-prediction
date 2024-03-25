#!/bin/bash

# USAGE '$ source ./cleanup.sh'
# UPDATE YOUR ENV NAME
ENV=solar-flare

echo "default conda env"
conda info | egrep "conda version|active environment"

echo "deactive conda env"
eval "$(conda shell.bash hook)"
conda deactivate

# wait for 5 seconds
sleep 5

echo "delete conda env"
conda env remove --name=$ENV -y

echo "default conda env"
conda info | egrep "conda version|active environment"