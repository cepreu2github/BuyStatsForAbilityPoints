class BuyStatsUI extends UIScreen config(BuyStatsForAbilityPoints);

//Unit needs to be set before the call
var XComGameState_Unit Unit;

var UIPanel Panel;
var UIButton PanelButtonAccept;
var UIIcon PerkIcon, ResetIcon;

var float fInitPosX, fInitPosY, EDGE_PADDING, fAlpha;
var int iVisibleWidth, iVisibleHeight, iIconSize, iSelectedPerkID;

var int iBuyAPCost;

struct StatBind
{
	var String Title;
	var ECharStatType Stat;
	var int Increment;
	var string Icon;
};

var config array<StatBind> Stats;

struct IconPosition
{	
	var int X;
	var int Y;
};

var array<UIIcon> PerkIconList;

//builds the selection screen "PopUp"
simulated function InitScreen(XcomPlayerController InitController, 
							  UIMovie InitMovie, optional name InitName)
{
	super.InitScreen(InitController, InitMovie, InitName);

	iVisibleWidth = 700 - 2 * EDGE_PADDING;
	iVisibleHeight = 200 + 2 * EDGE_PADDING;

	iBuyAPCost = class'GeneralOptions'.default.BuyAPCost;

	BuildContainer();

	//Put eligable Perks in the Box
	PutPerks();
}

//Builds the UI
simulated function BuildContainer()
{
	local String strTitle;
	local UIBGBox Background,PanelDecoration, Side;
	local UIText PanelTitle;
	//Background
	Background = Spawn(class'UIBGBox', self);
	Background.bAnimateOnInit = false;
	Background.bCascadeFocus = false;
	Background.InitBG('SelectChoice_Background');
	Background.AnchorCenter();
	Background.SetPosition(fInitPosX,fInitPosY);
	Background.SetSize(700,350);
	Background.SetBGColor("cyan");
	Background.SetAlpha(fAlpha);	

	//Decoration >> makes it look better//
	PanelDecoration = Spawn(class'UIBGBox',self);
	PanelDecoration.bAnimateOnInit = false;
	PanelDecoration.InitBG('SelectChoice_TitleBackground');
	PanelDecoration.AnchorCenter();
	PanelDecoration.setPosition(fInitPosX,fInitPosY-40);
	PanelDecoration.setSize(700,40);
	PanelDecoration.SetBGColor("cyan");
	PanelDecoration.SetAlpha(fAlpha);

	//Container
	Panel = Spawn(class'UIPanel', self);
	Panel.bAnimateOnInit = false;
	Panel.bCascadeFocus = false;
	Panel.InitPanel();
	Panel.SetPosition(fInitPosX,fInitPosY);
	Panel.SetSize(700,250);
	
	//Accept-Button
	PanelButtonAccept = Spawn(class'UIButton', self);
	PanelButtonAccept.bAnimateOnInit = false;
	PanelButtonAccept.InitButton('PanelButtonAccept',
		"Accept (" $ -iBuyAPCost $ "AP)", OnPanelButtonAccept);
	PanelButtonAccept.AnchorCenter();
	PanelButtonAccept.setPosition(-70,130);
	PanelButtonAccept.setSize(70,30);
	if(CanAffordPerk() && !Unit.BelowReadyWillState() && !Unit.IsInjured()) 
		PanelButtonAccept.EnableButton();
	Else 
		PanelButtonAccept.DisableButton();

	
	PanelButtonAccept.SetSelected(false);
	PanelButtonAccept.SetFontSize(18);
	PanelButtonAccept.SetResizeToText(true);
	PanelButtonAccept.SetTooltipText("Select Perk");	
	
	//Title
	strTitle = "Get stats improvement for " $ ReturnFullSoldierName();
	PanelTitle = Spawn(class'UIText',self);
	PanelTitle.bAnimateOnInit = false;
	PanelTitle.InitText('PanelTitle',strTitle,false);
	PanelTitle.AnchorCenter();
	PanelTitle.SetPosition(fInitPosX+EDGE_PADDING,fInitPosY-35);
	PanelTitle.SetSize(700,40);
	PanelTitle.SetText(
		class'UIUtilities_Text'.static.GetColoredText(strTitle, eUIState_Header, 25)
	);
}

function bool CanAffordPerk()
{
	local XComGameState_HeadquartersXCom XComHQ;
	XComHQ = XComGameState_HeadquartersXCom(
		`XCOMHISTORY.GetSingleGameStateObjectForClass(
			class'XComGameState_HeadquartersXCom'
		)
	);
	if (iBuyAPCost <= Unit.AbilityPoints)
	{
		return true;
	}
	else if (iBuyAPCost <= (Unit.AbilityPoints + XComHQ.GetAbilityPoints()))
	{
		return true;
	}
	return false;
}

//Puts the eligable perks into the selection screen
simulated function PutPerks()
{
	local int idx, iIconStartX, iIconStartY;
	local array<IconPosition> IconPosList;
	local IconPosition IconPos;

	//Initialize
	iIconStartX = fInitPosX+EDGE_PADDING;
	iIconStartY = fInitPosY+EDGE_PADDING;
		
	//calculate the x/y coordinates for the icons to show and save them in IconPosList
	for(idx=0; idx < Stats.Length; idx++)
	{
		IconPos.X = PosOffsetX(idx, iIconStartX, iIconSize, EDGE_PADDING);
		IconPos.Y = PosOffsetY(idx, iIconStartY, iIconSize, EDGE_PADDING);
		IconPosList.AddItem(IconPos);
	}
	
	//place all icons from 				
	for(idx=0;idx < Stats.Length;idx++)
	{
		//Spawn all Icons
		PerkIcon = Spawn(class'UIIcon',Panel);
		PerkIcon.bAnimateOnInit = false;
		PerkIcon.InitIcon('',Stats[idx].Icon,true,true,iIconSize);
		PerkIcon.AnchorCenter();
		PerkIcon.ProcessMouseEvents(OnChildMouseEvent);
		PerkIcon.SetPosition(IconPosList[idx].X,IconPosList[idx].Y);
		PerkIcon.SetTooltipText("Get "@Stats[idx].Increment@" "@Stats[idx].Title,
			Stats[idx].Title,25,20,,,true,0.1);
		PerkIcon.bDisableSelectionBrackets = true;
		PerkIcon.SetBGColor(class'UIUtilities_Colors'.const
			.DISABLED_HTML_COLOR);
		//Every spawned icon saved into a list for later reference
		PerkIconList.AddItem(PerkIcon);
	}

	//set first Icon as active
	PerkIconList[0].SetBGColor(class'UIUtilities_Colors'.const.ENGINEERING_HTML_COLOR);
	iSelectedPerkID = 0;
}

simulated function int PosOffsetX(
	int idx, int iIconStartX, int iIconWidhtHeight, int iSpacing
)
{
	return idx * (iIconWidhtHeight + iSpacing) + iIconStartX;
}

simulated function int PosOffsetY(
	int idx, int iIconStartY, int iIconWidhtHeight, int iSpacing
)
{
	return iIconStartY;
}

//Determine what has to happen if you click on an Icon -> Change Color to Yellow & save the ID
simulated function OnChildMouseEvent(UIPanel Control, int cmd)
{
	local int idx;
	local UIIcon ClickedIcon;
	local int iSelectedIconID;
	
	switch(cmd)
	{
		case class'UIUtilities_Input'.const.FXS_L_MOUSE_DOWN:
			If (PerkIconList.Find(Control) != -1)
			{
				//Get the ID of which Item was clicked
				iSelectedIconID = PerkIconList.Find(Control);
				//Set the Icon
				ClickedIcon = PerkIconList[iSelectedIconID];
				//Set all other icon colors back to default
				for(idx=0; idx < PerkIconList.Length; idx++) 
				{
					ResetIcon = PerkIconList[idx];
					ResetIcon.SetBGColor(class'UIUtilities_Colors'.const
						.DISABLED_HTML_COLOR);
				}
				//Change the clicked icon color to yellow
				ClickedIcon.SetBGColor(class'UIUtilities_Colors'.const
					.ENGINEERING_HTML_COLOR);
				iSelectedPerkID = iSelectedIconID;
				return;
			}

			break;				
	}
}

//Kinda standard function if you press anything besides left mousedown while the 
// selection popup is open -> will close it next time you go into soldier
// abilites should still let you choose a perk
simulated function bool OnUnrealCommand(int cmd, int arg)
{
	if ( !CheckInputIsReleaseOrDirectionRepeat(cmd, arg) )
		return true;

	switch( cmd )
	{
		//accepts the perk with Gamepad
		case class'UIUtilities_Input'.const.FXS_BUTTON_A: 
			AcceptSelectedPerk();
			break;

		case class'UIUtilities_Input'.const.FXS_BUTTON_L3:
			//ShowInfoPopup(); // not implemented, maybe later
			break;

		//handle all Gamepad right directions
		case class'UIUtilities_Input'.const.FXS_DPAD_RIGHT:
		case class'UIUtilities_Input'.const.FXS_BUTTON_RBUMPER:
		case class'UIUtilities_Input'.const.FXS_VIRTUAL_LSTICK_RIGHT:
			SelectIcon(iSelectedperkID,PerkIconList,1,
				class'UIUtilities_Colors'.const.DISABLED_HTML_COLOR,
				class'UIUtilities_Colors'.const.ENGINEERING_HTML_COLOR);
			break;
		
		//handle all Gamepad left directions	
		case class'UIUtilities_Input'.const.FXS_DPAD_LEFT:
		case class'UIUtilities_Input'.const.FXS_BUTTON_LBUMPER:
		case class'UIUtilities_Input'.const.FXS_VIRTUAL_LSTICK_LEFT:
			SelectIcon(iSelectedperkID,PerkIconList,-1,
				class'UIUtilities_Colors'.const.DISABLED_HTML_COLOR,
				class'UIUtilities_Colors'.const.ENGINEERING_HTML_COLOR);
			break;	

		case class'UIUtilities_Input'.const.FXS_DPAD_UP:
			break;
		case class'UIUtilities_Input'.const.FXS_DPAD_DOWN:
			break;
		
		//closes perk screen without a selection
		case class'UIUtilities_Input'.const.FXS_BUTTON_B:
		case class'UIUtilities_Input'.const.FXS_KEY_ESCAPE:
		case class'UIUtilities_Input'.const.FXS_R_MOUSE_DOWN:
			CloseScreen();
			break;

		case class'UIUtilities_Input'.const.FXS_MOUSE_SCROLL_UP:
			break;

		case class'UIUtilities_Input'.const.FXS_MOUSE_SCROLL_DOWN:
			break;
	}
	return true; // consume all input
}

simulated function SelectIcon(out int ID, array<UIIcon> IconList, int iDirection,
	string UnselectedColor, string SelectedColor)
{
	local UIIcon CurrentIcon;
	local UIICon NextIcon;
	local int iNextID;

	switch(iDirection)
	{
		case  1: for(iNextID = ID+1; iNextID < IconList.Length;iNextID++)
				{
					CurrentIcon = IconList[iD];
					CurrentIcon.SetBGColor(UnselectedColor);
					ID = iNextID;
					NextIcon = IconList[ID];
					NextIcon.SetBGColor(SelectedColor);
					return;
				}
				break;
				
		case -1: for(iNextID = ID-1;iNextID >= 0; iNextID--)
				{
					CurrentIcon = IconList[ID];
					CurrentIcon.SetBGColor(UnselectedColor);
					ID = iNextID;
					NextIcon = IconList[iD];
					NextIcon.SetBGColor(SelectedColor);
					return;
				}
				break;
		default: return;
	}
}

public function OnPanelButtonAccept(UIButton Button)
{
	AcceptSelectedPerk();
}

//Adds the selcted stats perk to the soldier
simulated function AcceptSelectedPerk()
{
	local XComGameStateHistory History;
	local XComGameState UpdateState;
	local XComGameStateContext_ChangeContainer ChangeContainer;
	local int idx;
	local int sharedCost;
	local float newStatValue;

	if(!CanAffordPerk())
	{
		CloseScreen();
		return;
	}

	idx = iSelectedPerkID;
	History = `XCOMHISTORY;
	ChangeContainer = class'XComGameStateContext_ChangeContainer'.static
		.CreateEmptyChangeContainer("Upgrade Stats in BuyStatUI");
	UpdateState = History.CreateNewGameState(true, ChangeContainer);
	Unit = XComGameState_Unit(
		UpdateState.ModifyStateObject(class'XComGameState_Unit', Unit.ObjectID)
	);

	newStatValue = Unit.GetMaxStat(Stats[idx].Stat) + float(Stats[idx].Increment);
	Unit.SetBaseMaxStat(
		Stats[idx].Stat, newStatValue, ECSMAR_None
	);
	Unit.SetCurrentStat(
		Stats[idx].Stat, newStatValue
	);
	sharedCost = PaySoldierAPs(iBuyAPCost);

	`GAMERULES.SubmitGameState(UpdateState);
	PaySharedAPs(sharedCost);

	CloseScreen();
}

simulated function int PaySoldierAPs(int AbilityPointCost)
{
	local int sharedCost;
	if (Unit.AbilityPoints >= AbilityPointCost)
	{
		// If the unit can afford the ability on their own, spend their AP
		Unit.AbilityPoints -= AbilityPointCost;
		Unit.SpentAbilityPoints += AbilityPointCost; // Save the amount of AP spent
		sharedCost = 0;
	}
	else
	{
		sharedCost = AbilityPointCost - Unit.AbilityPoints;
		Unit.SpentAbilityPoints += Unit.AbilityPoints;
		Unit.AbilityPoints = 0; // The unit spent all of their remaining AP
	}
	return sharedCost;
}

simulated function PaySharedAPs(int AbilityPointCost)
{
	local XComGameState_HeadquartersXCom XComHQ;
	local XComGameStateHistory History;
	local XComGameState NewGameState;

	History = `XCOMHISTORY;
	NewGameState = class'XComGameStateContext_ChangeContainer'.static
		.CreateChangeState("Upgrade Stats in BuyStatUI AP Costs");
	// If the unit must pay an Ability Point cost to purchase this ability
	XComHQ = XComGameState_HeadquartersXCom(
		History.GetSingleGameStateObjectForClass(class'XComGameState_HeadquartersXCom')
	);
	XComHQ = XComGameState_HeadquartersXCom(NewGameState.ModifyStateObject(
		class'XComGameState_HeadquartersXCom', XComHQ.ObjectID
	));
	XComHQ.AddResource(
		NewGameState, 'AbilityPoint', -AbilityPointCost
	);
	
	`XCOMGAME.GameRuleset.SubmitGameState(NewGameState);
}

//Returns the Soldiername to show in the perk selection popup
simulated function string ReturnFullSoldierName()
{	
	//local XComGameState_Unit Unit;
	local string m_SoldierName;

	m_SoldierName = Unit.GetFirstName() $ " " $
					Unit.GetNickName()  $ " " $
					Unit.GetLastName();

	return m_SoldierName;
}

defaultproperties
{
	EDGE_PADDING = 20;
	fInitPosX = -350;
	fInitPosY = -175;
	iIconSize = 64;
	fAlpha = 0.9f;
}