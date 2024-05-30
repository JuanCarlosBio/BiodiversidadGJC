#!/usr/bin/env bash

url_jardin_botanico="https://www.dropbox.com/scl/fi/ch7k8u3zyetx2nf1a8akp/jardin_botanico.kml?rlkey=azea65bdxdqjitcs6pby62rxs&dl=1"

wget -P data/jardin_botanico -O data/jardin_botanico.kml $url_jardin_botanico -N  
