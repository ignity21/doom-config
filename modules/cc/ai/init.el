;;; -*- lexical-binding: t; no-byte-compile: t; -*-
;;; cc/ai/init.el

;; User options for the :cc ai module.  `modules/README.org' requires a
;; module's user options to be defined in its init.el (loaded early, before
;; $DOOMDIR/config.el sets values from custom-vars.el).

(defcustom cc/openai-api-key ""
  "The API key for OpenAI."
  :type 'string
  :group 'cc-ai)

(defcustom cc/anthropic-api-key ""
  "The API key for Anthropic."
  :type 'string
  :group 'cc-ai)

(defcustom cc/deepseek-api-key ""
  "The API key for DeepSeek."
  :type 'string
  :group 'cc-ai)

(defcustom cc/gemini-api-key ""
  "The API key for Gemini."
  :type 'string
  :group 'cc-ai)

(defcustom cc/gptel-enable-copilot nil
  "Whether to enable GitHub Copilot as a gptel backend."
  :type 'boolean
  :group 'cc-ai)

(defcustom cc/gptel-enable-openai-sub nil
  "Whether to enable the ChatGPT subscription (OAuth) gptel backend.

Registered as \"openai-sub\" via `gptel-make-openai-oauth'.  Run
`gptel-openai-oauth-login' once to authenticate."
  :type 'boolean
  :group 'cc-ai)

(defcustom cc/gptel-default-backend 'deepseek
  "The default backend for gptel.

Besides the built-in providers below, this may be set to the `:id' of
any entry in `cc/gptel-openai-compatible-vendors'."
  :type '(choice
           (const :tag "DeepSeek" deepseek)
           (const :tag "OpenAI" openai)
           (const :tag "Anthropic" anthropic)
           (const :tag "Gemini" gemini)
           (const :tag "GitHub Copilot" copilot)
           (const :tag "ChatGPT subscription" openai-sub)
           (symbol :tag "Custom vendor :id"))
  :group 'cc-ai)

(defcustom cc/gptel-magit-backend nil
  "gptel backend for `gptel-magit' (commit messages, diff explain).

nil uses the active `gptel-backend'.  Otherwise a key into
`cc/gptel-backends': a built-in provider symbol (`deepseek', `openai',
...) or a custom vendor `:id'.  Set `cc/gptel-magit-model' as well when
the chosen model belongs to this backend."
  :type '(choice (const :tag "Active backend" nil)
           (symbol :tag "Registry key"))
  :group 'cc-ai)

(defcustom cc/gptel-magit-model nil
  "gptel model for `gptel-magit'; nil uses `gptel-model'."
  :type '(choice (const :tag "Default model" nil) (symbol :tag "Model"))
  :group 'cc-ai)

(defcustom cc/gptel-openai-compatible-vendors nil
  "Custom OpenAI-compatible backends to register with gptel.

Each element is a plist with the following keys:

  :id       (symbol, optional) Registry key, also usable as the value of
            `cc/gptel-default-backend'.  Defaults to a slug of :name
            (lower-cased, non-alphanumeric runs turned into `-').
  :name     (string, required) Backend name shown in gptel; must differ
            from the built-in backend names.
  :host     (string, required) API host, e.g. \"api.groq.com\".
  :key      (string, required) API key.
  :models   (list, required) Model list; each element is a symbol or a
            (symbol . plist) full spec (see `gptel-make-openai').
  :endpoint (string, optional) Defaults to \"/v1/chat/completions\".
  :protocol (string, optional) Defaults to \"https\".
  :stream   (boolean, optional) Defaults to t.
  :header / :request-params / :curl-args (optional) Passed through to
  `gptel-make-openai'."
  :type '(repeat plist)
  :group 'cc-ai)

(defcustom cc/gptel-file-tool-roots nil
  "Directories that gptel file tools may access.

Each entry and all of its descendants are accessible.  Relative paths
supplied by the model are resolved against the first entry.  When nil,
access is limited to the current project root, or `default-directory'
when the current buffer does not belong to a project."
  :type '(repeat directory)
  :group 'cc-ai)
