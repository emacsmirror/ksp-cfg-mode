# KSP-CFG mode

[![MELPA](http://melpa.org/packages/ksp-cfg-mode-badge.svg)](http://melpa.org/#/ksp-cfg-mode) [![BSD3](https://img.shields.io/badge/license-BSD3-43cd80.svg)](LICENSE.md)

A major-mode for editing Kerbal Space Program part (and other things) config files in Emacs.

## Status

* Syntactic lex with good (well, enthusiastic and correct if not tasteful) highlighting
* Intelligent automatic indentation
* Context-sensitive advice in the minibuffer

## Changes in 0.6

* Ack 2019
* Bump version
* Add emacs 24 req for lexical-binding (still optional)
* Appease checkdoc for symbols in docstrings
* Update cfg node keywords for 1.6.1
* Fix word/symbol syntax table entries for better word motion
* Prefer `forward-line` over `(end-of-line) (forward-char)` for better evil-mode compatibility
* Switch to cl-symbol-macrolet for end-of-indent-region checks for safer handling of over indented region at end-of-buffer.
* Reformat with `indent-tabs-mode`: `nil` because _I can_.
* Adjust `(looking-back)` use for modern Emacs 25.1+ 2-3 argument `looking-back`; should remain compatible with either.

## To-Do features

* Set up travis-ci testing across various Emacs releases.
* Support more [ModuleManager](https://github.com/sarbian/ModuleManager) syntaxes; variables, regexps, and node-indexing aren't implemented.
* Refactor context help; a more flexible means of inserting new help tips on a per-module and per-keyword basis would help.
* Better context help for common node-keys and modules.
