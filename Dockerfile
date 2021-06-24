FROM ubuntu:18.04

RUN apt update && apt install -y build-essential

RUN apt install -y python3-pip

RUN ln -s $(which python3.6) /usr/local/bin/python
RUN ln -s $(which pip3) /usr/local/bin/pip

ENV PYTHONUNBUFFERED 1

ENV USER sparkuser
ENV UID 1000
ENV GID 1000
ENV HOME /home/$USER
ENV PATH="${HOME}/.local/bin:${PATH}"
# ENV PYTHONPATH="somethig/modules:${PYTHONPATH}"
ENV TERM xterm-256color

RUN groupadd -g $GID group && adduser --disabled-password \
    --gecos "Non-root user" \
    --uid $UID \
    --gid $GID \
    --home $HOME \
    $USER

RUN apt update && apt install -y openjdk-8-jdk
RUN java -version

RUN apt install -y wget git scala

ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64
RUN wget -q https://downloads.apache.org/spark/spark-3.0.3/spark-3.0.3-bin-hadoop3.2.tgz
RUN tar xvf spark-*
RUN mv spark-3.0.2-bin-hadoop3.2 /opt/spark

USER $USER
WORKDIR $HOME

ENV SPARK_HOME /opt/spark
ENV PATH $PATH:$SPARK_HOME/bin
ENV PYTHONPATH $SPARK_HOME/python:$PYTHONPATH
ENV PYSPARK_DRIVER_PYTHON "jupyter"
ENV PYSPARK_DRIVER_PYTHON_OPTS "notebook --ip=0.0.0.0 --port=9999"
ENV PYSPARK_PYTHON python
ENV PATH $PATH:$JAVA_HOME/jre/bin
# ENV PYSPARK_SUBMIT_ARGS 

RUN pip install --upgrade pip

COPY --chown=$USER:$GID requirements.txt requirements.txt
RUN pip install -r requirements.txt

WORKDIR /opt/spark/jars
RUN wget -q https://repo1.maven.org/maven2/com/amazonaws/aws-java-sdk/1.11.563/aws-java-sdk-1.11.563.jar
RUN wget -q https://repo1.maven.org/maven2/org/apache/hadoop/hadoop-aws/3.2.0/hadoop-aws-3.2.0.jar
RUN wget -q https://repo1.maven.org/maven2/net/java/dev/jets3t/jets3t/0.9.4/jets3t-0.9.4.jar
RUN wget -q https://repo1.maven.org/maven2/com/jamesmurty/utils/java-xmlbuilder/0.6/java-xmlbuilder-0.6.jar
RUN wget -q https://repo1.maven.org/maven2/com/amazonaws/aws-java-sdk-bundle/1.11.563/aws-java-sdk-bundle-1.11.563.jar
RUN wget -q https://repo1.maven.org/maven2/org/apache/spark/spark-avro_2.12/3.0.3/spark-avro_2.12-3.0.3.jar

WORKDIR $HOME
