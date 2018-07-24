rp.cfg["Load disabled"] = false -- Disable loading
rp.cfg["Save disabled"] = false -- Disable saving
rp.cfg["Use MySQL"] = false -- Use MySQL Database instead of GMod's standard DB (Useful for synchronizing across multiple servers)

db["Player Table"] = "players" -- Table for all playerdata
db["Log Table"] = "logs" -- Table for all logs

-- MySQL only
if rp.cfg["Use MySQL"] then
	db["MySQL Host"] = "127.0.0.1" -- The host that your MySQL database is located
	db["MySQL Username"] = "root" -- The username that you log into MySQL with
	db["MySQL Password"] = "password" -- The password that you log into MySQL with
	db["MySQL Database"] = "name" -- The name of the database that we'll be using
	db["MySQL Port"] = 3306 -- The port of the database that we'll be using
end

hook.Add("LoadSQL", "Load SQL tables", function()
	print(Color(255, 0, 0), "\n[RP] Setting up database tables:")
	rp.sql.add({
		name = db["Player Table"],
		columns = {
			{
				name = "SteamID",
				type = "VARCHAR(18)", -- In MySQL primay keys must be of known length
				not_null = true,
				primary_key = true
			},
			{
				name = "Money",
				type = "INTEGER",
			},
			{
				name = "BankMoney",
				type = "INTEGER",
			},
			{
				name = "Car",
				type = "TEXT"
			},
			{
				name = "SVRank",
				type = "TEXT",
			},
			{
				name = "Access",
				type = "TEXT",
			},
			{
				name = "RPName",
				type = "TEXT"
			},
			{
				name = "Gender",
				type = "TEXT",
			},
			{
				name = "RadioFreq",
				type = "INTEGER"
			},
			{
				name = "PlayTime",
				type = "INTEGER"
			},
			{
				name = "ArrestTime",
				type = "INTEGER"
			}
		}
	})

	rp.sql.add({
		name = db["Log Table"],
		columns = {
			{
				name = "Event",
				type = "TEXT",
				not_null = true
			},
			{
				name = "Time",
				type = "TEXT"
			},
			{
				name = "Message",
				type = "TEXT"
			}
		}
	})
	print(Color(0, 255, 0), "[RP] Finished setting up database tables\n")
end)