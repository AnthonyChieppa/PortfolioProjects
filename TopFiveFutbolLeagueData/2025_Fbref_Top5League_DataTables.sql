--Drop table if exists PlayerStats--

-- Columns with '.1' are Per 90 for this table

create table PlayerStats
(
Player	varchar,
Nation	varchar,
Pos	varchar,
Squad	varchar,
Comp	varchar,
Age	float,
Born	float,	
MP	int,
Starts	int,
Min	float,
"90s"	float,
Gls	int,
Ast	int,
"G+A"	int,
"G-PK"	int,	
PK	int,
PKatt	int,
CrdY	int,
CrdR	int,
xG	float,
npxG	float,
xAG	float,
"npxG+xAG"	float,
PrgC	int,
PrgP	int,
PrgR	int,
"Gls.1"	float,
"Ast.1"	float,
"G+A.1"	float,
"G-PK.1"	float,
"G+A-PK"	float,
"xG.1"	float,
"xAG.1"	float,
"xG+xAG"	float,
"npxG.1"	float,
"npxG+xAG.1"	float
)

-- Column 'tkl' is for any type of player while 'tkl.1' is for number of dribblers for this table

create table DefenseStats
(
Player	varchar,
Nation	varchar,
Pos	varchar,
Squad	varchar,
Comp	varchar,
Age		float,
Born	float,
"90s"	float,
Tkl	int,
TklW	int,
"Def 3rd"	int,
"Mid 3rd"	int,
"Att 3rd"	int,
"Tkl.1"	int,
"Att"	int,
"Tkl%"	float,
Lost	int,
Blocks	int,
Sh	int,
Pass	int,
"Int"	int,
"Tkl+Int"	int,
Clr	int,
Err	int
)

-- This table has two sets of data
-- Standard column names are for shot creating actions
-- Columns with '.1' are for goal creating actions

create table GCA
(
Player	varchar,
Nation	varchar,
Pos	varchar,
Squad	varchar,
Comp	varchar,
Age	float,
Born	float,	
"90s"	float,
SCA	int,
"SCA90"	float,
PassLive	int,
PassDead	int,
"TO"	int,
Sh	int,
Fld	int,
Def	int,
GCA	int,
"GCA90"	float,
"PassLive.1"	int,
"PassDead.1"	int,
"TO.1"	int,
"Sh.1"	int,
"Fld.1"	int,
"Def.1"	int
)

-- This table has four sets of data
-- Standard column names are for total passsing stat numbers
-- Columns with '.1' are for short passing stats
-- Columns with '.2' are for medium passing stats
-- Columns with '.3' are for long passing stats

create table PassingStats
(
Player	varchar,
Nation	varchar,
Pos	varchar,
Squad	varchar,
Comp	varchar,
Age	float,
Born	float,	
"90s"	float,
Cmp	int,
Att	int,
"Cmp%"	float,
TotDist	int,
PrgDist	int,
"Cmp.1"	int,
"Att.1"	int,
"Cmp%.1"	float,
"Cmp.2"	int,
"Att.2"	int,
"Cmp%.2"	float,
"Cmp.3"	int,
"Att.3"	int,
"Cmp%.3"	float,
Ast	int,
xAG	float,
xA	float,
"A-xAG"	float,
KP	int,
"3-Jan"	int,
PPA	int,
CrsPA	int,
PrgP	int
)
ALTER TABLE PassingStats
RENAME COLUMN "3-Jan" TO "1/3"
Select * from PassingStats

-- This table has four sets of data
-- Touches, Take-Ons, Carries, and Receiving are the categories

create table PossessionStats
(
Player	varchar,
Nation	varchar,
Pos	varchar,
Squad	varchar,
Comp	varchar,
Age	float,
Born	float,	
"90s"	float,
Touches	int,
"Def Pen"	int,	
"Def 3rd"	int,
"Mid 3rd"	int,
"Att 3rd"	int,
"Att Pen"	int,
Live	int,
Att	int,
Succ	int,
"Succ%"	float,
Tkld	int,
"Tkld%"	float,
Carries	int,
TotDist	int,
PrgDist	int,
PrgC	int,
"3-Jan"	int,
CPA	int,
Mis	int,
Dis	int,
Rec	int,
PrgR	int
)
ALTER TABLE PossessionStats
RENAME COLUMN "3-Jan" TO "1/3"
Select * from PossessionStats

-- This table has two sets of data
-- Standard stats for shots and expected goals from shots

create table ShootingStats
(
Player	varchar,
Nation	varchar,
Pos	varchar,
Squad	varchar,
Comp	varchar,
Age	float,
Born	float,	
"90s"	float,
Gls	int,
Sh	int,
SoT	int,
"SoT%"	float,
"Sh/90"	float,
"SoT/90"	float,
"G/Sh"	float,
"G/SoT"	float,
Dist	float,
FK	int,
PK	int,
PKatt	int,
xG	float,
npxG	float,
"npxG/Sh"	float,
"G-xG"	float,
"np:G-xG"	float
)

-- This table has two sets of data
-- Performance and aerial duels

Create Table Misc
(
Player	varchar,
Nation	varchar,
Pos	varchar,
Squad	varchar,
Comp	varchar,
Age	float,
Born	float,	
"90s"	float,
CrdY	int,
CrdR	int,
"2CrdY"	int,
Fls	int,
Fld	int,
Off	int,
Crs	int,
Int	int,
TklW	int,
PKwon	int,
PKcon	int,
OG	int,
Recov	int,
Won	int,
Lost	int,
"Won%"	float
)

-- This table has three sets of data
-- Playing time, performance, and penalty kicks

Create Table Gk
(
Player	varchar,
Nation	varchar,
Pos	varchar,
Squad	varchar,
Comp	varchar,
Age	float,
Born	float,	
MP	int,
Starts	int,
Min	float,
"90s"	float,
GA	int,
"GA90"	float,
SoTA	int,
Saves	int,
"Save%"	float,
W	int,
D	int,
L	int,
CS	int,
"CS%"	float,
PKatt	int,
PKA	int,
PKsv	int,
PKm	int,
"Save%.1" float
)

-- This table has seven sets of data
-- goals, expected, launched, passes, Goal Kicks, Crosses, Sweeper

Create Table GkAvd
( 
Player	varchar,
Nation	varchar,
Pos	varchar,
Squad	varchar,
Comp	varchar,
Age	float,
Born	float,	
"90s"	float,
GA	int,
PKA	int,
FK	int,
CK	int,
OG	int,
PSxG	float,
"PSxG/SoT"	float,
"PSxG+/-"	float,
"/90"	float,
Cmp	int,
Att	int,
"Cmp%"	float,
"Att (GK)"	int,
Thr	int,
"Launch%"	float,
AvgLen	float,
"Att.1"	int,
"Launch%.1"	float,
"AvgLen.1"	float,
Opp	int,
Stp	int,
"Stp%"	float,
"#OPA"	int,
"#OPA/90"	float,
AvgDist	float
)