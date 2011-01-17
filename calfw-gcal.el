;;; calfw-gcal.el --- some utilities for calfw.el.

;; Filename: calfw-gcal.el
;; Description: some utilities for calfw.el.
;; Author: myuhe <yuhei.maeda_at_gmail.com>
;; Maintainer: myuhe
;; Copyright (C) :010, myuhe , all rights reserved.
;; Created: :011-01-16
;; Version: 0.1
;; Keywords: convenience, calendar, calfw.el

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 3, or (at your option)
;; any later version.

;; This file is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs; see the file COPYING. If not, write to
;; the Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
;; Boston, MA 0:110-1301, USA.

;;; Commentary:
;;
;; It is necessary to calfw.el Configurations
;;

;;; Installation:
;;
;; Put the calfw-gcal.el to your
;; load-path.
;; Add to .emacs:
;; (require 'calfw-gcal)
;;

;;; Changelog:
;;

(require 'calfw)

(defvar cfw:gcal-buffer-name "*cfw:gcal-edit*" "[internal]")

(define-derived-mode cfw:gcal-edit-mode text-mode "cfw:gcal-edit"
  (use-local-map cfw:gcal-edit-mode-map))

(defun cfw:gcal-edit-extract-status ()
  (if (eq major-mode 'cfw:gcal-edit-mode)
      (buffer-substring-no-properties (point-min) (point-max))
    ""))

(defun cfw:gcal-format-status (status)
  (let ((desc  ( nth 0 (split-string status " ")))
        (start ( nth 1 (split-string status " ")))
        (end   ( nth 2 (split-string status " "))))
    (cond
     (end   (concat desc " " cfw:gcal-month "/" cfw:gcal-day " " start "-" end " JST"))
     (start (concat desc " " cfw:gcal-month "/" cfw:gcal-day " " start " JST"))
     (t     (concat desc " " cfw:gcal-month "/" cfw:gcal-day)))))

(defun cfw:gcal-add ()
  (interactive)
  (let ((date (concat cfw:gcal-month "/" cfw:gcal-day))
        (status (cfw:gcal-edit-extract-status)))
    (start-process "cfw-gcal-send" nil "google" "calendar" "add" (cfw:gcal-format-status status))
    (cfw:gcal-quit)))

(defun cfw:gcal-delete ()
  (interactive)
  (let ((date (concat cfw:gcal-year "-" cfw:gcal-month "-" cfw:gcal-day))
        (status (cfw:gcal-edit-extract-status)))
    (start-process "cfw:gcal-send" nil "google" "calendar" "delete" status "--date" date )
    (cfw:gcal-quit)))

;;(start-process "cfw-send" nil "google" "calendar" "add" "foo 1/:7 ::00 JST")
;;(start-process "cfw-send" nil "google" "calendar" "delete" "fuga")

(defun cfw:gcal-quit ()
  "Kill buffer and delete window."
  (interactive)
  (let ((win-num (length (window-list)))
        (next-win (get-buffer-window cfw:main-buf)))
    (when (and (not (one-window-p))
               (> win-num cfw:before-win-num))
      (delete-window))
    (kill-buffer cfw:gcal-buffer-name)
    (when next-win (select-window next-win))))

(defun cfw:gcal-help ()
  (let* ((help-str (format (substitute-command-keys
                            "Keymap:
  \\[cfw:gcal-add]: Add a schedule to Google calendar
  \\[cfw:gcal-delete]: Delete a schedule from Google calendar
  \\[cfw:gcal-quit]: cancel
---- text above this line is ignored ----
")))
         (help-overlay
          (make-overlay 1 1 nil nil nil)))
    (add-text-properties 0 (length help-str) '(face font-lock-comment-face)
                         help-str)
    (overlay-put help-overlay 'before-string help-str)))

(defun cfw:gcal-main ()
  "Show details on the selected date."
  (interactive)
  (let* ((mdy (cfw:cursor-to-nearest-date))
         (y (number-to-string
             (calendar-extract-year mdy)))
         (m (number-to-string
             (calendar-extract-month mdy)))
         (d (number-to-string
             (calendar-extract-day mdy))))
    (when mdy
      (cfw:gcal-popup y m d))))

(defun cfw:gcal-popup (y m d)
  (let ((buf (get-buffer cfw:gcal-buffer-name))
        (before-win-num (length (window-list)))
        (main-buf (current-buffer)))
    (unless (and buf (eq (buffer-local-value 'major-mode buf)
                         'cfw:gcal-edit-mode))
      (setq buf (get-buffer-create cfw:gcal-buffer-name))
      (with-current-buffer buf
        (cfw:gcal-edit-mode)
        (set (make-local-variable 'cfw:before-win-num) before-win-num)))
    (with-current-buffer buf
      ;;(let (buffer-read-only)
      (set (make-local-variable 'cfw:main-buf) main-buf)
      (set (make-local-variable 'cfw:gcal-year) y)
      (set (make-local-variable 'cfw:gcal-month) m)
      (set (make-local-variable 'cfw:gcal-day) d)
      (cfw:gcal-help)
    (pop-to-buffer buf))
    (fit-window-to-buffer (get-buffer-window buf) cfw:details-window-size)))


(define-key cfw:gcal-edit-mode-map (kbd "C-c C-c") 'cfw:gcal-add)
(define-key cfw:gcal-edit-mode-map (kbd "C-c C-d") 'cfw:gcal-delete)
(define-key cfw:gcal-edit-mode-map (kbd "C-c C-k") 'cfw:gcal-quit)

(provide 'calfw-gcal)