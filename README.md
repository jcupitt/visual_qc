# README

Deployed on heroku as 

https://whispering-mesa-93684.herokuapp.com

## Generate preview images

    $ cd previews
    $ ./previews.sh ~/vol/dhcp-derived-data/derived_aug20_recon07_combined

## Data

Database is seeded from `db/participant-info-7jan21.csv`. This file is made
by downloading the release sheet from the dHCP release spreadsheet.

## To-do

- Display age at scan.
- Add a Sean-style view showing surface overlaid on volume for two axies.
- Remember the view tab when advancing.
- If the scan view has been previously scored by this user, display the
  previous rating.
- Colour -1 as red in overview and report to make them easy to pick out.

## Local dev

    $ bundle install 
    $ bundle exec rails db:migrate
    $ bundle exec rake db:seed
    $ bundle exec rails server
    $ firefox localhost:3000

## Deploy

    $ heroku login
    $ heroku git:remote -a whispering-mesa-93684
    $ git push heroku master
    $ heroku pg:reset 
    $ heroku run rails db:migrate
    $ heroku run rails db:seed

