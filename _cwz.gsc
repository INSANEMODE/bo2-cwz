#include maps/mp/_utility;
#include common_scripts/utility;
#include maps/mp/zombies/_zm_utility;
#include maps/mp/gametypes_zm/_hud_util;

init()
{
	precacheshader("damage_feedback");
	precacheshader("menu_mp_fileshare_custom");
	precacheshader("menu_mp_killstreak_select");

	level thread onPlayerConnect();
}

onPlayerConnect()
{
	for(;;)
	{
		level waittill("connected", player);
		player iprintln("^1Cold War Zombies");
		level.perk_purchase_limit = 9;
		player thread zombies();
		player thread visuals();
		player thread onPlayerSpawned();
	}
}

zombies()
{
	level endon("end_game");
	self endon("disconnect");
	for(;;)
	{
		level waittill("start_of_round");
		if(level.zombie_health > 10000)
		{
			level.zombie_health = 10000;
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
		self thread maxammo();
		if ((level.script == "zm_transit") || (level.script == "zm_highrise") || (level.script == "zm_buried"))
		{
			self thread aether_shroud();
			self thread aether_shroud_hud();
		}
		else
		{
			self thread frenzied_guard();
			self thread frenzied_guard_hud();
		}
		self thread health_bar_hud();
		self thread self_revive_hud();
		self thread quickrevive();
		self thread staminup();
		self thread speedcola();
		self thread mulekick_save_weapons();
		self thread mulekick_restore_weapons();
	}
}

maxammo()
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

aether_shroud()
{
	level endon("end_game");
	self endon("disconnect");
	for(;;)
	{
		if (self.kills >= 45 && self actionslotthreebuttonpressed())
		{	
			duration = 0;
			for(;;)
			{
				duration += 1;
				self setperk("specialty_noname");
				self.ignoreme = true;
				self setvisionsetforplayer("zombie_last_stand", 0);
				if (duration >= 160)
				{
					self unsetperk("specialty_noname");
					self.ignoreme = false;
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

aether_shroud_hud()
{
	level endon("end_game");
	self endon("disconnect");
	flag_wait("initial_blackscreen_passed");
	
	aether_shroud_hud = newClientHudElem(self);
	aether_shroud_hud.alignx = "right";
	aether_shroud_hud.aligny = "bottom";
	aether_shroud_hud.horzalign = "user_right";
	aether_shroud_hud.vertalign = "user_bottom";
	aether_shroud_hud.x -= 155;
	aether_shroud_hud.y -= 2;
	aether_shroud_hud.alpha = 0;
	aether_shroud_hud.color = ( 1, 1, 1 );
	aether_shroud_hud.hidewheninmenu = 1;
	aether_shroud_hud setShader("menu_mp_killstreak_select", 32, 32);
	
	for(;;)
	{
		if (self.kills >= 45)
		{	
			aether_shroud_hud.alpha = 1;
		}
		else 
		{
			aether_shroud_hud.alpha = 0.25;
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
			frenzied_guard_hud.alpha = 0.25;
		}
		wait 0.05;
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
	
	self_revive_hud = newClientHudElem(self);
	self_revive_hud.alignx = "left";
	self_revive_hud.aligny = "bottom";
	self_revive_hud.horzalign = "user_left";
	self_revive_hud.vertalign = "user_bottom";
	self_revive_hud.x += 155;
	self_revive_hud.alpha = 0;
	self_revive_hud.color = ( 1, 1, 1 );
	self_revive_hud.hidewheninmenu = 1;
	self_revive_hud setShader("damage_feedback", 32, 32);
	
	self waittill_any("perk_acquired", "perk_lost");
	for(;;)
	{
		if (self hasperk("specialty_quickrevive") && getPlayers().size <= 1)
		{	

			self_revive_hud.alpha = 1;
		}
		else 
		{
			self_revive_hud.alpha = 0;
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

mulekick_save_weapons()
{
	level endon("end_game");
	self endon("disconnect");
	for (;;)
	{
		if (!self hasPerk("specialty_additionalprimaryweapon"))
		{
			self waittill("perk_acquired");
			wait 0.05;
		}

		if (self hasPerk("specialty_additionalprimaryweapon"))
		{
			primaries = self getweaponslistprimaries();
			if (primaries.size >= 3)
			{
				weapon = primaries[primaries.size - 1];
				self.a_saved_weapon = maps/mp/zombies/_zm_weapons::get_player_weapondata(self, weapon);
			}
			else
			{
				self.a_saved_weapon = undefined;
			}
		}

		wait 0.05;
	}
}

mulekick_restore_weapons()
{
	level endon("end_game");
	self endon("disconnect");
	for (;;)
	{
		self waittill("perk_acquired");

		if (isDefined(self.a_saved_weapon) && self hasPerk("specialty_additionalprimaryweapon"))
		{
			pap_triggers = getentarray( "specialty_weapupgrade", "script_noteworthy" );

			give_wep = 1;
			if ( isDefined( self ) && self maps/mp/zombies/_zm_weapons::has_weapon_or_upgrade( self.a_saved_weapon["name"] ) )
			{
				give_wep = 0;
			}
			else if ( !maps/mp/zombies/_zm_weapons::limited_weapon_below_quota( self.a_saved_weapon["name"], self, pap_triggers ) )
			{
				give_wep = 0;
			}
			else if ( !self maps/mp/zombies/_zm_weapons::player_can_use_content( self.a_saved_weapon["name"] ) )
			{
				give_wep = 0;
			}
			else if ( isDefined( level.custom_magic_box_selection_logic ) )
			{
				if ( !( [[ level.custom_magic_box_selection_logic ]]( self.a_saved_weapon["name"], self, pap_triggers ) ) )
				{
					give_wep = 0;
				}
			}
			else if ( isDefined( self ) && isDefined( level.special_weapon_magicbox_check ) )
			{
				give_wep = self [[ level.special_weapon_magicbox_check ]]( self.a_saved_weapon["name"] );
			}

			if (give_wep)
			{
				current_wep = self getCurrentWeapon();
				self maps/mp/zombies/_zm_weapons::weapondata_give(self.a_saved_weapon);
				self switchToWeapon(current_wep);
			}

			self.a_saved_weapon = undefined;
		}
	}
}
