# Email
A simple email server I made as I wasnt able to find any email servers with my use case of being able to send an email from any username on a domain with out doing any config.
## Should you use this
**No** probably not. This is not optimized at all and one wrong json file will cause the whole thing to panic and stop. 
## Setup 
1) Create a directory where you want your emails to be saved, I want mine to be in `~/emails/`. 
2) Next create `emails.json` in that directory then put in `{"files":[]}` into it. Next get the exact path of the folder by running `pwd` copy that. 
3) Then clone this repo. 
4) Edit `settings.json` and put in the path into `"emailDir"`. 
5) Then put in a webhook or leave it blank if you don't want one. 
6) Then enter an api key **this is needed** if you dont have it **anyone will be able to read your emails**. 
7) Then put in your domain you want to have at the end of the user@domain.tld
8) Then compile the project with `v -prod -autofree .` 
9) then run it with `./email`. 
### DNS
If you want to use a custom domain you're going to have to setup dns. 
1) Go to your registars dns settings then add an A record with the name of `email` and set the value to the ip of your server. 
2) Then create an mx record with the name of `@` and the data to `email.[your domain]`. 
3) Then create a text record with the name of `@` and the value of `v=spf1 mx -all`
