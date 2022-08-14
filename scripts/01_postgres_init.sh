#!/bin/sh

isNewDb=false
export PGDATA="/var/lib/postgres/data"

printLog() {
    now=`date +"%Y-%m-%d %H:%M"`
    echo "[$now] $1"
}


printLog "🟢 starting postgres_init script as postgres user"

printLog "💭 Checking to see if you already have a DB in volume"
if [ -z "$(ls -A /var/lib/postgres/data)" ]; then
    printLog "🟠 Looks like the DB has not been initialized... let's fix that 🔧"
    initdb -D /var/lib/postgres/data
    isNewDb=true
    printLog "🟢 Default postgres DB initialized"
else
    printLog "🟢 DB has already been initialized... 🎉 Moving forward"
fi

printLog "💭 Checking to see if the developer has alternate configs that they would like loaded from /configs"

printLog "💭 searching for alternate postgresql.conf"
if [ -f "/configs/postgresql.conf" ]; then
    printLog "🟠 Looks like the developer has defined a postgresql.conf that they would like to be used"
    cp -vrf /configs/postgresql.conf /var/lib/postgres/data && printLog "🟢 Copy postgresql.conf complete" || "🔴 Copy postgresql.conf failed"
else
    printLog "🟢 No config found, keeping default and moving forward"
fi

printLog "💭 searching for alternate pg_hba.conf"
if [ -f "/configs/pg_hba.conf" ]; then
    printLog "🟠 Looks like the developer has defined a pg_hba.conf that they would like to be used"
    cp -vrf /configs/pg_hba.conf /var/lib/postgres/data && printLog "🟢 Copy pg_hba.conf complete" || "🔴 Copy pg_hba.conf failed"
else
    printLog "🟢 No config found, keeping default and moving forward"
fi

printLog "✅ Config adjustments complete, let's run mutations"
for SCRIPT in /mutations/*.sh; do chmod +x $SCRIPT; ./$SCRIPT; done

printLog "✅ Ensuring that /var/lib/postgres has no root permissions"
sudo chown postgres:postgres -Rv /var/lib/postgres

printLog "🔑 initial key-turn, starting postgres for the first time, hopefully it's going to start."
pg_ctl start || printLog "🔴 Sheeeea. something is broken, start the kettle." && printLog "🟢 Start was successful."

printLog "💭 Checking to see if there is a need to run init.sql"
if [[ "$isNewDb" == true ]] && [ -f /configs/init.sql ]; then
    printLog "🟢 The dev has provided a init.sql and the DB is new, so we will now run init.sql on the DB"
    pg_isready -h 127.0.0.1 && psql -h 127.0.0.1 -a -f /configs/init.sql
else
    printLog "🔴 nope, this DB is not new, or the init.sql has not been provided, moving on..."
fi

printLog "💭 stopping then starting the db for the last time 🫡"
pg_ctl stop