#!/usr/bin/env bash

dropbox_link="https://www.dropbox.com/scl/fo/2u4u07trn78t5zsgyw1e0/AAiwqZX3REF4n9TzQoqIUZo?rlkey=klgoza8195zajrt2udewzcwvu&st=udp7531k&dl=1"

wget -P data/ -O data/protected_species.zip $dropbox_link -N -q
unzip data/protected_species.zip -d data/protected_species ; rm data/protected_species.zip
