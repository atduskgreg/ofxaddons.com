# ofxAddons

The central place to discover openFrameworks addons. 

### Running app locally

1. clone from https://github.com/atduskgreg/ofxaddons.com
2. cd into ofxaddons.com
3. create file `auth.rb` with line:
`$auth_params="client_id=xxx&client_secret=xxx"` where xxx is replaced with secret information.
4. run `bundle install` to install all the missing gems (you may need to run `gem update` first and `gem install bundler`)
5. if you don’t have postgres installed locally, use port or homebrew to get it
6. `$ initdb /usr/local/var/postgres -E utf8`
7. `$ pg_ctl -D /usr/local/var/postgres -l /usr/local/var/postgres/server.log start`
8. `$ export PGHOST=localhost`
9. `$ createdb ofxaddons`
10. Make sure the database is there by running `$ psql ofxaddons`, then `$ \list`. You should see ofxaddons as a row. Now exit with `$ \quit`
11. download the latest database dump file from heroku (or use the sample included in the repository), put it in the root of the ofxaddons.com directory, and restore it by running `pg_restore --verbose --clean --no-acl --no-owner -h localhost -U postgresusername -d databasename dumpfilename.dump`. for example `pg_restore --verbose --clean --no-acl --no-owner -h localhost -U kikko -d ofxaddons a613.dump`
12. Once it’s restored, cd into ofxaddons.com
13. Finally, launch the server with : ruby app.rb. App is viewable at `http://localhost:4567/` and non-cached at `http://localhost:4567/render` 
