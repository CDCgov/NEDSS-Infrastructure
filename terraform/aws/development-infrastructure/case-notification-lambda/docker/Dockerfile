FROM public.ecr.aws/lambda/python:3.12

# Install system tools
RUN dnf install -y \
    gcc \
    gcc-c++ \
    make \
    python3.12 \
    python3.12-devel \
    python3.12-pip \
    unixODBC \
    unixODBC-devel \    
    unzip \
    tar \
    && dnf clean all

# Install msodbcsql18
ADD https://packages.microsoft.com/config/rhel/9/prod.repo /etc/yum.repos.d/msprod.repo 
RUN ACCEPT_EULA=Y dnf install -y msodbcsql18 && dnf clean all && \
    # Create Lambda layer directory
    mkdir -p /opt/python /opt/lib /opt/etc && \
    # Install Python libs into /opt/python
    pip3.12 install --no-cache-dir pyodbc paramiko -t /opt/python && \
    # Copy msodbcsql18 library files into /opt/lib and add ODBC configuration
    export filename=$(ls /opt/microsoft/msodbcsql18/lib64/) && \
    cp /opt/microsoft/msodbcsql18/lib64/"$filename" /opt/lib/ && \
    echo "[ODBC Driver 18 for SQL Server]" > /opt/etc/odbcinst.ini && \
    echo "Description=Microsoft ODBC Driver 18 for SQL Server" >> /opt/etc/odbcinst.ini && \
    echo "Driver=/opt/lib/$filename" >> /opt/etc/odbcinst.ini && \
    echo "UsageCount=1" >> /opt/etc/odbcinst.ini && \
    cp /usr/lib64/libodbc*.so* /usr/lib64/libltdl.so.7 /usr/lib64/libc.so.6 /usr/lib64/ld-linux-x86-64.so.2 /opt/lib/ && \
    cp /etc/odbc.ini /opt/etc/

# Zip it up for Lambda layer
WORKDIR /opt
RUN zip -r9 /layer.zip .