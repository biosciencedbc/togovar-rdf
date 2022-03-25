FROM openlink/virtuoso-opensource-7:7.2

ENV VIRT_Parameters_NumberOfBuffers=2720000 \
    VIRT_Parameters_MaxDirtyBuffers=2000000 \
    VIRT_Parameters_DirsAllowed=/load \
    VIRT_SPARQL_MaxQueryExecutionTime=600 \
    VIRT_SPARQL_ResultSetMaxRows=1000000 \
    DBA_PASSWORD=dba

RUN mkdir /load

ADD ./test.sh /test.sh
RUN chmod 777 /test.sh && chmod 777 /virtuoso-entrypoint.sh

ENTRYPOINT [ "/test.sh" ]
