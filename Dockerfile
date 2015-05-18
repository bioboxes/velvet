FROM ubuntu:14.04
MAINTAINER first_name last_name, mail@example.com

RUN apt-get update -y && \
    apt-get install -y --no-install-recommends \
    velvet wget xz-utils ca-certificates

ENV CONVERT https://github.com/bronze1man/yaml2json/raw/master/builds/linux_386/yaml2json
# download yaml2json and make it executable
RUN cd /usr/local/bin && wget --quiet ${CONVERT} && chmod 700 yaml2json

ENV JQ http://stedolan.github.io/jq/download/linux64/jq
# download jq and make it executable
RUN cd /usr/local/bin && wget --quiet ${JQ} && chmod 700 jq

# Locations for biobox file validator
ENV VALIDATOR /bbx/validator/
ENV BASE_URL https://s3-us-west-1.amazonaws.com/bioboxes-tools/validate-biobox-file
ENV VERSION  0.x.y
RUN mkdir -p ${VALIDATOR}

# download the validate-biobox-file binary and extract it to the directory $VALIDATOR
RUN wget \
      --quiet \
      --output-document -\
      ${BASE_URL}/${VERSION}/validate-biobox-file.tar.xz \
    | tar xJf - \
      --directory ${VALIDATOR} \
      --strip-components=1

ENV PATH ${PATH}:${VALIDATOR}

# Add Taskfile to /
ADD Taskfile /

# Add assemble script to the directory /usr/local/bin inside the container.
# /usr/local/bin is appended to the $PATH variable what means that every script
# in that directory will be executed in the shell  without providing the path.
ADD assemble /usr/local/bin/

# download the assembler schema
RUN wget \
    --output-document /schema.yaml \
    https://raw.githubusercontent.com/bioboxes/rfc/master/container/short-read-assembler/input_schema.yaml

ENTRYPOINT ["assemble"]
