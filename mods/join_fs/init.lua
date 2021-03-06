dofile(minetest.get_modpath("join_fs") .. "/api.lua")

-- Rules slide from agreerules

join_fs.register_slide({
	name = "rules",
	should_show = function(player, has_been_shown_before)
		return not minetest.check_player_privs(player:get_player_name(), {interact=true})
	end,
	show = function(player)
		local msgs = {
			"Welcome to Capture the Flag!",
			"Developed, hosted, and moderated by rubenwardy.",
			"    tip: use /vote_next to skip to the next round",
			",By playing on this server you agree to these rules:",
			"1. Be nice. eg: No (excessive or bad) swearing",
			"2. No dating",
			"3. Don't be a cheater",
			"    (No hacked clients or griefing/sabotage of team)",
			"4. Don't impersonate other community members",
			"Failure to follow these rules may result in a kick or ban",
			"     (temp or permanent) depending on severity."}

		local fs = ""
		for _, line in pairs(msgs) do
			if fs ~= "" then
				fs = fs .. ","
			end
			fs = fs .. minetest.formspec_escape(line)
		end

		fs = "size[8,9] textlist[0.1,0.1;7.8,7;rules;" .. fs .. "]"
		fs = fs .. " button_exit[0.5,7;3.5,2;yes;" ..
			minetest.formspec_escape("Yes, let me play!") .. "]"
		fs = fs .. " button[4,7;3.5,2;no;" ..
			minetest.formspec_escape("No, get me out of here!") .. "]"
		minetest.show_formspec(player:get_player_name(), "join_fs:rules", fs)
	end
})

minetest.register_on_player_receive_fields(function(player, form, fields)
	if form == "join_fs:rules" then
		local name  = player:get_player_name()

		if fields.rules then
			return true
		elseif not fields.yes or fields.no then
			minetest.kick_player(name,
				"You need to agree to the rules to play on this server. " ..
				"Please rejoin and confirm another time.")
			return true
		end

		local privs = minetest.get_player_privs(name)
		privs.shout = true
		privs.interact = true

		minetest.set_player_privs(name, privs)
		minetest.chat_send_player(name, "Welcome "..name.."! You have now permission to play!")

		join_fs.confirm(name, "rules")
		join_fs.show_next_slide(player)
	end
end)
