FROM gcr.io/cloudshell-images/cloudshell:latest

# Add your content here

# To trigger a rebuild of your Cloud Shell image:
# 1. Commit your changes locally: git commit -a
# 2. Push your changes upstream: git push origin master

# This triggers a rebuild of your image hosted at gcr.io/ideas-justme/mycustomshell.
# You can find the Cloud Source Repository hosting this file at https://source.developers.google.com/p/ideas-justme/r/mycustomshell

RUN apt-get update -y && apt-get upgrade -y && apt-get install pwgen netcat python-yaml mtr tcpdump ipcalc sshfs hping3 zsh -y 

# terraform
COPY --from=hashicorp/terraform /bin/terraform /usr/bin/

# kubectl completion
RUN kubectl completion bash > /etc/bash_completion.d/kubectl

# install vim as your user (replace my user by yours)
RUN git clone --depth=1 https://github.com/amix/vimrc.git /opt/vim_runtime && sh ~/.vim_runtime/install_awesome_vimrc.sh

RUN echo "$EDITOR=vim" >> /etc/environment
RUN echo "$CLOUDSDK_COMPUTE_ZONE=europe-west1-b" >> /etc/environment
RUN echo "$CLOUDSDK_COMPUTE_REGION=europe-west1" >> /etc/environment
RUN echo "$CLOUDSDK_CORE_PROJECT=myplaygrounds-inter" >> /etc/environment

# extrass
RUN echo 'function cdl { cd $1; ls -la;}' >> /etc/profile
RUN echo 'alias h=history' >> /etc/profile

# set zsh as default shell and install omz
RUN echo 'zsh' >> /etc/profile
RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

#RUN echo "if [ "`id -u`" -eq 0 ]; then USERCOLOR='95'; else USERCOLOR='32'; fi" >> /etc/profile 
#RUN echo 'export PS1="[\[\e[1;"$USERCOLOR"m\]\u\[\e[m\]\[\e[1;31m\]@\[\e[m\]\[\e[3;35m\]\H\[\e[m\] \[\e[1;30m\]| \[\e[m\]\[\e[1;34m\]\w\[\e[m\] \[\e[1;29m\]\t\[\e[m\]]\[\e[1;33m\]$\[\e[m\]"' >> /etc/profile
