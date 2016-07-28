# Start with docker-tangerine-support, which provides the core Tangerine apps.
FROM ubuntu:14.04 

# Never ask for confirmations
ENV DEBIAN_FRONTEND noninteractive
RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections

ENV T_HOST_NAME local.tangerinecentral.org
ENV T_USER1 user1
ENV T_USER1_PASSWORD password
ENV T_TREE_HOSTNAME / 
ENV T_TREE_URL /tree 

ENV T_ADMIN admin
ENV T_PASS password
ENV T_COUCH_HOST localhost
ENV T_COUCH_PORT 5984
ENV T_ROBBERT_PORT 4444
ENV T_TREE_PORT 4445
ENV T_BROCKMAN_PORT 4446
ENV T_DECOMPRESSOR_PORT 4447


RUN apt-get update && \ 
    apt-get install -y vim git


## Ruby
RUN apt-get install -y curl && \ 
    gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 && \
    curl -L https://get.rvm.io | bash -s stable && \
    /bin/bash -l -c "rvm requirements" && \
    /bin/bash -l -c "rvm install ruby-1.9.3" && \
    /bin/bash -l -c "rvm --default use ruby-1.9.3" 

ENV PATH /usr/local/rvm/rubies/ruby-1.9.3-p551/bin:/usr/local/rvm/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
ENV GEM_PATH /usr/local/rvm/rubies/ruby-1.9.3-p551/
ENV GEM_HOME /usr/local/rvm/rubies/ruby-1.9.3-p551/ 

# Install Couchdb
RUN apt-get -y install software-properties-common && \
    apt-add-repository -y ppa:couchdb/stable && \
    apt-get update && apt-get -y install couchdb && \
    chown -R couchdb:couchdb /usr/lib/couchdb /usr/share/couchdb /etc/couchdb /usr/bin/couchdb && \
    chmod -R 0770 /usr/lib/couchdb /usr/share/couchdb /etc/couchdb /usr/bin/couchdb && \
    mkdir /var/run/couchdb && \
    chown -R couchdb /var/run/couchdb && \
    sed -i -e "s#\[couch_httpd_auth\]#\[couch_httpd_auth\]\ntimeout=9999999#" /etc/couchdb/local.ini && \
    sed -i 's#;bind_address = 127.0.0.1#bind_address = 0.0.0.0#' /etc/couchdb/local.ini && \
    couchdb -k && \
    couchdb -b 

# RUN couchdb -b && sleep 5 && curl -XGET http://$T_ADMIN:$T_PASS@127.0.0.1:5984
# RUN couchdb -b && sleep 5 && curl -XGET http://127.0.0.1:5984
# RUN curl -XPUT http://$T_ADMIN:$T_PASS@127.0.0.1:5984/tangerine
# RUN curl -XPUT http://127.0.0.1:5984/tangerine

# Install CouchApp
RUN apt-get install build-essential python-dev -y && \ 
    curl -O https://bootstrap.pypa.io/get-pip.py && \
    sudo python get-pip.py && \
    sudo pip install couchapp

# Install dependencies for compiling app
RUN mkdir tangerine && \
    cd /tangerine && \
    gem install watch && \
    gem install uglifier && \
    gem install execjs && \
    curl -sL https://deb.nodesource.com/setup_4.x | sudo bash - && \
    apt-get install nodejs -y && \ 
    npm install -g coffee-script
#    gem install rake

RUN gem install watchr 

ADD ./ /tangerine/

# CouchApp is currently chocking on our couchappignore
RUN rm /tangerine/app/.couchappignore
# Create a configuration doc
RUN cp /tangerine/app/_docs/configuration.sample /tangerine/app/_docs/configuration.json
# Compilie the app
RUN cd /tangerine/app/_attachments/js && ./init.sh

VOLUME /var/lib/couchb/ 
EXPOSE 5984
WORKDIR /tangerine
ENTRYPOINT ./entrypoint.sh 
