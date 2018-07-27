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

