# README

Deployed on heroku as 

https://whispering-mesa-93684.herokuapp.com

## Local dev

    $ bundle install --without production
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
    $ ./previews.sh ~/vol/dhcp-derived-data/derived_02Jun2018/participants.tsv



