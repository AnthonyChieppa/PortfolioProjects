Select * From playerstats
Select * From shootingstats
Select * From gca
Select * From misc
Select * From passingstats
Select * From possessionstats
Select * From defensestats



-- Table is implied that we are looking at FORWARDS stats per 90 minutes

With Forward_stats as (
  Select
	sta.player, sta.nation, sta.pos, sta.squad, 
	sta.comp as League, sta.age, sta.min, sta."90s", 
	sta.xAG as ExpectedAssists, sta.npxG as NonPenaltyGoals,
	sta."xAG.1"::numeric as xAG_per90,
	sta."npxG.1"::numeric as xnpG_per90,
	sta.PrgP / sta."90s"::numeric as PrgP_per90,
	poss.PrgR/sta."90s"::numeric as PrgR_per90,
	poss.prgc / sta."90s"::numeric as prgc_per90,
	pass.PPA / sta."90s"::numeric as PPA_per90,
	pass.CrsPA / sta."90s"::numeric as CrsPA_per90,
	shot."Sh/90"::numeric as shots_per90, shot.PK,
	shot."Sh/90" as Shots, shot."SoT/90", shot.dist,
	gs."SCA90"::numeric as sca_per90,
	gs."TO.1" / sta."90s"::numeric as "Take-OnsGCA_per90",
	gs."SCA90" as "Shot-Creating Actions", gs."GCA90" as "Goal-Creating Actions",
	gs."TO.1" / sta."90s"::numeric as "Successfull Take-ons that Lead to a Goal",
	misc."Won%"::numeric as aerial_win_pct,
	def."Tkl%"::numeric as tackle_pct,
	(shot."Sh/90"+gs."SCA90"+gs."GCA90"+sta.PrgP+poss.PrgC)/ sta."90s"::numeric as AttackingActions_per90
From playerstats sta
	Left Join shootingstats shot Using (player, pos, comp, "90s")
	Left Join passingstats pass Using (player, pos, comp, "90s")
	Left Join defensestats def Using (player, pos, comp, "90s")
	Left Join possessionstats poss Using (player, pos, comp, "90s")
	Left Join misc Using (player, pos, comp, "90s")
	Left Join gca gs Using (player, pos, comp, "90s")
Where sta.min > 800
  And sta.pos = 'FW'
  And sta.comp in ('Premier League', 'La Liga', 'Serie A', 'Bundesliga', 'Ligue 1')
)
--Select * From Forward_stats
--order by min asc

-- Visualizations in the first join are: 
-- Expected Assists per Progressive Carries, Non-Penalty Goals per Progressive Carries,
-- Shots on Target per Progressive Carries, Shot Creating Actions per Progressive Carries,
-- And Goal Creating Actions per Progressive Carries
-- Visualizations in the second join are: 
-- Successfull Take-ons that Lead to a Goal per Shot Distance, and Successfull Take-ons that Lead to a Goal per Goal Creating Actions.
Select 
	player, nation, pos, squad, 
	League, age, min, "90s", 
	Round(prgc_per90::numeric, 2) as prgc_per90, 
	xAG_per90, xnpG_per90, shots_per90, 
	"SoT/90", dist, 
	Round(PPA_per90::numeric, 2) as PPA_per90, 
	Round(CrsPA_per90::numeric, 2) as CrsPA_per90,
	"Shot-Creating Actions", "Goal-Creating Actions",
	Round("Successfull Take-ons that Lead to a Goal"::numeric, 2)
	as "Successfull Take-ons that Lead to a Goal"
From Forward_stats
Order by xnpG_per90 desc;


-- Visualizations in this query are: 
-- Stacked Bar Chart on the ranking of squad forwards by how effective they are.
-- On tableau I limited this to the top 20
Select squad, League,
	Count(Distinct(player)) as num_forwards,
	Round(Avg(xnpG_per90::numeric), 2) as xnpG_per90,
    Round(Avg(Shots::numeric), 2) as avg_shots_per90,
    Round(Avg("Shot-Creating Actions"::numeric), 2) as avg_ShotCreatingActions_per90,
	Round(Avg(PPA_per90::numeric), 2) as PPA_per90, 
	Round(Avg(CrsPA_per90::numeric), 2) as CrsPA_per90
From Forward_stats
Group by squad, League
Having Count(Distinct(player)) > 1
Order by xnpG_per90 desc;


-- Visualizations in this query are:
-- Player data comparison radar,
-- Top 10 Forwards by League via Non-Penalty XG Percentile or Shot Creating Action Percentile (Per 90)
-- Partition by on sta.comp means that players are being compared to by other forwars in the same league.
-- Percent_Rank() scans through the dataset and assigns a percentile based on its rank after being compared using Partition by
Select 
	player, league, squad, age, nation, min, "90s", 
	xnpG_per90, NonPenaltyGoals, xAG_per90,
	sca_per90, 
	Round("Take-OnsGCA_per90"::numeric, 2) as "Take-OnsGCA_per90",
	Round(Prgr_per90::numeric, 2) as prgr_per90, 
	Round(Prgp_per90::numeric, 2) as prgp_90, 
	Round(prgc_per90::numeric, 2) as prgc_per90,
    Round(Percent_Rank() Over (Partition by League Order by xnpG_per90)::numeric, 3) as npxG_percentile,	
    Round(Percent_Rank() Over (Partition by League Order by xAG_per90)::numeric, 3) as xAG_percentile,
    Round(Percent_Rank() Over (Partition by League Order by PrgR_per90)::numeric, 3) as PrgR_percentile,   
	Round(Percent_Rank() Over (Partition by League  Order by PrgP_per90)::numeric, 3) as PrgP_percentile,
	Round(Percent_Rank() Over (Partition by League  Order by PrgC_per90)::numeric, 3) as PrgC_percentile,
	Round(Percent_Rank() Over (Partition by League  Order by PPA_per90)::numeric, 3) as PPA_percentile,
	Round(Percent_Rank() Over (Partition by League  Order by CrsPA_per90)::numeric, 3) as CrsPA_percentile,
	Round(Percent_Rank() Over (Partition by League Order by shots_per90)::numeric, 3) as shots_percentile,
	Round(Percent_Rank() Over (Partition by League Order by Pk/"90s")::numeric, 3) as PK_percentile,
    Round(Percent_Rank() Over (Partition by League Order by sca_per90)::numeric, 3) as sca_percentile,
	Round(Percent_Rank() Over (Partition by League Order by "Take-OnsGCA_per90")::numeric, 3) as "Take-OnsGCA_percentile",
	Round(Percent_Rank() Over (Partition by League Order by aerial_win_pct)::numeric, 3) as AerialDuels_percentile,
	Round(Percent_Rank() Over (Partition by League Order by tackle_pct)::numeric, 3) as TklInt_percentile,
	Round(Percent_Rank() Over (Partition by League  Order by AttackingActions_per90)::numeric, 3) as AttackingActions_percentile		  
From Forward_stats
Order by npxG_percentile desc;



-- Table is implied that we are looking at MIDFIELDERS stats per 90 minutes

With Midfield_stats as (
  Select 
  	sta.player, sta.nation, sta.pos, sta.squad, 
  	sta.comp as League, sta.age, sta.min, sta."90s",
    sta.xAG as ExpectedAssists, sta."npxG.1" as ExpectedNonPenaltyGoals,
    shot."Sh/90" as Shots, shot."SoT/90", shot.dist,
	sta."npxG+xAG" / sta."90s"::numeric as NonPenaltyGoalsPlusAssists_per90,
	sta.prgp / sta."90s"::numeric as prgp_per90,
    poss.prgc / sta."90s"::numeric as prgc_per90,
	poss.prgr / sta."90s"::numeric as prgr_per90,
	poss."Succ%"::numeric as Succ_TakeOn_pct,
	poss."Def 3rd" / sta."90s"::numeric as Def_3rd_per90,
	poss."Mid 3rd" / sta."90s"::numeric as Mid_3rd_per90,
	poss."Att 3rd" / sta."90s"::numeric as Att_3rd_per90,
	poss.dis / sta."90s"::numeric as Dispossed_per90,
	pass.kp / sta."90s"::numeric as keypasses_per90,
	pass.PPA / sta."90s"::numeric as PPA_per90,
	pass.CrsPA / sta."90s"::numeric as CrsPA_per90,
	pass."Cmp.1" / sta."90s"::numeric as ShortCompletedPasses_per90,
	pass."Cmp.2" / sta."90s"::numeric as MediumCompletedPasses_per90,
	pass."Cmp.3" / sta."90s"::numeric as LongCompletedPasses_per90,
	pass."Cmp.1"::numeric / pass.cmp AS pct_short,
	pass."Cmp.2"::numeric / pass.cmp AS pct_medium,
	pass."Cmp.3"::numeric / pass.cmp AS pct_long,
	misc.recov / sta."90s"::numeric as BallRecoveries_per90,
	misc.won / sta."90s"::numeric as HeadersWon_per90,
	misc.Int / sta."90s"::numeric as Interceptions_per90,
	misc.Fld / sta."90s"::numeric as FoulsDrawn_per90,
	misc.Fls / sta."90s"::numeric as FoulsCommitted_per90,
	misc.recov / sta."90s"::numeric as recoveries_per90,
    misc.Fld / sta."90s"::numeric as fouls_drawn_per90,
    misc.Fls / sta."90s"::numeric as fouls_committed_per90,
    misc."Won%"::numeric as aerial_win_pct,
	def."Tkl%"::numeric as tackle_pct
From playerstats sta
	Left Join shootingstats shot Using (player, pos, comp, "90s")
	Left Join passingstats pass Using (player, pos, comp, "90s")
	Left Join defensestats def Using (player, pos, comp, "90s")
	Left Join possessionstats poss Using (player, pos, comp, "90s")
	Left Join misc Using (player, pos, comp, "90s")
	Left Join gca Using (player, pos, comp, "90s")
Where sta.min > 800
	And sta.comp in ('Premier League', 'La Liga', 'Serie A', 'Bundesliga', 'Ligue 1')
	And sta.pos = 'MF'
	And Not Exists (
		Select 1 
		From playerstats ps
		Join misc ms Using (player, pos, comp, "90s")
		Where ps.player = sta.player
			And ps.pos In ('MF', 'FW')
		Group by ps.player, ms.recov
		Having Count(Distinct(ps.pos)) = 2
			And ms.recov < 130
    )
)
--Select * From Midfield_stats


-- Visualizations in this query are:
-- Progressive carries by multiple metrics
-- Top 10 Midfielders bymultiple metrics
-- Scatterplot on ball recoveries by interception, fouls drawn, and fouls committed
Select 
	player, nation, pos, squad, League, age, min, "90s", 
	ExpectedAssists,  ExpectedNonPenaltyGoals,
	Shots, "SoT/90", dist, 
	Round(prgc_per90, 2) as prgc_per90,
  	Round(ShortCompletedPasses_per90, 2) as ShortCompletedPasses_per90,
  	Round(MediumCompletedPasses_per90, 2) as MediumCompletedPasses_per90,
  	Round(LongCompletedPasses_per90, 2) as LongCompletedPasses_per90,
  	Round(pct_short, 3) as pct_short,
  	Round(pct_medium, 3) as pct_medium,
  	Round(pct_long, 3) as pct_long,
  	Round(keypasses_per90, 2) as keypasses_per90,
	Round(PPA_per90::numeric, 2) as PPA_per90, 
	Round(CrsPA_per90::numeric, 2) as CrsPA_per90,
  	Round(BallRecoveries_per90, 2) as BallRecoveries_per90,
  	Round(HeadersWon_per90, 2) as HeadersWon_per90,
  	Round(Interceptions_per90, 2) as Interceptions_per90,
  	Round(FoulsDrawn_per90, 2) as FoulsDrawn_per90,
  	Round(FoulsCommitted_per90, 2) as FoulsCommitted_per90
From Midfield_stats 
Order by prgc_per90 desc;


-- Visualizations in this query are:
-- Stacked butterfly chart on passing
Select squad, League,
	Count(Distinct(player)) as num_midfielders,
	Round(Avg(ShortCompletedPasses_per90::numeric), 2) as ShortCompletedPasses_per90,
    Round(Avg(MediumCompletedPasses_per90::numeric), 2) as MediumCompletedPasses_per90,
    Round(Avg(LongCompletedPasses_per90::numeric), 2) as LongCompletedPasses_per90,
  	Round(Avg(pct_short::numeric), 2) as pct_short,
  	Round(Avg(pct_medium::numeric), 2) as pct_medium,
  	Round(Avg(pct_long::numeric), 2) as pct_long
From Midfield_stats
Group by squad, League
Having Count(Distinct(player)) > 1
Order by num_midfielders desc;


--Visualizations for this query are:
--Midfielder radar chart
Select 
	player, league, squad, age, nation, min, "90s", 
	ExpectedAssists, ExpectedNonPenaltyGoals, Shots, "SoT/90",
	Def_3rd_per90, Mid_3rd_per90, Att_3rd_per90, 
	Succ_TakeOn_pct, Dispossed_per90,
	Round(Percent_Rank() Over (Partition by League Order by NonPenaltyGoalsPlusAssists_per90)::numeric, 3) as "npxG+xAG_percentile",
	Round(Percent_Rank() Over (Partition by League Order by prgc_per90)::numeric, 3) as PgrC_percentile,
	Round(Percent_Rank() Over (Partition by League Order by prgr_per90)::numeric, 3) as PgrR_percentile,
	Round(Percent_Rank() Over (Partition by League Order by prgP_per90)::numeric, 3) as PgrP_percentile,
	Round(Percent_Rank() Over (Partition by League Order by keypasses_per90)::numeric, 3) as KeyPasses_percentile,
	Round(Percent_Rank() Over (Partition by League  Order by PPA_per90)::numeric, 3) as PPA_percentile,
	Round(Percent_Rank() Over (Partition by League  Order by CrsPA_per90)::numeric, 3) as CrsPA_percentile,
	Round(Percent_Rank() Over (Partition by League Order by recoveries_per90)::numeric, 3) as BallRecoveries_percentile,
	Round(Percent_Rank() Over (Partition by League Order by fouls_drawn_per90)::numeric, 3) as FoulsDrawn_percentile,
	Round(Percent_Rank() Over (Partition by League Order by fouls_committed_per90)::numeric, 3) as FoulsCommitted_percentile,
	Round(Percent_Rank() Over (Partition by League Order by Dispossed_per90)::numeric, 3) as Dispossed_per90_percentile,
	Round(Percent_Rank() Over (Partition by League Order by aerial_win_pct)::numeric, 3) as AerialDuels_percentile,
	Round(Percent_Rank() Over (Partition by League Order by tackle_pct)::numeric, 3) as Tackles_percentile,
	Round(Percent_Rank() Over (Partition by League Order by Succ_TakeOn_pct)::numeric, 3) as Succ_TakeOn_percentile
From Midfield_stats
Order by KeyPasses_percentile desc;



-- Table is implied that we are looking at DEFENDERS stats per 90 minutes
With Defender_stats as
(
Select 
	sta.player, sta.nation, sta.pos, sta.squad, 
  	sta.comp as League, sta.age, sta.min, sta."90s",
    sta.xAG as ExpectedAssists, sta."npxG.1" as NonPenaltyGoals,
    shot."Sh/90" as Shots, shot."SoT/90",
	sta.prgp / sta."90s"::numeric as prgp_per90,
    poss.prgc / sta."90s"::numeric as prgc_per90,
	poss.prgr / sta."90s"::numeric as prgr_per90,
	poss."Succ%"::numeric as Succ_TakeOn_pct,
	poss."Def 3rd" / sta."90s"::numeric as Def_3rd_per90,
	poss."Mid 3rd" / sta."90s"::numeric as Mid_3rd_per90,
	poss."Att 3rd" / sta."90s"::numeric as Att_3rd_per90,
	poss.dis / sta."90s"::numeric as Dispossed_per90,
	pass.kp / sta."90s"::numeric as keypasses_per90,
	pass.PPA / sta."90s"::numeric as PPA_per90,
	pass.CrsPA / sta."90s"::numeric as CrsPA_per90,
	pass."Cmp.1" / sta."90s"::numeric as ShortCompletedPasses_per90,
	pass."Cmp.2" / sta."90s"::numeric as MediumCompletedPasses_per90,
	pass."Cmp.3" / sta."90s"::numeric as LongCompletedPasses_per90,
	pass."Cmp.1"::numeric / pass.cmp AS pct_short,
	pass."Cmp.2"::numeric / pass.cmp AS pct_medium,
	pass."Cmp.3"::numeric / pass.cmp AS pct_long,
	def."Tkl%"::numeric as tackle_pct,
	def.clr / sta."90s"::numeric as clr_per90,
	def.err / sta."90s"::numeric as errors_per90,
	misc.Int / sta."90s"::numeric as Interceptions_per90,
	misc.recov / sta."90s"::numeric as BallRecoveries_per90,
	misc.won / sta."90s"::numeric as HeadersWon_per90,
    misc.Fld / sta."90s"::numeric as fouls_drawn_per90,
    misc.Fls / sta."90s"::numeric as fouls_committed_per90,
	misc.PKcon / sta."90s"::numeric as PK_conc_per90,
	misc.CrdY / sta."90s"::numeric as Yellow_cards_per90,
    misc."Won%"::numeric as aerial_win_pct
From playerstats sta
	Left Join shootingstats shot Using (player, pos, comp, "90s")
	Left Join passingstats pass Using (player, pos, comp, "90s")
	Left Join defensestats def Using (player, pos, comp, "90s")
	Left Join possessionstats poss Using (player, pos, comp, "90s")
	Left Join misc Using (player, pos, comp, "90s")
	Left Join gca Using (player, pos, comp, "90s")
Where sta.min > 800
	And sta.comp in ('Premier League', 'La Liga', 'Serie A', 'Bundesliga', 'Ligue 1')
	And sta.pos = 'DF'
)
--Select * from Defender_stats
--Order by tackle_pct desc

-- Visualizations for this query are:
-- Bar Chart on average ball recoveries per squad
-- Scatterplot on Defensive third touches vs. ProgP
-- Top 10 Defenders
Select
	player, squad, League,
	--Count(Distinct(player)) as num_defenders,
	Round(Avg(Def_3rd_per90), 2) as Touches_in_Def_Third,
	Round(Avg(Mid_3rd_per90), 2) as Touches_in_Mid_Third,
	Round(Avg(prgp_per90), 2) as prgp_per90,
	Round(Avg(tackle_pct), 2) as avg_tackle_pct,
	Round(Avg(Interceptions_per90), 2) as avg_interceptions,
	Round(Avg(BallRecoveries_per90), 2) as avg_recoveries,
	Round(Avg(HeadersWon_per90), 2) as avg_headers_won,
	Round(Avg(aerial_win_pct), 2) as avg_aerial_win_pct,
	Round(Avg(clr_per90), 2) as Clearences_per90
From Defender_stats
	Group by player, squad, League
	--Having Count(Distinct(player)) > 2
Order by avg_tackle_pct desc;


-- Visualizations for this query are:
-- Dot plot on distribution tendencies per league (long vs short)
Select
	player, squad, League,
	Round(ShortCompletedPasses_per90, 2) as short_passes,
	Round(MediumCompletedPasses_per90, 2) as medium_passes,
	Round(LongCompletedPasses_per90, 2) as long_passes,
	Round(pct_short * 100, 1) as pct_short,
	Round(pct_medium * 100, 1) as pct_medium,
	Round(pct_long * 100, 1) as pct_long
From Defender_stats
Order by long_passes desc;


-- Visualizations for this query are:
-- Radar chart for comparing defenders
Select
	player, league, squad, age, nation, "90s",
	Round(Percent_Rank() Over (Partition by League Order by tackle_pct)::numeric, 3) as Tackles_percentile,
	Round(Percent_Rank() Over (Partition by League Order by prgc_per90)::numeric, 3) as ProgressiveCarries_percentile,
	Round(Percent_Rank() Over (Partition by League Order by prgP_per90)::numeric, 3) as ProgressivePasses_percentile,
	Round(Percent_Rank() Over (Partition by League Order by keypasses_per90)::numeric, 3) as KeyPasses_percentile,
	Round(Percent_Rank() Over (Partition by League  Order by CrsPA_per90)::numeric, 3) as CrossesPenaltyArea_percentile,
	Round(Percent_Rank() Over (Partition by League Order by Ballrecoveries_per90)::numeric, 3) as BallRecoveries_percentile,
	Round(Percent_Rank() Over (Partition by League Order by fouls_drawn_per90)::numeric, 3) as FoulsDrawn_percentile,
	Round(Percent_Rank() Over (Partition by League Order by fouls_committed_per90)::numeric, 3) as FoulsCommitted_percentile,
	Round(Percent_Rank() Over (Partition by League Order by aerial_win_pct)::numeric, 3) as AerialDuels_percentile,
	Round(Percent_Rank() Over (Partition by League Order by errors_per90)::numeric, 3) as Errors_percentile
From Defender_stats
Order by Tackles_percentile desc;


-- Table is implied that we are looking at Goalkeeper stats per 90 minutes
Select * From gk
Select * From gkavd

With Goalkeeper_stats as
(
Select 
	gk.player, gk.nation, gk.pos, gk.squad, 
  	gk.comp as League, gk.age, gk.min, gk."90s",
    gk."GA90" as Goals_Against_per90,
	gk."Save%" as Save_Percentage, 
	gk."CS%" as CleanSheet_Percentage,
	gk."Save%.1" as PenSave_Percentage, 
	gk.Saves / gk."90s":: numeric as Saves_per90,
	gk.CS / gk."90s":: numeric as CleanSheets_per90,
	gkavd.AvgLen as Average_Pass_Length,
	gkavd."AvgLen.1" as Average_GoalKick_Length,
	gkavd.Stp as Crosses_Stopped,
	gkavd."Stp%" as Crosses_Stopped_Percentage,
	gkavd."#OPA/90" as Sweeper_Actions_per90,
	gkavd.AvgDist as Average_Sweeping_Distance,
	pass."Cmp.1" / gk."90s"::numeric as ShortCompletedPasses_per90,
	pass."Cmp.2" / gk."90s"::numeric as MediumCompletedPasses_per90,
	pass."Cmp.3" / gk."90s"::numeric as LongCompletedPasses_per90,
	pass."Cmp.1"::numeric / pass.cmp AS pct_short,
	pass."Cmp.2"::numeric / pass.cmp AS pct_medium,
	pass."Cmp.3"::numeric / pass.cmp AS pct_long,
	def.clr / gk."90s"::numeric as clr_per90,
	def.err / gk."90s"::numeric as errors_per90,
	poss."Def 3rd" / gk."90s"::numeric as Def_3rd_per90,
	poss.Rec / gk."90s"::numeric as Passes_Recieved_per90,
	misc.PKcon / gk."90s"::numeric as PK_conc_per90
From gk
	Left Join gkavd Using (player, pos, comp, "90s")
	Left Join passingstats pass Using (player, pos, comp, "90s")
	Left Join defensestats def Using (player, pos, comp, "90s")
	Left Join possessionstats poss Using (player, pos, comp, "90s")
	Left Join misc Using (player, pos, comp, "90s")
Where gk.min > 500
	And gk.comp in ('Premier League', 'La Liga', 'Serie A', 'Bundesliga', 'Ligue 1')
)
--Select * From Goalkeeper_stats

-- Visualizations from this query are:
-- Scatterplot for sweeping actions to save percentage
-- Bar chart that shows clean sheets per 90 by player
Select
	player, squad, League,
	Round(Saves_per90, 2) as Saves_per90,
	Round(Save_Percentage::numeric, 2) as Save_Percentage,
	Round(PenSave_Percentage::numeric, 2) as Penalty_Save_Percentage,
	Round(CleanSheets_per90, 2) as CleanSheets_per90,
	Round(Sweeper_Actions_per90::numeric, 2) as Sweeper_Actions_per90,
	Round(Average_Sweeping_Distance::numeric, 1) as Avg_Sweeping_Distance
From Goalkeeper_stats
Order by Save_Percentage desc;

-- Visualizations from this query are:
-- Bar chart that shows % of passing types by player
-- Scatterplot on average pass length by average goal kick length
Select
	player, squad, League,
	Round(ShortCompletedPasses_per90, 2) as short_passes,
	Round(MediumCompletedPasses_per90, 2) as medium_passes,
	Round(LongCompletedPasses_per90, 2) as long_passes,
	Round(pct_short * 100, 1) as pct_short,
	Round(pct_medium * 100, 1) as pct_medium,
	Round(pct_long * 100, 1) as pct_long,
	Round(Average_Pass_Length::numeric, 1) as Avg_Pass_Length,
	Round(Average_GoalKick_Length::numeric, 1) as Avg_GoalKick_Length
From Goalkeeper_stats
Order by long_passes desc;

--Visualizations from this query are:
-- Goalkeeper radar chart
Select
	player, league, squad, age, nation, "90s",
	Round(Percent_Rank() Over (Partition by League Order by Save_Percentage)::numeric, 3) as Save_pctile,
	Round(Percent_Rank() Over (Partition by League Order by PenSave_Percentage)::numeric, 3) as PenSave_pctile,
	Round(Percent_Rank() Over (Partition by League Order by Sweeper_Actions_per90)::numeric, 3) as Sweeper_pctile,
	Round(Percent_Rank() Over (Partition by League Order by CleanSheets_per90)::numeric, 3) as CleanSheets_pctile,
	Round(Percent_Rank() Over (Partition by League Order by pct_short)::numeric, 3) as ShortPass_pctile,
	Round(Percent_Rank() Over (Partition by League Order by pct_long)::numeric, 3) as LongPass_pctile,
	Round(Percent_Rank() Over (Partition by League Order by errors_per90)::numeric, 3) as Errors_pctile
From Goalkeeper_stats
Order by Save_pctile desc;