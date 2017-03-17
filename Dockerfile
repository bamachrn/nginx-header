FROM registry.centos.org/centos/centos:latest
MAINTAINER Bama Charan Kundu <bkundu@redhat.com>
RUN yum install make gcc zlib* pcre* -y && \
    yum clean all
RUN curl -L -o nginx-1.11.2.tar.gz http://nginx.org/download/nginx-1.11.2.tar.gz && \
    tar -xzvf nginx-1.11.2.tar.gz

RUN cd / && \
    curl -L -o headers-more-nginx-module-0.32.tar.gz https://github.com/openresty/headers-more-nginx-module/archive/v0.32.tar.gz && \
    tar -xvf headers-more-nginx-module-0.32.tar.gz
RUN cd nginx-1.11.2 && \
    ./configure --prefix=/opt/nginx --add-module=/headers-more-nginx-module-0.32 && \
    make && \
    make install

RUN ln -s /opt/nginx/sbin/nginx /usr/sbin/nginx && \
    ln -s /opt/nginx/logs /var/log/nginx && \
    mkdir -p /usr/share/nginx/html && \
    mkdir -p /etc/nginx && \
    cp -r /opt/nginx/conf/* /etc/nginx/

ADD root /

RUN chmod 777 /run.sh
RUN chmod -R 777 /usr/share/nginx/html/
RUN echo "nginx on CentOS7" > /usr/share/nginx/html/index.html
RUN chmod 777 /run /var/log/nginx 

EXPOSE 8080

ENTRYPOINT ["/run.sh"]
