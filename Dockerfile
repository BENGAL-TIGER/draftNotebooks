FROM debian:latest
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    wget \
    bzip2 \
    ca-certificates \
    sudo \
    gnupg gnupg1 gnupg2 \
    # lsb_release \
    locales \
    fonts-liberation \
    libgtk2.0-dev \
    aptitude

RUN   for deb in deb deb-src; do echo "$deb http://build.openmodelica.org/apt `lsb_release -cs` nightly"; done | tee /etc/apt/sources.list.d/openmodelica.list && \
      wget -q http://build.openmodelica.org/apt/openmodelica.asc -O- | sudo apt-key add -  && \
# To verify that your key is installed correctly   && \
      apt-key fingerprint
# Gives output:
# pub   2048R/64970947 2010-06-22
#      Key fingerprint = D229 AF1C E5AE D74E 5F59  DF30 3A59 B536 6497 0947
# uid                  OpenModelica Build System

# Update index (again)
RUN apt-get update && apt-get install -y omc omlib-modelica-3.2.2 \
    python-pip python-dev build-essential  git libzmq3-dev

# Install Jupyter notebook, always upgrade pip
RUN pip install --upgrade pip
RUN pip install jupyter \
                pyzmq \
                OMPython


# Install OMPython and jupyter-openmodelica kernel
# RUN pip install -U git+git://github.com/OpenModelica/OMPython.git
RUN pip install -U git+git://github.com/OpenModelica/jupyter-openmodelica.git

# Create a user profile "openmodelicausers" inside the docker container as we should run the docker container as non-root users
RUN useradd -m -s /bin/bash openmodelicausers

# Copy the kernel from root location to non root location so that jupyter notebook when started as non-root can find openmodelica kernel
RUN cp -R /root/.local/share/jupyter/kernels/OpenModelica /usr/local/share/jupyter/kernels/

# Change the container to non-root "openmodelicauser" and set the env
USER openmodelicausers
ENV HOME /home/openmodelicausers
ENV USER openmodelicausers
WORKDIR $HOME


EXPOSE 8888

CMD ["jupyter", "notebook", "--port=8888", "--ip=0.0.0.0", "--allow-root"]
