tell application "iTunes"
	display dialog "Gimme playlist name" default answer ""
	set plName to the text returned of the result
	set curPl to user playlist plName -- current playlist
	set dupes to {}
	set prevTrack to {"", 0}
	set trackNo to 1
	repeat with aTrack in every track of curPl
		set curTrack to {get name of aTrack, get time of aTrack}
		if curTrack = prevTrack then
			set the end of dupes to trackNo
		end if
		set trackNo to trackNo + 1
		set prevTrack to curTrack
	end repeat
	set dupePos to 0
	repeat with dupe in dupes
		set rmTrack to dupe - dupePos
		-- log rmTrack
		delete track rmTrack of curPl
		set dupePos to dupePos + 1
	end repeat
	set dialogLine to "Deleted " & (count dupes) & " dupes in " & plName & " playlist"
	display dialog dialogLine buttons {"OK"}
end tell