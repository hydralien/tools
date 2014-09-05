# What's this? It's a script that goes through all Apple Mail filters and converts them to Sieve filters, so you could go server-side on email filtering
# Why? Because I'm lazy - I've accumulated a fair bunch of Apple Mail filters along the way, and converting them manually wasn't much fun. And I found no working option to convert it on the Internet.
# NOTE: this is validated with a quite limited use case - in my filters, I mostly match against subject and sometimes against CC/To, so it definitely has some issues with other fields. Please review / try loading the results first and don't disable all your Mail filters right away.
# Exporting filters: just run the script - it will ask you if you want to use disabled filters as active (useful to re-export after you have already disabled Mail filters), then if you want to disable Mail filters (useful when you're certain in your Sieve filterset), and then where to save the results.
# Also, there's an online validation form at http://libsieve-php.sourceforge.net/ - but the best way to validate something works is to put it to where it's about to be used (provided that place gives you enough feedback if something goes off)

set useDisabledQuestion to display dialog "Do you want to use disabled filters as enabled? Useful when you do export after having filters disabled." buttons {"Yes", "No"} default button 2
set useDisabledAnswer to button returned of useDisabledQuestion

set disableQuestion to display dialog "Should the script disable you filters after export? Useful if you are certain in result to stop Mail from filtering mail." buttons {"Yes", "No"} default button 2
set disableAnswer to button returned of disableQuestion

set stopQuestion to display dialog "How about stop processing rules when message is *moved* from Inbox? my Mail filters had no \"stop evaluating rules\" flag, because message is not processed im Mail after it moved away - it's different in Sieve, you need to stop processing explicitly.\nSounds good?" buttons {"Yes", "No"} default button 2
set stopAnswer to button returned of stopQuestion


set my text item delimiters to " "
set resultRules to {"require [\"fileinto\",\"copy\",\"body\"];"}
tell application "Mail"
	#name of every account
	#properties of every account
	set ruleSet to rules
	repeat with theRule in ruleSet
		set filterDisabled to ""
		if enabled of theRule = false and useDisabledAnswer is equal to "No" then
			set filterDisabled to "false #"
		end if
		
		set my text item delimiters to " "
		set prefix to "
"
		set currentRule to {}
		set end of currentRule to "# rule:[" & name of theRule & "]"
		if all conditions must be met of theRule = true then
			set end of currentRule to "if " & filterDisabled & "allof("
		else
			set end of currentRule to "if " & filterDisabled & "anyof("
		end if
		
		set ruleCollection to {}
		set ruleConditions to rule conditions of theRule
		repeat with ruleCond in ruleConditions
			set ruleType to rule type of ruleCond
			set ruleQ to qualifier of ruleCond
			set ruleExp to "[\"" & (expression of ruleCond) & "\"]"
			
			set headerNames to {}
			set ruleObjectType to "header"
			if ruleType = "header key" then
				set end of headerNames to (header of ruleCond)
			else if ruleType = cc header then
				set end of headerNames to "CC"
			else if ruleType = subject header then
				set end of headerNames to "Subject"
			else if ruleType = to header then
				set end of headerNames to "To"
			else if ruleType = to or cc header then
				set end of headerNames to "To"
				set end of headerNames to "CC"
			else if ruleType = from header then
				set end of headerNames to "From"
			else if ruleType = message content then
				set ruleObjectType to "body"
				set end of headerNames to ""
			else
				set end of headerNames to "NOT SUPPORTED rule type " & (ruleType as string)
				set prefix to "
#"
			end if
			
			repeat with headerName in headerNames
				if length of headerName is not 0 then
					set headerName to "[\"" & headerName & "\"]"
				end if
				
				set ruleLine to {ruleObjectType}
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
		end repeat
		set my text item delimiters to "," & prefix
		set end of currentRule to ruleCollection as string
		set my text item delimiters to " "
		
		set end of currentRule to ")"
		set end of currentRule to "{"
		
		set moveTo to (move message of theRule)
		if should move message of theRule = true then
			# set end of currentRule to "discard;"
			set movePath to {}
			repeat while class of moveTo = container
				set beginning of movePath to name of moveTo
				set moveTo to container of moveTo
			end repeat
			set beginning of movePath to "INBOX"
			set my text item delimiters to "."
			set end of currentRule to "fileinto \"" & (movePath as string) & "\";"
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
			set end of currentRule to "fileinto :copy \"" & (copyPath as string) & "\";"
			set my text item delimiters to " "
		end if
		
		if delete message of theRule = true then
			set end of currentRule to "discard;"
		end if
		
		if stop evaluating rules of theRule = true or (should move message of theRule = true and stopAnswer = "Yes") then
			set end of currentRule to "stop;"
		end if
		
		set end of currentRule to "}"
		#log currentRule
		
		set my text item delimiters to prefix
		
		set end of resultRules to prefix & currentRule as string
		
		if disableAnswer is equal to "Yes" then
			set enabled of theRule to false
		end if
	end repeat
	#set ruleCond to rule condition [0] of someRule
	#log ruleCond
	resultRules
end tell


set my text item delimiters to "
"
set resultString to resultRules as string

set my text item delimiters to ""
set resultFileName to (choose file name with prompt "Save Rules to file" default name "mail_rules_sieve_export.txt" default location path to desktop) as text
if resultFileName does not end with ".txt" then set resultFile to resultFile & ".txt"

tell application "Finder"
	if exists file resultFileName then
		delete file resultFileName
	end if
end tell

set resultFile to open for access resultFileName with write permission
write resultString to resultFile
close access resultFile


