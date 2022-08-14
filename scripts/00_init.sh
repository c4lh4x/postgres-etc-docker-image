#!/bin/sh

echo "🐘 postgres entrypoint root script"

su postgres -c 01_postgres_init.sh

03_start_db.sh