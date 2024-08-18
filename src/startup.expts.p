/* initialisation stuff */

compile(sys_fname_path(popfilename) dir_>< 'controlLite.p');
compile(sys_fname_path(popfilename) dir_>< 'experiments.p');

1024 -> popgcratio;
20000000 -> popmemlim;          ;;; program image grew to 88Mbytes
90 -> poplinewidth;
poplinewidth+40 -> poplinemax;

lvars myStart = 1;
lvars myEnd = 100;


vars noSkills = [{remove a1SkillWalk} {remove a1SkillFindWater} {remove a1SkillFindFood} {remove a1SkillWithdraw} {remove a1SkillFindRest} {remove a1SkillPlay} {remove a1SkillAttack}];

/* remove individual agents */
RunExpt('No Som 5e', myEnd, myStart, 20000, 200, [enemy enemy reset {remove a1PainSomaticMarker}]);
[expts 9-12] =>

RunExpt('No react 5e', myEnd, myStart, 20000, 200, [enemy enemy reset {remove a1ActionProposer}]);
[expts 13-16] =>

RunExpt('No relevance 5e', myEnd, 71, 20000, 200, [enemy enemy reset {remove a1DangerRelEval}]);
[expts 17-20] =>

RunExpt('No skills 7l', myEnd, myStart, 20000, 200, [{exec {7 setOrganic}} ^^noSkills]);
RunExpt('No skills 5e', myEnd, myStart, 20000, 200, [enemy enemy reset ^^noSkills]);
[expts 21-24] =>

/* run with more enemies and lives */
RunExpt('Expt1 7e 9l', myEnd, myStart, 20000, 200, [enemy enemy enemy enemy reset {exec {9 setOrganic}} ^^level1 ^^level2 ^^level3]);
RunExpt('Expt2 7e 9l', myEnd, myStart, 20000, 200, [enemy enemy enemy enemy reset {exec {9 setOrganic}} ^^level2 ^^level3]);
RunExpt('Expt3 7e 9l', myEnd, myStart, 20000, 200, [enemy enemy enemy enemy reset {exec {9 setOrganic}} ^^level3]);
RunExpt('Expt4 7e 9l', myEnd, myStart, 20000, 200, [enemy enemy enemy enemy reset {exec {9 setOrganic}}]);
[expts 63-68 end] =>

