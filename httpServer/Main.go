package main

import (
	"encoding/json"
	"fmt"
	"github.com/DusanKasan/parsemail"
	"github.com/google/uuid"
	"github.com/pollen5/discord-oauth2"
	"golang.org/x/oauth2"
	"html/template"
	"net/http"
	"os"
	"path/filepath"
	"strconv"
)

type EmailReturn struct {
	Index   int
	Sender  string
	Subject string
	Body    string
}

type PageData struct {
	Subject string
	To      string
	From    string
	Body    string
	Html    bool
	Id      int
}

type EmailListData struct {
	Emails []EmailReturn
}

type DiscordResponse struct {
	Id       string
	Username string
	Avatar   string
	Tag      string
}

// Todo: generate this randomly
var state = uuid.New().String()
var authorized = uuid.New().String()

// todo: fix this mess
func CheckAuth(r *http.Request) bool {
	// Check for auth cookie
	cookie, err := r.Cookie("auth")

	if err != nil {
		return false
	}

	value := cookie.Value

	if value == authorized {
		return true
	}
	return false
}

func getFiles(folder string) ([]parsemail.Email, []EmailReturn, []string) {
	// Next, getting all the files in it and parsing
	files := []string{}
	filepath.Walk(folder, func(path string, f os.FileInfo, err error) error {
		files = append(files, path)
		return nil
	})
	// Now that we have the files we neeed to parse
	emails := []parsemail.Email{}
	emailReturn := []EmailReturn{}
	fileNames := []string{}
	i := 0
	for _, file := range files {
		reader, err := os.Open(file)

		if err != nil {
			fmt.Println("Unable to open file")
			continue
		}

		email, err := parsemail.Parse(reader)

		if err != nil {
			fmt.Println(err)
			fmt.Println("Unable to parse email")
			continue
		}

		ret := EmailReturn{
			Index:   i,
			Sender:  email.From[0].Address,
			Subject: email.Subject,
			Body:    email.TextBody,
		}

		emails = append(emails, email)
		emailReturn = append(emailReturn, ret)
		fileNames = append(fileNames, file)
		i++
	}
	return emails, emailReturn, fileNames
}

func main() {
	if len(os.Args) < 6 {
		fmt.Printf("%s [path to email storage] [discord client id] [discord client secret] [allowed discord user id] [device ip]", os.Args[0])
		os.Exit(0)
	}
	// Setting the args
	folder := os.Args[1]
	clientId := os.Args[2]
	clientSecret := os.Args[3]
	allowed := os.Args[4]
    deviceIP := os.Args[5]
	emails, emailReturn, fileNames := getFiles(folder)
	// Now that we have that we can make the template
	emailTemplate := template.Must(template.ParseFiles("public/email.html"))
	emailsTemplate := template.Must(template.ParseFiles("public/emails.html"))
	// Setting up oauth
    redirectURL := fmt.Sprintf("http://%s/auth/callback", deviceIP)
	conf := &oauth2.Config{
		RedirectURL:  redirectURL,
		ClientID:     clientId,
		ClientSecret: clientSecret,
		Scopes:       []string{discord.ScopeIdentify},
		Endpoint:     discord.Endpoint,
	}
	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		// Check for auth cookie
		log := CheckAuth(r)
		if log {
			http.Redirect(w, r, "/emails", http.StatusTemporaryRedirect)
			return
		}
		// Redirect to signin
		http.Redirect(w, r, conf.AuthCodeURL(state), http.StatusTemporaryRedirect)
	})
	// Handle callback
	http.HandleFunc("/auth/callback", func(w http.ResponseWriter, r *http.Request) {
		if r.FormValue("state") != state {
			w.WriteHeader(http.StatusBadRequest)
			w.Write([]byte("State does not match."))
			return
		}
		token, err := conf.Exchange(oauth2.NoContext, r.FormValue("code"))

		if err != nil {
			w.WriteHeader(http.StatusInternalServerError)
			w.Write([]byte(err.Error()))
			return
		}
		res, err := conf.Client(oauth2.NoContext, token).Get("https://discordapp.com/api/users/@me")
		defer res.Body.Close()
		decoder := json.NewDecoder(res.Body)

		var data DiscordResponse
		err = decoder.Decode(&data)
		if err != nil {
			fmt.Fprintf(w, "Uhh")
			return
		}

		if allowed == data.Id {
			cookie := http.Cookie{
				Name:     "auth",
				Value:    authorized,
				MaxAge:   86400,
				HttpOnly: false,
				Path:     "/",
			}
			http.SetCookie(w, &cookie)
			// We cant redirect because of a safari bug so we need to send user to another page
			fmt.Fprintf(w, "<a href=\"/emails\">Emails</a>")
		} else {
			fmt.Fprint(w, "Bye!")
		}
	})
	// Listening
	http.HandleFunc("/emails", func(w http.ResponseWriter, r *http.Request) {
		isAuth := CheckAuth(r)
		if isAuth == false {
			http.Redirect(w, r, conf.AuthCodeURL(state), http.StatusTemporaryRedirect)
			return
		}
		// Refreshing email list
		emails, emailReturn, fileNames = getFiles(folder)

		data := EmailListData{
			Emails: emailReturn,
		}
		emailsTemplate.Execute(w, data)
	})
	http.HandleFunc("/email", func(w http.ResponseWriter, r *http.Request) {
		isAuth := CheckAuth(r)
		if isAuth == false {
			http.Redirect(w, r, conf.AuthCodeURL(state), http.StatusTemporaryRedirect)
			return
		}
		// Getting email id
		id := r.URL.Query().Get("id")
		if id == "" {
			fmt.Fprintf(w, "You need an id!")
			return
		}
		// Converting to int
		idInt, err := strconv.Atoi(id)
		if err != nil {
			fmt.Fprintf(w, "Unable to convert int!")
			return
		}
		// Getting the email
		email := emails[idInt]
		body := email.TextBody
		ishtml := false
		if email.HTMLBody != "" {
			body = email.HTMLBody
			ishtml = true
		}
		// Now running the template
		data := PageData{
			Subject: email.Subject,
			To:      email.To[0].Address,
			From:    email.From[0].Address,
			Body:    body,
			Html:    ishtml,
			Id:      idInt,
		}
		emailTemplate.Execute(w, data)
	})

	http.HandleFunc("/api/raw", func(w http.ResponseWriter, r *http.Request) {
		isAuth := CheckAuth(r)
		if isAuth == false {
			http.Redirect(w, r, conf.AuthCodeURL(state), http.StatusTemporaryRedirect)
			return
		}
		// Getting email id
		id := r.URL.Query().Get("id")
		if id == "" {
			fmt.Fprintf(w, "You need an id!")
			return
		}
		// Converting to int
		idInt, err := strconv.Atoi(id)
		if err != nil {
			fmt.Fprintf(w, "Unable to convert int!")
			return
		}

		email := emails[idInt]
		if email.HTMLBody != "" {
			fmt.Fprintf(w, email.HTMLBody)
		} else {
			fmt.Fprintf(w, "Not html!")
		}
	})
	http.HandleFunc("/api/delete", func(w http.ResponseWriter, r *http.Request) {
		isAuth := CheckAuth(r)
		if isAuth == false {
			http.Redirect(w, r, conf.AuthCodeURL(state), http.StatusTemporaryRedirect)
			return
		}
		// Getting email id
		id := r.URL.Query().Get("id")
		if id == "" {
			fmt.Fprintf(w, "You need an id!")
			return
		}
		// Converting to int
		idInt, err := strconv.Atoi(id)
		if err != nil {
			fmt.Fprintf(w, "Unable to convert int!")
			return
		}
		emails = append(emails[idInt:], emails[idInt+1:]...)
		emailReturn = append(emailReturn[idInt:], emailReturn[idInt+1:]...)
		os.Remove(fileNames[idInt])
		fileNames = append(fileNames[idInt:], fileNames[idInt+1:]...)

	})

    http.HandleFunc("/api/emails", func(w http.ResponseWriter, r *http.Request) {
		isAuth := CheckAuth(r)
		if isAuth == false {
			http.Redirect(w, r, conf.AuthCodeURL(state), http.StatusTemporaryRedirect)
			return
		}
    })

	http.ListenAndServe(":80", nil)

}
