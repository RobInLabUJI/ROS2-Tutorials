FROM osrf/ros2:bouncy-ros-base

RUN apt-get update && apt-get install -y \
	nodejs \
#    xvfb=2:1.18.4-0ubuntu0.7 \
#	x11-apps=7.7+5+nmu1ubuntu1 \
#	netpbm=2:10.0-15.3\
    && rm -rf /var/lib/apt/lists/

RUN pip3 install \
  jupyterlab

ENV NB_USER jovyan
ENV NB_UID 1000
ENV HOME /home/${NB_USER}

RUN adduser --disabled-password \
    --gecos "Default user" \
    --uid ${NB_UID} \
    ${NB_USER}

COPY *.ipynb ${HOME}/
USER root
RUN chown -R ${NB_UID} ${HOME}

USER ${NB_USER}
WORKDIR ${HOME}

CMD ["jupyter", "lab", "--ip", "0.0.0.0", "--no-browser"]

# Install cling dependencies
USER root
RUN apt-get update && \
    apt-get install -yq --no-install-recommends git g++ debhelper devscripts gnupg \
    && rm -rf /var/lib/apt/lists/

# Create cling folder
RUN mkdir /cling
#RUN chown -R $NB_USER:users /cling
WORKDIR /cling

# Download cling from https://root.cern.ch/download/cling/
#USER $NB_USER
#COPY download_cling.py download_cling.py
#RUN python3 download_cling.py
RUN git clone http://root.cern.ch/git/llvm.git src \
	&& cd src && git checkout cling-patches \
	&& cd tools && git clone http://root.cern.ch/git/cling.git \
	&& git clone http://root.cern.ch/git/clang.git \
	&& cd clang && git checkout cling-patches
	
RUN mkdir build \
	&& cd build \
	&& cmake -DCMAKE_BUILD_TYPE=Release ../src \
	&& cmake --build . \
	&& cmake --build . --target install

# install cling kernel
WORKDIR /usr/local/share/cling/Jupyter/kernel

USER root
RUN pip3 install -e .
RUN jupyter-kernelspec install cling-cpp11
RUN chown -R ${NB_UID} ${HOME}

WORKDIR $HOME

# Switch back to jovyan to avoid accidental container runs as root
USER $NB_USER
#ENV PATH="/cling/bin:${PATH}"
