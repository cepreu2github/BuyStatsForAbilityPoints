class UIScreenListener_MonthlyAP extends UIScreenListener;

// When the Screen defined at the end of this file is opened, execute this code
event OnInit(UIScreen Screen)
{
	local UIResistanceReport uiResistanceReport;

	uiResistanceReport = UIResistanceReport(Screen);

	AddResource(class'GeneralOptions'.default.RegularApIncome);
}

exec function AddResource(int Points)
{
	local XComGameState_HeadquartersXCom XComHQ;
	local XComGameStateHistory History;
	local XComGameState NewGameState;

	History = `XCOMHISTORY;

	NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("Create Overflow AP");
	XComHQ = XComGameState_HeadquartersXCom(History.GetSingleGameStateObjectForClass(class'XComGameState_HeadquartersXCom'));
	XComHQ = XComGameState_HeadquartersXCom(NewGameState.CreateStateObject(class'XComGameState_HeadquartersXCom', XComHQ.ObjectID));
	NewGameState.AddStateObject(XComHQ);

	// Add an amount of ability points equal to the ResourceQuantity2 value from the GiveReward function that we used as a parameter
	XComHQ.AddResource( NewGameState, 'AbilityPoint', Points );
	`XCOMGAME.GameRuleset.SubmitGameState(NewGameState);
	
}

defaultProperties
{
	// Set the screen that the Event at the top of this file is listening for
	ScreenClass = UIResistanceReport
}