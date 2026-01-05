;;; -*- lexical-binding: t; no-byte-compile: t; -*-
;;; cc/agenda/config.el

;; DOOM org-todo-keywords explanation
;;
;; ----------------------------------------
;; Group 1
;; This sequence is used for projects
;;
;; TODO: A task that needs to be done.
;; PROJ: A project, which is a collection of tasks.
;; LOOP: A recurring task.
;; STRT: A task that has been started.
;; WAIT: A task that is waiting on something or someone.
;; HOLD: A task that is on hold.
;; IDEA: An idea that might be turned into a task later.
;; ---------
;; DONE: A task that has been completed.
;; KILL: A task that has been cancelled or is no longer applicable.
;;
;; ----------------------------------------
;; Group 2
;; This sequence is used for tasks
;;
;; [ ]: An incomplete checklist item.
;; [-]: A checklist item that is in progress.
;; [?]: A checklist item that is in a state of uncertainty or waiting.
;; ---------
;; [X]: A completed checklist item.
;;
;; ----------------------------------------
;; Group 3
;; This sequence is likely used for items that represent a decision or an approval process
;; OKAY: An item that is deemed okay or acceptable.
;; YES: An affirmative decision.
;; NO: A negative decision.

(defvar cc/org-agenda-dir "~/org/todos/"
  "Agenda home directory")

(defvar cc/agenda-habits-file nil
  "The file path to store habits.")

(defvar cc/agenda-projects-file nil
  "The file path to store personal projects.")

(defvar cc/agenda-work-file nil
  "The file path to store work projects.")

(defvar cc/agenda-study-file nil
  "The file path to store study tasks.")

(after! org
  (setq! org-log-repeat nil
         +org-capture-todo-file (file-name-concat cc/org-agenda-dir "todo.org")
         +org-capture-journal-file (file-name-concat cc/org-agenda-dir "journal.org")
         cc/agenda-habits-file (file-name-concat cc/org-agenda-dir "habits.org")
         cc/agenda-projects-file (file-name-concat cc/org-agenda-dir "projects.org")
         cc/agenda-work-file (file-name-concat cc/org-agenda-dir "work.org")
         cc/agenda-study-file (file-name-concat cc/org-agenda-dir "study.org")
         org-deadline-warning-days 5
         org-log-done 'time
         org-todo-repeat-to-state "LOOP"
         org-log-into-drawer t)

  (setq! org-tag-alist
         '(("English" . ?e)
           ("C++" . ?c)
           ("Python" . ?p)
           ("Trading" . ?t)))

  (setq! org-capture-templates
         '(
           ;; Quick tasks
           ("t" "Quick todo" entry
            (file+headline +org-capture-todo-file "Quick Tasks")
            "* [ ] %?\n%U\n"
            :prepend t
            :kill-buffer t)
           ("s" "Quick start" entry
            (file+headline +org-capture-todo-file "Quick Tasks")
            "* [-] %?\n%U\n"
            :clock-in t
            :clock-keep t
            :prepend t
            :kill-buffer t)
           ("i" "Quick ideas" entry
            (file+headline +org-capture-todo-file "Ideas")
            "* %u %?\n%i\n"
            :prepend t)
           ("j" "Write journal" plain
            (file+olp+datetree +org-capture-journal-file)
            "%?\n---"
            :kill-buffer t
            :tree-type week)
           ;; Study
           ("c" "Start a cource" entry
            (file+headline cc/agenda-study-file "Courses")
            "* PROJ %^{Course name} :Course:
:PROPERTIES:
:CATEGORY: %\\1
:END:
%i
STARTED:%u
** TODO L1%?"
            :prepend t
            :empty-lines 1)
           ("b" "Start a book" entry
            (file+headline cc/agenda-study-file "Books")
            "* PROJ %^{Book name} :Book:
:PROPERTIES:
:CATEGORY: %\\1
:END:
%i
STARTED:%u
** TODO C1%?"
            :empty-lines 1)
           ("b" "Start a segment" entry
            (file+headline cc/agenda-study-file "Segments")
            "* TODO %?\n%i\nSTARTED:%u\n"
            :empty-lines 1)

           ;; Projects
           ("p" "Start a project" entry
            (file+headline cc/agenda-projects-file "Projects")
            "* PROJ %^{Project name} :Project:
:PROPERTIES:
:CATEGORY: %\\1
:END:
%i
CREATED:%u
** TODO Task1%?"
            :prepend t
            :empty-lines 1)
           ("w" "Start a work project" entry
            (file+headline cc/agenda-work-file "Projects")
            "* PROJ %^{Project name} :Work:
:PROPERTIES:
:CATEGORY: %\\1
:END:
%i
CREATED:%u
** TODO Task1%?"
            :prepend t
            :empty-lines 1)

           ;; Habits
           ("h" "Create a habit")
           ("hd" "Daily habit" entry
            (file+headline cc/agenda-habits-file "Habits")
            "* LOOP %^{Habit Name}\nSCHEDULED: <%<%Y-%m-%d %a> .+1d>\n"
            :prepend t
            :empty-lines 1
            )
           ("hw" "Weekly habit" entry
            (file+headline cc/agenda-habits-file "Habits")
            "* LOOP %^{Habit Name}\nSCHEDULED: <%<%Y-%m-%d %a> .+1w>\n"
            :prepend t
            :empty-lines 1
            )
           ("hm" "Monthly habit" entry
            (file+headline cc/agenda-habits-file "Habits")
            "* LOOP %^{Habit Name}\nSCHEDULED: <%<%Y-%m-%d %a> .+1m>\n"
            :prepend t
            :empty-lines 1
            )
           ))
  )

(after! org-agenda
  (setq! org-agenda-files `(,cc/org-agenda-dir)
         org-stuck-projects
         '("+TODO=\"PROJ\""
           ("TODO" "STRT")
           nil
           ""))

  ;; todo tags trigger
  (setq! org-todo-state-tags-triggers
         '(
           ;; Group 1
           ("KILL" ("CANCELED" . t))
           ("WAIT" ("WAITING" . t))
           ("HOLD" ("WAITING") ("HOLD" . t))
           (done ("WAITING") ("HOLD"))
           ("TODO" ("WAITING") ("HOLD") ("CANCELED"))
           ("STRT" ("WAITING") ("HOLD") ("CANCELED"))
           ("DONE" ("WAITING") ("HOLD") ("CANCELED"))

           ;; Group 2
           ("[?]" ("WAITING". t))
           ("[-]" ("WAITING"))
           ("[X]" ("WAITING"))
           ("[ ]" ("WAITING"))))

  ;; Customized agenda views
  (setq! org-agenda-custom-commands
         '(
           ;; Daily review
           ("d" "Daily Dashboard"
            ((todo "STRT|[-]"
                   ((org-agenda-overriding-header "In Progress")
                    (org-agenda-sorting-strategy '(priority-up effort-down))))
             (agenda ""
                     ((org-agenda-span 3)
                      (org-agenda-start-day "0d") ; "-1d" for yesterday
                      (org-deadline-warning-days 5)
                      (org-agenda-overriding-header "Today's Agenda")))
             (stuck ""
                    ((org-agenda-overriding-header "Stucked")))))

           ;; Weekly review
           ("r" "Weekly Review"
            ((agenda ""
                     ((org-agenda-span 10)
                      (org-agenda-start-day "-7d")
                      (org-deadline-warning-days 7)
                      (org-agenda-overriding-header "Weekly Review")))
             (stuck ""
                    ((org-agenda-overriding-header "Stuck Projects")))
             (todo "DONE"
                   ((org-agenda-overriding-header "Completed Tasks")
                    (org-agenda-sorting-strategy '(priority-up effort-down))))
             ))

           ;; Habits
           ("h" "Habits"
            tags-todo "+CATEGORY=\"Habit\""
            ((org-agenda-overriding-header "Habits")
             (org-agenda-sorting-strategy
              '(todo-state-down effort-up category-keep))))

           ;; Overview
           ("o" "Agenda Overview"
            ((tags "+CATEGORY=\"Task\""
                   ((org-agenda-overriding-header "Quick Tasks")
                    (org-agenda-sorting-strategy '(priority-up effort-down))))
             (tags "+CATEGORY=\"Idea\""
                   ((org-agenda-overriding-header "Ideas")))
             (tags-todo "-HOLD-CANCELLED/!"
                        ((org-agenda-overriding-header "Tasks")
                         (org-agenda-sorting-strategy '(category-keep))))
             (tags-todo "-CANCELED/!STRT"
                        ((org-agenda-overriding-header "In Progress")
                         (org-agenda-sorting-strategy '(todo-state-down effort-up category-keep))))
             ;; TODO Add more later
             ))

           ;; Tags todo search
           ;; ("g" "Taged todos"

           ;;  ((tags-todo "+CATEGORY=\"Learning\"")
           ;;   (tags-todo "+CATEGORY=\"Hobby\"")
           ;;   (tags-todo "+CATEGORY=\"Housekeeping\"")
           ;;   (tags-todo "+CATEGORY=\"Child\"")
           ;;   (tags-todo "+CATEGORY=\"Finance\"")
           ;;   (tags-todo "+CATEGORY=\"CS\"")
           ;;   (tags-todo "+CATEGORY=\"CPP\"")
           ;;   (tags-todo "+CATEGORY=\"Python\"")
           ;;   (tags-todo "+CATEGORY=\"Math\"")
           ;;   (tags-todo "+CATEGORY=\"Frontend\"")
           ;;   (tags-todo "+CATEGORY=\"Backend\"")
           ;;   (tags-todo "+CATEGORY=\"Database\"")
           ;;   ))

           ;; Archive search
           ("A" "Archive Search" search ""
            ((org-agenda-files (directory-files-recursively cc/org-agenda-dir ".org_archive$"))))

           ;; Effort review
           ("t" "Effort Table" alltodo ""
            ((org-columns-default-format-for-agenda
              "%10CATEGORY %15ITEM(TASK) %2PRIORITY %5TODO %SCHEDULED %DEADLINE %5EFFORT(ESTIMATED){:} %5CLOCKSUM(SPENT)")
             (org-agenda-view-columns-initially t)
             (org-agenda-start-day "-7d")
             (org-agenda-span 10)))
           )
         )

  (setq! org-agenda-start-with-log-mode t
         org-agenda-show-future-repeats nil)
  (map! :map org-agenda-mode-map
        "C" #'org-agenda-columns))


(after! org-clock
  (setq! org-clock-in-switch-to-state #'cc/org-clock-in-switch-state
         org-clock-report-include-clocking-task t))
