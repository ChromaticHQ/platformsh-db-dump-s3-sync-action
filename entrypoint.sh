#!/bin/sh -l

php --version
aws --version
platform --version

sed -i 's/#   StrictHostKeyChecking ask.*/StrictHostKeyChecking accept-new/' /etc/ssh/ssh_config
FILENAME="${INPUT_DB_DUMP_FILENAME_BASE}-$(date +%F-%T)"

# Check if neither optional relationship nor optional app value exists.
if [ -z "${INPUT_PLATFORMSH_RELATIONSHIP}" ] && [ -z "${INPUT_PLATFORMSH_APP}" ]
then
  # Run command without --relationship and --app parameters.
  platform db:dump -v --yes --project "$INPUT_PLATFORMSH_PROJECT" --environment "$INPUT_PLATFORMSH_ENVIRONMENT" --gzip -f "$FILENAME".sql.gz
else
  # Check if the optional app value does not exist, run --relationship only.
  if [ -z "${INPUT_PLATFORMSH_APP}" ]
  then
    # Run command with --relationship parameter only.
    platform db:dump -v --yes --project "$INPUT_PLATFORMSH_PROJECT" --environment "$INPUT_PLATFORMSH_ENVIRONMENT" --relationship "$INPUT_PLATFORMSH_RELATIONSHIP" --gzip -f "$FILENAME".sql.gz
  # Check if the optional relationship value does not exist, run --app only.
  elif [ -z "${INPUT_PLATFORMSH_RELATIONSHIP}" ]
  then
    # Run command with --app parameter only.
    platform db:dump -v --yes --project "$INPUT_PLATFORMSH_PROJECT" --environment "$INPUT_PLATFORMSH_ENVIRONMENT" --app "$INPUT_PLATFORMSH_APP" --gzip -f "$FILENAME".sql.gz
  else
    # To get here we must have both --relationship and --app values available.
    # Run command with --relationship and --app parameters.
    platform db:dump -v --yes --project "$INPUT_PLATFORMSH_PROJECT" --environment "$INPUT_PLATFORMSH_ENVIRONMENT" --relationship "$INPUT_PLATFORMSH_RELATIONSHIP" --app "$INPUT_PLATFORMSH_APP" --gzip -f "$FILENAME".sql.gz
  fi
fi

aws s3 cp "$FILENAME".sql.gz s3://"$INPUT_AWS_S3_BUCKET"
