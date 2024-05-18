function GetDesire()
	if DotaTime() >= (32 * 60) or ((GetGameMode() == 23) and (DotaTime() >= (19 * 60))) then
		return BOT_MODE_DESIRE_ABSOLUTE * 4
	end


	return 0
end