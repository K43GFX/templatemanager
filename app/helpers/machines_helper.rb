module MachinesHelper

	# Shows the çorrect data for last VM update
	# @param [DateTime] last_update last VM update time
	def detectUpdate(last_update)
		if last_update.nil?
			#machine unreachable
			'<i class="material-icons" style="color: #e53935; font-size: 14px;">check_circle</i><span style="color: gray;">Machine was not reached</span>'.html_safe
		else
			('<i class="material-icons" style="color: green; font-size: 14px;">check_circle</i><span style="color: gray;">Last updated: ' + last_update + '</span>').html_safe
		end
	end

	# Sets the color of the state icon
	# @param [String] state state of VM
	def statecolor(state)
		if state == "running"
			"color: green;".html_safe
		elsif state == "poweroff"
			"color: gray;".html_safe
		else
			"color: yellow;".html_safe
		end
	end

	# Shows the last update time of VM
	# @param [DateTime] time last VM update time
	def timescale(time, identifier)
		if time.today?
			# " Last checked Today at #{time.in_time_zone("Europe/Tallinn").to_s(:time)}".html_safe
			"<span id='#{identifier}-count-up'>0:00</span>".html_safe
		end



	end
end
