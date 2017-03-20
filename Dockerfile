FROM registry.centos.org/centos/centos:latest
MAINTAINER Bama Charan Kundu <bkundu@redhat.com>
RUN yum install make gcc zlib-devel pcre-devel rpm-build tar openssl-devel -y && \
    yum clean all

RUN useradd -u 1000 builder
WORKDIR /home/builder

ADD nginx.spec.centos7.patch /home/builder

RUN cd /home/builder && \
    curl -LO http://nginx.org/packages/centos/7/SRPMS/nginx-1.10.3-1.el7.ngx.src.rpm && \
    rpm -Uvh nginx-1.10.3-1.el7.ngx.src.rpm

RUN cd /home/builder/rpmbuild/SOURCES/ && \
    curl -L -o headers-more-nginx-module-0.32.tar.gz https://github.com/openresty/headers-more-nginx-module/archive/v0.32.tar.gz

RUN cd /home/builder/rpmbuild/SPECS && \
    patch -p0 /home/builder/nginx.spec.centos7.patch
    rpmbuild -ba nginx.spec

RUN yum install -y /home/builder/rpmbuild/RPMS/x86_64/nginx-1.10.3-1.el7.centos.ngx.x86_64.rpm && \
    mkdir -p /usr/share/nginx/html

ADD root /

RUN chmod 777 /run.sh
RUN chmod -R 777 /usr/share/nginx/html/
RUN echo "nginx on CentOS7" > /usr/share/nginx/html/index.html
RUN chmod 777 /run /var/log/nginx

EXPOSE 8080

ENTRYPOINT ["/run.sh"]
