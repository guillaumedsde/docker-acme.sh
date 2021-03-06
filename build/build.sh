#!/bin/sh
set -x

LATEST_VERSION="$(git ls-remote https://github.com/acmesh-official/acme.sh.git HEAD | awk '{ print $1}')"

VERSION=${VERSION:-LATEST_VERSION}

if [ "${CI_COMMIT_REF_NAME}" = "master" ]; then
    TAGS=" -t ${CI_REGISTRY_USER}/${DOCKERHUB_REPO_NAME}:${VERSION} -t ${CI_REGISTRY_USER}/${DOCKERHUB_REPO_NAME}:latest "
else
    # cleanup branch name
    BRANCH="$(echo "${CI_COMMIT_REF_NAME}" | tr / _)"
    # tag image with branch name
    TAGS="-t ${CI_REGISTRY_USER}/${DOCKERHUB_REPO_NAME}:${BRANCH}"
fi

docker buildx build . \
    --platform "${BUILDX_PLATFORM}" \
    --build-arg BUILD_DATE="$(date -u +"%Y-%m-%dT%H:%M:%SZ")" \
    --build-arg VCS_REF="${VERSION}" \
    ${TAGS} \
    --push
