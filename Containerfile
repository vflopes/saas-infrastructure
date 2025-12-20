FROM hashicorp/terraform:1.14 AS terraform

FROM python:3.13-slim

ARG POETRY_VERSION=2.2.1

# Poetry installs scripts to ~/.local/bin, so we need to add this to PATH
ENV PATH="/root/.local/bin:${PATH}"

COPY --from=terraform /bin/terraform /usr/local/bin/terraform

RUN apt update &&\
  apt install -y unzip curl pipx

RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" &&\
  unzip awscliv2.zip &&\
  ./aws/install &&\
  rm -rf awscliv2.zip aws

RUN pipx ensurepath --global &&\
  pipx install --include-deps poetry==${POETRY_VERSION}

WORKDIR /workspace

COPY . /workspace/

RUN poetry self add poetry-plugin-export &&\ 
  poetry export --all-groups -f requirements.txt -o requirements.txt --without-hashes &&\
  pip install --no-cache-dir -r requirements.txt

RUN echo "PS1='\u@\W: '" >> /root/.bashrc

ENTRYPOINT ["/bin/bash"]
