# Contributing
## Dependencies
It requires Ruby >2, git for development.

### Installation
You need to install the `bundler` and `rake` gems first:

    $ gem install bundler
    $ gem install rake
    
Then you should build this project:

    $ rake
    
*This process must have access to read and write to the directory of the 
project. Internet connection is also needed for dependency installation.*

## Features and bugs
You can add your pull request if you want to add any feature or bug fix. Also 
you can write an issue if you do not want/can to do it yourself.
 
## Code style
Required:
- BDD (coverage as full as possible)
- YARD docs

Optional:
- No warnings from `rubocop`

## Rake tasks
See `Rakefile`

## Code guide
First, you need to read the documentation of the tardvig gem, because the
structure of this project is based on it.

Back-end code is written in Ruby language. It is divided into two parts (and
directories): `lib` and `game`. `lib` contents back-end engine and helper
classes, `game` consists of the game itself: acts, texts, etc.

When user runs the game, Rack starts the Rack application `Doorman` which is
proxy for HTTP server and WebSocket server. `Doorman` also starts a new game 
session (which consists of an instance of `Play`) when a new player is connected
through WebSocket.

When user opens the page of the game in his browser, HTTP server gives him it
through Doorman and the JavaScript front-end code connects this page to back-end
through WebSocket. Doorman starts a new `Play` (see above).

Play sequentially runs the parts of the game ("acts"; see the `Act` class), 
passing them some useful objects (`Toolkit`, `GameIO`) during the process.

Entire time all of these objects actively interact with front-end through
WebSocket, changing displayed things.

# Maintenance
## Some statements
*There are some obvious statements. Of course, you already know them.
I am writing them to myself.*
* Only maintainer do things like publishing a new release and he is doing that 
whenever he want.
* Gem file should contain production-ready version. It means no development
files, such as specs, documentation, CVS, dotfiles, `/^[A-Z][a-z]+file$/`, etc. 
It contains only files which are needed in runtime + user documentation,
license.
It also must not require to run rake tasks: files inside the gem must include
non-gem dependencies.

## Versioning
SemVer