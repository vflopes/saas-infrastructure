FROM hashicorp/terraform:1.14 AS terraform

FROM python:3.13-slim

ARG POETRY_VERSION=2.2.1

ENV PATH="/root/.local/bin:${PATH}"

COPY --from=terraform /bin/terraform /usr/local/bin/terraform

RUN apt update &&\
  apt install -y unzip curl pipx git

RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" &&\
  unzip awscliv2.zip  &&\
  ./aws/install  &&\
  rm -rf awscliv2.zip aws

RUN pipx ensurepath --global &&\
  pipx install poetry==${POETRY_VERSION}

WORKDIR /workspace

COPY pyproject.toml poetry.lock /workspace/

RUN poetry env use /usr/local/bin/python &&\
  poetry install --no-interaction --no-ansi --all-groups

RUN echo "PS1='\u@\W: '" >> /root/.bashrc
RUN echo "$(poetry env activate)" >> /root/.bashrc

ENTRYPOINT ["/bin/bash"]