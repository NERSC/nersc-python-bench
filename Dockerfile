
FROM ubuntu:16.04
MAINTAINER Rollin Thomas

# Update and install prerequisites

RUN                                 \
    apt-get update              &&  \
    apt-get install -y              \
        build-essential             \
        gfortran                    \
        python                      \
        python-pip                  \
        python-mysqldb              \
        zlib1g-dev

# Install python packages

RUN                                                                         \
    pip install astropy

# Install MPICH

ADD http://www.mpich.org/static/downloads/3.2/mpich-3.2.tar.gz              \
    /usr/local/src/

RUN                                                                         \
    cd /usr/local/src                                                   &&  \
    tar xf mpich-3.2.tar.gz                                             &&  \
    cd mpich-3.2                                                        &&  \
    ./configure                                                         &&  \
    make -j 2                                                           &&  \
    make install                                                        &&  \
    cd /usr/local/src                                                   &&  \
    rm -rf mpich-3.2

# Install mpi4py

ADD https://bitbucket.org/mpi4py/mpi4py/downloads/mpi4py-2.0.0.tar.gz       \
    /usr/local/src/

RUN                                                                         \
    cd /usr/local/src                                                   &&  \
    tar zxf mpi4py-2.0.0.tar.gz                                         &&  \
    cd mpi4py-2.0.0                                                     &&  \
    python setup.py build                                               &&  \
    python setup.py install                                             &&  \
    cd /usr/local/src                                                   &&  \
    rm -rf mpi4py-2.0.0

# Install mpi4py-import benchmark script and benchmark script

ADD scripts/mpi4py-import.py /usr/local/bin
RUN chmod a+x /usr/local/bin/mpi4py-import.py

ADD scripts/report-benchmark.py /usr/local/bin
RUN chmod a+x /usr/local/bin/report-benchmark.py

# Confine astropy cache and config to container.

ENV XDG_CACHE_HOME=/srv/cache
RUN mkdir -p $XDG_CACHE_HOME/astropy

ENV XDG_CONFIG_HOME=/srv/config
RUN mkdir -p $XDG_CONFIG_HOME/astropy

RUN python -c "import astropy"

# Install pynamic v1.3

ADD https://github.com/LLNL/pynamic/archive/1.3.tar.gz                      \
    /opt

RUN                                                                         \
    cd /opt                                                             &&  \
    tar zxf 1.3.tar.gz                                                  &&  \
    cd pynamic-1.3/pynamic-pyMPI-2.6a1                                  &&  \
    python ./config_pynamic.py 495 1850 -e -u 215 1850 -n 100 -t ; exit 0

