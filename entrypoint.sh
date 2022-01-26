#!/bin/sh -l

php --version
aws --version
platform --version

sed -i 's/#   StrictHostKeyChecking ask.*/StrictHostKeyChecking accept-new/' /etc/ssh/ssh_config
FILENAME="${INPUT_DB_DUMP_FILENAME_BASE}-$(date +%F-%T)"

# If we are not limiting the tables with INPUT_ONLY_INCLUDE_THESE_TABLES, then
# this will pass harmlessly as an empty string in the platform db:dump command.
# @todo Can malicious users run command injection attack with table name input?
DUMP_ONLY_THESE_TABLES=""
for table in ${INPUT_DUMP_ONLY_THESE_TABLES}
do
  # Add table options into array.
  DUMP_ONLY_THESE_TABLES+=("--table $table")
done

# Check if the optional relationship value exists.
if [ -z "${INPUT_PLATFORMSH_RELATIONSHIP}" ]
then
  # Run command without --relationship parameter.
  platform db:dump -v --yes --project "$INPUT_PLATFORMSH_PROJECT" --environment "$INPUT_PLATFORMSH_ENVIRONMENT" ${DUMP_ONLY_THESE_TABLES[@]} --gzip -f "$FILENAME".sql.gz
else
  # Run command with --relationship parameter.
  platform db:dump -v --yes --project "$INPUT_PLATFORMSH_PROJECT" --environment "$INPUT_PLATFORMSH_ENVIRONMENT" --relationship "$INPUT_PLATFORMSH_RELATIONSHIP" ${DUMP_ONLY_THESE_TABLES[@]} --gzip -f "$FILENAME".sql.gz
fi

aws s3 cp "$FILENAME".sql.gz s3://"$INPUT_AWS_S3_BUCKET"
