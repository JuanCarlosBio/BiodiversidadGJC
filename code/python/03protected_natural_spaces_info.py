#!/usr/bin/env python

import requests
from bs4 import BeautifulSoup 

r = requests.get("https://descargas.grancanaria.com/jardincanario/ESPACIOS%20NATURALES%20PROTEGIDOS%20DE%20GRAN%20CANARIA/")

soup = BeautifulSoup(r.content, 'html.parser')

links = soup.find_all('a')

for link in links:
    print(link.get('href'))