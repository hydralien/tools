--  Mail2Sieve.applescript
--  Mail2Sieve

--  Created by Boris Turchik on 13.07.2014.
--  Copyright (c) 2014 Boris Turchik. All rights reserved.

script Mail2Sieve
	property parent : class "AMBundleAction"
	
	on runWithInput_fromAction_error_(input, anAction, errorRef)
		-- Add your code here, returning the data to be passed to the next action.
		
		return input
	end runWithInput_fromAction_error_
	
end script
