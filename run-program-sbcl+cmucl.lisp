

(in-package run-program)
#|
   The RUN-PROGRAM routine runs a program, returing a program 
   structure with input, output, error streams


|#


(defun %get-path-variable ()
  #+sbcl  (sb-posix:getenv "PATH")
  #+cmucl (unix:unix-getenv "PATH"))

(defun %get-default-environment ()
  #+sbcl   (sb-ext:posix-environ)
  #+cmu common-lisp::lisp-environment-list)

(defun run-program (program args
		    &key
		    (environment (%get-default-environment))
		    (wait nil))

  "Run a program, the path of which is fully specified.

ARGS is a list of strings, representing arguments.
ENVIRONMENT is a list of conses like (FOO . BAR) or a string like FOO=BAR
WAIT is T if Lisp waits for program to finish.

Remember to run PROCESS-CLOSE at end, or streams will remain open."
  (#+sbcl sb-ext:run-program
	  #+cmu  ext:run-program
	  ;;
	  program args
	  ;; in cmucl, substitute environment for ENV
	  #+sbcl :environment 
	  #+cmu :env
	  (loop for thing in environment
		collect
		(cond ((consp thing)
		       (format nil "~A=~A" (car thing) (cdr thing)))
		      ((stringp thing)
		       thing)
		      (t
		       (error "Invalid item ~A in environment" thing))))
	  ;;
	  :wait wait
	  #+sbcl :search #+sbcl nil
	  :pty NIL :input :STREAM
	  :output :STREAM 
	  :error :STREAM
	  :status-hook nil))

;; import process accessors - setf expanders don't work, but
;; we never use them

(defun process-alive-p (p)
  (#+sbcl sb-impl::process-alive-p #+cmu ext:process-alive-p p))
(defun process-close (p)
  (#+sbcl sb-impl::process-close #+cmu ext:process-close p))
(defun process-core-dumped (p)
  (#+sbcl sb-impl::process-core-dumped #+cmu ext:process-core-dumped p))
(defun process-error (p)
  (#+sbcl sb-impl::process-error #+cmu ext:process-error p))
(defun process-exit-code (p)
  (#+sbcl sb-impl::process-exit-code #+cmu ext:process-exit-code p))
(defun process-input (p)
  (#+sbcl sb-impl::process-input #+cmu ext:process-input p))
(defun process-output (p)
  (#+sbcl sb-impl::process-output #+cmu ext:process-output p))
(defun process-kill (p)
  (#+sbcl sb-impl::process-kill #+cmu ext:process-kill p 9))
(defun process-p (p)
  (#+sbcl sb-impl::process-p #+cmu ext:process-p p))
