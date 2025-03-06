FROM ubuntu:latest

# Install dependencies
RUN apt-get -y update && \
    apt-get install -y build-essential git cmake libssl-dev python3 python3-venv pip

# Get liboqs
RUN git clone --depth 1 --branch main https://github.com/open-quantum-safe/liboqs

# Install liboqs
RUN cmake -S liboqs -B liboqs/build -DBUILD_SHARED_LIBS=ON && \
    cmake --build liboqs/build --parallel 4 && \
    cmake --build liboqs/build --target install

# Enable a normal user
RUN useradd -m -c "Open Quantum Safe" oqs
USER oqs
WORKDIR /home/oqs

# Create a Python 3 virtual environment
RUN python3 -m venv venv

# Get liboqs-pwr
RUN git clone --depth 1 --branch main https://github.com/open-quantum-safe/liboqs-pwr.git

# Install liboqs-pwr
ENV LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/lib
ENV PYTHONPATH=$PYTHONPATH:/home/oqs/liboqs-pwr
RUN . venv/bin/activate && cd liboqs-pwr && pip install . && cd $HOME
