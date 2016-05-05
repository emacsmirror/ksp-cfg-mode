;;; KSP-cfg mode --- major mode for editing KSP CFG and ModuleManager files

;; Copyright (c) 2016 Emily Backes

;; Redistribution and use in source and binary forms, with or without
;; modification, are permitted provided that the following conditions
;; are met:
;;
;; * Redistributions of source code must retain the above copyright
;;   notice, this list of conditions and the following disclaimer.
;;
;; * Redistributions in binary form must reproduce the above copyright
;;   notice, this list of conditions and the following disclaimer in
;;   the documentation and/or other materials provided with the
;;   distribution.
;;
;; * Neither the names of the authors nor the names of contributors
;;   may be used to endorse or promote products derived from this
;;   software without specific prior written permission.
;;
;; THIS SOFTWARE IS PROVIDED BY THE AUTHORS ``AS IS'' AND ANY EXPRESS
;; OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
;; WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
;; ARE DISCLAIMED.  IN NO EVENT SHALL THE AUTHORS BE LIABLE FOR ANY
;; DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
;; DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE
;; GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
;; INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
;; WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
;; NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
;; SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

;; Author: Emily Backes <lucca@accela.net>
;; Keywords: languages games modding

;;; Commentary:

;; This defines a new major mode for KSP modding of part files that
;; provides syntax highlighting and intelligent indentation.

;; todo:
;; * support the ModuleManager variable and regexp syntaxes
;; * refactor context help
;; * better context help for common keys and modules

;;; Code:

(require 'cl-lib)

(defgroup ksp-cfg nil
  "Major mode for editing Kerbal Space Program cfg files in Emacs."
  :group 'languages
  :prefix "ksp-cfg-")

(defcustom ksp-cfg-basic-indent 8
  "Indentation of KSP cfg structures inside curly braces.  Squad
seems to use 8."
  :type 'integer
  :group 'ksp-cfg
  :safe t)

(defcustom ksp-cfg-idle-help-p t
  "Display context-sensitive help when idle."
  :type 'boolean
  :group 'ksp-cfg
  :risky t)

(defcustom ksp-cfg-idle-delay 0.125
  "Number of seconds idle time to wait before trying to help the
user based on context.  `ksp-cfg-idle-help-p' must be non-nil."
  :type 'number
  :group 'ksp-cfg
  :risky t)

(defgroup ksp-cfg-faces nil
  "Configure the faces used by ksp-cfg font locking."
  :group 'ksp-cfg
  :group 'faces
  :prefix "ksp-cfg-")

(defvar ksp-cfg-node-face 'ksp-cfg-node-face)
(defface ksp-cfg-node-face
  '((t (:inherit font-lock-type-face)))
  "Face for KSP-cfg nodes, used to open brace-blocks like PART, MODULE, etc."
  :group 'ksp-cfg-faces)

(defvar ksp-cfg-key-face 'ksp-cfg-key-face)
(defface ksp-cfg-key-face
  '((t (:inherit font-lock-variable-name-face)))
  "Face for KSP-cfg keys, which come before = inside nodes."
  :group 'ksp-cfg-faces)

(defvar ksp-cfg-name-face 'ksp-cfg-name-face)
(defface ksp-cfg-name-face
  '((t (:inherit font-lock-variable-name-face :slant italic)))
 "Face for KSP-cfg names, as in \[name\] or name = ..."
  :group 'ksp-cfg-faces)

(defvar ksp-cfg-constant-face 'ksp-cfg-constant-face)
(defface ksp-cfg-constant-face
  '((default :inherit font-lock-constant-face))
  "Face for KSP-cfg known constants, like true and false."
  :group 'ksp-cfg-faces)

(defvar ksp-cfg-number-face 'ksp-cfg-number-face)
(defface ksp-cfg-number-face
  '((t (:inherit font-lock-string-face)))
 "Face for KSP-cfg numbers."
  :group 'ksp-cfg-faces)

(defvar ksp-cfg-filter-face 'ksp-cfg-filter-face)
(defface ksp-cfg-filter-face
  '((t (:inherit font-lock-builtin-face)))
  "Face for KSP-cfg filters, such as :HAS :NEEDS and :FINAL."
  :group 'ksp-cfg-faces)

(defvar ksp-cfg-operator-face 'ksp-cfg-operator-face)
(defface ksp-cfg-operator-face
  '((t (:inherit font-lock-keyword-face)))
  "Face for KSP-cfg operators."
  :group 'ksp-cfg-faces)

;; Generated from KSP 1.1.2 using something like:
;; $ find ~/.local/share/Steam/SteamApps/common/Kerbal\ Space\ Program/GameData/Squad -type f -name \*.cfg -print0 |xargs -0 grep '^\s*[A-Z]' |grep -v = |cut -d: -f2 |perl -pe 's/^\s+//; s[//.*$][]; s/\s+$//; $_="\"$_\"\n"' |sort -u |tr \\n \  |fmt

(defvar ksp-cfg-node-types
  '("Adjectives" "Adjunctives" "Adverbs" "AGENT" "ARM" "AUDIO" "Base"
    "BIOME_RESOURCE" "Bridges" "BriefingConclusions" "CharacterAttributes"
    "Characters" "Circumstances" "CONSTRAINFX" "CONSTRAINLOOKFX"
    "CONSTRAINT" "ContractBackstory" "Contracts" "CREW_REQUEST" "Distribution"
    "DRAG_CUBE" "EFFECT" "EFFECTS" "Exceptional" "Excuses" "EXPERIENCE_TRAIT"
    "EXPERIMENT_DEFINITION" "Expiration" "FactLeadIns" "Facts" "Flag" "Funds"
    "GLOBAL_RESOURCE" "Grand" "INPUT_RESOURCE" "INTERNAL" "IonPlume" "ISRU"
    "LeadIns" "MODEL" "MODEL_MULTI_PARTICLE" "MODEL_PARTICLE" "MODULE"
    "MODULE_DEFINITIONS" "ObjectPredicates" "OUTPUT_RESOURCE" "PARAM"
    "Parent" "PART" "PART_REQUEST" "PassiveEnergy" "PLANETARY_RESOURCE"
    "Predicates" "PREFAB_PARTICLE" "Progression" "PROP" "PROPELLANT"
    "RDNode" "Recovery" "Reputation" "RESOURCE" "RESOURCE_CONFIGURATION"
    "RESOURCE_DEFINITION" "RESOURCE_OVERLAY_CONFIGURATION_DOTS"
    "RESOURCE_OVERLAY_CONFIGURATION_LINES"
    "RESOURCE_OVERLAY_CONFIGURATION_SOLID" "RESOURCE_PROCESS"
    "RESOURCE_REQUEST" "RESULTS" "Satellite" "Science" "Significant"
    "Situations" "Station" "STORY_DEF" "STRATEGY" "STRATEGY_DEPARTMENT"
    "Survey" "SURVEY_DEFINITION" "TechTree" "TemperatureModifier" "Test"
    "ThermalEfficiency" "Thrust" "Tour" "Trivial" "TUTORIAL")
  "A list of strings describing the node type keywords known to KSP.")

;;; Generated from ModuleManager 2.6.23
;;; $ perl -ne 'next unless /":([a-z]+)\[?"/i; print "\"$1\"\n"' moduleManager.cs |sort -u |fmt
(defvar ksp-cfg-filter-types
  '("AFTER" "BEFORE" "FINAL" "FIRST" "FOR" "HAS" "LEGACY" "NEEDS")
  "A list of :FILTER operations from ModuleManager.")

(defvar ksp-cfg-wildcarded-name-regexp
  "\\(?:\\s_+\\|\\*\\|\\?\\)+")

(defvar ksp-cfg-node-decl-regexp
  (concat "\\([-@+$!%]?\\)\\("
	  (regexp-opt ksp-cfg-node-types 'symbols)
	  "\\)\\(?:\\[\\("
	  ksp-cfg-wildcarded-name-regexp
	  "\\)\\]\\)?"))

(defun ksp-cfg-explain-node-decl ()
  (let ((op (match-string 1))
	(node-type (match-string 2))
	(target (match-string 4)))
    (message "%s%s: %s %s node%s"
	     op
	     node-type
	     (cl-case (string-to-char op)
	       (?@ "edit an existing")
	       ((?+ ?$) "copy an existing")
	       ((?- ?!) "delete an existing")
	       (?% "edit or create a new")
	       (t "create a new"))
	     node-type
	     (if target (concat " named " target) ""))))

(defvar ksp-cfg-filter-spec-regexp
  (concat ":\\(" (regexp-opt ksp-cfg-filter-types 'symbols) "\\)"))

(defun ksp-cfg-explain-filter-spec ()
  (let ((filter-type (match-string 1))
	(decased-type (upcase (match-string 1))))
    (message ":%s%s" filter-type
	     (cond
	      ((equal decased-type "HAS")
	       "[...]: filter by nodes that have ...")
	      ((equal decased-type "NEEDS")
	       "[...]: apply this patch only if ... is present")
	      ((equal decased-type "FIRST")
	       ": apply this patch in the first pass")
	      ((equal decased-type "LEGACY")
	       ": apply this patch in the legacy pass -- don't use this")
	      ((equal decased-type "BEFORE")
	       "[modname]: apply this patch before the patches for modname")
	      ((equal decased-type "FOR")
	       "[modname]: apply this patch with the patches for modname")
	      ((equal decased-type "AFTER")
	       "[modname]: apply this patch after the patches for modname")
	      ((equal decased-type "FINAL")
	       ": apply this patch in the final pass, after all others")))))

(defvar ksp-cfg-filter-payload-regexp
  (concat "\\([,&|]?\\)\\([-!@#~]\\)\\(\\s_+\\)\\(?:\\[\\("
	  ksp-cfg-wildcarded-name-regexp
	  "\\)\\]\\)?"))

(defun ksp-cfg-explain-filter-payload ()
  (let ((outer-context (match-string 1))
	(inner-operator (match-string 2))
	(symbol-operand (match-string 3))
	(symbol-target (or (match-string 4) "...none yet ...")))
    (message "filter payload: %s%s%s"
	     outer-context
	     (cl-case (string-to-char outer-context)
	       (?| ": OR ... ")
	       ((?& ?,) ": AND ... ")
	       (t "(no outer context) "))
	     (format
	      (cl-case (string-to-char inner-operator)
		(?@ "%s: include %s nodes matching %s")
		((?! ?-) "%s: exclude %s nodes matching %s")
		(?# "%s: include %s keys matching %s")
		(?~ "%s: exclude %s keys matching %s"))
	      inner-operator
	      symbol-operand
	      symbol-target))))

(defvar ksp-cfg-keywords nil)
(setq ksp-cfg-keywords
      `((,ksp-cfg-node-decl-regexp
	 (1 ksp-cfg-operator-face)
	 (2 ksp-cfg-node-face)
	 (4 ksp-cfg-name-face nil t))
	("^\\s-*\\(\\s.?\\)\\(name\\)\\s-*=\\s-*\\(\\s_+\\)\\s-*$"
	 (1 ksp-cfg-operator-face)
	 (2 ksp-cfg-key-face)
	 (3 ksp-cfg-name-face))
	("^\\s-*\\(\\s.?\\)\\(\\s_+\\)\\s-*\\s.?="
	 (1 ksp-cfg-operator-face)
	 (2 ksp-cfg-key-face))
	("\\([#~]\\)\\(\\s_+\\)"
	 (1 ksp-cfg-operator-face)
	 (2 ksp-cfg-key-face))
	("\\_<\\([Tt]rue\\|[Ff]alse\\)\\_>"
	 (1 ksp-cfg-constant-face))
	("\\(-?\\_<[0-9]+\\(?:\\.[0-9]+\\)?\\(?:[eE][-+]?[0-9]+\\)?\\)\\_>"
	 (1 ksp-cfg-number-face))
	(,(concat "\\(:" (regexp-opt ksp-cfg-filter-types 'symbols) "\\)")
	 (1 ksp-cfg-filter-face))))

(defvar ksp-cfg-mode-syntax-table
  (let ((st (make-syntax-table)))
    (modify-syntax-entry '(?! . ?~) "." st)
    (modify-syntax-entry '(?A . ?Z) "_" st)
    (modify-syntax-entry '(?a . ?z) "_" st)
    (modify-syntax-entry '(?0 . ?9) "_" st)
    (modify-syntax-entry ?_ "_" st)
    (modify-syntax-entry ?\  " " st)
    (modify-syntax-entry ?\t " " st)
    (modify-syntax-entry ?\{ "(\}" st)
    (modify-syntax-entry ?\} ")\{" st)
    (modify-syntax-entry ?\[ "(\]" st)
    (modify-syntax-entry ?\] ")\[" st)
    (modify-syntax-entry ?\n "> " st)
    (modify-syntax-entry ?\r "> " st)
    (modify-syntax-entry ?/ ". 12" st)
    ;;; note specifically that parens do not behave as parens.
    st)
  "Syntax table used in ksp-cfg-mode buffers.")

(defvar ksp-cfg-mode-abbrev-table nil
  "Abbreviation table used in ksp-cfg-mode buffers.")
(define-abbrev-table 'ksp-cfg-mode-abbrev-table '())

(defvar ksp-cfg-mode-map
  (let ((map (make-sparse-keymap "KSP-cfg mode")))
    (define-key map "\C-c\C-c" 'comment-region)
    map)
  "Keymap used in ksp-cfg-mode buffers.")

(defun ksp-cfg-region-balance (start end)
  "Determine the structural balance across the described region
by examining braces.

Currently this is called with start at (point-min), so it scans
from the beginning of the buffer for any region, which is not a
good idea for full-buffer re-indentation (O(n^2)).  As KSP
configs are generally fairly small, this will do for now.

This simple lexer does understand and handle the // so that
commented structures do not interfere with indentation."
  (save-excursion
    (cl-loop
     initially (progn
		 (goto-char start)
		 (skip-chars-forward "^{}/" end))
     when (looking-at "{") sum +1 into balance
     when (looking-at "}") sum -1 into balance
     when (looking-at "//") do (progn
				 (end-of-line)
				 (backward-char))
     do (progn
	  (forward-char)
	  (skip-chars-forward "^{}/" end))
     until (>= (point) end)
     finally return balance)))

(defun ksp-cfg-indent-line ()
  "Intelligently indent the current line according to `ksp-cfg-basic-indent'."
  (save-excursion
    (let* ((origin (point))
	   (bol (progn (beginning-of-line) (point)))
	   (eol (progn (end-of-line) (point)))
	   (nest (ksp-cfg-region-balance (point-min) eol))
	   (local-change (ksp-cfg-region-balance bol eol))
	   (goal (* ksp-cfg-basic-indent
		    (- nest (max 0 local-change))))
	   (delta (- goal (current-indentation))))
      (when (and (>= goal 0) (not (zerop delta)))
	(indent-rigidly bol eol delta)))))

(defun ksp-cfg-cleanup ()
  "Perform various cleanups of the buffer; this will re-indent,
convert spaces to tabs, and perform general whitespace cleanup
like trailing blank removal."
  (interactive)
  (tabify (point-min) (point-max))
  (indent-region (point-min) (point-max))
  (whitespace-cleanup))

;; shamelessly borrowed timer from eldoc-mode
(defvar ksp-cfg-timer nil
  "KSP-cfg's timer object.")
(defvar ksp-cfg-current-idle-delay ksp-cfg-idle-delay
  "Idle time delay in use by KSP-cfg's timer; this is used to
notice changes to `ksp-cfg-idle-delay'.")

(defun ksp-cfg-schedule-timer ()
  (or (and ksp-cfg-timer
	   (memq ksp-cfg-timer timer-idle-list))
      (setq ksp-cfg-timer
	    (run-with-idle-timer
	     ksp-cfg-idle-delay nil
	     (lambda () (ksp-cfg-show-help)))))
  (cond ((not (= ksp-cfg-idle-delay ksp-cfg-current-idle-delay))
	 (setq ksp-cfg-current-idle-delay ksp-cfg-idle-delay)
	 (timer-set-idle-time ksp-cfg-timer ksp-cfg-idle-delay t))))

(defun ksp-cfg-in-value-of-key-p (key)
  "True if point is inside the value part of a node's key named key."
  (save-excursion
    (let ((origin (point))
	  (bol (progn (beginning-of-line) (point)))
	  (re (concat "^\\s-*\\s.?" key "\\s-*=")))
      (search-forward-regexp re origin t))))

(defun ksp-cfg-show-help ()
  "Try to display a relevant help message for the context around
point.  Ensures the message doesn't go to the *Messages* buffer."
  (let ((message-log-max nil))
    (and
     (not (or this-command
	      executing-kbd-macro
	      (bound-and-true-p edebug-active)))
     (save-excursion
       ;; Well, let's see what we find.
       (let* ((origin (point))
	      (bol (progn (beginning-of-line) (point)))
	      (eol (progn (end-of-line) (point))))
	 (goto-char origin)

	 ;; Backup a step if we're off the end of the line.
	 (when (and (eolp)
		    (not (bolp)))
	   (backward-char))

	 ;; Ensure we aren't still bonking our heads on the end of the buffer.
	 (when (not (eobp))
	   ;; Backup past the boring pair-closes
	   (skip-syntax-backward ")-" bol)

	   ;; If we're looking at something that might be a symbol, find
	   ;; the beginning.
	   (when (eq (char-syntax (char-after)) ?_)
	     (skip-syntax-backward "_" bol))

	   ;; and the beginning of any prefixed punctuation
	   (skip-syntax-backward "." bol)

	   ;; but if that puts us at the start of a [...], then do that
	   ;; again, unless it's a :has
	   (when (and (eq (char-before) ?\[)
		      (not (looking-back ":HAS\\[" bol)))
	     (backward-char)
	     (skip-syntax-backward "_" bol)
	     (skip-syntax-backward "." bol))

	   (cond
	    ((looking-at ".*=") nil) ;; no help for keys yet
	    ((and (looking-at ksp-cfg-node-decl-regexp)
		  (not (looking-back ":HAS\\[")))
	     (ksp-cfg-explain-node-decl))
	    ((looking-at ksp-cfg-filter-spec-regexp)
	     (ksp-cfg-explain-filter-spec))
	    ((looking-at ksp-cfg-filter-payload-regexp)
	     (ksp-cfg-explain-filter-payload))
	    ((in-value-of-key-p "attachRules")
	     (message "%s" "attachRules: list of numbers (0=false, 1=true): stack, srfAttach, allowStack, allowSrfAttach, allowCollision"))
	    ((in-value-of-key-p "name")
	     (message "%s" "name: sets the name of this node"))
	    (t nil))))))))

(defun ksp-cfg-clear-message ()
  "Clear the message display, if any."
  (let ((message-log-max nil))
    (message nil)))

(define-derived-mode ksp-cfg-mode fundamental-mode "KSP-cfg"
  "Major mode for editing Kerbal Space Program configuration files for
use in modding parts, etc.

\\<ksp-cfg-mode-map>"
  :group 'ksp-cfg
  (setq-local local-abbrev-tables ksp-cfg-mode-abbrev-table)
  (setq-local case-fold-search t)
  (setq-local comment-start "//")
  (setq-local comment-start-skip "//+\\s-*")
  (setq-local comment-end "")
  (setq-local indent-line-function 'ksp-cfg-indent-line)
  (setq-local font-lock-defaults '(ksp-cfg-keywords nil t nil))
  (setq-local indent-tabs-mode t)
  (add-hook 'post-command-hook 'ksp-cfg-schedule-timer nil t)
  (add-hook 'pre-command-hook 'ksp-cfg-clear-message nil t)
  (ksp-cfg-cleanup)
  (font-lock-fontify-buffer))

(provide 'ksp-cfg-mode)

;;; ksp-cfg-mode.el ends here
