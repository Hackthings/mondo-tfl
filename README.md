# Mondo TFL

Pulls in travel information from TFL, matches journeys to the transaction, generates a JPG Receipt and attaches it to the Mondo transaction.

---

![travel info in Mondo](https://cloud.githubusercontent.com/assets/395/15808595/e3bbfd0a-2b72-11e6-917e-560a387c15de.PNG)

---

## Todo

- known slight bug in matching transactions, 99% of the time it matches all the time ;-)
- only selects the first contactless card in TFL. So if you've been using contactless cards on TFL before and have multiple contactless cards registered @ contactless.tfl.gov.uk then it probably won't select the right card. Ideally Mondo-TFL would let you select which card to scrape.

## Getting Started

1. Login to https://developers.getmondo.co.uk/.
2. Explore API endpoints in the Playground.
3. Create a New OAuth Client in Clients.
4. Set the Redirect URL to `http://localhost:3000/auth/mondo/callback`, you may set `Confidentiality` to confidential as we are creating a server based client, as apposed to something like an iPad application.
5. Make note of the `Client ID` and the `Client Secret`.
6. Download or Clone Mondo-TFL from https://github.com/jameshill/mondo-tfl
7. Create a `.env` file in your application root containing your ID & Secret it should look **something** like this, obviously this is just a dummy example, use *your* creditials.

```
MONDO_CLIENT_ID=
MONDO_SECRET=
AWS_ACCESS_KEY_ID=
AWS_SECRET_ACCESS_KEY=
AWS_REGION=eu-west-1
AWS_S3_BUCKET=
```

Once you have done the standard database creation and migration you should be all ready to explore

```
rake db:create
rake db:migrate
rails server
open http://localhost:3000
```

You'll then need to login, which will then take you through the Mondo OAuth implementation.

Once logged in you now need to provide you Transport for London username & password.

Now that both credentials have been stored in the application you can run the following rake command:

```rake mondo_tfl:attach_receipts```

This will cycle through each user in the local database and query both TFL & Mondo for TFL journeys.
It will then generate a journey log in a JPG image and then upload to Amazon S3, and register the file with Mondo.

To clear all the attached receipts use the following:

```rake mondo_tfl:clear_receipts```

It will cycle through each user in the local database and deregister the first file attached to each TFL transaction.