sudo -u postgres psql -c "CREATE USER vrikshaappuser WITH PASSWORD 'KNU_:YX:H68H~G!';"
sudo -u postgres psql -c "CREATE DATABASE bonded;"
sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE bonded TO vrikshaappuser;"
sudo sed -i "s/ident/md5/g" /var/lib/pgsql/data/pg_hba.conf
sudo sed -i "s/peer/md5/g" /var/lib/pgsql/data/pg_hba.conf
sudo systemctl reload postgresql
