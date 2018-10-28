class BuyStatsPromotionScreenListener extends UIScreenListener;

event OnInit(UIScreen Screen)
{
	local UIScreen Promotion_Screen;
	local XcomGameState_HeadquartersXCom XComHQ;
	local UIAlert Alert;
	local XComGameState_Unit Unit;

	if (!class'GeneralOptions'.default.ShowBuyStatsButton)
	{
		return;
	}

	Alert = UIAlert(Screen);

	Promotion_Screen = UIArmory_PromotionHero(Screen);
	if(Promotion_Screen != none)
	{
		XComHQ = class'UIUtilities_Strategy'.static.GetXComHQ();
		if (XComHQ.HasFacilityByName('Recoverycenter'))
		{
			SpawnButton(Promotion_Screen);
		}
	}
}

simulated function SpawnButton(UIScreen Promotion_Screen)
{
	local UIButton BuyStatsButton;
	
	BuyStatsButton = Promotion_Screen.Spawn(class 'UIButton', Promotion_Screen);
	BuyStatsButton.SetResizeToText(false);
	BuyStatsButton.bAnimateOnInit = false;
	BuyStatsButton.InitButton('BuyStatsBTN', "Buy stats", OnBuyStatsButton)
		.SetPosition(1040, 750).SetWidth(150);			
}

simulated function OnBuyStatsButton(UIButton Button)
{
	`log("Clicked \"Buy stats\" button");
	//`log("Class is "@Unit.GetSoldierClassTemplate().DataName@"Aborting");
	OpenSelectionScreen(Button.Screen);
}

simulated function OpenSelectionScreen(UIScreen Screen)
{
	local BuyStatsUI SelectionPanel;
	local XComGameStateHistory History;
	local UIScreen Promotion_Screen;
	
	Promotion_Screen = Screen;

	History = `XCOMHISTORY;

	SelectionPanel = Promotion_Screen.Spawn(class'BuyStatsUI',Promotion_Screen);
	SelectionPanel.Unit = XComGameState_Unit(History.GetGameStateForObjectID(
		UIArmory_PromotionHero(Promotion_Screen).UnitReference.ObjectID)
	);
	Promotion_Screen.Movie.Stack.Push(SelectionPanel);
	SelectionPanel.Show(); 
}

defaultproperties
{
	//setting it to a specific screen so it won't fire on every fucking screen we are in
	//setting it to none after all so it will work with overriden UIArmory_PromotionHero
	ScreenClass = none;
	//Debug variables
}