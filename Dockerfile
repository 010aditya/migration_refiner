FROM openjdk:21-slim
WORKDIR /app
RUN apt-get update && \
    apt-get install -y wget unzip && \
    wget https://services.gradle.org/distributions/gradle-8.6-bin.zip && \
    unzip gradle-8.6-bin.zip -d /opt && \
    ln -s /opt/gradle-8.6/bin/gradle /usr/bin/gradle && \
    rm -rf /var/lib/apt/lists/*
ENV JAVA_HOME=/usr/local/openjdk-21
ENV PATH=$PATH:/opt/gradle-8.6/bin
COPY . /app
RUN pip install --upgrade pip && pip install -r requirements.txt
CMD ["python", "main.py"]
