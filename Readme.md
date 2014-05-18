# ofxAddons

The central place to discover openFrameworks addons.

## Running app locally

### Prerequisites

1. Ruby 2.0.0 or greater
1. [Bundler](bundler.io)
1. PostgreSQL 9.x (recommend using [homebrew](http://brew.sh/) or [mac ports](http://www.macports.org/) to install)
1. [Heroku Toolbelt](https://toolbelt.heroku.com/)

### Setup

1. Clone the repository:

    `$ git clone https://github.com/atduskgreg/ofxaddons.com`

1. Change directories in to the cloned repository:

    `$ cd ofxaddons.com`

1. Install the gems dependencies

    `$ bundle install`

1. Set up the database.

  **NOTE**: At the moment there's not a current copy of the database schema in the repository, so it would be tough to start from scratch.

  Copy the production database to your local machine:

  **WARNING**: the database `ofxaddons` must not exist locally before you do this!

    `$ heroku login`

    `$ heroku pg:pull HEROKU_POSTGRESQL_JADE ofxaddons`

1. Launch the server:

    `$ foreman start`

    You should now be able to navigate to load the web site at http://localhost:5000

### Crawling

####API Keys
If you want to avoid rate limiting with the Github API (hint: you _do_) then you need to [register a new application](https://github.com/settings/applications/new) and get some API keys.

There are several ways to set up your environment, but here's one way using Foreman.

1. Create a `.env` file in the repository root

    `$ touch .env`

1. Add your API key and secret to the file:

    GITHUB_CLIENT_ID=xxxxxxxxxxxxxxxxxxxx
    GITHUB_CLIENT_SECRET=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

1. Restart Foreman

**WARNING**: Never check in the `.env` file. It will screw up the production environment.

Further reading on [using foreman for config vars](https://devcenter.heroku.com/articles/config-vars#using-foreman).

#### Running a Crawl

Crawling and updating is all run through a series of rake tasks defined in Rakefile. To run the master task:

`$ bundle exec rake cron`
