export version=0.1; for e in js css; do wget "https://github.com/danse/tornado/raw/${version}/tornado.$e" -O data/tornado.${e}; done
