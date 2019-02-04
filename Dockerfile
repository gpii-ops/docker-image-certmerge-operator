FROM golang:1.11.5-alpine3.8 AS build

ENV CERTMERGE_RELEASE=v0.0.3 \
    CERTMERGE_PROJECT=github.com/prune998/certmerge-operator \
    CERTMERGE_GIT_SHA=20ed30cb4f5acb17f0efeb222acfba3962ab0dd9 \
    OPERATOR_SDK_RELEASE=v0.4.0 \
    OPERATOR_SDK_PROJECT=github.com/operator-framework/operator-sdk \
    OPERATOR_SDK_GIT_SHA=cc5fe885869c181d820557bd296f092637fa70af \
    DEP_VERSION=v0.5.0 \
    DEP_SHA=287b08291e14f1fae8ba44374b26a2b12eb941af3497ed0ca649253e21ba2f83 \
    CGO_ENABLED=0 \
    LANG=C.UTF-8

ENV CERTMERGE_GIT_REPO=https://${CERTMERGE_PROJECT}.git \
    OPERATOR_SDK_GIT_REPO=https://${OPERATOR_SDK_PROJECT}.git \
    DEP_URL=https://github.com/golang/dep/releases/download/${DEP_VERSION}/dep-linux-amd64

RUN apk add --update --no-cache \
      curl \
      git \
      make \
    && curl -LsS "${DEP_URL}" -o /usr/bin/dep \
    && echo "${DEP_SHA}  /usr/bin/dep" |  sha256sum -c - \
    && chmod +x /usr/bin/dep \
    && git clone --branch "${OPERATOR_SDK_RELEASE}" --depth=1 -- "${OPERATOR_SDK_GIT_REPO}" "${GOPATH}/src/${OPERATOR_SDK_PROJECT}" \
    && cd "${GOPATH}/src/${OPERATOR_SDK_PROJECT}" \
    && git show-ref --verify HEAD | grep -q "^${OPERATOR_SDK_GIT_SHA}" \
    && make dep \
    && make install \
    && git clone --branch "${CERTMERGE_RELEASE}" --depth=1 -- "${CERTMERGE_GIT_REPO}" "${GOPATH}/src/${CERTMERGE_PROJECT}" \
    && cd "${GOPATH}/src/${CERTMERGE_PROJECT}" \
    && git show-ref --verify HEAD | grep -q "^${CERTMERGE_GIT_SHA}" \
    && operator-sdk generate k8s \
    && go build -o /certmerge-operator cmd/manager/main.go


FROM scratch

ENV CERTMERGE_UID=10000 \
    CERTMERGE_GID=10000

COPY --from=build /certmerge-operator /certmerge-operator

USER ${CERTMERGE_UID}:${CERTMERGE_GID}

CMD ["/certmerge-operator"]
