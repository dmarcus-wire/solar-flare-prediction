#!/bin/bash

# USAGE '$ source ./setup.sh'
# UPDATE YOUR ENV NAME AND VERSION
ENV=solar-flare
VERS=3.12

echo "update conda"
conda update -n base -c defaults conda -y

echo "check if conda $ENV exists"
if conda env list | grep -q "\b$ENV/b";then
    echo "conda environment $ENV already exists"
else
    "create the conda environment $ENV"
    conda create -n $ENV python=$VERS -y
fi

echo "activate the virtual env"
eval "$(conda shell.bash hook)"
conda activate $ENV

echo "install packages from conda-forge"
conda install -c conda-forge jupyterlab matplotlib opencv boto3 -y

echo "match the python version"
python -m ipykernel install --user --name=$ENV

echo "default conda env"
conda info | egrep "conda version|active environment"