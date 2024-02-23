VERSION="4.1.1"

cd /tmp
wget https://github.com/mozilla/mozjpeg/archive/refs/tags/v${VERSION}.tar.gz -O mozjpeg.tar.gz
tar xvzf mozjpeg.tar.gz
cd mozjpeg-${VERSION}
mkdir build
cd build
sudo cmake -G"Unix Makefiles" -DPNG_SUPPORTED=OFF ../
make install 
make deb
sudo dpkg -i mozjpeg_*.deb
sudo ln -s /opt/mozjpeg/bin/cjpeg /usr/bin/cjpeg
sudo ln -s /opt/mozjpeg/bin/jpegtran /usr/bin/jpegtran
