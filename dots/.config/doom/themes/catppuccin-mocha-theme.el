;;; catppuccin-mocha-theme.el --- Catppuccin Mocha -*- lexical-binding: t; no-byte-compile: t; -*-
;;
;; Based on doom-one-theme.el
;; Palette: Catppuccin Mocha
;;
;;; Commentary:
;;
;; Catppuccin Mocha theme for Doom Emacs.
;;
;;; Code:

(require 'doom-themes)


;;
;;; Variables

(defgroup catppuccin-mocha-theme nil
  "Options for the `catppuccin-mocha' theme."
  :group 'doom-themes)

(defcustom catppuccin-mocha-brighter-modeline nil
  "If non-nil, more vivid colors will be used to style the mode-line."
  :group 'catppuccin-mocha-theme
  :type 'boolean)

(defcustom catppuccin-mocha-brighter-comments nil
  "If non-nil, comments will be highlighted in more vivid colors."
  :group 'catppuccin-mocha-theme
  :type 'boolean)

(defcustom catppuccin-mocha-comment-bg catppuccin-mocha-brighter-comments
  "If non-nil, comments will have a subtle highlight to enhance their
legibility."
  :group 'catppuccin-mocha-theme
  :type 'boolean)

(defcustom catppuccin-mocha-padded-modeline doom-themes-padded-modeline
  "If non-nil, adds a 4px padding to the mode-line.
Can be an integer to determine the exact padding."
  :group 'catppuccin-mocha-theme
  :type '(choice integer boolean))


;;
;;; Theme definition

(def-doom-theme catppuccin-mocha
  "A dark theme based on Catppuccin Mocha."
  :family 'catppuccin-mocha
  :background-mode 'dark

  ;; name        default       256             16
  ((bg         '("#1e1e2e" "black"         "black"))
   (fg         '("#cdd6f4" "#bfbfbf"       "brightwhite"))

   ;; These are off-color variants of bg/fg, used primarily for `solaire-mode',
   ;; but can also be useful as a basis for subtle highlights (e.g. for hl-line
   ;; or region), especially when paired with the `doom-darken', `doom-lighten',
   ;; and `doom-blend' helper functions.
   (bg-alt     '("#181825" "black"         "black"))
   (fg-alt     '("#a6adc8" "#a0a0a0"       "white"))

   ;; These should represent a spectrum from bg to fg, where base0 is a starker
   ;; bg and base8 is a starker fg. For example, if bg is light grey and fg is
   ;; dark grey, base0 should be white and base8 should be black.
   (base0      '("#11111b" "black"         "black"))
   (base1      '("#181825" "#1e1e1e"       "brightblack"))
   (base2      '("#1e1e2e" "#2e2e2e"       "brightblack"))
   (base3      '("#313244" "#262626"       "brightblack"))
   (base4      '("#45475a" "#3f3f3f"       "brightblack"))
   (base5      '("#585b70" "#525252"       "brightblack"))
   (base6      '("#6c7086" "#6b6b6b"       "brightblack"))
   (base7      '("#9399b2" "#979797"       "brightblack"))
   (base8      '("#cdd6f4" "#dfdfdf"       "brightwhite"))

   (grey       base4)
   (red        '("#f38ba8" "#ff8787"       "red"))
   (orange     '("#fab387" "#ffaf87"       "brightred"))
   (green      '("#a6e3a1" "#afff87"       "green"))
   (teal       '("#94e2d5" "#87ffd7"       "brightgreen"))
   (yellow     '("#f9e2af" "#ffd787"       "yellow"))
   (blue       '("#89b4fa" "#87afff"       "brightblue"))
   (dark-blue  '("#45475a" "#5f5f87"       "blue"))
   (magenta    '("#cba6f7" "#d7afff"       "brightmagenta"))
   (violet     '("#b4befe" "#afafff"       "magenta"))
   (cyan       '("#89dceb" "#87d7ff"       "brightcyan"))
   (dark-cyan  '("#74c7ec" "#5fafff"       "cyan"))

   ;; These are the "universal syntax classes" that doom-themes establishes.
   ;; These *must* be included in every doom themes, or your theme will throw an
   ;; error, as they are used in the base theme defined in doom-themes-base.
   (highlight      blue)
   (vertical-bar   (doom-darken base1 0.1))
   (selection      dark-blue)
   (builtin        magenta)
   (comments       (if catppuccin-mocha-brighter-comments cyan base5))
   (doc-comments   (doom-lighten (if catppuccin-mocha-brighter-comments cyan base5) 0.25))
   (constants      violet)
   (functions      blue)
   (keywords       magenta)
   (methods        cyan)
   (operators      teal)
   (type           yellow)
   (strings        green)
   (variables      '("#f5c2e7" "#d7afff" "brightmagenta"))
   (numbers        orange)
   (region         `(,(doom-lighten (car bg-alt) 0.15) ,@(doom-lighten (cdr base1) 0.35)))
   (error          red)
   (warning        yellow)
   (success        green)
   (vc-modified    orange)
   (vc-added       green)
   (vc-deleted     red)

   ;; These are extra color variables used only in this theme; i.e. they aren't
   ;; mandatory for derived themes.
   (modeline-fg              fg)
   (modeline-fg-alt          base5)
   (modeline-bg              (if catppuccin-mocha-brighter-modeline
                                 (doom-darken blue 0.45)
                               (doom-darken bg-alt 0.1)))
   (modeline-bg-alt          (if catppuccin-mocha-brighter-modeline
                                 (doom-darken blue 0.475)
                               `(,(doom-darken (car bg-alt) 0.15) ,@(cdr bg))))
   (modeline-bg-inactive     `(,(car bg-alt) ,@(cdr base1)))
   (modeline-bg-inactive-alt `(,(doom-darken (car bg-alt) 0.1) ,@(cdr bg)))

   (-modeline-pad
    (when catppuccin-mocha-padded-modeline
      (if (integerp catppuccin-mocha-padded-modeline) catppuccin-mocha-padded-modeline 4))))


  ;;;; Base theme face overrides
  (((line-number &override) :foreground base4)
   ((line-number-current-line &override) :foreground fg)
   ((font-lock-comment-face &override)
    :background (if catppuccin-mocha-comment-bg (doom-lighten bg 0.05) 'unspecified))
   (mode-line
    :background modeline-bg :foreground modeline-fg
    :box (if -modeline-pad `(:line-width ,-modeline-pad :color ,modeline-bg)))
   (mode-line-inactive
    :background modeline-bg-inactive :foreground modeline-fg-alt
    :box (if -modeline-pad `(:line-width ,-modeline-pad :color ,modeline-bg-inactive)))
   (mode-line-emphasis :foreground (if catppuccin-mocha-brighter-modeline base8 highlight))

   ;;;; css-mode <built-in> / scss-mode
   (css-proprietary-property :foreground orange)
   (css-property             :foreground green)
   (css-selector             :foreground blue)
   ;;;; doom-modeline
   (doom-modeline-bar :background (if catppuccin-mocha-brighter-modeline modeline-bg highlight))
   (doom-modeline-buffer-file :inherit 'mode-line-buffer-id :weight 'bold)
   (doom-modeline-buffer-path :inherit 'mode-line-emphasis :weight 'bold)
   (doom-modeline-buffer-project-root :foreground green :weight 'bold)
   ;;;; elscreen
   (elscreen-tab-other-screen-face :background "#313244" :foreground "#181825")
   ;;;; ivy
   (ivy-current-match :background dark-blue :distant-foreground base0 :weight 'normal)
   ;;;; LaTeX-mode
   (font-latex-math-face :foreground green)
   ;;;; markdown-mode
   (markdown-markup-face :foreground base5)
   (markdown-header-face :inherit 'bold :foreground red)
   ((markdown-code-face &override) :background (doom-lighten base3 0.05))
   ;;;; rjsx-mode
   (rjsx-tag :foreground red)
   (rjsx-attr :foreground orange)
   ;;;; solaire-mode
   (solaire-mode-line-face
    :inherit 'mode-line
    :background modeline-bg-alt
    :box (if -modeline-pad `(:line-width ,-modeline-pad :color ,modeline-bg-alt)))
   (solaire-mode-line-inactive-face
    :inherit 'mode-line-inactive
    :background modeline-bg-inactive-alt
    :box (if -modeline-pad `(:line-width ,-modeline-pad :color ,modeline-bg-inactive-alt))))

  ;;;; Base theme variable overrides
  ())

;;; catppuccin-mocha-theme.el ends here
