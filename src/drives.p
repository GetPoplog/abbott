/* -------------------------------------------------------------------------
   ---       Concern Processing in Autonomous Agents - PhD Thesis        ---
   ---                                                                   ---
   ---       Copyright (c) Steve Allen, 1998. All rights reserved.       ---
   -------------------------------------------------------------------------

   File:            drives.p
   Author           Steve Allen, 4 Nov 2000 - (see revisions at EOF)
   Purpose:         Rules to define Abbott's drive agents.

   Libraries:       LIB sim_agent, poprulebase, objectclass, rc_graphic
                    LIB (*local) gl_agent, gl_abbott

   Related Files:   abbott.p

*/

/* --- Introduction --------------------------------------------------------

This file contains the rules that define the drive agents for the
Abbott SoM model.

Drive agents calculate their current activation level as a function of the
error signal (drive) produced by sensor agents responsible for monitoring
their controlled variable.

--------------------------------------------------------------------------*/

/* -- Extend search lists -- */

lvars filepath = sys_fname_path(popfilename);

extend_searchlist(filepath, popincludelist) -> popincludelist;
extend_searchlist(filepath, popuseslist) -> popuseslist;

/* -- System includes -- */

include gridland.ph;

uses gl_agent;
uses gl_abbott3;

/***************************************************************************
Public functions writen in this module.

***************************************************************************/

vars procedure NewDriveAggression;
vars procedure NewDriveCold;
vars procedure NewDriveCuriosity;
vars procedure NewDriveFatigue;
vars procedure NewDriveHunger;
vars procedure NewDriveSelfProtection;
vars procedure NewDriveThirst;
vars procedure NewDriveWarmth;

/***************************************************************************
External functions accessed by this module.
Specify through module public interface include files or define explicitly.
***************************************************************************/

/* -- gl_agent -- */

vars GlNameAgent;

/* -- abbott.p -- */
vars sys_suspend_ruleset;

/* -- control.p -- */

vars procedure ExtractConditionKeys;
/***************************************************************************
Private functions in this module.
Define as lexical.

***************************************************************************/

/***************************************************************************
Private macros and constants.
Define as lexical.
***************************************************************************/


/***************************************************************************
Global data declared in this module.
Extern definitions for any external global data used by this module.
File wide static data.
***************************************************************************/

/* -- Sim Agent -- */

vars sim_parent;
vars sim_myself;
vars sim_cycle_number;

/* -- Motivations -- */

vars drive_aggression_rulesystem;
vars drive_cold_rulesystem;
vars drive_curiosity_rulesystem;
vars drive_fatigue_rulesystem;
vars drive_hunger_rulesystem;
vars drive_self_protection_rulesystem;
vars drive_thirst_rulesystem;
vars drive_warmth_rulesystem;

lconstant cold_drive = {cold_drive 0};
lconstant curiosity_drive = {curiosity_drive 0};
lconstant fatigue_drive = {fatigue_drive 0};
lconstant hunger_drive = {hunger_drive 0};
lconstant self_protection_drive = {self_protection_drive 0};
lconstant thirst_drive = {thirst_drive 0};
lconstant warmth_drive = {warmth_drive 0};

lvars item;

/**************************************************************************
Functions

***************************************************************************/

/* ====================================================================== */

/* -- Ruleset Vars -- */

vars drive_aggression_calc_activation_ruleset;
vars drive_aggression_calc_activation_rulefam;

/***************************************************************************
NAME
    NewDriveAggression

SYNOPSIS
    NewDriveAggression(parent, name);

FUNCTION
    Aggression drive agent. This agent is triggered by a rise in
    noradrenaline above its set point. It looks for behaviours that will
    lower the adrenaline level.

RETURNS
    None
***************************************************************************/

define vars procedure NewDriveAggression(parent, name) /* -> agent */;
    lvars parent, name;
    lvars agent;

    newgl_drive() -> agent;
    parent -> gl_parent(agent);
    "alive" -> sim_status(agent);
    GlNameAgent(agent, name);

    "driveAggression" -> gl_id(agent);

    "decrease_noradrenaline" -> gl_drive(agent);
    "noradrenaline" -> gl_controlled_var(agent);

    0 -> gl_act_level(agent);
    10 -> gl_set_point(agent);
     5 -> gl_var_range(agent);
    10 -> gl_sat_criterion(agent);

    drive_aggression_rulesystem -> sim_rulesystem(agent);

    ExtractConditionKeys(agent) -> gl_cond_filter(agent);
    [do] -> gl_act_filter(agent);
    return(agent);
enddefine;

/* -- Rulesystem -- */

define :rulesystem drive_aggression_rulesystem;
    include: drive_aggression_calc_activation_rulefam
enddefine;

/* -- Rulefamilies -- */

define :rulefamily drive_aggression_calc_activation_rulefam;
    ruleset: drive_aggression_calc_activation_ruleset
    ruleset: sys_suspend_ruleset
enddefine;

/* -- Rulesets -- */

define :ruleset drive_aggression_calc_activation_ruleset;

    [VARS blackboard];

    RULE drive_aggression_calc
        [INDATA ?blackboard [sensor noradrenaline value ?value ==]]
        ==>
        [POP11
            lvars dist;

            /* activation level a function of drive - Primary Appraisal */
            (value - gl_set_point(sim_myself))/gl_var_range(sim_myself)
                -> gl_act_level(sim_myself);

            /* boost motivation when enemy detected - Secondary Appraisal */
            if gl_act_level(sim_myself) > 0 and
                        sim_present_data([map enemy ==], blackboard) then
                gl_act_level(sim_myself) * 5 -> gl_act_level(sim_myself);
            elseif gl_act_level(sim_myself) > 0 and
                        sim_present_data(![percept == enemy ?dist ==], blackboard) then
                gl_act_level(sim_myself) * 5 * 2/dist -> gl_act_level(sim_myself);
            endif;

            sim_eval_data([PUSH {%gl_id(sim_myself),
                    gl_act_level(sim_myself), gl_drive(sim_myself)%}
                                            activationLevels], blackboard);
        ]
        [PUSHRULESET sys_suspend_ruleset]
        [STOP]
enddefine;

/* ====================================================================== */

/* -- Ruleset Vars -- */

vars drive_cold_calc_activation_ruleset;
vars drive_cold_calc_activation_rulefam;

/***************************************************************************
NAME
    NewDriveCold

SYNOPSIS
    NewDriveCold(parent, name);

FUNCTION
    Cold drive agent. This agent is triggered by a fall in
    temperature below its set point. It looks for behaviours that will
    increase the temperature level.

RETURNS
    None
***************************************************************************/

define vars procedure NewDriveCold(parent, name) /* -> agent */;
    lvars parent, name;
    lvars agent;

    newgl_drive() -> agent;
    parent -> gl_parent(agent);
    "alive" -> sim_status(agent);
    GlNameAgent(agent, name);

    "driveCold" -> gl_id(agent);

    "increase_temperature" -> gl_drive(agent);
    "temperature" -> gl_controlled_var(agent);

    0 -> gl_act_level(agent);
    37 -> gl_set_point(agent);
    3 -> gl_var_range(agent);
    37 -> gl_sat_criterion(agent);

    drive_cold_rulesystem -> sim_rulesystem(agent);

    ExtractConditionKeys(agent) -> gl_cond_filter(agent);
    [activationLevels] -> gl_act_filter(agent);
    return(agent);
enddefine;

/* -- Rulesystem -- */

define :rulesystem drive_cold_rulesystem;
    include: drive_cold_calc_activation_rulefam
enddefine;

/* -- Rulefamily -- */

define :rulefamily drive_cold_calc_activation_rulefam;
    ruleset: drive_cold_calc_activation_ruleset
    ruleset: sys_suspend_ruleset
enddefine;

/* -- Rulesets -- */

define :ruleset drive_cold_calc_activation_ruleset;

    [VARS blackboard];

    RULE drive_cold_calc
        [INDATA ?blackboard [sensor temperature value ?value ==]]
        ==>
        [POP11
            /* activation level a function of drive - Primary Appraisal */
            -(1 + value - gl_set_point(sim_myself))/gl_var_range(sim_myself)
                        -> gl_act_level(sim_myself);

            sim_eval_data([PUSH {%gl_id(sim_myself),
                gl_act_level(sim_myself), gl_drive(sim_myself)%}
                                            activationLevels], blackboard);
        ]
        [PUSHRULESET sys_suspend_ruleset]
        [STOP]
enddefine;


/* ====================================================================== */

/* -- Ruleset Vars -- */

vars drive_curiosity_calc_activation_ruleset;
vars drive_curiosity_calc_activation_rulefam;

/***************************************************************************
NAME
    NewDriveCuriosity

SYNOPSIS
    NewDriveCuriosity(parent, name);

FUNCTION
    Curiosity drive agent. This agent is triggered by a fall in
    endorphine below its set point. It looks for behaviours that will
    increase the endorphine level.

RETURNS
    None
***************************************************************************/

define vars procedure NewDriveCuriosity(parent, name) /* -> agent */;
    lvars parent, name;
    lvars agent;

    newgl_drive() -> agent;
    parent -> gl_parent(agent);
    "alive" -> sim_status(agent);
    GlNameAgent(agent, name);

    "driveCuriosity" -> gl_id(agent);

    "increase_endorphine" -> gl_drive(agent);
    "endorphine" -> gl_controlled_var(agent);

    20 -> gl_set_point(agent);
    10 -> gl_var_range(agent);
    25 -> gl_sat_criterion(agent);

    drive_curiosity_rulesystem -> sim_rulesystem(agent);

    ExtractConditionKeys(agent) -> gl_cond_filter(agent);
    [activationLevels] -> gl_act_filter(agent);
    return(agent);
enddefine;

/* -- Rulesystem -- */

define :rulesystem drive_curiosity_rulesystem;
    include: drive_curiosity_calc_activation_rulefam
enddefine;

/* -- Rulefamily -- */

define :rulefamily drive_curiosity_calc_activation_rulefam;
    ruleset: drive_curiosity_calc_activation_ruleset
    ruleset: sys_suspend_ruleset
enddefine;

/* -- Rulesets -- */

define :ruleset drive_curiosity_calc_activation_ruleset;

    [VARS blackboard];

    RULE drive_curiosity_calc
        [INDATA ?blackboard [sensor endorphine value ?value ==]]
        ==>
        [POP11
            lvars dist;

            /* activation level a function of drive - Primary Appraisal */
            -(value - gl_set_point(sim_myself))/gl_var_range(sim_myself)
                -> gl_act_level(sim_myself);

            /* boost motivation when block detected - Secondary Appraisal */
            if gl_act_level(sim_myself) > 0 and
                        sim_present_data([map block ==], blackboard) then
                gl_act_level(sim_myself) * 3 -> gl_act_level(sim_myself);
            elseif gl_act_level(sim_myself) > 0 and
                        sim_present_data(![percept == block ?dist ==], blackboard) then
                gl_act_level(sim_myself) * 3 * 2/dist -> gl_act_level(sim_myself);
            endif;

            sim_eval_data([PUSH {%gl_id(sim_myself),
                gl_act_level(sim_myself), gl_drive(sim_myself)%}
                                        activationLevels], blackboard);
        ]
        [PUSHRULESET sys_suspend_ruleset]
        [STOP]
enddefine;

/* ====================================================================== */

/* -- Ruleset Vars -- */

vars drive_fatigue_calc_activation_ruleset;
vars drive_fatigue_calc_activation_rulefam;

/***************************************************************************
NAME
    NewDriveFatigue

SYNOPSIS
    NewDriveFatigue(parent, name);

FUNCTION
    Fatigue drive agent. This agent is triggered by a fall in energy
    below its set point. It looks for behaviours that will increase the
    energy level.

RETURNS
    None
***************************************************************************/

define vars procedure NewDriveFatigue(parent, name) /* -> agent */;
    lvars parent, name;
    lvars agent;

    newgl_drive() -> agent;
    parent -> gl_parent(agent);
    "alive" -> sim_status(agent);
    GlNameAgent(agent, name);

    "driveFatigue" -> gl_id(agent);

    "increase_energy" -> gl_drive(agent);
    "energy" -> gl_controlled_var(agent);

    0 -> gl_act_level(agent);
    100 -> gl_set_point(agent);
    50 -> gl_var_range(agent);
    150 -> gl_sat_criterion(agent);

    drive_fatigue_rulesystem -> sim_rulesystem(agent);

    ExtractConditionKeys(agent) -> gl_cond_filter(agent);
    [activationLevels] -> gl_act_filter(agent);
    return(agent);
enddefine;


/* -- Rulesystem -- */

define :rulesystem drive_fatigue_rulesystem;
    include: drive_fatigue_calc_activation_rulefam
enddefine;

/* -- Rulefamily -- */

define :rulefamily drive_fatigue_calc_activation_rulefam;
    ruleset: drive_fatigue_calc_activation_ruleset
    ruleset: sys_suspend_ruleset
enddefine;

/* -- Rulesets -- */

define :ruleset drive_fatigue_calc_activation_ruleset;

    [VARS blackboard];

    RULE drive_fatigue_calc
        [INDATA ?blackboard [sensor energy value ?value ==]]
        ==>
        [POP11
            lvars dist;

            /* activation level a function of drive - Primary Appraisal */
            -(value - gl_set_point(sim_myself))/gl_var_range(sim_myself)
                * 4 -> gl_act_level(sim_myself);

            /* boost motivation when block detected - Secondary Appraisal */
            if gl_act_level(sim_myself) > 0 and
                        sim_present_data([map block ==], blackboard) then
                gl_act_level(sim_myself) * 4 -> gl_act_level(sim_myself);
            elseif gl_act_level(sim_myself) > 0 and
                        sim_present_data(![percept == block ?dist ==], blackboard) then
                gl_act_level(sim_myself) * 4 * 2/dist -> gl_act_level(sim_myself);
            endif;


            sim_eval_data([PUSH {%gl_id(sim_myself),
                gl_act_level(sim_myself), gl_drive(sim_myself)%}
                                            activationLevels], blackboard);
        ]
        [PUSHRULESET sys_suspend_ruleset]
        [STOP]
enddefine;


/* ====================================================================== */

/* -- Ruleset Vars -- */

vars drive_hunger_calc_activation_ruleset;
vars drive_hunger_calc_activation_rulefam;

/***************************************************************************
NAME
    NewDriveHunger

SYNOPSIS
    NewDriveHunger(parent, name);

FUNCTION
    Hunger drive agent. This agent is triggered by a fall in
    blood_suger below its set point. It looks for behaviours that will
    increase the blood_sugar level.

RETURNS
    None
***************************************************************************/

define vars procedure NewDriveHunger(parent, name) /* -> agent */;
    lvars parent, name;
    lvars agent;

    newgl_drive() -> agent;
    parent -> gl_parent(agent);
    "alive" -> sim_status(agent);
    GlNameAgent(agent, name);

    "driveHunger" -> gl_id(agent);

    "increase_blood_sugar" -> gl_drive(agent);
    "blood_sugar" -> gl_controlled_var(agent);

    0 -> gl_act_level(agent);
    20 -> gl_set_point(agent);
    10 -> gl_var_range(agent);
    30 -> gl_sat_criterion(agent);

    drive_hunger_rulesystem -> sim_rulesystem(agent);

    ExtractConditionKeys(agent) -> gl_cond_filter(agent);
    [activationLevels] -> gl_act_filter(agent);
    return(agent);
enddefine;

/* -- Rulesystem -- */

define :rulesystem drive_hunger_rulesystem;
    include: drive_hunger_calc_activation_rulefam
enddefine;

/* -- Rulefamily -- */

define :rulefamily drive_hunger_calc_activation_rulefam;
    ruleset: drive_hunger_calc_activation_ruleset
    ruleset: sys_suspend_ruleset
enddefine;

/* -- Rulesets -- */

define :ruleset drive_hunger_calc_activation_ruleset;

    [VARS blackboard];

    RULE drive_hunger_calc
        [INDATA ?blackboard [sensor blood_sugar value ?value ==]]
        ==>
        [POP11
            lvars dist;

            /* activation level a function of drive - Primary Appraisal */
            -(value - gl_set_point(sim_myself))/gl_var_range(sim_myself)
                                                -> gl_act_level(sim_myself);

            /* boost motivation when food detected - Secondary Appraisal */
            if gl_act_level(sim_myself) > 0 and
                        sim_present_data([map food ==], blackboard) then
                gl_act_level(sim_myself) * 4 -> gl_act_level(sim_myself);
            elseif gl_act_level(sim_myself) > 0 and
                        sim_present_data(![percept == food ?dist ==], blackboard) then
                gl_act_level(sim_myself) * 4 * 2/dist -> gl_act_level(sim_myself);
            endif;

            sim_eval_data([PUSH {%gl_id(sim_myself),
                gl_act_level(sim_myself), gl_drive(sim_myself)%}
                                            activationLevels], blackboard);
        ]
        [PUSHRULESET sys_suspend_ruleset]
        [STOP]
enddefine;


/* ====================================================================== */

/* -- Ruleset Vars -- */

vars drive_self_protection_calc_activation_ruleset;
vars drive_self_protection_calc_activation_rulefam;

/***************************************************************************
NAME
    NewDriveSelfProtection

SYNOPSIS
    NewDriveSelfProtection(parent, name);

FUNCTION
    SelfProtection drive agent. This agent is triggered by an increase
    in pain above its set point. It looks for behaviours that will
    decrease the pain level.

RETURNS
    None
***************************************************************************/

define vars procedure NewDriveSelfProtection(parent, name) /* -> agent */;
    lvars parent, name;
    lvars agent;

    newgl_drive() -> agent;
    parent -> gl_parent(agent);
    "alive" -> sim_status(agent);
    GlNameAgent(agent, name);

    "driveSelfProtection" -> gl_id(agent);

    "decrease_pain" -> gl_drive(agent);
    "pain" -> gl_controlled_var(agent);

    0 -> gl_act_level(agent);
    0 -> gl_set_point(agent);
    2 -> gl_var_range(agent);
    0 -> gl_sat_criterion(agent);

    drive_self_protection_rulesystem -> sim_rulesystem(agent);

    ExtractConditionKeys(agent) -> gl_cond_filter(agent);
    [activationLevels] -> gl_act_filter(agent);
    return(agent);
enddefine;

/* -- Rulesystem -- */

define :rulesystem drive_self_protection_rulesystem;
    include: drive_self_protection_calc_activation_rulefam
enddefine;

/* -- Rulefamily -- */

define :rulefamily drive_self_protection_calc_activation_rulefam;
    ruleset: drive_self_protection_calc_activation_ruleset
    ruleset: sys_suspend_ruleset
enddefine;

/* -- Rulesets -- */

define :ruleset drive_self_protection_calc_activation_ruleset;

    [VARS blackboard];

    RULE drive_self_protection_calc
        [INDATA ?blackboard [sensor pain value ?value ==]]
        [INDATA ?blackboard [sensor asifpain value ?value2 ==]]
        ==>
        [POP11
            max(value2, value) -> value;
            /* activation level a function of drive - Primary Appraisal */
            (value - gl_set_point(sim_myself))/gl_var_range(sim_myself)
                    -> gl_act_level(sim_myself);

            /* boost motivation when in freespace - Secondary Appraisal */
            if gl_act_level(sim_myself) > 0 and
                    sim_present_data([map freespace ==], blackboard) then
                gl_act_level(sim_myself) * 5 -> gl_act_level(sim_myself);
            endif;

            sim_eval_data([PUSH {%gl_id(sim_myself),
                gl_act_level(sim_myself), gl_drive(sim_myself)%}
                                            activationLevels], blackboard);
        ]
        [PUSHRULESET sys_suspend_ruleset]
        [STOP]

    RULE drive_self_protection_calc
        [INDATA ?blackboard [sensor pain value ?value ==]]
        ==>
        [POP11
            /* activation level a function of drive - Primary Appraisal */
            (value - gl_set_point(sim_myself))/gl_var_range(sim_myself)
                    -> gl_act_level(sim_myself);

            /* boost motivation when in freespace - Secondary Appraisal */
            if gl_act_level(sim_myself) > 0 and
                    sim_present_data([map freespace ==], blackboard) then
                gl_act_level(sim_myself) * 5 -> gl_act_level(sim_myself);
            endif;

            sim_eval_data([PUSH {%gl_id(sim_myself),
                gl_act_level(sim_myself), gl_drive(sim_myself)%}
                                            activationLevels], blackboard);
        ]
        [PUSHRULESET sys_suspend_ruleset]
        [STOP]

    RULE drive_self_protection_calc
        [INDATA ?blackboard [sensor asifpain value ?value ==]]
        ==>
        [POP11
            /* activation level a function of drive - Primary Appraisal */
            (value - gl_set_point(sim_myself))/gl_var_range(sim_myself)
                    -> gl_act_level(sim_myself);

            /* boost motivation when in freespace - Secondary Appraisal */
            if gl_act_level(sim_myself) > 0 and
                    sim_present_data([map freespace ==], blackboard) then
                gl_act_level(sim_myself) * 5 -> gl_act_level(sim_myself);
            endif;

            sim_eval_data([PUSH {%gl_id(sim_myself),
                gl_act_level(sim_myself), gl_drive(sim_myself)%}
                                            activationLevels], blackboard);
        ]
        [PUSHRULESET sys_suspend_ruleset]
        [STOP]
enddefine;


/* ====================================================================== */

/* -- Ruleset Vars -- */

vars drive_thirst_calc_activation_ruleset;
vars drive_thirst_calc_activation_rulefam;

/***************************************************************************
NAME
    NewDriveThirst

SYNOPSIS
    NewDriveThirst(parent, name);

FUNCTION
    Thirst drive agent. This agent is triggered by a fall in
    vascular_volume below its set point. It looks for behaviours that will
    increase the vascular_volume level.

RETURNS
    None
***************************************************************************/

define vars procedure NewDriveThirst(parent, name) /* -> agent */;
    lvars parent, name;
    lvars agent;

    newgl_drive() -> agent;
    parent -> gl_parent(agent);
    "alive" -> sim_status(agent);
    GlNameAgent(agent, name);

    "driveThirst" -> gl_id(agent);

    "increase_vascular_volume" -> gl_drive(agent);
    "vascular_volume" -> gl_controlled_var(agent);

    0 -> gl_act_level(agent);
    20 -> gl_set_point(agent);
    10 -> gl_var_range(agent);
    30 -> gl_sat_criterion(agent);

    drive_thirst_rulesystem -> sim_rulesystem(agent);

    ExtractConditionKeys(agent) -> gl_cond_filter(agent);
    [activationLevels] -> gl_act_filter(agent);
    return(agent);
enddefine;

/* -- Rulesystem -- */

define :rulesystem drive_thirst_rulesystem;
    include: drive_thirst_calc_activation_rulefam
enddefine;

/* -- Rulefamily -- */

define :rulefamily drive_thirst_calc_activation_rulefam;
    ruleset: drive_thirst_calc_activation_ruleset
    ruleset: sys_suspend_ruleset
enddefine;

/* -- Rulesets -- */

define :ruleset drive_thirst_calc_activation_ruleset;

    [VARS blackboard];

    RULE drive_thirst_calc
        [INDATA ?blackboard [sensor vascular_volume value ?value ==]]
        ==>
        [POP11
            lvars dist;

            /* activation level a function of drive - Primary Appraisal */
            -(value - gl_set_point(sim_myself))/gl_var_range(sim_myself)
                                                -> gl_act_level(sim_myself);

            /* boost motivation when water detected - Secondary Appraisal */
            if gl_act_level(sim_myself) > 0 and
                        sim_present_data([map water ==], blackboard) then
                gl_act_level(sim_myself) * 4 -> gl_act_level(sim_myself);
            elseif gl_act_level(sim_myself) > 0 and
                        sim_present_data(![percept == water ?dist ==], blackboard) then
                gl_act_level(sim_myself) * 4 * 2/dist -> gl_act_level(sim_myself);
            endif;

            sim_eval_data([PUSH {%gl_id(sim_myself),
                gl_act_level(sim_myself), gl_drive(sim_myself)%}
                                            activationLevels], blackboard);
        ]
        [PUSHRULESET sys_suspend_ruleset]
        [STOP]
enddefine;

/* ====================================================================== */

/* -- Ruleset Vars -- */

vars drive_warmth_calc_activation_ruleset;
vars drive_warmth_calc_activation_rulefam;

/***************************************************************************
NAME
    NewDriveWarmth

SYNOPSIS
    NewDriveWarmth(parent, name);

FUNCTION
    Warmth drive agent. This agent is triggered by a rise in
    temperature above its set point. It looks for behaviours that will
    decrease the temperature level.

RETURNS
    None
***************************************************************************/

define vars procedure NewDriveWarmth(parent, name) /* -> agent */;
    lvars parent, name;
    lvars agent;

    newgl_drive() -> agent;
    parent -> gl_parent(agent);
    "alive" -> sim_status(agent);
    GlNameAgent(agent, name);

    "driveWarmth" -> gl_id(agent);

    "decrease_temperature" -> gl_drive(agent);
    "temperature" -> gl_controlled_var(agent);

    0 -> gl_act_level(agent);
    37 -> gl_set_point(agent);
    3 -> gl_var_range(agent);
    37 -> gl_sat_criterion(agent);

    drive_warmth_rulesystem -> sim_rulesystem(agent);

    ExtractConditionKeys(agent) -> gl_cond_filter(agent);
    [activationLevels] -> gl_act_filter(agent);
    return(agent);
enddefine;

/* -- Rulesystem -- */

define :rulesystem drive_warmth_rulesystem;
    include: drive_warmth_calc_activation_rulefam
enddefine;

/* -- Rulefamily -- */

define :rulefamily drive_warmth_calc_activation_rulefam;
    ruleset: drive_warmth_calc_activation_ruleset
    ruleset: sys_suspend_ruleset
enddefine;

/* -- Rulesets -- */

define :ruleset drive_warmth_calc_activation_ruleset;

    [VARS blackboard];

    RULE drive_warmth_calc
        [INDATA ?blackboard [sensor temperature value ?value ==]]
        ==>
        [POP11
            /* activation level a function of drive - Primary Appraisal */
            (-1 + value - gl_set_point(sim_myself))/gl_var_range(sim_myself)
                -> gl_act_level(sim_myself);

            sim_eval_data([PUSH {%gl_id(sim_myself),
                gl_act_level(sim_myself), gl_drive(sim_myself)%}
                                            activationLevels], blackboard);
        ]
        [PUSHRULESET sys_suspend_ruleset]
        [STOP]
enddefine;


/* ====================================================================== */


/* --- Revision History ---------------------------------------------------

--- Steve Allen, Nov 4, 2000
    created drives.p based on motivations.p

--- Steve Allen, Aug 6, 2000
    uses sim_eval_data() and bug fix where [NOT [selectd ==]] acted on
    wrong database.

--- Steve Allen, Aug 4, 2000
    uses INDATA and new SIM_AGENT toolkit.

--- Steve Allen, Nov 19 1998
    Standardised headers.

--- Steve Allen, Nov 8 1998
    Added Exp2 motivation agents.

--- Steve Allen, Jun 1 1998
    First written.
*/
