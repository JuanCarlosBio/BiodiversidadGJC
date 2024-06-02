#!/usr/bin/env bash

fv="https://www.dropbox.com/scl/fo/z9ad8tcbh02d2zy7g7xf0/h?rlkey=yvu3gii63sfvpicsgplvbty88&dl=0"
ai="https://www.dropbox.com/scl/fo/j8wy15nzlrpn98dkpsu6e/h?rlkey=27la6qjalew06kc9wy3cgundv&dl=0"

wget -P images/ -O images/flora_vascular.zip $fv -N -q
wget -P images/ -O images/invertebrados.zip $ai -N -q 