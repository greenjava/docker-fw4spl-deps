FROM ubuntu:14.04

# Might want to bust cache here if looking to upgrade the distribution
RUN apt-get update && apt-get upgrade -y

# Install build dependencies
RUN apt-get install -y curl \
                       make \
                       gcc \
                       clang \
                       python2.7 \
                       git \
                       perl \
                       build-essential \
                       python \
                       "^libxcb.*" \
                       libx11-xcb-dev \
                       libglu1-mesa-dev \
                       libxrender-dev \
                       libxi-dev \
                       libgstreamer1.0-dev \
                       libdbus-1-dev

RUN curl -sSL https://cmake.org/files/v3.4/cmake-3.4.3-Linux-x86_64.tar.gz | tar -xzC /opt

ENV CMAKE=/opt/cmake-3.4.3-Linux-x86_64/bin/cmake
ENV FW4SPL_BINPKG=/src/fw4spl/binpkg/
ENV FW4SPL_BINPKG_VERSION=0.10.2
ENV FW4SPL_BINPKG_BUILDTYPE=Release
ENV FW4SPL_BINPKG_ARCHIVE=/tmp/archive

# Create workspace
RUN bash -c "mkdir -p $FW4SPL_BINPKG/{Build,Src,Install}"

# Clone sources
RUN cd $FW4SPL_BINPKG/Src && git clone --depth=1 -b fw4spl_$FW4SPL_BINPKG_VERSION https://github.com/fw4spl-org/fw4spl-deps.git

WORKDIR $FW4SPL_BINPKG/Build
# Configure project
RUN $CMAKE $FW4SPL_BINPKG/Src/fw4spl-deps \
      -DARCHIVE_DIR=$FW4SPL_BINPKG_ARCHIVE \
      -DCMAKE_INSTALL_PREFIX=$FW4SPL_BINPKG/Install \
      -DCMAKE_BUILD_TYPE=$FW4SPL_BINPKG_BUILDTYPE

# Build dependencies; removes the downloads after each step in order to reduce snapshot size
# Note: build one item at a time to leverage cache. Archives can be copied in from the current directory
# if you want to avoid repeated downloads.

RUN make jpeg/fast && rm -f $FW4SPL_BINPKG_ARCHIVE/*
RUN make zlib/fast && rm -f $FW4SPL_BINPKG_ARCHIVE/*
RUN make tiff/fast && rm -f $FW4SPL_BINPKG_ARCHIVE/*
RUN make libpng/fast && rm -f $FW4SPL_BINPKG_ARCHIVE/*
RUN make libiconv/fast && rm -f $FW4SPL_BINPKG_ARCHIVE/*
RUN make libxml/fast && rm -f $FW4SPL_BINPKG_ARCHIVE/*
RUN make expat/fast && rm -f $FW4SPL_BINPKG_ARCHIVE/*
RUN make python/fast && rm -f $FW4SPL_BINPKG_ARCHIVE/*
RUN make boost/fast && rm -f $FW4SPL_BINPKG_ARCHIVE/*
RUN make freetype/fast && rm -f $FW4SPL_BINPKG_ARCHIVE/*
RUN make icu4c/fast && rm -f $FW4SPL_BINPKG_ARCHIVE/*

##############################################
# QT5 requirements                           #
# https://wiki.qt.io/Building_Qt_5_from_Git  #
##############################################
RUN apt-get update && apt-get -y build-dep qtbase5-dev

# Libxcb
RUN apt-get -y install --no-install-recommends \
    "^libxcb.*"                                \
    libx11-xcb-dev                             \
    libglu1-mesa-dev                           \
    libxrender-dev                             \
    libxi-dev

# Accessibility
RUN apt-get -y install --no-install-recommends \
    "libatspi2*"                               \
    libdbus-1-dev

# QT WebKit requirements
RUN apt-get -y install --no-install-recommends \
    flex                                       \
    bison                                      \
    gperf                                      \
    libicu-dev                                 \
    libxslt-dev                                \
    ruby               
    
# QT WebEngine requirements
RUN apt-get -y install --no-install-recommends \
    libssl-dev                                 \
    libxcursor-dev                             \
    libxcomposite-dev                          \
    libxdamage-dev                             \
    libxrandr-dev                              \
    libfontconfig1-dev                         \
    libcap-dev                                 \
    libbz2-dev                                 \
    libgcrypt11-dev                            \
    libpci-dev                                 \
    libnss3-dev                                \
    libxcursor-dev                             \
    libxcomposite-dev                          \
    libxdamage-dev                             \
    libxrandr-dev                              \
    libdrm-dev                                 \
    libfontconfig1-dev                         \
    libxtst-dev                                \
    libasound2-dev                             \
    libcups2-dev                               \
    libpulse-dev                               \
    libudev-dev                                \
    libssl-dev

# QT Multimedia
RUN apt-get -y install --no-install-recommends \
    libasound2-dev   \
    libgstreamer*    \
    gstreamer*       \
    && apt-get clean

RUN make qt/fast && rm -f $FW4SPL_BINPKG_ARCHIVE/*
RUN make vtk/fast && rm -f $FW4SPL_BINPKG_ARCHIVE/*
RUN make vxl/fast && rm -f $FW4SPL_BINPKG_ARCHIVE/*
RUN make gdcm/fast && rm -f $FW4SPL_BINPKG_ARCHIVE/*
RUN make itk/fast && rm -f $FW4SPL_BINPKG_ARCHIVE/*
RUN make camp/fast && rm -f $FW4SPL_BINPKG_ARCHIVE/*
RUN make cppunit/fast && rm -f $FW4SPL_BINPKG_ARCHIVE/*
RUN make ann/fast && rm -f $FW4SPL_BINPKG_ARCHIVE/*
RUN make dcmtk/fast && rm -f $FW4SPL_BINPKG_ARCHIVE/*
RUN make json-spirit/fast && rm -f $FW4SPL_BINPKG_ARCHIVE/*
RUN make glm/fast && rm -f $FW4SPL_BINPKG_ARCHIVE/*
RUN make jsoncpp/fast && rm -f $FW4SPL_BINPKG_ARCHIVE/*
RUN make cppunit/fast && rm -f $FW4SPL_BINPKG_ARCHIVE/*

CMD ["/bin/bash"]
