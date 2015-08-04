# PreSales-Huddle-iOS
This is an iOS app which could be used for interaction between Sales team & Development
Leads. This app uses REST API for fetching and storing data.
The webservice is developed in go and is a submodule in the project.

# Setup
Only setup required is a running go service.
The go service requires sqllite3 database file and few tables created for it.
Please follow instruction to setup webservice on its git hub Readme

To setup submodule run command:

git submodule init
git submodule update

This will pull code from go-webservice git hub project