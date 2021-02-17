# platformsh-db-dump-s3-sync-action

GitHub Action to take a database dump from a platform.sh site and copy the dump to S3.

## Usage

```yaml
- uses: chromatichq/db-backup-sync-action@v1
  with:
    platformsh_project: 'XXXX-project-id'  # required.
    platformsh_environment: 'main'  # required.
    platformsh_relationship: 'database'  # optional. specify if the project has multiple databases.
    aws_s3_bucket: 'bucket-name'  # required.
    db_dump_filename_base: 'sitename-db-dump'
  env:
    PLATFORMSH_CLI_TOKEN: ${{ secrets.PLATFORMSH_CLI_TOKEN }}  # required.
    AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}  # required.
    AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}  # required.
    AWS_DEFAULT_REGION: 'us-west-2' # required.
```
