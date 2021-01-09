# README

Deployed on heroku as 

https://whispering-mesa-93684.herokuapp.com

## Data

Database is built from `db/participant-info-7jan21.csv`. This file is made by
downloading the release sheet from the dHCP release spreadsheet:

https://docs.google.com/spreadsheets/d/1m3Ypl8H5WkW9C8-tOgB9xmhX2L77yA6wZ7jPdbEEej0

## Local dev

    $ bundle install 
    $ rails db:migrate
    $ rails server

## Deploy

    $ heroku login
    $ heroku git:remote -a whispering-mesa-93684
    $ git push heroku master
    $ heroku pg:reset 
    $ heroku run rails db:migrate
    $ heroku run rails db:seed

## Generate preview images

    $ cd previews
    $ ./previews.sh ~/vol/dhcp-derived-data/derived_aug20_recon07_combined

