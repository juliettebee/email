# Email
A simple email server I made as I wasnt able to find any email servers with my use case of being able to send an email from any username on a domain with out doing any config.
## Should you use this
**No** probably not. This is not optimized at all and one wrong json file will cause the whole thing to panic and stop. Along with that you **cannot** send emails.
## Setup 
Create a directory where you want your emails to be saved, I want mine to be in `~/emails/`. Next create `emails.json` in that directory then put in `{"files":[]}` into it. Next get the exact path of the folder by running `pwd`. Mine is `/Users/eu/emails` save that. Then clone this repo. Edit `settings.json` and put in the path into `"emailDir"`. Then put in a webhook or leave it blank if you don't want one. Then enter an api key **this is needed** if you dont have it **anyone will be able to read your emails**. Then compile the project with `v .` then run it with `./email`. 
### DNS
If you want to use a custom domain you're going to have to setup dns. Go to your registars dns settings then add an A record with the name of `email` and set the value to the ip of your server. Then create an mx record with the name of `@` and the data to `email.[your domain]`. 
