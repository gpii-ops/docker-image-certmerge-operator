FROM golang:1.13.6-alpine3.11 AS build

ENV CGO_ENABLED=0 \
    LANG=C.UTF-8

RUN apk add --update --no-cache \
      curl \
      git \
      grep \
      make

# operator-sdk
ENV OPERATOR_SDK_RELEASE=v0.14.1 \
    OPERATOR_SDK_PROJECT=github.com/operator-framework/operator-sdk \
    OPERATOR_SDK_GIT_SHA=1c3106afd103ff868bceb9c6a6c077b17bad363c

ENV OPERATOR_SDK_GIT_REPO=https://${OPERATOR_SDK_PROJECT}.git

RUN git clone --branch "${OPERATOR_SDK_RELEASE}" --depth=1 -- "${OPERATOR_SDK_GIT_REPO}" "/src/${OPERATOR_SDK_PROJECT}" \
    && cd "/src/${OPERATOR_SDK_PROJECT}" \
    && git show-ref --verify HEAD | grep -q "^${OPERATOR_SDK_GIT_SHA}" \
    && make tidy \
    && make install

# certmerge-operator
ENV CERTMERGE_RELEASE=v0.0.3-gpii.2 \
    CERTMERGE_PROJECT=github.com/gpii-ops/certmerge-operator \
    CERTMERGE_GIT_SHA=9727eb15ce7fee160bef4bfc3ccec4808e3e4feb

ENV CERTMERGE_GIT_REPO=https://${CERTMERGE_PROJECT}.git


RUN git clone --branch "${CERTMERGE_RELEASE}" --depth=1 -- "${CERTMERGE_GIT_REPO}" "/src/${CERTMERGE_PROJECT}" \
    && cd "/src/${CERTMERGE_PROJECT}" \
    && git show-ref --verify HEAD | grep -q "^${CERTMERGE_GIT_SHA}" \
    && operator-sdk generate k8s \
    && operator-sdk generate crds \
    && go build -o /certmerge-operator cmd/manager/main.go


FROM scratch

ENV CERTMERGE_UID=10000 \
    CERTMERGE_GID=10000

COPY --from=build /certmerge-operator /certmerge-operator

USER ${CERTMERGE_UID}:${CERTMERGE_GID}

CMD ["/certmerge-operator"]
