FROM ubuntu:14.04
MAINTAINER Michael Barton, mail@michaelbarton.me.uk

ENV PACKAGES make gcc wget libc6-dev zlib1g-dev ca-certificates xz-utils
RUN apt-get update -y && apt-get install -y --no-install-recommends ${PACKAGES}

ENV ASSEMBLER_DIR /tmp/assembler
ENV ASSEMBLER_URL https://www.ebi.ac.uk/~zerbino/velvet/velvet_1.2.10.tgz
ENV ASSEMBLER_BLD make 'MAXKMERLENGTH=100' && mv velvet* /usr/local/bin/ && rm -r ${ASSEMBLER_DIR}

RUN mkdir ${ASSEMBLER_DIR}
RUN cd ${ASSEMBLER_DIR} &&\
    wget --quiet ${ASSEMBLER_URL} --output-document - |\
    tar xzf - --directory . --strip-components=1 && eval ${ASSEMBLER_BLD}

ENV CONVERT https://github.com/bronze1man/yaml2json/raw/master/builds/linux_386/yaml2json
RUN cd /usr/local/bin && wget --quiet ${CONVERT} && chmod 700 yaml2json

ENV JQ http://stedolan.github.io/jq/download/linux64/jq
RUN cd /usr/local/bin && wget --quiet ${JQ} && chmod 700 jq

ENV BASE_URL  https://s3-us-west-1.amazonaws.com/bioboxes-tools/validate-input
ENV VERSION   validate-input-current.tar.xz
ENV VALIDATOR /bbx/validator/
RUN mkdir -p ${VALIDATOR}
RUN wget \
      --quiet \
      --output-document -\
      ${BASE_URL}/${VERSION} \
    | tar xJf - \
      --directory ${VALIDATOR} \
      --strip-components=1
ENV PATH ${PATH}:${VALIDATOR}
ADD schema.json ${VALIDATOR}

ADD Taskfile /
ADD assemble /usr/local/bin/

ENTRYPOINT ["/bin/bash"]
CMD ["assemble"]
