#!/bin/sh -l

php --version
aws --version
platform --version

sed -i 's/#   StrictHostKeyChecking ask.*/StrictHostKeyChecking accept-new/' /etc/ssh/ssh_config
FILENAME="${INPUT_DB_DUMP_FILENAME_BASE}-$(date +%F-%T)"

# Check if the optional relationship value exists.
if [ -z "${INPUT_PLATFORMSH_RELATIONSHIP}" ]
then
  echo "No relationship variable provided so no relationship parameter added to platform db:dump."
else
  # Manually add to args variable which can then hold many parameters.
  # Subsequent parameters can be added in the same way, increasing the index.
  args[0]="--relationship $INPUT_PLATFORMSH_RELATIONSHIP"
fi

platform db:dump -v --yes --project "$INPUT_PLATFORMSH_PROJECT" --environment "$INPUT_PLATFORMSH_ENVIRONMENT" "${args[@]}" --gzip -f "$FILENAME".sql.gz

aws s3 cp "$FILENAME".sql.gz s3://"$INPUT_AWS_S3_BUCKET"
