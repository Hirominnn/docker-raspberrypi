FROM balenalib/raspberrypi3-ubuntu:xenial
# FROM balenalib/raspberrypi3-ubuntu:xenial-20191011
ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    cmake \
    git \
    libssl-dev \
    wget

# install pyenv
RUN git clone git://github.com/yyuu/pyenv.git $HOME/.pyenv
RUN git clone https://github.com/yyuu/pyenv-virtualenv.git $HOME/.pyenv/plugins/pyenv-virtualenv
ENV PYTHON_VERSION 3.6.9
ENV PYTHON_ROOT $HOME/local/python-$PYTHON_VERSION
ENV PYENV_ROOT $HOME/.pyenv
ENV PATH $PYENV_ROOT/shims:$PYENV_ROOT/bin:$PYTHON_ROOT/bin:$PATH
RUN pyenv install $PYTHON_VERSION
RUN pyenv global $PYTHON_VERSION

# build opencv
RUN pip install numpy
RUN mkdir /data \
    && cd /data \
    && wget https://github.com/opencv/opencv/archive/4.1.1.tar.gz \
    && tar xvf 4.1.1.tar.gz \
    && mkdir /data/opencv-4.1.1/build \
    && cd /data/opencv-4.1.1/build
RUN sed -i -e "66 s/Eigen/eigen3\/Eigen/g" /data/opencv-4.1.1/modules/core/include/opencv2/core/private.hpp
RUN cmake \
    -D CMAKE_BUILD_TYPE=RELEASE \
    -D CMAKE_INSTALL_PREFIX=${HOME}/.pyenv/versions/${PYTHON_VERSION}/usr/local/ \
    -D INSTALL_C_EXAMPLES=OFF \
    -D BUILD_NEW_PYTHON_SUPPORT=ON \
    -D BUILD_opencv_python3=ON \
    -D BUILD_opencv_legacy=OFF \
    -D INSTALL_PYTHON_EXAMPLES=OFF \
    -D BUILD_EXAMPLES=OFF \
    -D PYTHON_EXECUTABLE=${HOME}/.pyenv/versions/${PYTHON_VERSION}/bin/python \
    -D PYTHON_LIBRARY=${HOME}/.pyenv/versions/${PYTHON_VERSION}/lib/libpython3.6m.a \
    -D PYTHON_INCLUDE_DIR=${HOME}/.pyenv/versions/${PYTHON_VERSION}/include/python3.6m \
    -D PYTHON_INCLUDE_DIRS=${HOME}/.pyenv/versions/${PYTHON_VERSION}/include/python3.6m \
    -D PYTHON_INCLUDE_DIRS2=${HOME}/.pyenv/versions/${PYTHON_VERSION}/include/python3.6m \
    -D INCLUDE_DIRS=${HOME}/.pyenv/versions/${PYTHON_VERSION}/include/python3.6m \
    -D INCLUDE_DIRS2=${HOME}/.pyenv/versions/${PYTHON_VERSION}/include/python3.6m \
    -D PYTHON_PACKAGES_PATH=${HOME}/.pyenv/versions/${PYTHON_VERSION}/lib/python3.6/site-packages \
    -D PYTHON_NUMPY_INCLUDE_DIR=${HOME}/.pyenv/versions/${PYTHON_VERSION}/lib/python3.6/site-packages/numpy/core/include \
    -D WITH_OPENCL=OFF \
    -D WITH_OPENCL_SVM=OFF \
    -D WITH_OPENCLAMDFFT=OFF \
    -D WITH_OPENCLAMDBLAS=OFF ..
RUN make
RUN make install
RUN ldconfig

# path
RUN cd ~/.pyenv/versions/3.6.9/lib/python3.6/site-packages/ \
    && ln -s ~/.pyenv/versions/3.6.9/usr/local/lib/python3.6/site-packages/cv2/python-3.6/cv2.cpython-36m-arm-linux-gnueabihf.so cv2.so
