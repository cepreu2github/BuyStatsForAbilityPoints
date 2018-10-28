class X2DownloadableContentInfo_BuyStatsForAbilityPoints extends X2DownloadableContentInfo;

static event OnPostTemplatesCreated()
{
	if (class'GeneralOptions'.default.DisableCovertOpsStatBoosts)
	{
		DisableCovertOpsStatBoostRewards();
	}
}

static function DisableCovertOpsStatBoostRewards()
{
	local X2StrategyElementTemplateManager	StratMgr;
	local array<X2StrategyElementTemplate>	ActionTemplates;
	local X2CovertActionTemplate			ActionTemplate;
	local array<X2DataTemplate>				AllDifficultiesTemplates;
	local int								i, j, k;
	
	StratMgr = class'X2StrategyElementTemplateManager'.static.GetStrategyElementTemplateManager();
	ActionTemplates = StratMgr.GetAllTemplatesOfClass(class'X2CovertActionTemplate');
	
	for (i = 0; i < ActionTemplates.Length; i++)
	{
		StratMgr.FindDataTemplateAllDifficulties(ActionTemplates[i].DataName, AllDifficultiesTemplates);
		
		for (j = 0; j < AllDifficultiesTemplates.Length; j++)
		{
			ActionTemplate = X2CovertActionTemplate(AllDifficultiesTemplates[j]);
			
			for (k = 0; k < ActionTemplate.Slots.Length; k++)
			{
				ActionTemplate.Slots[k].Rewards.Length = 0;
			}
		}
		
		AllDifficultiesTemplates.Length = 0;
	}
}