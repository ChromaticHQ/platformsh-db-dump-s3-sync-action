#!/bin/sh -l

php --version
aws --version
platform --version

sed -i 's/#   StrictHostKeyChecking ask.*/StrictHostKeyChecking accept-new/' /etc/ssh/ssh_config
FILENAME="${INPUT_DB_DUMP_FILENAME_BASE}-$(date +%F-%T)"

# Check if the optional relationship value exists.
if [ -z "${INPUT_PLATFORMSH_RELATIONSHIP}" ]
then
  # Run command without --relationship parameter.
  platform db:dump -v --yes --project "$INPUT_PLATFORMSH_PROJECT" --environment "$INPUT_PLATFORMSH_ENVIRONMENT" --gzip -f "$FILENAME".sql.gz
else
  # Run command with --relationship parameter.
  platform db:dump -v --yes --project "$INPUT_PLATFORMSH_PROJECT" --environment "$INPUT_PLATFORMSH_ENVIRONMENT" --relationship "$INPUT_PLATFORMSH_RELATIONSHIP" --gzip -f "$FILENAME".sql.gz
fi

aws s3 cp "$FILENAME".sql.gz s3://"$INPUT_AWS_S3_BUCKET"
