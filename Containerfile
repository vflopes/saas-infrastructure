FROM hashicorp/terraform:1.14 AS terraform

FROM python:3.13-slim

ARG POETRY_VERSION=2.2.1
ARG APP_USER=devuser
ARG APP_UID=1000
ARG APP_GID=1000

ENV PATH="/root/.local/bin:${PATH}"

COPY --from=terraform /bin/terraform /usr/local/bin/terraform

RUN apt update &&\
  apt install -y unzip curl pipx git

RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" &&\
  unzip awscliv2.zip  &&\
  ./aws/install  &&\
  rm -rf awscliv2.zip aws

RUN groupadd --gid $APP_GID $APP_USER && useradd --uid $APP_UID --gid $APP_GID -m -s /bin/bash $APP_USER

WORKDIR /dev

RUN chown -R $APP_USER:$APP_USER /dev

USER $APP_USER
  
RUN pipx ensurepath --global &&\
  pipx install poetry==${POETRY_VERSION}

WORKDIR /workspace

COPY pyproject.toml poetry.lock /workspace/

RUN poetry env use /usr/local/bin/python &&\
  poetry install --no-interaction --no-ansi --all-groups

RUN echo "PS1='\u@\W: '" >> /root/.bashrc
RUN echo "$(poetry env activate)" >> /root/.bashrc

ENTRYPOINT ["/bin/bash"]
