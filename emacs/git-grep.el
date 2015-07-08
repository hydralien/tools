;; source: https://www.ogre.com/node/447

(defun git-grep (search path)
  "git-grep the entire current repo"
  (interactive (list (completing-read "Search for: " nil nil nil (current-word)) (read-file-name "in directory: " nil "" t)))
  (grep-find (concat "git --no-pager grep -P -n --no-color "
                     (shell-quote-argument search)
                     " "
                     (replace-regexp-in-string "/ssh.?:.+:" "" path))))

(provide 'git-grep)