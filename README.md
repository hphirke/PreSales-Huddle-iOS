# PreSales-Huddle-iOS
This is an iOS app which could be used for interaction between Sales team & Development
Leads. This app uses REST API for fetching and storing data.
The webservice is developed in go and is a submodule in the project.

# Setup
Only setup required is a running go service.
The go service requires sqllite3 database file and few tables created for it.
If you pull the submodule (intructions below), you should get all webservice
code.
Please follow instruction to setup webservice on its git hub Readme
You need to have go compiler for mac to build the binary and then run it.

To setup submodule run command:

- git submodule init
- git submodule update

This will pull code from go-webservice git hub project

or you can use (which will fetch all submodules automatically):
git clone --recursive <PreSales-Huddle-iOS app url>
