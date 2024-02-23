#!/bin/sh
mkdir build
cd build
sudo cmake -G"Unix Makefiles" -DPNG_SUPPORTED=OFF ../
make install 
make deb
sudo dpkg -i mozjpeg_*.deb
sudo ln -s /opt/mozjpeg/bin/cjpeg /usr/bin/cjpeg
sudo ln -s /opt/mozjpeg/bin/jpegtran /usr/bin/jpegtran
