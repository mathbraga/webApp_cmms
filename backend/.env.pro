# Node.js environment:
NODE_ENV=production

# HTTP port:
HTTP_PORT=3001

# Database connection:
PGUSER=postgres
PGHOST=localhost
PGDATABASE=db_dev
PGPASSWORD=123456
PGPORT=5432

# Cron jobs configuration
# Leave value blank if you do not want the cron job to be executed
# Cron patterns and ranges: https://www.npmjs.com/package/cron#usage-basic-cron-usage
# Every second (for usage in development): * * * * * *
# Every day at 00:00:00 (for usage in production): 0 0 0 * * *
CRON_DIFF=
CRON_DUMP=
CRON_REFRESH=
CRON_TEST=
