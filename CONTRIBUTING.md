# Contributing
## Dependencies
It requires Ruby >2, git, npm for development. It also requires some
development tools for compiling gems' native extensions: ruby-devel,
gcc (including g++).

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
- BDD (coverage as full as possible). RSpec for Ruby, Jasmine for JS.
- Docs. YARD for Ruby, JSDoc for JS.

Optional:
- No warnings from `rubocop` (for Ruby)
- JavaScript: semicolons, max line width = 80.

## Rake tasks
See `Rakefile`

## Code guide
### Back-end
#### Abstraction level 0. Tardvig

First, you need to read the documentation of the tardvig gem, because the
structure of this project is based on it.

#### Abstraction level 1. Core
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

#### Abstraction level 2. Action Core
`Action` is a main type of acts (see its documentation).
Its main part is `Landscape` (hexagonal grid), which consists of `Ground` 
(static surfaces, such as water, mountains, floor) and `Entity`s (objects 
which stands on the ground).

It is important that ground always takes one hexagon. However, entities can 
take multiple places and there are can be many entities at the same place. 
This is why action core also includes `PlaceEntity` for easier movement
of entities and `entities_index`, which contains coordinates for 
"central" points of entities for faster access and recognition of 
central entities' parts.

When action is started, landscape with its content is converted into 
simplier format and sent to front-end.

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
