Two-tiered tagging system

Tier 1: Default User preference Feed
Tagging by default is done using preset fixed options, for which users set preferences (from 1-5) on initiation. These preferences are region + sector, both of which have one primary + two optional secondaries. 

The user relevance score for each news event is thus calculated as follow:
Top level: Sector relevance x Region relevance x System relevance (default Sorting Score)
Full equation: ((User Preference x Primary Sector Weight + User Preference x Secondary Sector Weight + User Preference x Tertiary Sector Weight)/Total Weight of Sectors) x ((User Preference x Primary Region Weight + User Preference x Secondary Region Weight + User Preference x Tertiary Sector Region)/(Total Weight of Regions)) x Default Sorting Score

Requires testing, but the base assumption is that the tendency for mid-sector, mid-relevance events to be prioritised is likely desirable (as minimum scores likely reflect deliberate avoidance).
Note that ISO region codes will have to be matched programmatically to user preference regions

Region list: All regions using  – ISO 3166-1 alpha-3 Code
Sector list: "1"=Politics & Government, "2"=Business & Economy, "3"=Conflict / Military, "4"= Crime & Justice, "5"= Technology, "6"=Environment & Climate, "7"=Weather, "8"=Real Estate, "9"=Science, "10"=Health & Medicine, "11"=Education, "12"=Sports, "13"=Arts & Entertainment, "14"=Lifestyle & Culture, "15"=Religion & Ethics, “16”= Opinion & Commentary, “17”= Other
(1-8 hard, 9-16 soft)


Tier 2: Dynamic Feed
Dynamic feed items are automatically brought to the top of the user feed, internally sorted based on the calculations above.
For each event, there are up to five dynamic tags generated from relevant Public Figures, Companies, Institutions, or Locations. For consistency, only Wikipedia titles in the relevant language may be used (en-GB/zh-HK/zh-CN); entities without multilingual Wikipedia entries in all required languages are not included.
