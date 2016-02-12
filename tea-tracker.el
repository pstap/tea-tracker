;;; tea-tracker.el -- Emacs interface for gongfu tea ceremonies
;; Author: Peter Stapleton (pstap92@gmail.com)
;; Version: 0.1
;; Keywords: tea, gongfu, brew, steep
;; 

;;; Commentary:
;; This package provides an interface for timing and tracking
;; the process of a gongfu tea ceremony.

;;; Code:

(defun tea-tracker ()
  "Start tea-tracker."
  (interactive)
  (switch-to-buffer "tea-tracker")
  (tea-tracker-mode))

;; Global Variables
(defvar *steeps* nil "Contains steeps and steep number.")
(defvar *steep-count* 0 "The number of steeps.")
(defvar *tea-tracker-sound* "/Users/Peter/.emacs.d/tea-alert.wav"
  "Path to alert sound.")
(defvar *tea-tracker-sound-command* "afplay %s"
  "Command used to play defined sound.")
(defvar *steeping?* nil "The current state of the steep timer.")
(defvar *tea-name* nil)

;; Define keybinds here
(define-derived-mode tea-tracker-mode special-mode "tea-tracker"
  (define-key tea-tracker-mode-map (kbd "a") 'tea-tracker-start-steeping)
  (define-key tea-tracker-mode-map (kbd "r") 'tea-tracker-draw-ui))

;; Functions
(defun tea-tracker-init ()
  "Called when tea-tracker start."
  (setf *steep-count* 0)
  (setf *steeps* nil))

(defun tea-tracker-start-steeping ()
  "Start the timer if one is not currently running."
  (interactive)
  (if *steeping?*
	  (message "Currently steeping.")
	(call-interactively 'tea-tracker-start-timer)))

(defun tea-tracker-start-timer (time)
  "Ask for a TIME (in seconds) to brew for."
  (interactive "nSteep Time: ")
  (setq *steeping?* t)
  (run-with-timer time nil 'tea-tracker-steep-finished)
  (setq *steeps* (append *steeps* (list (tea-tracker-make-steep time))))
  (tea-tracker-draw-ui))
  
(defun tea-tracker-make-steep (time)
  "Create the steep entry with steep number, TIME, and an empty notes string."
  (list (setf *steep-count* (1+ *steep-count*)) time ""))

(defun tea-tracker-draw-ui ()
  "Draw the tea-tracker UI."
  (interactive)
  (let ((inhibit-read-only t))
	(erase-buffer)
	(insert (if *steeping?*
				(format "Steep #%d is steeping!\n" *steep-count*)
			  "Not steeping!\n"))
	(tea-tracker-print-steeps)))

(defun tea-tracker-print-steeps ()
  "Print the steeps list to the buffer."
  (dolist (steep *steeps*)
	(let ((steep-num (car steep))
		  (steep-time (car (cdr steep)))
		  (descr (cdr (cdr steep))))
	  (insert (format "Steep %d (%ds)\n"
					  steep-num
					  steep-time)))))

(defun tea-tracker-steep-finished ()
  "Run when timer is finished."
  (message (format "Steep %d finished!" *steep-count*))
  (start-process-shell-command "tea-tracker-timer" nil
							   (format *tea-tracker-sound-command* *tea-tracker-sound*))
  (setf *steeping?* nil)
  (tea-tracker-draw-ui))

(provide 'tea-tracker)

;;; tea-tracker.el ends here
