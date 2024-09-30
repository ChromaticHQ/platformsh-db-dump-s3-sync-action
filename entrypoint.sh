#!/bin/sh -l

php --version
aws --version
platform --version

sed -i 's/#   StrictHostKeyChecking ask.*/StrictHostKeyChecking accept-new/' /etc/ssh/ssh_config
FILENAME="${INPUT_DB_DUMP_FILENAME_BASE}-$(date +%F-%T)"

echo "About to go into loop"

# If we are not limiting the tables with INPUT_ONLY_INCLUDE_THESE_TABLES, then
# this will pass harmlessly as an empty string in the platform db:dump command.
# @todo Can malicious users run command injection attack with table name input?
DUMP_ONLY_THESE_TABLES=""
for table in ${INPUT_DUMP_ONLY_THESE_TABLES}
do
  echo "Without parentheses..."
  echo "--table $table"
  echo "And now with parentheses..."
  echo "--table ${table}"
  # Add table options into array.
  # DUMP_ONLY_THESE_TABLES+=("--table ${table}")
done

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
    # Also the optional DUMP_ONLY_THESE_TABLES argument limits to a subset of tables, separated by spaces.
    platform db:dump -v --yes --project "$INPUT_PLATFORMSH_PROJECT" --environment "$INPUT_PLATFORMSH_ENVIRONMENT" --relationship "$INPUT_PLATFORMSH_RELATIONSHIP" --app "$INPUT_PLATFORMSH_APP" ${DUMP_ONLY_THESE_TABLES[*]} --gzip -f "$FILENAME".sql.gz
  fi
fi

aws s3 cp "$FILENAME".sql.gz s3://"$INPUT_AWS_S3_BUCKET"
