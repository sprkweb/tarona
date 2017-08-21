# Contributing
[![Build Status](https://travis-ci.org/sprkweb/tarona.svg?branch=master)](https://travis-ci.org/sprkweb/tarona)

## Table of Contents

* [Features and Bugs](#features-and-bugs)
* [Installation](#installation)
  * [Dependencies](#dependencies)
  * [How to build](#how-to-build)
* [Code Style](#code-style)
* [Rake Tasks](#rake-tasks)
* [Code Guide](#code-guide)
  * [Back-end](#back-end)
  * [Front-end](#front-end)
* [Maintenance](#maintenance)

## Features and Bugs
**[Issue tracker](https://github.com/sprkweb/tarona/issues)**

You can add your pull request if you want to add any feature or bug fix. Also
you can write an issue if you do not want to/can not do it yourself.

## Installation
#### Dependencies
It requires `ruby v2.x`, `git`, `npm` for development. It also requires some
development tools for compiling gems' native extensions: `ruby-devel`,
`gcc` (including `g++`).

#### How to build
You need to install the `bundler` and `rake` gems first:

    $ gem install bundler
    $ gem install rake

Then you should build this project:

    $ rake

*This process must have access to read and write to the directory of the
project. Internet connection is also needed for dependency installation.*

## Code Style
Required:
- BDD (coverage as full as possible). RSpec for Ruby, Jasmine for JS.
- Docs. YARD for Ruby, JSDoc for JS.

Optional:
- No warnings from `rubocop` (for Ruby)
- JavaScript: semicolons, max line width = 80.

Versioning is SemVer

## Rake Tasks
are useful for development.
See `Rakefile`

## Code Guide
### Back-end
#### Level 0. Tardvig

First, you need to read the documentation of the tardvig gem, because the
structure of this project is based on it.

#### Level 1. Core
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

The important part is saving mechanism. In this level it is realized as
the `#session` attribute of the `Toolkit`. It is hash which contains all the
information about current game state. Whilst game it is filled with the
information in such way that:

1. It contains everything about the game, so
2. it can be saved anytime as YAML file without any additional processing and
  when it is loaded, the game is in the same state.

Therefore, all parts of the game is divided into information and processors.

Information is stored in the `session` and must not contain any events or
attributes which is not contained in the `session`. Examples: `Entity`,
`Ground`, `Landscape`.

Processors base their activity on information from the `session`, not their
attributes (they will be lost as soon as the game is saved and loaded).
Examples: descendants of `PrManager`, `PlaceEntity`, `Pathfinder`.

#### Level 2. Action Core
See `lib/tarona/act_types/action/`.

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
a simplier format and sent to the front-end.

#### Level 3. Extensions for Action
See `lib/tarona/act_types/action/` and `game/classes`.

It is where the game engine ends and the game mechanics begin.

There are a lot of various commands which extends game with their mechanics.
I do not want to list them here, because it is the most actively developing
part of the game. You can just read names of the files from the directories
above.

Some of them, just for example: `Mobilize` command allows player to move some
of his entities and `Death` removes killed entities from map.

### Front-end
See `public/scripts`.

#### Level 1. Core
The front-end structure is similar to back-end. The main part is `Runner`.
It initializes `Messenger` (event-driven wrapper for WebSockets) and, using it,
requests server either to open a new session or to load an old one, depending
on the cookies.

When it gets session information, it gives it to the `Display`, which runs
`generator`s (function which generates DOM for the certain type of acts) when
server runs acts.

#### Level 2. Action.Generator
`Action.Generator` generates hexagonal field and entities on it when the
`Action` is started.

It is extensible through `Scripts`, which are given to it as a part of one
of arguments. They are run at the end of generation. They are used to listen
for events and do something when they happen.

## Maintenance
### Some statements
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
