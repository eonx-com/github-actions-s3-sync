#!/bin/bash
set -eo pipefail

# Validate required environment variables
echo "Validating Environment Variables"
if [[ -z "${AWS_DEFAULT_REGION}" ]]; then echo "ERROR: Missing required 'AWS_DEFAULT_REGION' environment variable"; error="1"; fi
if [[ -z "${AWS_ACCESS_KEY_ID}" ]]; then echo "ERROR: Missing required 'AWS_ACCESS_KEY_ID' environment variable"; error="1"; fi
if [[ -z "${AWS_SECRET_ACCESS_KEY}" ]]; then echo "ERROR: Missing required 'AWS_SECRET_ACCESS_KEY' environment variable"; error="1"; fi
if [[ -z "${DESTINATION_BUCKET}" ]]; then echo "ERROR: Missing required 'DESTINATION_BUCKET' environment variable"; error="1"; fi
if [[ -z "${GITHUB_SHA}" ]]; then echo "ERROR: Missing required 'GITHUB_SHA' environment variable"; error="1"; fi
if [[ -z "${SOURCE_PATH}" ]]; then echo "ERROR: Missing required 'SOURCE_PATH' environment variable"; error="1"; fi

if [[ "${error}" == "1" ]]; then
  exit 1;
fi

# If an environment file was specified, make sure it exists before we start
if [[ -n "${ENVIRONMENT_SOURCE_FILENAME}" && ! -f "${ENVIRONMENT_SOURCE_FILENAME}" ]]; then echo "ERROR: The specified environment file (${ENVIRONMENT_SOURCE_FILENAME}) could not be found"; exit 1; fi

# Set default ACL
if [[ -z "${ACL}" ]]; then export ACL="public-read"; fi

# Sync files to S3 bucket
echo "Syncing To S3 Bucket"
aws s3 sync "${SOURCE_PATH}" "s3://${DESTINATION_BUCKET}" --acl "${ACL}" --metadata "Commit=${GITHUB_SHA}" --delete;
