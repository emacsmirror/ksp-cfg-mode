# KSP-CFG mode

[![MELPA](http://melpa.org/packages/ksp-cfg-mode-badge.svg)](http://melpa.org/#/ksp-cfg-mode) [![BSD3](https://img.shields.io/badge/license-BSD3-43cd80.svg)](LICENSE.md)

A major-mode for editing Kerbal Space Program part (and other things) config files in Emacs.

## Status

* Release 0.4
* Syntactic lex with good (well, enthusiastic and correct if not tasteful) highlighting
* Intelligent automatic indentation
* Context-sensitive advice in the minibuffer

## Changes

* A better region indent and inductive line indent
* Make more features configurable and default-off
* Ensure hooks are buffer-local

## To-Do features

* Set up travis-ci testing across various Emacs releases.
* Support more [ModuleManager](https://github.com/sarbian/ModuleManager) syntaxes; variables, regexps, and node-indexing aren't implemented.
* Refactor context help; a more flexible means of inserting new help tips on a per-module and per-keyword basis would help.
* Better context help for common node-keys and modules.
