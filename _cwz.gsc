#include maps/mp/_utility;
#include common_scripts/utility;
#include maps/mp/zombies/_zm_utility;
#include maps/mp/gametypes_zm/_hud_util;

init()
{
	precacheshader("damage_feedback");
	precacheshader("menu_mp_fileshare_custom");

	level thread onPlayerConnect();
}

onPlayerConnect()
{
	for(;;)
	{
		level waittill("connected", player);
		player iprintln("^1Cold War Zombies");
		level.perk_purchase_limit = 9;
		player thread BO4zombiehealth();
		player thread visuals();
		player thread onPlayerSpawned();
	}
}

BO4zombiehealth()
{
	level endon("end_game");
	self endon("disconnect");
	for(;;)
	{
		level waittill("start_of_round");
		if(level.zombie_health > 11272)
		{
			level.zombie_health = 11272;
		}
		wait 0.05;
	}
}

visuals()
{
	self setClientDvar("r_fog", 0);
	self setClientDvar("r_dof_enable", 0);
	self setClientDvar("r_lodBiasRigid", -1000);
	self setClientDvar("r_lodBiasSkinned", -1000);
	self setClientDvar("r_lodScaleRigid", 1);
	self setClientDvar("r_lodScaleSkinned", 1);
	self useservervisionset(1);
	self setvisionsetforplayer("remote_mortar_enhanced", 0);
}

onPlayerSpawned()
{
	level endon("end_game");
	self endon("disconnect");
	for(;;)
	{
		self waittill("spawned_player");
		self setperk("specialty_unlimitedsprint");
		self thread BO4maxammo();
		self thread drop_weapon();
		self thread frenzied_guard();
		self thread frenzied_guard_hud();
		self thread quickrevive();
		self thread staminup();
		self thread speedcola();
		self thread health_bar_hud();
		self thread self_revive_hud();
	}
}

BO4maxammo()
{
	level endon("end_game");
	self endon("disconnect");
	for(;;) 
	{
		self waittill("zmb_max_ammo");
		weaps = self getweaponslist(1);
		foreach (weap in weaps) 
		{
			self setweaponammoclip(weap, weaponclipsize(weap));
		}
		wait 0.05;
	}
}

drop_weapon()
{
	level endon("end_game");
	self endon("disconnect");
	for (;;) 
	{
		if (self meleebuttonpressed()) 
		{
			duration = 0;
			while (self meleebuttonpressed()) 
			{
				duration += 1;
				if (duration == 25) 
				{
					weap = self getCurrentWeapon();
					self dropItem(weap);
					break;
				}
				wait 0.05;
			}
		}
		wait 0.05;
	}
}

frenzied_guard()
{
	level endon("end_game");
	self endon("disconnect");
	for(;;)
	{
		if (self.kills >= 60 && self actionslotthreebuttonpressed())
		{	
			duration = 0;
			for(;;)
			{
				duration += 1;
				self EnableInvulnerability();
				self setvisionsetforplayer("zombie_death", 0);
				if (duration >= 300)
				{
					self DisableInvulnerability();
					self setvisionsetforplayer("remote_mortar_enhanced", 0);
					self.kills = 0;
					break;
				}
				wait 0.05;
			}
		}
		wait 0.05;
	}
}

frenzied_guard_hud()
{
	level endon("end_game");
	self endon("disconnect");
	flag_wait("initial_blackscreen_passed");
	
	frenzied_guard_hud = newClientHudElem(self);
	frenzied_guard_hud.alignx = "right";
	frenzied_guard_hud.aligny = "bottom";
	frenzied_guard_hud.horzalign = "user_right";
	frenzied_guard_hud.vertalign = "user_bottom";
	frenzied_guard_hud.x -= 155;
	frenzied_guard_hud.y -= 2;
	frenzied_guard_hud.alpha = 0;
	frenzied_guard_hud.color = ( 1, 1, 1 );
	frenzied_guard_hud.hidewheninmenu = 1;
	frenzied_guard_hud setShader("menu_mp_fileshare_custom", 32, 32);
	
	for(;;)
	{
		if (self.kills >= 60)
		{	
			frenzied_guard_hud.alpha = 1;
		}
		else 
		{
			frenzied_guard_hud.alpha = 0.5;
		}
		wait 0.05;
	}
}

quickrevive()
{
	level endon("end_game");
	self endon("disconnect");
	for (;;)
	{
		if (self hasperk("specialty_quickrevive") && self.health < self.maxHealth)
		{
			self.health += 1;
		}
		wait 0.1;
	}
}



staminup()
{
	level endon("end_game");
	self endon("disconnect");
	for (;;)
	{
		self waittill_any("perk_acquired", "perk_lost");
	
		if (self hasperk("specialty_longersprint"))
		{
			self setperk("specialty_movefaster");
			self setperk("specialty_fallheight");
			self setperk("specialty_stalker");
		}
		else
		{
			self unsetperk("specialty_movefaster");
			self unsetperk("specialty_fallheight");
			self unsetperk("specialty_stalker");
		}
	}
}

speedcola()
{
	level endon("end_game");
	self endon("disconnect");
	for (;;)
	{
		self waittill_any("perk_acquired", "perk_lost");
	
		if (self hasperk("specialty_fastreload"))
		{
			self setperk("specialty_fastweaponswitch");
		}
		else
		{
			self unsetperk("specialty_fastweaponswitch");
		}
	}
}

health_bar_hud()
{
	level endon("end_game");
	self endon("disconnect");
	flag_wait("initial_blackscreen_passed");

	health_bar = self createprimaryprogressbar();
	if (level.script == "zm_buried")
	{
		health_bar setpoint(undefined, "BOTTOM", -335, -95);
	}
	else if (level.script == "zm_tomb")
	{
		health_bar setpoint(undefined, "BOTTOM", -335, -100);
	}
	else
	{
		health_bar setpoint(undefined, "BOTTOM", -335, -70);
	}
	health_bar.hidewheninmenu = 1;
	health_bar.bar.hidewheninmenu = 1;
	health_bar.barframe.hidewheninmenu = 1;

	health_bar_text = self createprimaryprogressbartext();
	if (level.script == "zm_buried")
	{
		health_bar_text setpoint(undefined, "BOTTOM", -410, -95);
	}
	else if (level.script == "zm_tomb")
	{
		health_bar_text setpoint(undefined, "BOTTOM", -410, -100);
	}
	else
	{
		health_bar_text setpoint(undefined, "BOTTOM", -410, -70);
	}
	health_bar_text.hidewheninmenu = 1;

	while (1)
	{
		if (isDefined(self.e_afterlife_corpse))
		{
			if (health_bar.alpha != 0)
			{
				health_bar.alpha = 0;
				health_bar.bar.alpha = 0;
				health_bar.barframe.alpha = 0;
				health_bar_text.alpha = 0;
			}
			
			wait 0.05;
			continue;
		}

		if (health_bar.alpha != 1)
		{
			health_bar.alpha = 1;
			health_bar.bar.alpha = 1;
			health_bar.barframe.alpha = 1;
			health_bar_text.alpha = 1;
		}

		health_bar updatebar(self.health / self.maxhealth);
		health_bar_text setvalue(self.health);

		wait 0.05;
	}
}

self_revive_hud()
{
	level endon("end_game");
	self endon("disconnect");
	flag_wait("initial_blackscreen_passed");
	
	qr_hud = newClientHudElem(self);
	qr_hud.alignx = "left";
	qr_hud.aligny = "bottom";
	qr_hud.horzalign = "user_left";
	qr_hud.vertalign = "user_bottom";
	qr_hud.x += 155;
	qr_hud.alpha = 0;
	qr_hud.color = ( 1, 1, 1 );
	qr_hud.hidewheninmenu = 1;
	qr_hud setShader("damage_feedback", 32, 32);
	
	self waittill_any("perk_acquired", "perk_lost");
	for(;;)
	{
		if (self hasperk("specialty_quickrevive") && getPlayers().size <= 1)
		{	

			qr_hud.alpha = 1;
		}
		else 
		{
			qr_hud.alpha = 0;
		}
		wait 0.05;
	}
}
