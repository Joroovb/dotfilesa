function fish_greeting
	# set cur_hour $(date +"%H")  		#gets the current hour
	set cur_hour (date +%H)		#gets the current hour

	if [ "$cur_hour" -ge 0 ] && [ "$cur_hour" -le 6 ]
		lolbanner Get some sleep!
	else 
		if [ "$cur_hour" -gt 6 ] && [ "$cur_hour" -lt 12 ]
			lolbanner Good morning!
		else 
			if [ "$cur_hour" -ge 12 ] && [ "$cur_hour" -lt 16 ]
				lolbanner Good afternoon!
			else
				if [ "$cur_hour" -ge 16 ] && [ "$cur_hour" -lt 20 ]
					lolbanner Good evening!
				else 
					lolbanner Good night!
				end
			end
		end
	end
end