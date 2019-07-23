# version 1.0
FROM nvidia/cuda:10.0-cudnn7-devel-ubuntu18.04

ENV LANG=C.UTF-8 LC_ALL=C.UTF-8

RUN mkdir /root/Project
WORKDIR /root/Project

COPY .vimrc /root/
COPY requirements.txt /root/Project

RUN \
    apt-get update  && \
    apt-get install -y \
        vim \
        git \
        zip \
        unzip \
        htop \
        nano \
        man \
        cmake \
        libsm6 \
        libxext6 \
        libxrender-dev \
	tmux \
	screen \

# Install ssh server, allow password auth and make user pass 'docker'
RUN \
    apt-get install -y openssh-server && \
    sed -i "\$aPasswordAuthentication yes\nPermitRootLogin yes" /etc/ssh/sshd_config && \
    echo 'root:docker' | chpasswd

# Install python dependencies
RUN \
    update-alternatives --install /usr/bin/python python /usr/bin/python3.6 1 && \
    apt-get install -y python3-pip && \
    update-alternatives --install /usr/bin/pip pip /usr/bin/pip3 1 && \
    pip install jupyter && \
    pip install jupyter_contrib_nbextensions && \
    pip install jupyter_nbextensions_configurator && \
    pip install yapf && \
    jupyter contrib nbextension install --user && \
    jupyter nbextensions_configurator enable --user && \
    #
    # Installation of vim_bindings
    mkdir -p $(jupyter --data-dir)/nbextensions && \
    # Now clone the repository
    cd $(jupyter --data-dir)/nbextensions && \
    git clone https://github.com/lambdalisue/jupyter-vim-binding vim_binding && \
    chmod -R go-w vim_binding && \
    cd - && \
    #
    # Activate extensions
    jupyter nbextension enable notify/notify && \
    jupyter nbextension enable toc2/main && \
    jupyter nbextension enable execute_time/ExecuteTime && \
    jupyter nbextension enable freeze/main && \
    jupyter nbextension enable hide_header/main && \
    jupyter nbextension enable codefolding/main && \
    jupyter nbextension enable code_prettify/code_prettify && \
    # jupyter nbextension enable vim_binding/vim_binding && \
    #
    # Install python dependencies
    pip install -r requirements.txt && \
    rm requirements.txt

EXPOSE 8888
EXPOSE 22

CMD jupyter notebook --notebook-dir=/root/Project --no-browser --allow-root --port 8888 -ip=0.0.0.0 --NotebookApp.token='docker'
