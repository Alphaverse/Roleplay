rp.cfg["Default SVRank"] = "User"
rp.cfg["Default Access"] = "bvwypxsolfkchgn"

local defrank = rp.cfg["Default SVRank"]
local defacc = rp.cfg["Default Access"]

hook.Add("LoadRanks", "Add ranks", function()
	print(Color(255, 0, 0), "\n[RP] Setting up ranks:")
	RANK_OWNER = rp.rank.add({
		name = "Owner",
		access = "*zdam" .. defacc,
		check_for_higher_rank = false,
		not_admin = false,
		default_rank = false
	})

	RANK_SUPERADMIN = rp.rank.add({
		name = "SuperAdmin",
		access = "zdam" .. defacc,
		check_for_higher_rank = true,
		not_admin = false,
		default_rank = false
	})

	RANK_DEVELOPER = rp.rank.add({
		name = "Developer",
		access = "dam" .. defacc,
		check_for_higher_rank = true,
		not_admin = false,
		default_rank = false
	})

	RANK_ADMIN = rp.rank.add({
		name = "Admin",
		access = "am" .. defacc,
		check_for_higher_rank = true,
		not_admin = false,
		default_rank = false
	})

	RANK_MODERATOR = rp.rank.add({
		name = "Moderator",
		access = "m" .. defacc,
		check_for_higher_rank = true,
		not_admin = false,
		default_rank = false
	})

	RANK_DEFAULT = rp.rank.add({
		name = defrank,
		access = defacc,
		check_for_higher_rank = false,
		not_admin = true,
		default_rank = true
	})
	print(Color(0, 255, 0), "[RP] Finished setting up ranks\n")


	rp.cfg["Admins"] = {}
	rp.cfg["Admins"][RANK_OWNER] = true
	rp.cfg["Admins"][RANK_SUPERADMIN] = true
	rp.cfg["Admins"][RANK_DEVELOPER] = true
	rp.cfg["Admins"][RANK_ADMIN] = true
	rp.cfg["Admins"][RANK_MODERATOR] = true

	rp.cfg["Users"] = {}
	rp.cfg["Users"][RANK_DEFAULT] = true
end)