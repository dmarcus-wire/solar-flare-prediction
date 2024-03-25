#!/bin/bash

# USAGE '$ source ./setup.sh'
# UPDATE YOUR ENV NAME AND VERSION
ENV=solar-flare
VERS=3.12

# install miniconda
mkdir -p ~/miniconda3
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/miniconda3/miniconda.sh
bash ~/miniconda3/miniconda.sh -b -u -p ~/miniconda3
rm -rf ~/miniconda3/miniconda.sh

# initialize newly-installed Miniconda
~/miniconda3/bin/conda init bash
~/miniconda3/bin/conda init zsh

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