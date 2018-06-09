# KSP-CFG mode

[![MELPA](http://melpa.org/packages/ksp-cfg-mode-badge.svg)](http://melpa.org/#/ksp-cfg-mode) [![BSD3](https://img.shields.io/badge/license-BSD3-43cd80.svg)](LICENSE.md)

A major-mode for editing Kerbal Space Program part (and other things) config files in Emacs.

## Status

* Release 0.5.1
* Syntactic lex with good (well, enthusiastic and correct if not tasteful) highlighting
* Intelligent automatic indentation
* Context-sensitive advice in the minibuffer

## Changes

* Basic updates for KSP 1.4.3
* Reluctantly acknowlege 2018

## To-Do features

* Set up travis-ci testing across various Emacs releases.
* Support more [ModuleManager](https://github.com/sarbian/ModuleManager) syntaxes; variables, regexps, and node-indexing aren't implemented.
* Refactor context help; a more flexible means of inserting new help tips on a per-module and per-keyword basis would help.
* Better context help for common node-keys and modules.
