FROM python:3.7-alpine

LABEL "com.github.actions.name"="AWS λ deploy"
LABEL "com.github.actions.description"="Test, zip, and send an a λ to S3"
LABEL "com.github.actions.icon"="sunrise"
LABEL "com.github.actions.color"="hotpink"

LABEL "repository"="http://github.com/wellcometrust/reporting"
LABEL "homepage"="http://github.com/wellcometrust/reporting"
LABEL "maintainer"="Wellcome Collection <digital@wellcomecollection.org>"

ARG CLI_VERSION=1.16.161
RUN apk -uv add --no-cache zip && \
    pip install --no-cache-dir awscli==$CLI_VERSION

ADD entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
