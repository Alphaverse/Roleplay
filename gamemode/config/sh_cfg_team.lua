-- President Models
rp.cfg["President Models"] = {}
rp.cfg["President Models"]["Male"] = {
	"models/player/breen.mdl"
}
rp.cfg["President Models"]["Female"] = {
	""
}



-- F.B.I. Models
rp.cfg["F.B.I. Agent Models"] = {}
rp.cfg["F.B.I. Agent Models"]["Male"] = {
	""
}
rp.cfg["F.B.I. Agent Models"]["Female"] = {
	""
}



-- S.W.A.T. Models
rp.cfg["S.W.A.T. Unit Models"] = {}
rp.cfg["S.W.A.T. Unit Models"]["Male"] = {
	"models/player/swat.mdl"
}
rp.cfg["S.W.A.T. Unit Models"]["Female"] = {
	"models/player/swat.mdl"
}



-- Police Models
rp.cfg["Police Officer Models"] = {}
rp.cfg["Police Officer Models"]["Male"] = {
	"models/player/police.mdl"
}
rp.cfg["Police Officer Models"]["Female"] = {
	"models/player/police_fem.mdl"
}



-- Paramedic Models
rp.cfg["Paramedic Models"] = {}
rp.cfg["Paramedic Models"]["Male"] = {
	""
}
rp.cfg["Paramedic Models"]["Female"] = {
	""
}



-- Fireman Models
rp.cfg["Fireman Models"] = {}
rp.cfg["Fireman Models"]["Male"] = {
	""
}
rp.cfg["Fireman Models"]["Female"] = {
	""
}



-- Dispatch Models
rp.cfg["Dispatch Models"] = {}
rp.cfg["Dispatch Models"]["Male"] = {
	""
}
rp.cfg["Dispatch Models"]["Female"] = {
	""
}



-- Citizen Models (used for all non-government jobs)
rp.cfg["Citizen Models"] = {}
rp.cfg["Citizen Models"]["Male"] = {
	"models/player/group01/male_01.mdl",
	"models/player/group01/male_02.mdl",
	"models/player/group01/male_03.mdl",
	"models/player/group01/male_04.mdl",
	"models/player/group01/male_05.mdl",
	"models/player/group01/male_06.mdl",
	"models/player/group01/male_07.mdl",
	"models/player/group01/male_08.mdl",
	"models/player/group01/male_09.mdl",
	"models/player/kleiner.mdl",
	"models/player/odessa.mdl"
}
rp.cfg["Citizen Models"]["Female"] = {
	"models/player/group01/female_01.mdl",
	"models/player/group01/female_02.mdl",
	"models/player/group01/female_03.mdl",
	"models/player/group01/female_04.mdl",
	"models/player/group01/female_05.mdl",
	"models/player/group01/female_06.mdl",
	"models/player/mossman.mdl"
}



-- Prisoner Models
rp.cfg["Prisoner Models"] = {}
rp.cfg["Prisoner Models"]["Male"] = {
	"models/player/group01/male_01.mdl",
	"models/player/group01/male_02.mdl",
	"models/player/group01/male_03.mdl",
	"models/player/group01/male_04.mdl",
	"models/player/group01/male_05.mdl",
	"models/player/group01/male_06.mdl",
	"models/player/group01/male_07.mdl",
	"models/player/group01/male_08.mdl",
	"models/player/group01/male_09.mdl",
}
rp.cfg["Prisoner Models"]["Female"] = {
	"models/player/group01/female_01.mdl",
	"models/player/group01/female_02.mdl",
	"models/player/group01/female_03.mdl",
	"models/player/group01/female_04.mdl",
	"models/player/group01/female_05.mdl",
	"models/player/group01/female_06.mdl",
	"models/player/mossman.mdl"
}




-- Creating all teams
hook.Add("LoadTeams", "Add Teams", function()
	print(Color(255, 0, 0), "\n[RP] Setting up teams:")
		TEAM_PRESIDENT = rp.team.add({
			name = "President",
			color = Color(255, 50, 25),
			males = rp.cfg["President Models"]["Male"],
			females = rp.cfg["President Models"]["Female"],
			maxplayers = 1,
			minimumhours = 30,
			neededaccess = "p",
		})

		TEAM_FBI = rp.team.add({
			name = "F.B.I. Agent",
			color = Color(102, 0, 0),
			males = rp.cfg["F.B.I. Agent Models"]["Male"],
			females = rp.cfg["F.B.I. Agent Models"]["Female"],
			maxplayers = 3,
			minimumhours = 25,
			neededaccess = "xw",
		})

		TEAM_SWAT = rp.team.add({
			name = "S.W.A.T. Unit",
			color = Color(102, 51, 0),
			males = rp.cfg["S.W.A.T. Unit Models"]["Male"],
			females = rp.cfg["S.W.A.T. Unit Models"]["Female"],
			maxplayers = 4,
			minimumhours = 20,
			neededaccess = "swv",
		})

		TEAM_POLICE = rp.team.add({
			name = "Police Officer",
			color = Color(50, 50, 255),
			males = rp.cfg["Police Officer Models"]["Male"],
			females = rp.cfg["Police Officer Models"]["Female"],
			maxplayers = 6,
			minimumhours = 15,
			neededaccess = "owv",
		})

		TEAM_PARAMEDIC = rp.team.add({
			name = "Paramedic",
			color = Color(51, 153, 255),
			males = rp.cfg["Paramedic Models"]["Male"],
			females = rp.cfg["Paramedic Models"]["Female"],
			maxplayers = 3,
			minimumhours = 10,
			neededaccess = "lv",
		})

		TEAM_FIREMAN = rp.team.add({
			name = "Fireman",
			color = Color(51, 153, 204),
			males = rp.cfg["Fireman Models"]["Male"],
			females = rp.cfg["Fireman Models"]["Female"],
			maxplayers = 3,
			minimumhours = 10,
			neededaccess = "fv",
		})

		TEAM_DISPATCH = rp.team.add({
			name = "Dispatch",
			color = Color(0, 204, 153),
			males = rp.cfg["Dispatch Models"]["Male"],
			females = rp.cfg["Dispatch Models"]["Female"],
			maxplayers = 2,
			minimumhours = 5,
			neededaccess = "k",
		})

		TEAM_CITIZEN = rp.team.add({
			name = "Citizen",
			color = Color(0, 204, 0), -- #00cc00 Link green
			males = rp.cfg["Citizen Models"]["Male"],
			females = rp.cfg["Citizen Models"]["Female"],
			maxplayers = game.MaxPlayers(),
			minimumhours = 0,
			neededaccess = "b",
		})

		TEAM_CHEF = rp.team.add({
			name = "Chef",
			color = Color(255, 125, 200),
			males = rp.cfg["Citizen Models"]["Male"],
			females = rp.cfg["Citizen Models"]["Female"],
			maxplayers = 2,
			minimumhours = 0,
			neededaccess = "c",
		})

		TEAM_DOCTOR = rp.team.add({
			name = "Doctor",
			color = Color(0, 102, 102),
			males = rp.cfg["Citizen Models"]["Male"],
			females = rp.cfg["Citizen Models"]["Female"],
			maxplayers = 2,
			minimumhours = 0,
			neededaccess = "h",
		})

		TEAM_GUNS = rp.team.add({
			name = "Gun Dealer",
			color = Color(255, 140, 0),
			males = rp.cfg["Citizen Models"]["Male"],
			females = rp.cfg["Citizen Models"]["Female"],
			maxplayers = 2,
			minimumhours = 0,
			neededaccess = "gw",
		})

		TEAM_MECHANIC = rp.team.add({
			name = "Mechanic",
			color = Color(0, 255, 66),
			males = rp.cfg["Citizen Models"]["Male"],
			females = rp.cfg["Citizen Models"]["Female"],
			maxplayers = 2,
			minimumhours = 0,
			neededaccess = "nv",
		})
	print(Color(0, 255, 0), "[RP] Finished setting up teams\n")


	rp.cfg["Default Job"] = TEAM_CITIZEN

	rp.cfg["TargetID Teams"] = {}
	rp.cfg["TargetID Teams"][TEAM_PRESIDENT] = true

	rp.cfg["Government Table"] = {}
	rp.cfg["Government Table"][TEAM_PRESIDENT] = true
	rp.cfg["Government Table"][TEAM_FBI] = true
	rp.cfg["Government Table"][TEAM_SWAT] = true
	rp.cfg["Government Table"][TEAM_POLICE] = true
	rp.cfg["Government Table"][TEAM_PARAMEDIC] = true
	rp.cfg["Government Table"][TEAM_FIREMAN] = true
	rp.cfg["Government Table"][TEAM_DISPATCH] = true

	rp.cfg["Citizen Table"] = {}
	rp.cfg["Citizen Table"][TEAM_CITIZEN] = true
	rp.cfg["Citizen Table"][TEAM_CHEF] = true
	rp.cfg["Citizen Table"][TEAM_DOCTOR] = true
	rp.cfg["Citizen Table"][TEAM_GUNS] = true
	rp.cfg["Citizen Table"][TEAM_MECHANIC] = true
end)
