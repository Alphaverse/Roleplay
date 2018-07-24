rp.command = {}
rp.command.stored = {}

local string = string
local table = table


-- Add a new command
function rp.command.add(command, access, targetsearch, callback)
	-- Check if we left out access and/or targetsearch (because we don't want them)
	if not callback then
		if isfunction(access) then
			callback = access
			access = rp.cfg["Normal Access"]
			targetsearch = false
		elseif isstring(access) then
			callback = targetsearch
			targetsearch = false
		else
			callback = targetsearch
			targetsearch = access or false
			access = rp.cfg["Normal Access"]
		end
	end

	-- Store the command
	rp.command.stored[string.lower(command)] = {
		access = access,
		callback = callback,
		targetsearch = targetsearch
	}
end

-- This is called when a player runs a command
function rp.command.runCommand(player, command, args)
	-- Check if command exists
	if command and rp.command.stored[string.lower(command)] then
		command = string.lower(command)

		-- Call the hook
		if hook.Run("PlayerUseCommand", player, command, args) then
			-- Check if the command has targetsearch on
			if rp.command.stored[command].targetsearch then
				local target = rp.player.get(args[1], player)
				if not target then return end

				-- Remove the target and call the function
				table.remove(args, 1)
				local success, fault = pcall(rp.command.stored[command].callback, player, target, args)

				-- Check to see if we did not succeed
				if not success then
					print(fault .. "\n")
				end
			else
				-- Call the function
				local success, fault = pcall(rp.command.stored[command].callback, player, args)

				-- Check to see if we did not succeed
				if not success then
					print(fault .. "\n")
				end
			end
		else
			player:Notify("You can not use this command!", NOTIFY_ERROR)
		end
	else
		player:Notify("This is not a valid command!", NOTIFY_ERROR)
	end
end
