#!/usr/bin/env bash

#link="https://drive.google.com/file/d/-/view?usp=sharing"
link="https://drive.google.com/uc?export=download&id=1CjFJabXYeJl_bThrHcECo3qvevEwYIr-"

wget -P data/ -O data/temp.zip $link -q ; unzip data/temp.zip -d data/

mkdir -p data/protected_species

mv data/results/* data/protected_species/ ; rmdir data/results ; rm data/temp.zip