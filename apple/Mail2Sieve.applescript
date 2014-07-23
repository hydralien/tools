# there's an online validation form at http://libsieve-php.sourceforge.net/

set my text item delimiters to " "
set resultRules to {"require [\"fileinto\"];"}
tell application "Mail"
	#name of every account
	#properties of every account
	set ruleSet to rules
	repeat with theRule in ruleSet
		if enabled of theRule = true then
			if all conditions must be met of theRule = true then
				set end of resultRules to "if anyof("
			else
				set end of resultRules to "if allof("
			end if
			
			set ruleCollection to {}
			set ruleConditions to rule conditions of theRule
			repeat with ruleCond in ruleConditions
				set ruleType to rule type of ruleCond
				set ruleQ to qualifier of ruleCond
				set ruleExp to "[\"" & (expression of ruleCond) & "\"]"
				
				set headerName to ""
				if ruleType = "header key" then
					set headerName to (header of ruleCond)
				else if ruleType = cc header then
					set headerName to "CC"
				else if ruleType = subject header then
					set headerName to "Subject"
				else
					set headerName to "UNKNOWN"
				end if
				set headerName to "[\"" & headerName & "\"]"
				
				set ruleLine to {"header"}
				if ruleQ = does not contain value then
					set beginning of ruleLine to "not"
					set end of ruleLine to ":contains" & headerName & ruleExp
				else if ruleQ = begins with value then
					set end of ruleLine to ":matches" & headerName & "[\"" & (expression of ruleCond) & "*\"]"
				else if ruleQ = does contain value then
					set end of ruleLine to ":contains" & headerName & ruleExp
				else
					set end of ruleLine to ":is" & headerName & "[\"\"]"
				end if
				set end of ruleCollection to ruleLine as string
			end repeat
			set my text item delimiters to ",\n"
			set end of resultRules to ruleCollection as string
			set my text item delimiters to " "
			
			set end of resultRules to ")"
			set end of resultRules to "{"
			
			set moveTo to (move message of theRule)
			if should move message of theRule = true then
				set end of resultRules to "discard;"
				set movePath to {}
				repeat while class of moveTo = container
					set beginning of movePath to name of moveTo
					set moveTo to container of moveTo
				end repeat
				set beginning of movePath to "INBOX"
				set my text item delimiters to "."
				set end of resultRules to "fileinto \"" & (movePath as string) & "\";"
				set my text item delimiters to " "
			end if
			
			set copyTo to (copy message of theRule)
			if should copy message of theRule = true then
				set copyPath to {}
				repeat while class of copyTo = container
					set beginning of copyPath to name of copyTo
					set copyTo to container of copyTo
				end repeat
				set beginning of copyPath to "INBOX"
				set my text item delimiters to "."
				set end of resultRules to "fileinto \"" & (copyPath as string) & "\";"
				set my text item delimiters to " "
			end if
			
			if delete message of theRule = true then
				set end of resultRules to "discard;"
			end if
			
			if stop evaluating rules of theRule = true then
				set end of resultRules to "stop;"
			end if
			
			set end of resultRules to "}"
			#log resultRules
		end if
	end repeat
	#set ruleCond to rule condition [0] of someRule
	#log ruleCond
	resultRules
end tell


set my text item delimiters to "
"
set result to resultRules as string
#resultRules

