FROM nginx

# Set up all arguments first
ARG AUTHOR="Alexander Hultnér<hultner@github.com>"
ARG MAINTAINER="Alexander Hultnér<hultner@github.com>"
ARG GIT_COMMIT="unknown"
ARG VERSION="unknown"

LABEL author=$AUTHOR
LABEL maintainer=$MAINTAINER
LABEL git-commit=$GIT_COMMIT
LABEL version=$VERSION

COPY . /usr/share/nginx/html
