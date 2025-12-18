FROM hashicorp/terraform:1.14 AS terraform

FROM python:3.13-slim

ARG POETRY_VERSION=2.2.1

WORKDIR /usr/src/workspace

RUN apt update &&\
  apt install -y unzip curl pipx git

RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" &&\
  unzip awscliv2.zip  &&\
  ./aws/install  &&\
  rm -rf awscliv2.zip aws

RUN pipx ensurepath --global &&\
  pipx install poetry==${POETRY_VERSION}

ENV PATH="/root/.local/bin:${PATH}"

COPY . .

RUN poetry config virtualenvs.create false &&\
  poetry install --no-interaction --no-ansi

CMD ["poetry", "run", "python", "src/main.py"]