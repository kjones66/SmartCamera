InFar = catFile('trial3_InFar.csv', 'In');
InFarB = addDepth(InFar, 'Far');
InNear = catFile('trial3_InNear.csv', 'In');
InNearB = addDepth(InNear, 'Near');
OutFar = catFile('trial3_OutFar.csv', 'Out');
OutFarB = addDepth(OutFar, 'Far');
OutNear = catFile('trial3_OutNear.csv', 'Out');
OutNearB = addDepth(OutNear, 'Near');
OutFarB = OutFarB(2:38,:);

trial3_TotalTable = [InFarB ; InNearB ; OutFarB ; OutNearB];
% csvwrite('trial2_TT.csv', trial2_TotalTable)
trial3_TotalTable.Var910 = categorical(trial3_TotalTable.Var910);
trial3_TotalTable.Var911 = categorical(trial3_TotalTable.Var911);
% trial2_TotalTable2 = trial2_TotalTable(:,619:661);
% trial2_TotalTable3 = trial2_TotalTable(:,[619:661 910:911]);
trial3_TotalTable4 = trial3_TotalTable(:,[20:499 910:911]);


%Trial 3
ON1 = catFile('trial3_OutNear.csv','Out');
ON1 = addDepth(ON1, 'Near');
ON1 = ON1(1:10,560:619);
ON1 = catFile('trial3_OutNear.csv','Out');
ON2 = ON1(1:10,560:619);
ON3 = ON1(11:42,740:799);
ON4 = ON1(43:92,620:679);
 
OutNear2 = table2array(ON2);
OutNear3 = table2array(ON3);
OutNear4 = table2array(ON4);
[OutNear] = [OutNear2;OutNear3;OutNear4];
Out_Near = array2table(OutNear);
Out_Near = addDepth(Out_Near,'Out');
Out_Near = addDepth(Out_Near,'Near');
Out_Near.Var61 = categorical(Out_Near.Var61);
Out_Near.Var62 = categorical(Out_Near.Var62);
