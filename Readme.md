# ofxAddons

The central place to discover openFrameworks addons.

## Running app locally

### Prerequisites

1. Ruby 2.1.3 or greater
1. [Bundler](bundler.io)
1. PostgreSQL 9.x (recommend using [homebrew](http://brew.sh/) or [mac ports](http://www.macports.org/) to install)
1. [Heroku Toolbelt](https://toolbelt.heroku.com/)

### Setup

1. Clone the repository:

    $ git clone https://github.com/atduskgreg/ofxaddons.com

1. Change directories in to the cloned repository:

    $ cd ofxaddons.com

1. Install the gems dependencies

    $ bundle install

1. Set up the database.

    You have two basic options: start with an empty database, or grab a backup from heroku.

    #### Start with an empty database

        $ rake db:setup

    #### Copy the production database to your local machine

      This option is only available if you have access to the Heroku production server.

      **WARNING**: the database `ofxaddons` must not exist locally before you do this!

        $ heroku login

        $ rake db:drop

        $ heroku pg:pull DATABASE_URL ofxaddons --app ofxaddons-cedar

        $ rake db:migrate

1. Create a dotenv file:

    WARNING: Never check in the `.env` file. It will screw up the production environment.

    $ touch .env

    Open up .env and add the following lines:

        PORT=5000
        WEB_CONCURRENCY=1

1. Launch the server:

    $ foreman start

    You should now be able to navigate to load the web site at http://localhost:5000

### Crawling

#### API Keys
If you want to avoid rate limiting (hint: you _do_) with the Github API then you need to [register a new application](https://github.com/settings/applications/new) and get some API keys.

API keys are strictly optional. If you don't use them, the app will run fine, but you'll be subject to rate limiting. After you make a few thousand requests Github will start rejecting your requests.

Once you've got your API keys, there are several ways to set up your environment, but here's one way using Foreman.

1. Create a `.env` file in the repository root

    $ touch .env

   WARNING: Never check in the `.env` file. It will screw up the production environment.

1. Add your API key and secret to the file:

    GITHUB_CLIENT_ID=xxxxxxxxxxxxxxxxxxxx
    GITHUB_CLIENT_SECRET=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

1. Restart Foreman

Further reading on [using foreman for config vars](https://devcenter.heroku.com/articles/config-vars#using-foreman).

#### Running a Crawl

Crawling and updating is run through the script runner:

    $ rails r 'Importer.new.run(no_cache: true)'

If you pass no_cache: false, the importer will use a cached responses from the github API (if available). This helps speed up development since you skip all the HTTP request overhead and just read the responses off of the local disk.
