
#!/bin/bash
echo "🚀 Waking up the PostgreSQL Database Server..."

USER_DATA_DIR="/tmp/pg_data_14"
BIN_DIR="/usr/lib/postgresql/14/bin"

if [ ! -d "$USER_DATA_DIR" ]; then
    echo "Creating a brand-new database cluster from scratch..."
    $BIN_DIR/initdb -D "$USER_DATA_DIR" >/dev/null
    
    echo "ssl = off" > "$USER_DATA_DIR/postgresql.conf"
    echo "unix_socket_directories = '/tmp'" >> "$USER_DATA_DIR/postgresql.conf"
    echo "shared_buffers = 32MB" >> "$USER_DATA_DIR/postgresql.conf"
    echo "max_connections = 20" >> "$USER_DATA_DIR/postgresql.conf"
    
    echo "local all all trust" > "$USER_DATA_DIR/pg_hba.conf"
    echo "host all all 127.0.0.1/32 trust" >> "$USER_DATA_DIR/pg_hba.conf"
    
    # Start the server and create the user role
    $BIN_DIR/pg_ctl -D "$USER_DATA_DIR" -l /tmp/postgres.log start
    sleep 3
        # 1. Create the standard 'postgres' superuser account with an explicit password
    $BIN_DIR/psql -h localhost -U $(whoami) -d template1 -c "CREATE USER postgres WITH SUPERUSER PASSWORD 'secret';" >/dev/null 2>&1
    
    # 2. Update your terminal session profile password to match for local script testing
    $BIN_DIR/psql -h localhost -U $(whoami) -d template1 -c "ALTER USER $(whoami) WITH PASSWORD 'secret';" >/dev/null 2>&1
fi

# Catch-all: Only start the server if it isn't already running
if ! $BIN_DIR/pg_isready -h localhost -p 5432 >/dev/null 2>&1; then
    $BIN_DIR/pg_ctl -D "$USER_DATA_DIR" -l /tmp/postgres.log start
    sleep 2
fi

# Confirm the final connection state
$BIN_DIR/pg_isready -h localhost -p 5432 -d postgres
