# osu! Group Stats [![Build Status](https://travis-ci.org/justinsacbibit/osu-group-stats.svg?branch=master)](https://travis-ci.org/justinsacbibit/osu-group-stats)

## Required software

* Elixir: http://www.phoenixframework.org/docs/installation
* PostgreSQL: https://wiki.postgresql.org/wiki/Detailed_installation_guides
* Node and NPM: https://nodejs.org/en/

To run the osu! Group Stats app:

  1. Install dependencies with `mix deps.get`
  2. Create your database with `mix ecto.create` (make sure Postgres is running)
  3. Import [a database dump](https://www.dropbox.com/s/6cmgvht8iicnswq/uw_osu_dump_008?dl=0) with `pg_restore -d uw_osu_dev /path/to/uw_osu_dump` (may also need to specify `-h localhost -U postgres` if you get errors)
  4. Install JavaScript dependencies with `npm install`
  3. Start Phoenix endpoint with `mix phoenix.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Note that these instructions have not been tested on a "fresh" machine, so there may be additional steps required that I may have forgotten about. Please file an issue if you're having trouble getting set up!
