/* -------------------------------------------------------------------------
   ---       Concern Processing in Autonomous Agents - PhD Thesis        ---
   ---                                                                   ---
   ---       Copyright (c) Steve Allen, 1998. All rights reserved.       ---
   -------------------------------------------------------------------------

   File:            abbott.p
   Author           Steve Allen, 4 Nov 2000 - (see revisions at EOF)
   Purpose:         To perform Abbott housekeeping tasks and build the
                    Society of Mind that is the Abbott architecture.

   Libraries:       LIB sim_agent, poprulebase, objectclass, rc_graphic
                    LIB (*local) gl_agent, gl_abbott

   Related Files:   sensors.p dir_nemes.p maps.p recognisers.p
                    motivations.p emotions.p filter.p managers.p
                    behaviours.p effectors.p body.p
*/

/* --- Introduction --------------------------------------------------------

This files contains the Abbott definitions for the SoM Abbott architecture.
The members of the society are held in the variable "the_society" - allowing
new child agents to be easily added.

--------------------------------------------------------------------------*/

/* -- Extend search lists -- */

lvars filepath = sys_fname_path(popfilename);

extend_searchlist(filepath, popincludelist) -> popincludelist;
extend_searchlist(filepath, popuseslist) -> popuseslist;

/* -- System includes -- */

include gridland.ph;

uses gl_agent;
uses gl_abbott3;
uses float_parameters;

compile(sys_fname_path(popfilename) dir_>< 'sensors.p');
compile(sys_fname_path(popfilename) dir_>< 'dir_nemes.p');
compile(sys_fname_path(popfilename) dir_>< 'recognisers.p');
compile(sys_fname_path(popfilename) dir_>< 'maps.p');
compile(sys_fname_path(popfilename) dir_>< 'drives.p');
compile(sys_fname_path(popfilename) dir_>< 'changeGen.p');
compile(sys_fname_path(popfilename) dir_>< 'relevanceEval.p');
compile(sys_fname_path(popfilename) dir_>< 'somaticMarker.p');
compile(sys_fname_path(popfilename) dir_>< 'filter.p');
compile(sys_fname_path(popfilename) dir_>< 'motivatorManager.p');
compile(sys_fname_path(popfilename) dir_>< 'motivatorMetaManager.p');
compile(sys_fname_path(popfilename) dir_>< 'actionProposer.p');
compile(sys_fname_path(popfilename) dir_>< 'managers.p');
compile(sys_fname_path(popfilename) dir_>< 'behaviours.p');
compile(sys_fname_path(popfilename) dir_>< 'skills.p');
compile(sys_fname_path(popfilename) dir_>< 'effectors.p');
compile(sys_fname_path(popfilename) dir_>< 'body.p');

/***************************************************************************
Public functions writen in this module.

    define vars procedure InitAbbott(agent);
    define :method vars sim_setup(agent:gl_parent);
    define :method vars print_instance(item:gl_parent);
    define :method vars print_instance(item:gl_child);
    define :method vars sim_run_agent(agent:gl_abbott, agents);

***************************************************************************/

/* -- Abbott Architecture -- */

vars procedure InitAbbott;          /* initialise the SoM Abbott agent    */
vars procedure sim_setup;           /* SIM_AGENT initialisation routine   */
vars procedure print_instancec;     /* define print instances for Abbott  */
vars procedure sim_run_agent;       /* SIM_AGENT execute agent routine    */

/***************************************************************************
External functions accessed by this module.
Specify through module public interface include files or define explicitly.
***************************************************************************/

/* -- Sensors: sensor.p -- */

vars procedure NewSenseBloodPressure;
vars procedure NewSenseBloodSugar;
vars procedure NewSenseEnergy;
vars procedure NewSenseHeartRate;
vars procedure NewSensePain;
vars procedure NewSenseRespirationRate;
vars procedure NewSenseTemperature;
vars procedure NewSenseVascularVolume;
vars procedure NewSenseNorAdrenaline;
vars procedure NewSenseAdrenaline;
vars procedure NewSenseDopamine;
vars procedure NewSenseEndorphine;
vars procedure NewSenseOccupancy;
vars procedure NewSenseHardness;
vars procedure NewSenseOrganic;
vars procedure NewSenseBrightness;
vars procedure NewSenseFoot;

/* -- Directions: dir_neme.p -- */

vars procedure NewDirTopLeft;
vars procedure NewDirTop;
vars procedure NewDirTopRight;
vars procedure NewDirRight;
vars procedure NewDirBottomRight;
vars procedure NewDirBottom;
vars procedure NewDirBottomLeft;
vars procedure NewDirLeft;

/* -- Recognisers: recognisers.p -- */

vars procedure NewRecogniserAttendTo;

/* -- Maps: maps.p -- */

vars procedure NewMapOccupancy;
vars procedure NewMapFreespace;
vars procedure NewMapWater;
vars procedure NewMapFood;
vars procedure NewMapLivingBeing;
vars procedure NewMapBlock;
vars procedure NewMapAbbott;
vars procedure NewMapEnemy;

/* -- Drives: drives.p -- */

vars procedure NewDriveAggression;
vars procedure NewDriveCold;
vars procedure NewDriveCuriosity;
vars procedure NewDriveFatigue;
vars procedure NewDriveHunger;
vars procedure NewDriveSelfProtection;
vars procedure NewDriveThirst;
vars procedure NewDriveWarmth;

/* -- Relevance Evaluaton: relevanceEval.p -- */

vars procedure NewDangerRelEval;

/* -- Somatic Markers: somaticMarker.p -- */

vars procedure NewPainSomaticMarker;

/* -- Filter: filter.p -- */

vars procedure NewAttentionFilter;

/* -- Motivator Manager: motivatorManager.p -- */

vars procedure NewMotivatorManager;

/* -- Motivator Manager: motivatorMetaManager.p -- */

vars procedure NewMotivatorMetaManager;

/* -- Behaviours: behaviours.p -- */

vars procedure NewBehaviourAttack;
vars procedure NewBehaviourDrink;
vars procedure NewBehaviourEat;
vars procedure NewBehaviourPlay;
vars procedure NewBehaviourRest;
vars procedure NewBehaviourWalk;
vars procedure NewBehaviourWithdraw;

/* -- Managers: managers.p -- */

vars procedure NewManagerFinder;
vars procedure NewManagerLookFor;
vars procedure NewManagerLookForward;
vars procedure NewManagerGoTowards;

/* -- Action Proposer: actionProposer.p -- */

vars procedure NewActionProposer;

/* -- Change Genertors: changeGen.p -- */

vars procedure NewNoradrenalineChangeGen;
vars procedure NewAdrenalineChangeGen;
vars procedure NewDopamineChangeGen;

/* -- Skills: skills.p -- */

vars procedure NewSkillAttack;
vars procedure NewSkillDrink;
vars procedure NewSkillEat;
vars procedure NewSkillPlay;
vars procedure NewSkillRest;
vars procedure NewSkillWalk;
vars procedure NewSkillWithdraw;

/* -- Effectors: effectors.p -- */

vars procedure NewEffectorFoot;
vars procedure NewEffectorHand;
vars procedure NewEffectorMouth;
vars procedure NewEffectorEye;

/* -- Body: body.p --*/

vars procedure NewBodyRegulation;

/* -- control.p -- */

vars sim_sense_eaten;

/***************************************************************************
Private functions in this module.
Define as lexical.
***************************************************************************/

/***************************************************************************
Private macros and constants.
***************************************************************************/

/* -- Society: defines the Abbott SoM -- */


lconstant the_society = [

    /* competence level 0 */

    [[SenseAdrenaline SenseNorAdrenaline SenseDopamine SenseEndorphine SenseBloodPressure
        SenseBloodSugar SenseEnergy SensePain SenseTemperature
            SenseRespirationRate SenseVascularVolume SenseOccupancy
                SenseHardness SenseOrganic SenseEye
                    SenseBrightness SenseFoot] ^gl_sensors]

    [[DirTopLeft DirTop DirTopRight DirRight DirBottomRight
        DirBottom DirBottomLeft DirLeft] ^gl_dir_nemes]

    [[MapOccupancy MapFreespace MapWater MapFood MapLivingBeing
        MapBlock MapAbbott MapEnemy MapBlock] ^gl_maps]

    [[DriveCold DriveFatigue DriveHunger DriveSelfProtection DriveThirst
        DriveCuriosity DriveAggression DriveWarmth] ^gl_drives]

    [[DangerRelEval] ^gl_relevanceEvals]

    [[ActionProposer] ^gl_actionProposers]

    [[SkillWalk SkillFindWater SkillFindFood SkillWithdraw
        SkillFindRest SkillPlay SkillAttack] ^gl_skills]

    [[NoradrenalineChangeGen AdrenalineChangeGen DopamineChangeGen]
                                         ^gl_changeGens]

    [[EffectorFoot EffectorMouth EffectorHand EffectorEye] ^gl_effectors]

    [[BodyRegulation] ^gl_body]

    /* competence level 1 */

    [[RecogniserAttendTo] ^gl_recognisers]

    [[PainSomaticMarker] ^gl_somaticMarkers]

    /* competence level 2 */

    [[AttentionFilter] ^gl_attentionFilter]

    [[MotivatorManager] ^gl_motivatorManager]

    [[ManagerFinder ManagerLookFor ManagerLookForward
        ManagerGoTowards] ^gl_managers]

    [[BehaviourWalk BehaviourDrink BehaviourEat BehaviourWithdraw
        BehaviourRest BehaviourPlay BehaviourAttack] ^gl_behaviours]

    /* competence level 3 */

    [[MotivatorMetaManager] ^gl_motivatorMetaManager]

    ];

/***************************************************************************
Global data declared in this module.
Extern definitions for any external global data used by this module.
File wide static data.

***************************************************************************/

vars sim_parent;                        /* Abbott parent agent  */
vars blackboard;                        /* global blackboard    */

lvars i;                                /* local variable       */

/* -- Abbott Rulesystem -- */

vars abbott_rulesystem;             /* Abbott housekeeping rulesystem     */

vars sys_suspend_ruleset;
vars sys_suspend_ruleset1;
vars sys_suspend_ruleset2;
vars sys_suspend_ruleset3;
vars sys_suspend_ruleset4;


/**************************************************************************
Functions
***************************************************************************/

/*
    Abbott Architecture
    ===================

    InitAbbott();                   - initilise the SoM Abbott agent
    sim_setup();                    - SIM_AGENT initialisation routine
    print_intance();                - define print instances for Abbott
    sim_run_agent();                - SIM_AGENT execute agent routine
*/

/***************************************************************************
NAME
    InitAbbott

SYNOPSIS
    InitAbbott(agent);

FUNCTION
    Initialises the Abbott Society of mind (parent and child agents) -
    building the society specified in varible "the_society", initialising
    the physiological variables and setting up the global black-board.

    The housekeeping rules are defined by the abbott_rulesystem.

RETURNS
    None.
***************************************************************************/

define vars procedure InitAbbott(agent);
    lvars agent;

    lvars specialists, agents, type, new_proc;
    lvars society_member, i;

    10 -> gl_adrenaline(agent);
    10 -> gl_adrenaline_sp(agent);
    10 -> gl_noradrenaline(agent);
    10 -> gl_noradrenaline_sp(agent);
    12 -> gl_blood_pressure(agent);
    12 -> gl_blood_pressure_sp(agent);
    30 -> gl_blood_sugar(agent);
    20 -> gl_blood_sugar_sp(agent);
    10 -> gl_dopamine(agent);
    10 -> gl_dopamine_sp(agent);
    20 -> gl_endorphine(agent);
    20 -> gl_endorphine_sp(agent);
    120 -> gl_energy(agent);
    100 -> gl_energy_sp(agent);
    75 -> gl_heart_rate(agent);
    75 -> gl_heart_rate_sp(agent);
    0 -> gl_pain(agent);
    0 -> gl_pain_sp(agent);
    0 -> gl_asifpain(agent);
    0 -> gl_asifpain_sp(agent);
    8 -> gl_respiration_rate(agent);
    8 -> gl_respiration_rate_sp(agent);
    37 -> gl_temperature(agent);
    37 -> gl_temperature_sp(agent);
    25 -> gl_vascular_volume(agent);
    20 -> gl_vascular_volume_sp(agent);

    "alive" -> sim_status(agent);
    [{SimSenseEaten}] -> sim_sensors(agent);
    abbott_rulesystem -> sim_rulesystem(agent);
    false -> gl_active_mot(agent);

    /* create a shared database */

    prb_newdatabase(sim_dbsize,[]) -> sim_data(agent);
    prb_newdatabase(sim_dbsize,[]) -> sim_shared_data(agent);
    true -> gl_use_shared_data(agent);          /* lets use it */

    /* initialise the Society of Mind called Abbott */

    vars data = sim_get_data(agent);
    [%
        for specialists in the_society do
            dl(specialists) -> (agents, type);
            [%
                for society_member in agents do
                    idval(identof("New" <> society_member)) -> new_proc;
                    if isprocedure(new_proc) then
                        new_proc(agent, society_member)
                    endif;
                endfor
            %] ->> type(agent), dl()
        endfor;
    %] -> gl_children(agent);

    agent -> gl_active_agent(gl_window);

    /* share same database between motivator manager and meta manager */
    lvars managerDB;
    if gl_motivatorManager(agent) /== nil and
                                gl_motivatorMetaManager(agent) /== nil then
        sim_get_data(front(gl_motivatorManager(agent))) -> managerDB;
        for agents in gl_motivatorMetaManager(agent) do
            managerDB -> gl_managerDB(agents);
        endfor;
    endif;

    /* setup database */
    prb_add_to_db([eye_position ^(gl_eye_position(agent))],
                                                        sim_get_data(agent));
    prb_add_to_db([activationLevels], sim_get_data(agent));
enddefine;

/***************************************************************************
NAME
    sim_setup

SYNOPSIS
    sim_setup(agent);

FUNCTION
    Provides a hook to setup the child agents in the Abbott SoM.

RETURNS
    None.
***************************************************************************/

define :method vars sim_setup(agent:gl_parent);
    lvars agent;
    lvars obj;
    call_next_method(agent);

    for obj in gl_children(agent) do
        sim_setup(obj);
    endfor;
enddefine;

/***************************************************************************
NAME
    print_instance

SYNOPSIS
    print_instance(agent);

FUNCTION
    Print rules for parent and child Abbott agents.

RETURNS
    None.
***************************************************************************/

define :method vars print_instance(item:gl_parent);
    dlocal pop_pr_places = 3;
    printf(
        '<agent %P at (%P %P) composed of %P>',
            [% sim_name(item), explode(gl_loc(item)),
                gl_children(item) %])
enddefine;

define :method vars print_instance(item:gl_child);
    dlocal pop_pr_places = 3;
    printf('%P',[% sim_name(item) %])
enddefine;

/***************************************************************************
NAME
    sim_run_agent

SYNOPSIS
    sim_run_agent(agent, agents);

FUNCTION
    This provides the main entry point for the Abbott SoM. The routine
    first calls the method for the parent Abbott agent, and then
    systematically runs the child agents that make up the society. Each
    child agent has its own private workspace on the global black-board by
    prefixing black-board entries with "xBB_"

RETURNS
    None.
***************************************************************************/

define :method vars sim_run_agent(agent:gl_abbott, agents);
    lvars agent, agents;
    lvars children, child;
    lvars item, add_list;

    if sim_status(agent) == "dead" then
        return;
    endif;

    /* define blackboard */
    dlocal blackboard = sim_get_data(agent);
    dlocal sim_myID;

    call_next_method(agent, agents);

    /* rulesystem for childeren */
    dlocal sim_parent = agent;


    /* run child agents */
    for children in gl_children_slots do
        for child in children(agent) do
            child -> sim_myself;
            gl_id(child) -> sim_myID;

            sim_run_agent(child, []);

            sim_do_actions(child, [], sim_cycle_number);
            []->(sim_get_data(child))("new_sense_data");
        endfor;
    endfor;

enddefine;

define :method vars sim_run_agent(agent:gl_shared_data_mixin, agents);
    dlocal sim_get_data = if gl_use_shared_data(agent) then
            sim_shared_data else sim_data endif;
    call_next_method(agent, agents);
enddefine;

/*========================================================================*/

define :rulesystem abbott_rulesystem;
    include: abbott_counter
    include: abbott_scheduler

enddefine;

define :ruleset abbott_counter;

    [VARS blackboard];

    RULE abbott_start
        [INDATA ?blackboard [clock_tick]]
        ==>
        [INDATA ?blackboard [NOT clock_tick]]
        [INDATA ?blackboard [REPLACE [cycle_count ==] [cycle_count 0]]]
        [INDATA ?blackboard [REPLACE [activationLevels ==][activationLevels]]]
        [STOP]

    RULE abbott_count
        [INDATA ?blackboard [cycle_count ?x]][->>count]
        ==>
        [INDATA ?blackboard [DEL ?count]]
        [POP11 x + 1 -> x]
        [INDATA ?blackboard [cycle_count ?x]]
        [STOP]
enddefine;

define :ruleset sys_suspend_ruleset;

    [VARS blackboard];

    RULE suspend
        [INDATA ?blackboard [cycle_count 0]]
        ==>
        [POPRULESET]
enddefine;

define :ruleset sys_suspend_ruleset1;

    [VARS blackboard];

    RULE suspend1
        [INDATA ?blackboard [cycle_count 1]]
        ==>
        [POPRULESET]
enddefine;

define :ruleset sys_suspend_ruleset2;

    [VARS blackboard];

    RULE suspend2
        [INDATA ?blackboard [cycle_count 2]]
        ==>
        [POPRULESET]
enddefine;


define :ruleset sys_suspend_ruleset3;

    [VARS blackboard];

    RULE suspend3
        [INDATA ?blackboard [cycle_count 3]]
        ==>
        [POPRULESET]
enddefine;

define :ruleset sys_suspend_ruleset4;

    [VARS blackboard];

    RULE suspend4
        [INDATA ?blackboard [cycle_count 4]]
        ==>
        [POPRULESET]
enddefine;

define :ruleset abbott_scheduler;

    [VARS blackboard];

    RULE abbott_start
        [INDATA ?blackboard [cycle_count 0]]
        ==>
        [POP11
            /*
                Action Selection Algorithm:

                1) Both the internal variables and the environment are
                   sensed, objects "subliminally" recognised, maps built.
                   Not all this information will be attended to by Abbott,
                   but only those pieces that are relevant to its
                   motivational state.

                2) Motivations are assessed and the effects of the
                   creature's affectal state computed. The motivation
                   with the highest activation is selected.
            */
        ]
        [STOP]

    RULE abbott_cycle1
        [INDATA ?blackboard [cycle_count 1]]
        ==>
        [POP11
            /*
                3) The active motivation selects the behaviour(s) that can
                   best satisfy its drive - a consumatory behaviour if the
                   incentive stimulus is present, an appetitive one
                   otherwise.
            */
        ]
        [STOP]

enddefine;

/*========================================================================*/


/* --- Revision History ---------------------------------------------------

--- Steve Allen, Nov 4, 2000
    Move towards the Abbott3 implementation

--- Steve Allen, Aug 4 2000
    Added support for new SIM_AGENT toolkit

--- Steve Allen, Nov 21 1998
    Standardised the header and finalise Abbott2.

--- Steve Allen, Nov 6 1998
    Additional agents added to support Abbott2.

--- Steve Allen, Nov 3 1998
    Abbott1 architecture defined.

--- Steve Allen, Jun 3 1998
    Internal structure of Abbott added.

--- Steve Allen, Jun 1 1998
    First written
*/
