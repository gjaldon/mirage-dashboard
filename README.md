# mirage-dashboard

A dashboard displaying useful data from
[MirageOS](https://mirage.io/) project and its related
repositories.

## Overview

MirageOS is continually updating/improving, keeping track of these
changes is tricky.

As part of the [2016 MirageOS Hackathon](http://canopy.mirage.io),
I'm starting this project as a learning exercise.

## What will the dashboard show?

* A list the core MirageOS libraries.
* Data related to each library:
  * Releases
  * Commits since last release
  * Top contributors
  * Build status (release, current...)
  * Dependencies
  * Other things?

## TO DO:

* Use [ocaml-github](https://github.com/mirage/ocaml-github) to
  gather basic data about the _MirageOS_ ecosystem.
* Dump data to JSON
* Crawl dependencies
* Create web-accessible HTML/JS dashboard (static)
* Wrap in Mirage Unikernel
* Cache data to limit GitHub API calls
* Serve publicly

## Done:

* README
* Start with CLI app
