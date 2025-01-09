FROM apache/dolphinscheduler-worker:3.1.5

# 变量
ENV LANG=C.UTF-8 \
    LC_ALL=en_US.UTF-8 \
    TZ="Asia/Shanghai" \
    MYSQL_JDBC_VERSION=9.1.0

# 组件依赖补充
RUN \
    echo "Install Dev tools" && \
        apt update && apt-get install -y curl net-tools && \
    echo "Download database driver jar (MySQL)" && \
        curl -L "https://repo1.maven.org/maven2/com/mysql/mysql-connector-j/${MYSQL_JDBC_VERSION}/mysql-connector-j-${MYSQL_JDBC_VERSION}.jar" \
            -o /opt/dolphinscheduler/libs/mysql-connector-j-${MYSQL_JDBC_VERSION}.jar && \
    echo "Purge build artifacts" && \
        apt-get purge -y --auto-remove && \
        apt-get clean && \
        rm -rf /var/lib/apt/lists/*

# Python环境（对应Python 3.12.8）
ENV MINIFORGE_VERSION=24.11.0-1
ENV CONDA_DIR=/opt/conda
ENV PATH=${CONDA_DIR}/bin:${PATH}
RUN \
    curl -L https://github.com/conda-forge/miniforge/releases/download/${MINIFORGE_VERSION}/Miniforge3-${MINIFORGE_VERSION}-Linux-$(uname -m).sh \
        -o /tmp/miniforge.sh && \
    /bin/bash /tmp/miniforge.sh -b -p ${CONDA_DIR} && \
    rm /tmp/miniforge.sh && \
    conda clean --tarballs --index-cache --packages --yes && \
    find ${CONDA_DIR} -follow -type f -name '*.a' -delete && \
    find ${CONDA_DIR} -follow -type f -name '*.pyc' -delete && \
    conda clean --force-pkgs-dirs --all --yes  && \
    echo ". ${CONDA_DIR}/etc/profile.d/conda.sh && conda activate base" >> /etc/skel/.bashrc && \
    echo ". ${CONDA_DIR}/etc/profile.d/conda.sh && conda activate base" >> ~/.bashrc

# 安装usql
RUN \
    echo "Install usql client" && \
        export USQL_VERSION=0.19.15 && \
        curl -L https://github.com/xo/usql/releases/download/v${USQL_VERSION}/usql_static-${USQL_VERSION}-linux-amd64.tar.bz2 \
            -o /tmp/usql.tar.gz2 && \
        tar xvf /tmp/usql.tar.gz2 -C /tmp && mv /tmp/usql_static /usr/bin/usql && \
        rm -rf /tmp/*
