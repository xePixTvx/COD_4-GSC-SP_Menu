#include common_scripts\utility;
#include maps\_utility;
#include maps\_debug;
#include maps\_hud_util;
#include maps\_cheat;

/*
Simple GSC MENU BASE by P!X
								for
										COD4
												SINGLEPLAYER
*/



_main()
{	
	self.ToggleTest = false;
	self.TestValue = 50;
	self.isGod = false;
	self.unlmAmmo = false;
	self.cheatSlowmoMode = false;
	self.cheatIgnoreAmmo = false;
	self.cheatClusterGrenade = false;
	self.ForceField = false;
	self.SuperSpeed = false;
	self.pix_friendlyfire = false;
	self.FovValue = 65;
	self.thirdPerson = false;
	
	
	self.MenuOpened = false;
	self.Scroller = [];
	self.Hud = [];
	self thread _menuStruct();
	self endon("disconnect");
	for(;;)
	{
		if(!self.MenuOpened)
		{
			if(self buttonPressed("enter")||self buttonPressed("kp_enter"))
			{
				self.MenuOpened = true;
				if(!isDefined(self.CurrentMenu))
				{
					self.CurrentMenu = "main";
				}
				self _createhud();
				self _loadMenu(self.CurrentMenu);
				wait .2;
			}
		}
		else
		{
			if(self buttonPressed("uparrow")||self buttonPressed("downarrow"))
			{
				self.Scroller[self.CurrentMenu] -= self buttonPressed("uparrow");
				self.Scroller[self.CurrentMenu] += self buttonPressed("downarrow");
				self _scrollUpdate();
				wait .125;
			}
			if(self buttonPressed("leftarrow"))
			{
				if(isDefined(level.Menu[self.CurrentMenu]["Value"][self.Scroller[self.CurrentMenu]]))
				{
					level.Menu[self.CurrentMenu]["Value"][self.Scroller[self.CurrentMenu]] -= level.Menu[self.CurrentMenu]["Steps"][self.Scroller[self.CurrentMenu]];
					if(level.Menu[self.CurrentMenu]["Value"][self.Scroller[self.CurrentMenu]]<level.Menu[self.CurrentMenu]["MinValue"][self.Scroller[self.CurrentMenu]])
					{
						level.Menu[self.CurrentMenu]["Value"][self.Scroller[self.CurrentMenu]] = level.Menu[self.CurrentMenu]["MaxValue"][self.Scroller[self.CurrentMenu]];
					}
					self.Hud["Value"][self.Scroller[self.CurrentMenu]] setValue(level.Menu[self.CurrentMenu]["Value"][self.Scroller[self.CurrentMenu]]);
					self _valueHandler(level.Menu[self.CurrentMenu]["Value"][self.Scroller[self.CurrentMenu]],level.Menu[self.CurrentMenu]["ValueType"][self.Scroller[self.CurrentMenu]]);
					wait level.Menu[self.CurrentMenu]["WaitTime"][self.Scroller[self.CurrentMenu]];
				}
			}
			if(self buttonPressed("rightarrow"))
			{
				if(isDefined(level.Menu[self.CurrentMenu]["Value"][self.Scroller[self.CurrentMenu]]))
				{
					level.Menu[self.CurrentMenu]["Value"][self.Scroller[self.CurrentMenu]] += level.Menu[self.CurrentMenu]["Steps"][self.Scroller[self.CurrentMenu]];
					if(level.Menu[self.CurrentMenu]["Value"][self.Scroller[self.CurrentMenu]]>level.Menu[self.CurrentMenu]["MaxValue"][self.Scroller[self.CurrentMenu]])
					{
						level.Menu[self.CurrentMenu]["Value"][self.Scroller[self.CurrentMenu]] = level.Menu[self.CurrentMenu]["MinValue"][self.Scroller[self.CurrentMenu]];
					}
					self.Hud["Value"][self.Scroller[self.CurrentMenu]] setValue(level.Menu[self.CurrentMenu]["Value"][self.Scroller[self.CurrentMenu]]);
					self _valueHandler(level.Menu[self.CurrentMenu]["Value"][self.Scroller[self.CurrentMenu]],level.Menu[self.CurrentMenu]["ValueType"][self.Scroller[self.CurrentMenu]]);
					wait level.Menu[self.CurrentMenu]["WaitTime"][self.Scroller[self.CurrentMenu]];
				}
			}
			if(self buttonPressed("enter")||self buttonPressed("kp_enter"))
			{
				if(!isDefined(level.Menu[self.CurrentMenu]["Value"][self.Scroller[self.CurrentMenu]]))
				{
					input = level.Menu[self.CurrentMenu]["Input"][self.Scroller[self.CurrentMenu]];
					func = level.Menu[self.CurrentMenu]["Func"][self.Scroller[self.CurrentMenu]];
					self thread [[func]](input);
					self _selectUpdate();
				}
				else
				{
					iprintln("^1Use Left/Right Arrow Keys to change!");
				}
				wait .4;
			}
			if(self buttonPressed("backspace"))
			{
				if(level.Menu[self.CurrentMenu]["Parent"]=="Exit")
				{
					self.MenuOpened = false;
					self _destroyText();
					self _destroyhud();
				}
				else
				{
					self _loadMenu(level.Menu[self.CurrentMenu]["Parent"]);
				}
				wait .4;
			}
		}
		if(self buttonPressed("F1"))
		{
			iprintln("^1ufo toggled");
			wait .4;
		}
		if(self buttonPressed("F2"))
		{
			iprintln("^1noclip toggled");
			wait .4;
		}
		if(self buttonPressed("F3"))
		{
			iprintln("^1super jump toggled");
			wait .4;
		}
		if(self buttonPressed("F4"))
		{
			iprintln("^1laser toggled");
			wait .4;
		}
		if(self buttonPressed("F5"))
		{
			iprintln("^1r_fullbright toggled");
			wait .4;
		}
		if(self buttonPressed("F6"))
		{
			iprintln("^1All Weapons Given");
			wait .4;
		}
		
		wait 0.05;
	}
}


_loadMenu(menu)
{
	self _destroyText();
	self _menuStruct();
	self.CurrentMenu = menu;
	if(!isDefined(self.Scroller[self.CurrentMenu]))
	{
		self.Scroller[self.CurrentMenu] = 0;
	}
	self _createText();
	self.Hud["BG"] scaleOverTime(.4,200,((level.Menu[self.CurrentMenu]["Text"].size*19)+45));
	self _scrollUpdate();
}
_scrollUpdate()
{
	if(self.Scroller[self.CurrentMenu]<0)
	{
		self.Scroller[self.CurrentMenu] = level.Menu[self.CurrentMenu]["Text"].size-1;
	}
	if(self.Scroller[self.CurrentMenu]>level.Menu[self.CurrentMenu]["Text"].size-1)
	{
		self.Scroller[self.CurrentMenu] = 0;
	}
	self.Hud["Scrollbar"] elemMoveOverTimeY(.124,50+(self.Scroller[self.CurrentMenu]*18));
	for(i=0;i<level.Menu[self.CurrentMenu]["Text"].size;i++)
	{
		if(i==self.Scroller[self.CurrentMenu])
		{
			self.Hud["Text"][i] thread _selectedEffect();
			if(isDefined(self.Hud["Value"][i]))
			{
				self.Hud["Value"][i] thread _selectedEffect();
			}
		}
		else
		{
			self.Hud["Text"][i] notify("Update_Scroll");
			self.Hud["Text"][i].alpha = 1;
			if(isDefined(self.Hud["Value"][i]))
			{
				self.Hud["Value"][i] notify("Update_Scroll");
				self.Hud["Value"][i].alpha = 1;
			}
		}
	}
}
_selectUpdate()
{
	self _menuStruct();
	for(i=0;i<level.Menu[self.CurrentMenu]["Text"].size;i++)
	{
		if(isDefined(level.Menu[self.CurrentMenu]["Toggle"][i]))
		{
			self.Hud["Text"][i].glowAlpha = 1;
			if(!level.Menu[self.CurrentMenu]["Toggle"][i])
			{
				self.Hud["Text"][i].glowColor = (1,0,0);
			}
			else
			{
				self.Hud["Text"][i].glowColor = (0.3,0.9,0.5);
			}
		}
	}
}
_createText()
{
	self.Hud["Title"] setText(level.Menu[self.CurrentMenu]["Title"]);
	self.Hud["Text"] = [];
	for(i=0;i<level.Menu[self.CurrentMenu]["Text"].size;i++)
	{
		if(isDefined(level.Menu[self.CurrentMenu]["Value"][i]))
		{
			self.Hud["Text"][i] = createText("default",1.5,"CENTER","TOP",200,50+(i*18),0,(1,1,1),1,(1,0,0),0,level.Menu[self.CurrentMenu]["Text"][i]);
			self.Hud["Value"][i] = createText("default",1.5,"LEFT","TOP",300,50+(i*18),0,(1,1,1),1,(1,0,0),0);
			self.Hud["Value"][i] setValue(level.Menu[self.CurrentMenu]["Value"][i]);
		}
		else
		{
			self.Hud["Text"][i] = createText("default",1.5,"CENTER","TOP",200,50+(i*18),0,(1,1,1),1,(1,0,0),0,level.Menu[self.CurrentMenu]["Text"][i]);
			if(isDefined(level.Menu[self.CurrentMenu]["Toggle"][i]))
			{
				self.Hud["Text"][i].glowAlpha = 1;
				if(!level.Menu[self.CurrentMenu]["Toggle"][i])
				{
					self.Hud["Text"][i].glowColor = (1,0,0);
				}
				else
				{
					self.Hud["Text"][i].glowColor = (0.3,0.9,0.5);
				}
			}
		}
	}
}
_destroyText()
{
	if(isDefined(self.Hud["Text"]))
	{
		for(i=0;i<self.Hud["Text"].size;i++)
		{
			if(isDefined(self.Hud["Value"][i]))
			{
				self.Hud["Value"][i] destroy();
			}
			self.Hud["Text"][i] destroy();
		}
	}
}
_createhud()
{
	self.Hud["BG"] = createRectangle("TOP","TOP",200,2,200,0,(0,0,0),(1/1.75),0,"white");
	self.Hud["Title"] = createText("default",2.0,"CENTER","TOP",200,20,0,(1,1,1),1,(1,0,0),0,level.Menu[self.CurrentMenu]["Title"]);
	self.Hud["Scrollbar"] = createRectangle("CENTER","TOP",200,50,200,20,(0,0,0),1,0,"white");
}
_destroyhud()
{
	self.Hud["BG"] destroy();
	self.Hud["Title"] destroy();
	self.Hud["Scrollbar"] destroy();
}
createText(font, fontscale, align, relative, x, y, sort, color, alpha, glowColor, glowAlpha, text)
{
	textElem = CreateFontString( font, fontscale );
	textElem setPoint( align, relative, x, y );
	textElem.sort = sort;
	textElem.color = color;
	textElem.alpha = alpha;
	textElem.glowColor = glowColor;
	textElem.glowAlpha = glowAlpha;
	if(isDefined(text))
	{
		textElem setText(text);
	}
	textElem.foreground = true;
	textElem.hideWhenInMenu = false;
	return textElem;
}
createRectangle(align, relative, x, y, width, height, color, alpha, sorting, shadero)
{
	barElemBG = newHudElem( self );
	barElemBG.elemType = "bar";
	if ( !level.splitScreen )
	{
		barElemBG.x = -2;
		barElemBG.y = -2;
	}
	barElemBG.width = width;
	barElemBG.height = height;
	barElemBG.align = align;
	barElemBG.relative = relative;
	barElemBG.xOffset = 0;
	barElemBG.yOffset = 0;
	barElemBG.children = [];
	barElemBG.color = color;
	if(isDefined(alpha))
		barElemBG.alpha = alpha;
	else
		barElemBG.alpha = 1;
	barElemBG setShader( shadero, width , height );
	barElemBG.hidden = false;
	barElemBG.sort = sorting;
	barElemBG setPoint(align,relative,x,y);
	return barElemBG;
}
_selectedEffect()
{
	self endon("Update_Scroll");
	for(;;)
	{
		self elemFadeOverTime(.3,0.3);
		wait .3;
		self elemFadeOverTime(.3,1);
		wait .3;
	}
}
elemFadeOverTime(time,alpha)
{
	self fadeovertime(time);
	self.alpha = alpha;
}
elemMoveOverTimeY(time,y)
{
	self moveovertime(time);
	self.y = y;
}
elemMoveOverTimeX(time,x)
{
	self moveovertime(time);
	self.x = x;
}
elemScaleOverTime(time,width,height)
{
	self scaleovertime(time,width,height);
}

_menuStruct()
{
	level.Menu = [];
	
	menu = "main";
	level.Menu[menu]["Parent"] = "Exit";
	level.Menu[menu]["Title"] = "P!X V1[UNFINISHED]";
	
	
	level.Menu[menu]["Text"][0] = "Complete All Levels";
	level.Menu[menu]["Func"][0] = ::_complete_all_levels;

	level.Menu[menu]["Text"][1] = "Godmode";
	level.Menu[menu]["Func"][1] = ::ToggleGod;
	level.Menu[menu]["Toggle"][1] = self.isGod;
	
	level.Menu[menu]["Text"][2] = "Unlimited Ammo";
	level.Menu[menu]["Func"][2] = ::toggleAmmo;
	level.Menu[menu]["Toggle"][2] = self.unlmAmmo;
	
	level.Menu[menu]["Text"][3] = "AI Ignore Player";
	level.Menu[menu]["Func"][3] = ::toggleInvisible;
	level.Menu[menu]["Toggle"][3] = self.ignoreme;
	
	level.Menu[menu]["Text"][4] = "Game Included Cheats";
	level.Menu[menu]["Func"][4] = ::_loadMenu;
	level.Menu[menu]["Input"][4] = "cheats";
	
	level.Menu[menu]["Text"][5] = "Forcefield of Death";
	level.Menu[menu]["Func"][5] = ::ToggleForceField;
	level.Menu[menu]["Toggle"][5] = self.ForceField;
	
	level.Menu[menu]["Text"][6] = "Suicide";
	level.Menu[menu]["Func"][6] = ::imsoDone;
	
	level.Menu[menu]["Text"][7] = "AI";
	level.Menu[menu]["Func"][7] = ::_loadMenu;
	level.Menu[menu]["Input"][7] = "ai";
	
	level.Menu[menu]["Text"][8] = "Fun";
	level.Menu[menu]["Func"][8] = ::_loadMenu;
	level.Menu[menu]["Input"][8] = "fun";
	
	level.Menu[menu]["Text"][9] = "Super Speed";
	level.Menu[menu]["Func"][9] = ::toggle_superSpeed;
	level.Menu[menu]["Toggle"][9] = self.SuperSpeed;
	
	
	
	menu = "fun";
	level.Menu[menu]["Parent"] = "main";
	level.Menu[menu]["Title"] = "Fun";
	
	level.Menu[menu]["Text"][0] = "Friendlyfire";
	level.Menu[menu]["Func"][0] = ::toggle_friendlyfire;
	level.Menu[menu]["Toggle"][0] = self.pix_friendlyfire;
	
	level.Menu[menu]["Text"][1] = "FOV";
	level.Menu[menu]["MinValue"][1] = 1;
	level.Menu[menu]["MaxValue"][1] = 160;
	level.Menu[menu]["Steps"][1] = 1;
	level.Menu[menu]["WaitTime"][1] = 0;
	level.Menu[menu]["Value"][1] = self.FovValue;
	level.Menu[menu]["ValueType"][1] = "fov";
	
	level.Menu[menu]["Text"][2] = "BUTTON BINDS";
	level.Menu[menu]["Func"][2] = ::_loadMenu;
	level.Menu[menu]["Input"][2] = "bind_info";
	
	menu = "bind_info";
	level.Menu[menu]["Parent"] = "fun";
	level.Menu[menu]["Title"] = "BUTTON BINDS";
	
	level.Menu[menu]["Text"][0] = "F1 - ufo";
	level.Menu[menu]["Text"][1] = "F2 - noclip";
	level.Menu[menu]["Text"][2] = "F3 - super jump";
	level.Menu[menu]["Text"][3] = "F4 - laser";
	level.Menu[menu]["Text"][4] = "F5 - r_fullbright";
	level.Menu[menu]["Text"][5] = "F6 - All Weapons";
	
	
	
	
	menu = "ai";
	level.Menu[menu]["Parent"] = "main";
	level.Menu[menu]["Title"] = "AI";
	
	level.Menu[menu]["Text"][0] = "Drop Weapons[Enemies]";
	level.Menu[menu]["Func"][0] = ::enemy_ai_dropWeapon;
	level.Menu[menu]["Text"][1] = "Kill All[Enemies]";
	level.Menu[menu]["Func"][1] = ::enemy_ai_kill;
	level.Menu[menu]["Text"][2] = "Drop Weapons[Friendlys]";
	level.Menu[menu]["Func"][2] = ::friend_ai_dropWeapon;
	level.Menu[menu]["Text"][3] = "Kill All[Friendlys]";
	level.Menu[menu]["Func"][3] = ::friend_ai_kill;
	
	
	
	menu = "cheats";
	level.Menu[menu]["Parent"] = "main";
	level.Menu[menu]["Title"] = "Cheats";
	level.Menu[menu]["Text"][0] = "Contrast Mode";
	level.Menu[menu]["Text"][1] = "BW Mode";
	level.Menu[menu]["Text"][2] = "Invert Mode";
	level.Menu[menu]["Text"][3] = "Slowmo Mode";
	level.Menu[menu]["Text"][4] = "Chaplin Mode";
	level.Menu[menu]["Text"][5] = "Ignore Ammo";
	level.Menu[menu]["Text"][6] = "Cluster Grenade";
	level.Menu[menu]["Text"][7] = "Tire Explosion Mode";
	level.Menu[menu]["Func"][0] = ::toggle_cheat_visions;
	level.Menu[menu]["Func"][1] = ::toggle_cheat_visions;
	level.Menu[menu]["Func"][2] = ::toggle_cheat_visions;
	level.Menu[menu]["Func"][3] = ::toggle_cheat_slowmo;
	level.Menu[menu]["Func"][4] = ::toggle_cheat_visions;
	level.Menu[menu]["Func"][5] = ::toggle_cheat_ignoreammo;
	level.Menu[menu]["Func"][6] = ::toggle_cheat_clustergrenade;
	level.Menu[menu]["Func"][7] = ::toggle_cheat_tireexplosion;
	level.Menu[menu]["Input"][0] = "contrast";
	level.Menu[menu]["Input"][1] = "bw";
	level.Menu[menu]["Input"][2] = "invert";
	level.Menu[menu]["Input"][4] = "chaplin";
	level.Menu[menu]["Toggle"][0] = level.visionSets["contrast"];
	level.Menu[menu]["Toggle"][1] = level.visionSets["bw"];
	level.Menu[menu]["Toggle"][2] = level.visionSets["invert"];
	level.Menu[menu]["Toggle"][4] = level.visionSets["chaplin"];
	level.Menu[menu]["Toggle"][3] = self.cheatSlowmoMode;
	level.Menu[menu]["Toggle"][5] = self.cheatIgnoreAmmo;
	level.Menu[menu]["Toggle"][6] = self.cheatClusterGrenade;
	level.Menu[menu]["Toggle"][7] = level.tire_explosion;
	
	
	
	
	
	//Test Menu
	menu = "sub";
	level.Menu[menu]["Parent"] = "main";
	level.Menu[menu]["Title"] = "Sub Menu";
	
	level.Menu[menu]["Text"][0] = "Option 1";
	level.Menu[menu]["Func"][0] = ::Test;
	
	level.Menu[menu]["Text"][1] = "Toggle Test";
	level.Menu[menu]["Func"][1] = ::ToggleTest;
	level.Menu[menu]["Toggle"][1] = self.ToggleTest;
	
	level.Menu[menu]["Text"][2] = "Value Test";
	level.Menu[menu]["MinValue"][2] = 0;
	level.Menu[menu]["MaxValue"][2] = 100;
	level.Menu[menu]["Steps"][2] = 1;
	level.Menu[menu]["WaitTime"][2] = 0.1;
	level.Menu[menu]["Value"][2] = self.TestValue;
	level.Menu[menu]["ValueType"][2] = "test";
}
_valueHandler(value,type)
{
	if(type=="test")
	{
		self.TestValue = value;
	}
	else if(type=="fov")
	{
		self.FovValue = value;
		setSavedDvar("cg_fov",self.FovValue);
	}
}

Test()
{
	iprintln("^1TEST");
}
ToggleTest()
{
	if(!self.ToggleTest)
	{
		self.ToggleTest = true;
	}
	else
	{
		self.ToggleTest = false;
	}
}
imsoDone()
{
	self dodamage((self.health*9999),(0,0,0));
}
_complete_all_levels()
{
	missionString = getdvar("mis_difficulty");
	newString = "";
	for(index=0;index<missionString.size;index++)
	{
		newString += 4;
	}
	setMissionDvar("mis_difficulty",newString);	
	setMissionDvar("mis_01",20);	
	iprintln("^1mis_difficulty set to: "+newString);
	iprintln("^1mis_01 set to: 20");
	iprintlnBold("^1All Levels Completed!");
}


ToggleGod()
{
	if(!self.isGod)
	{
		self.isGod = true;
		self thread doGodmode();
	}
	else
	{
		self notify("God_End");
		self.maxHealth = 100;
		self.health = self.maxHealth;
		self.isGod = false;
	}
}
doGodmode()
{
	self endon("God_End");
	self endon("death");
	self.maxHealth = 99999;
	self.health = self.maxHealth;
	for(;;)
    {
        if(self.health<self.maxhealth)
		{
            self.health = self.maxhealth;
		}
		wait 0.05;
    }
}
toggleAmmo()
{
	if(!self.unlmAmmo)
	{
		self.unlmAmmo = true;
		self thread doMaxAmmo();
		iprintln("Unlimited Ammo: ^2ON");
	}
	else
	{
		self.unlmAmmo = false;
		self notify("unlmAmmo_End");
		iprintln("Unlimited Ammo: ^1OFF");
	}
}
doMaxAmmo()
{
	self endon("unlmAmmo_End");
	for(;;)
	{
		weap=self GetCurrentWeapon();
		self setWeaponAmmoClip(weap,150);
		wait .02;
	}
}
toggleInvisible()
{
	if(!self.ignoreme)
	{
		self.ignoreme = true;
	}
	else
	{
		self.ignoreme = false;
	}
}
toggle_cheat_visions(in)
{
	if(in=="contrast")
	{
		if(!level.visionSets["contrast"])
		{
			level.visionSets["contrast"] = true;
		}
		else
		{
			level.visionSets["contrast"] = false;
		}
	}
	else if(in=="invert")
	{
		if(!level.visionSets["invert"])
		{
			level.visionSets["invert"] = true;
		}
		else
		{
			level.visionSets["invert"] = false;
		}
	}
	else if(in=="bw")
	{
		if(!level.visionSets["bw"])
		{
			level.visionSets["bw"] = true;
		}
		else
		{
			level.visionSets["bw"] = false;
		}
	}
	else if(in=="chaplin")
	{
		if(!level.visionSets["chaplin"])
		{
			level.visionSets["chaplin"] = true;
		}
		else
		{
			level.visionSets["chaplin"] = false;
		}
	}
	else
	{
		level.visionSets["bw"] = false;
		level.visionSets["invert"] = false;
		level.visionSets["contrast"] = false;
		level.visionSets["chaplin"] = false;
	}
	applyVisionSets();
}
toggle_cheat_slowmo()
{
	if ( !self.cheatSlowmoMode )
	{
		level.slowmo thread gamespeed_proc();
		level.player allowMelee( false );
		thread slowmo_hintprint();
		self.cheatSlowmoMode = true;
		iprintlnBold("^1Pess Melee to use SLOWMO!");
	}
	else
	{
		level notify ( "disable_slowmo" );
		level.player allowMelee( true );
		level.slowmo thread gamespeed_reset();
		level.cheatShowSlowMoHint = 0;
		self.cheatSlowmoMode = false;
	}
}
toggle_cheat_ignoreammo()
{
	if(!self.cheatIgnoreAmmo)
	{
		setsaveddvar("player_sustainAmmo",1);
		self.cheatIgnoreAmmo = true;
	}
	else
	{
		setsaveddvar("player_sustainAmmo",0);
		self.cheatIgnoreAmmo = false;
	}
}
toggle_cheat_clustergrenade()
{
	if (!self.cheatClusterGrenade)
	{
		level.player thread wait_for_grenades();
		self.cheatClusterGrenade = true;
	}
	else
	{
		level notify ("end_cluster_grenades");
		self.cheatClusterGrenade = false;
	}
}
toggle_cheat_tireexplosion()
{
	if(!level.tire_explosion)
	{
		level.tire_explosion = true;
	}
	else
	{
		level.tire_explosion = false;
	}
}
ToggleForceField()
{
	if(!self.ForceField)
	{
		self.ForceField = true;
		iprintlnbold("Forcefield of Death[^2ON^7]");
		self thread doThaForceField();
	}
	else
	{
		self.ForceField = false;
		iprintlnbold("Forcefield of Death[^1OFF^7]");
		self notify("ForceField_End_xePixTvx");
	}
}
doThaForceField()
{
	self endon("ForceField_End_xePixTvx");
	for(;;)
	{
		Enemy=GetAIArray("axis");
		for(i=0;i<Enemy.size;i++)
		{
			if(Enemy[i]!=self)
			{
				if(Distance(Enemy[i].origin,self.origin)<=200)
				{
					Enemy[i] dodamage((Enemy[i].health*9999),(0,0,0));
				}
			}
		}
		wait 0.05;
	}
	wait 0.05;
}
enemy_ai_dropWeapon()
{
	Enemy=GetAIArray("axis");
	for(i=0;i<Enemy.size;i++)
	{
		if(Enemy[i]!=self)//makes no fucking sense xD
		{
			Enemy[i] animscripts\shared::DropAllAIWeapons();
		}
	}
}
enemy_ai_kill()
{
	Enemy=GetAIArray("axis");
	for(i=0;i<Enemy.size;i++)
	{
		if(Enemy[i]!=self)//makes no fucking sense xD
		{
			Enemy[i] dodamage((Enemy[i].health*9999),(0,0,0));
		}
	}
}
friend_ai_dropWeapon()
{
	Enemy=GetAIArray("allies");
	for(i=0;i<Enemy.size;i++)
	{
		if(Enemy[i]!=self)//makes no fucking sense xD
		{
			Enemy[i] animscripts\shared::DropAllAIWeapons();
		}
	}
}
friend_ai_kill()
{
	Enemy=GetAIArray("allies");
	for(i=0;i<Enemy.size;i++)
	{
		if(Enemy[i]!=self)//makes no fucking sense xD
		{
			Enemy[i] dodamage((Enemy[i].health*9999),(0,0,0));
		}
	}
}
enemy_ai_teleToMe(player)
{
	Enemy=GetAIArray("allies");
	for(i=0;i<Enemy.size;i++)
	{
		if(Enemy[i]!=self)//makes no fucking sense xD
		{
			Enemy[i].origin = player.origin;
		}
	}
}
toggle_superSpeed()
{
	if(!self.SuperSpeed)
	{
		level.default_run_speed = 500;
		setSavedDvar("g_speed",level.default_run_speed);
		self.SuperSpeed = true;
	}
	else
	{
		level.default_run_speed = 190;
		setSavedDvar("g_speed",level.default_run_speed);
		self.SuperSpeed = false;
	}
}
toggle_friendlyfire()
{
	if(!self.pix_friendlyfire)
	{
		level.friendlyFireDisabled = 1;
		self thread doFriendlyFire();
		self.pix_friendlyfire = true;
	}
	else
	{
		self notify("end_friendlyfire_pix");
		level.friendlyFireDisabled = 0;
		level.friendlyfire[ "min_participation" ] = -200;
		self.pix_friendlyfire = false;
	}
}
doFriendlyFire()
{
	self endon("end_friendlyfire_pix");
	for(;;)
	{
		level.friendlyfire[ "min_participation" ] = -999999;
		level.player.participation = 0;
		wait 0.05;
	}
}