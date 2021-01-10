# Email
A simple email server I made as I wasnt able to find any email servers with my use case of being able to send an email from any username on a domain with out doing any config.
## Should you use this
**No** probably not. This is not optimized at all and one wrong json file will cause the whole thing to panic and stop. 
## Setup 
0) Open ports 25 and 80 
1) Create a directory where you want your emails to be saved, I want mine to be in `~/emails/`. 
2) Next create `emails.json` in that directory then put in `{"files":[]}` into it. Next get the exact path of the folder by running `pwd` copy that. 
3) Then clone this repo. 
4) Edit `settings.json` and put in the path into `"emailDir"`. 
5) Then put in a webhook or leave it blank if you don't want one. 
6) Then enter an api key **this is needed** if you dont have it **anyone will be able to read your emails** (If api is enabled). 
7) Then put in your domain you want to have at the end of the user@domain.tld
8) Then compile the project with `v -prod -autofree .` 
9) then run it with `./email`. 
### DNS
If you want to use a custom domain you're going to have to setup dns. 
1) Go to your registars dns settings then add an A record with the name of `email` and set the value to the ip of your server. 
2) Then create an mx record with the name of `@` and the data to `email.[your domain]`. 
3) Then create a text record with the name of `@` and the value of `v=spf1 mx -all`

## Settings
You can enabled/disable parts of the app if you want in the settings. By default everything is enabled.
## API
Replace the url query auth with your auth key in settings.json
### `[ip of your server]/emails?auth=[auth key]`
Get a list of email ids
Example: `[ip]/emails?auth=[auth key]`
### `[ip of your server]/email?id=[id from emails]&auth=[auth key]`
Get a specific email by id
Example: `[ip]/email?auth=[auth key]&id=email2020-12-30%2008:55:05.256.json`
### `[ip of your server]/send?server=[smtp server of the domain of the email you want to send]&from=[who you want it to be from]&to=[who you want to send it to]&subject=[subject of email]&body=[body of email]&auth=[auth key]`
Send an email
Example: `[ip of your server]/send?server=gmail-smtp-in.l.google.com&from=juliette%40juliette.page&to=[gmail user]%40gmail.com&subject=Hi&body=test&auth=[auth key]`
