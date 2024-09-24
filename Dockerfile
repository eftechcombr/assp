## STAGE 1 - BUILD
FROM perl:5.38.0-threaded AS BUILD

ENV VERSION ASSP_2.8.1_24261

WORKDIR /var/db/assp

RUN cpan-outdated -p | cpanm -n && \
	cpanm Mail::SPF::Query --force --notest --quiet && \
	cpanm IO::Socket::INET6 --force --quiet && \
	cpanm IO::Compress::Lzma --force --quiet && \
	cpanm IO::Compress::Xz --force --quiet && \
	cpanm IO::Compress::Zip --force --quiet && \
	cpanm Archive::Libarchive --force --quiet && \
	cpanm Alien::Libarchive --force --quiet

RUN cd /tmp && \
    curl -OL https://sourceforge.net/projects/assp/files/ASSP%20V2%20multithreading/2.8.1%2024261/ASSP_2.8.1%2024261install.zip && \
    curl -OL https://sourceforge.net/projects/assp/files/ASSP%20V2%20multithreading/ASSP%20V2%20module%20installation/assp.mod.zip

RUN mkdir -p /var/db && \
	mkdir -p /var/db/assp/tmpDB/files && \
	cd /var/db && \
	unzip "/tmp/ASSP_2.8.1%2024261install.zip" && \
	mv assp/assp.cfg.rename_on_new_install assp/assp.cfg && \
	cd /var/db/assp/ && \
	unzip /tmp/assp.mod.zip 

RUN perl /var/db/assp/assp.mod/install/mod_inst.pl /var/db/assp

RUN rm -rf /root/.cpan && \
	rm -rf /tmp/assp.mod.zip && \ 
	rm -rf /tmp/ASSP_*_install.zip

####
# - Plugins

WORKDIR /var/db/assp/Plugins 
RUN curl -OL https://sourceforge.net/projects/assp/files/ASSP%20V2%20multithreading/Plugins/ASSP_RSS%20-%20blocked%20mails%20RSS%20feed%20Plugin/ASSP_RSS_1.12.zip && \ 
	unzip ASSP_RSS_1.12.zip
	
RUN curl -OL https://sourceforge.net/projects/assp/files/ASSP%20V2%20multithreading/Plugins/ASSP_Razor%20-%20Razor2%20Plugin%20for%20ASSP/ASSP_Razor_1.11.zip && \
    unzip ASSP_Razor_1.11.zip 

RUN curl -OL https://sourceforge.net/projects/assp/files/ASSP%20V2%20multithreading/Plugins/ASSP_OCR%20-%20OCR%20Plugin/ASSP_OCR_2.26.zip && \
    unzip ASSP_OCR_2.26.zip
	
RUN curl -OL https://sourceforge.net/projects/assp/files/ASSP%20V2%20multithreading/Plugins/ASSP_FakeMX%20-%20sandwitch%20MX%20Plugin/ASSP_FakeMX_1.03.zip && \
    unzip ASSP_FakeMX_1.03.zip 
	
RUN curl -OL https://sourceforge.net/projects/assp/files/ASSP%20V2%20multithreading/Plugins/ASSP_DCC%20-%20DCC%20Plugin/ASSP_DCC_2.03.zip && \
	unzip ASSP_DCC_2.03.zip
	
RUN curl -OL https://sourceforge.net/projects/assp/files/ASSP%20V2%20multithreading/Plugins/ASSP_ARC%20-%20Archive%20Plugin/ASSP_ARC_2.11.zip && \
	unzip ASSP_ARC_2.11.zip
	
RUN curl -OL https://sourceforge.net/projects/assp/files/ASSP%20V2%20multithreading/Plugins/ASSP_AFC%20-%20AttachmentFullCheck%20Plugin/ASSP_AFC_5.46.zip && \
    unzip ASSP_AFC_5.46.zip	

RUN rm -rf *.zip
	

## STAGE 2 - COPY FROM BUILD TO SLIM THREADED PERL AND 

FROM perl:5.38.0-slim-threaded

RUN apt update -q && \
	apt -q -y install mariadb-client ca-certificates && \
	apt -q -y clean all

VOLUME [ "/var/db/assp" ]

COPY --from=BUILD /usr/local/lib/perl5 /usr/local/lib/perl5

COPY --from=BUILD /var/db/assp /var/db/assp

ADD assp.cfg /var/db/assp/

RUN chown -R nobody:nogroup /var/db/assp

EXPOSE 25/tcp 2525/tcp 465/tcp 587/tcp 55555/tcp 

WORKDIR /var/db/assp 

CMD [ "perl", "/var/db/assp/assp.pl", "/var/db/assp" ]
