FROM ubuntu:14.04
MAINTAINER first_name last_name, mail@example.com

RUN apt-get update -y && \
    apt-get install -y --no-install-recommends \
    velvet wget xz-utils ca-certificates

ENV CONVERT https://github.com/bronze1man/yaml2json/raw/master/builds/linux_386/yaml2json
RUN cd /usr/local/bin && wget --quiet ${CONVERT} && chmod 700 yaml2json

ENV JQ http://stedolan.github.io/jq/download/linux64/jq
RUN cd /usr/local/bin && wget --quiet ${JQ} && chmod 700 jq

# Locations for biobox file validator
ENV VALIDATOR /bbx/validator/
ENV BASE_URL https://s3-us-west-1.amazonaws.com/bioboxes-tools/validate-biobox-file
ENV VERSION  0.x.y
RUN mkdir -p ${VALIDATOR}
RUN wget \
      --quiet \
      --output-document -\
      ${BASE_URL}/${VERSION}/validate-biobox-file.tar.xz \
    | tar xJf - \
      --directory ${VALIDATOR} \
      --strip-components=1

ADD Taskfile /
ADD assemble /usr/local/bin/

ENV PATH ${PATH}:${VALIDATOR}
RUN wget \
    --output-document /schema.yaml \
    https://raw.githubusercontent.com/bioboxes/rfc/master/container/short-read-assembler/input_schema.yaml

ENV PATH ${PATH}:${VALIDATOR}
ENTRYPOINT ["assemble"]
