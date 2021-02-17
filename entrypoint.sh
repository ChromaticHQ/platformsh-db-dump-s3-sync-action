#!/bin/sh -l

php --version
aws --version
platform --version

sed -i 's/#   StrictHostKeyChecking ask.*/StrictHostKeyChecking accept-new/' /etc/ssh/ssh_config
FILENAME="${INPUT_DB_DUMP_FILENAME_BASE}-$(date +%F-%T)"

# Check if the optional relationship value exists.
RELATIONSHIP=""
if [ -z "${INPUT_PLATFORMSH_RELATIONSHIP}" ]
then
  echo "No relationship variable provided so no relationship parameter added to platform db:dump."
else
  RELATIONSHIP="--relationship $INPUT_PLATFORMSH_RELATIONSHIP"
fi

platform db:dump -v --yes --project "$INPUT_PLATFORMSH_PROJECT" --environment "$INPUT_PLATFORMSH_ENVIRONMENT" "$RELATIONSHIP" --gzip -f "$FILENAME".sql.gz

aws s3 cp "$FILENAME".sql.gz s3://"$INPUT_AWS_S3_BUCKET"
