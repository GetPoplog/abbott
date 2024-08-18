/* -------------------------------------------------------------------------
   ---       Concern Processing in Autonomous Agents - PhD Thesis        ---
   ---                                                                   ---
   ---       Copyright (c) Steve Allen, 2000. All rights reserved.       ---
   -------------------------------------------------------------------------

   File:            experiments.p
   Author           Steve Allen, 26 Dec 2000 - (see revisions at EOF)
   Purpose:         Uses gl_agent and sim_agent to create a Gridland
                    Scenario in which to experiment with Society of Mind
                    models of motivational agent architectures.

   Libraries:       LIB sim_agent, poprulebase, objectclass, rc_graphic
                    LIB (*local) gl_agent, gl_abbott3

   Related Files:   control.p file.p, enemy.p, abbott3a.p, sensors.p
                    dir_nemes.p maps.p relevanceEval.p recognisers.p
                    somaticMarker.p drives.p filter.p actionProposer.p
                    skills.p changeGen.p motivatorManager.p managers.p
                    behaviours.p motivatorMetaManager.p effectors.p
                    body.p
*/

/* --- Introduction --------------------------------------------------------

This files contains a number of procedures that can be used to evaluate
Abbott at various levels of competance. These procedures can readily be
modified to test other aspects of the architecture (only the basic
survivability of the agent is currently tested).

The tests (experiments) remove child members from the Society of Mind that
is Abbott, in order to evaluate the relative performace enhancements of the
different architectural levels.

Valid batch commands are:

    new                 - new experiment
    reset               - reset experiment
    ranseed ^seed       - set random number generator seed
    save                - save experiment
    open                - open experiment
    quit                - quit
    goto ^count         - goto cycle number
    big_step            - step one world cycle
    step                - step single cycle
    pause               - pause (cancel run)
    run                 - run
    display true/false  - enable/disable display
    grid {^x ^y ^cell array/nonarray}   - set grid size
    cycle false/^time   - set cycle time
    exec ^proc          - execute procedure
    exec {p1 p2 proc}   - execute proc(p1, p2);
    remove ^agent       - remove agent
    enemy               - add enemy  (must reset before start expt)
    abbott              - add abbott    "                     "
    food                - add food      "                     "
    water               - add water     "                     "
    line                - add line      "                     "
    circle              - add circle    "                     "
    square              - add square    "                     "
    rectangle           - add rectangle "                     "
    triangle            - add triangle  "                     "
    show_blank          - show no status windows
    show_status         - show status window
    show_data           - show data window
    show_debug          - show debug window
    trace_status true/false     - enable status trace
    trace_data true/false       - enable data trace
    trace_sensors true/false    - enable sensor trace
    trace_activation true/false - enable activation trace
    trace_debug false/^level    - enable debug trace
    wait                - wait for experiment to pause/stop

I.e.
        BatchStart([enemy enemy enemy abbott abbott reset show_blank run]);

                ... will run with an extra 3 enemies and 2 abbotts.

Commands with parameters must be passed as a vector. I.e.

        BatchStart([{goto 100} wait {exec {1 2 hello}}]);
--------------------------------------------------------------------------*/

/* dummy for a1 */
vars a1;

/* define the agents to remove for each competence level */

vars level3 = [{remove a1MotivatorMetaManager}];

vars level2 = [{remove a1AttentionFilter} {remove a1MotivatorManager}
        {remove a1ManagerFinder} {remove a1ManagerLookFor}
            {remove a1ManagerLookForward} {remove a1ManagerGoTowards}
        {remove a1BehaviourWalk} {remove a1BehaviourDrink}
            {remove a1BehaviourEat} {remove a1BehaviourWithdraw}
                {remove a1BehaviourRest} {remove a1BehaviourPlay}
                    {remove a1BehaviourAttack}];

vars level1 = [{remove a1RecogniserAttendTo} {remove a1PainSomaticMarker}];


/* define some experiments */

define vars procedure RunExptSeeds(name, numExpts, start, len, ran, myCmds, seeds);
    lvars name, numExpts, start, len, ran, myCmds, seeds;
    lvars seed, count, cmds;
    ran -> ranseed;

    [^^myCmds show_blank {goto ^len} wait quit] -> cmds;

    /* generate seeds */
    /*
    lvars seeds = [%for seed from 1 to numExpts do random(10000) endfor%];
    if start > 1 then allbutfirst(start-1,seeds)->seeds; endif;
    */

    /* print header */
    [name: ^name] =>
    [seeds: ^^seeds] =>
    [cmds:  {ranseed seed} ^^cmds] =>
    [results:] =>

    /*
        Perform tests - we have also included a way to break out of the
        loop if the test completes within the first 10 cycles. The only
        way this can happen is if you manually interrupt the test and
        say "goto 1" then "quit".
    */
    start -> count;
    for seed in seeds do
        BatchStart([{ranseed ^seed} ^^cmds]);
        [^name ^count cycles, lives (seed):    ^my_cycle_number    ^(gl_Organic(a1))   ( ^seed )] =>

        /* emergency stop */
        if my_cycle_number < 10 then quitloop endif;

        1 + count -> count;
    endfor;
enddefine;
define vars procedure RunExpt(name, numExpts, start, len, ran, myCmds);
    lvars name, numExpts, start, len, ran, myCmds;
    lvars seed, count, cmds;
    ran -> ranseed;

    [^^myCmds show_blank {goto ^len} wait quit] -> cmds;

    /* generate seeds */
    lvars seeds = [%for seed from 1 to numExpts do random(10000) endfor%];
    if start > 1 then allbutfirst(start-1,seeds)->seeds; endif;

    /* print header */
    [name: ^name] =>
    [seeds: ^^seeds] =>
    [cmds:  {ranseed seed} ^^cmds] =>
    [results:] =>

    /*
        Perform tests - we have also included a way to break out of the
        loop if the test completes within the first 10 cycles. The only
        way this can happen is if you manually interrupt the test and
        say "goto 1" then "quit".
    */
    start -> count;
    for seed in seeds do
        BatchStart([{ranseed ^seed} ^^cmds]);
        [^name ^count cycles, lives (seed):    ^my_cycle_number    ^(gl_Organic(a1))   ( ^seed )] =>

        /* emergency stop */
        if my_cycle_number < 10 then quitloop endif;

        1 + count -> count;
    endfor;
enddefine;

define vars procedure Expt1();
    RunExpt('Expt1', 30, 1, 10000, 200,
                        [^^level1 ^^level2 ^^level3]);
enddefine;

define vars procedure Expt2();
    RunExpt('Expt2', 30, 1, 10000, 200,
                        [^^level2 ^^level3]);
enddefine;

define vars procedure Expt3();
    RunExpt('Expt3', 30, 1, 10000, 200,
                        [^^level3]);
enddefine;

define vars procedure Expt4();
    RunExpt('Expt4', 30, 1, 10000, 200, []);
enddefine;

define vars procedure setFilter(a,b);
    dlocal prb_database = sim_get_data(a1);
    prb_flush1([filterSettings ==]);
    prb_add([filterSettings ^a ^b]);
enddefine;

vars e1,e2,e3;
define vars procedure setImortalE();
    100 -> gl_Organic(e1);
    100 -> gl_Organic(e2);
    100 -> gl_Organic(e3);
enddefine;

define vars procedure Expt5(percent, fixed);
    lvars percent, fixed, cmds, name;

    'Expt5(' >< percent >< ', ' >< fixed >< ')' -> name;
    [{exec {^percent ^fixed setFilter}}] -> cmds;
    RunExpt(name, 30, 1, 10000, 200, cmds);
enddefine;

define vars procedure Expt5b(percent, fixed);
    lvars percent, fixed, cmds, name;

    'Expt5b(' >< percent >< ', ' >< fixed >< ')' -> name;
    [^^level3 {exec {^percent ^fixed setFilter}}] -> cmds;
    RunExpt(name, 30, 1, 10000, 200, cmds);
enddefine;

define vars procedure resetMotivators();
    dlocal prb_database = sim_get_data(a1);
    prb_add([resetMotivators]);
enddefine;

define vars procedure Expt6();
    RunExpt('Expt6', 30, 1, 10000, 200, [{exec resetMotivators}]);
enddefine;

define vars procedure Expt7();
    RunExpt('Expt7', 30, 1, 10000, 200, [{remove a1ActionProposer}]);
enddefine;

define vars procedure Expt7b();
    RunExpt('Expt7b', 30, 1, 10000, 200,
        [{remove a1ActionProposer} ^^level3]);
enddefine;

define vars procedure setOrganic(val);
    lvars val;
    val -> gl_Organic(a1);
enddefine;


/*
Expt3();
Expt4();
Expt5(0.07,0.05);
Expt5(0.05,0.05);
Expt5(0,0.05);
Expt6();
*/
