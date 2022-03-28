FROM openlink/virtuoso-opensource-7:7.2

# virtuoso.iniの設定値
ENV DBA_PASSWORD=dba \
    VIRT_Parameters_NumberOfBuffers=8170000 \
    VIRT_Parameters_MaxDirtyBuffers=6000000 \
    VIRT_Parameters_DirsAllowed="/load, /test" \
    VIRT_SPARQL_MaxQueryExecutionTime=600 \
    VIRT_SPARQL_ResultSetMaxRows=1000000

RUN mkdir /load

ADD ./load.sh /load.sh
RUN chmod 777 /load.sh && chmod 777 /virtuoso-entrypoint.sh

ENTRYPOINT [ "/load.sh" ]
