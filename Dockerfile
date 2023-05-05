FROM httpd:2.4

RUN apt-get update \
	&& apt-get install -y --no-install-recommends \
    curl \
    ca-certificates \
    perl \
    make \
    gcc \
    libxml-parser-perl \
    libc6-dev \
	&& rm -rf /var/lib/apt/lists/*

RUN curl -L http://cpanmin.us | perl - App::cpanminus \
	&& cpanm local::lib CGI::Session Digest::SHA::PurePerl List::MoreUtils Net::DNS XML::Simple LWP::UserAgent JSON

RUN sed -i.bak -e \
  's%#LoadModule cgid_module%LoadModule cgid_module%g; \
   s%#AddHandler cgi-script .cgi%AddHandler cgi-script .pl .cgi%g; \
   s%#ServerName www.example.com:80%ServerName localhost:80%g; \
   s%Options Indexes FollowSymLinks%Options Indexes FollowSymLinks ExecCGI%g;' \
   /usr/local/apache2/conf/httpd.conf