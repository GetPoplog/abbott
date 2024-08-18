/* -------------------------------------------------------------------------
   ---       Concern Processing in Autonomous Agents - PhD Thesis        ---
   ---                                                                   ---
   ---       Copyright (c) Steve Allen, 1998. All rights reserved.       ---
   -------------------------------------------------------------------------

   File:            sensors.p
   Author           Steve Allen, 19 Nov 1998 - (see revisions at EOF)
   Purpose:         Rules to define Abbott's sensor agents.

   Libraries:       LIB sim_agent, poprulebase, objectclass, rc_graphic
                    LIB (*local) gl_agent, gl_abbott

   Related Files:   abbott.p

*/

/* --- Introduction --------------------------------------------------------

This file contains the rules that define the sensor agents for the Abbott
SoM model. Each sensor monitors a particular variable/attribute and posts
the perceived value on the blackboard at the start of each world cycle.

--------------------------------------------------------------------------*/

/* -- Extend search lists -- */

lvars filepath = sys_fname_path(popfilename);

extend_searchlist(filepath, popincludelist) -> popincludelist;
extend_searchlist(filepath, popuseslist) -> popuseslist;

/* -- System includes -- */

include gridland.ph;

uses gl_agent;
uses gl_abbott3;
uses int_parameters;

/***************************************************************************
Public functions writen in this module.

***************************************************************************/

vars procedure NewSenseBloodPressure;
vars procedure NewSenseBloodSugar;
vars procedure NewSenseEnergy;
vars procedure NewSenseHeartRate;
vars procedure NewSensePain;
vars procedure NewSenseRespirationRate;
vars procedure NewSenseTemperature;
vars procedure NewSenseVascularVolume;

vars procedure NewSenseAdrenaline;
vars procedure NewSenseNorAdrenaline;
vars procedure NewSenseDopamine;
vars procedure NewSenseEndorphine;

vars procedure NewSenseOccupancy;
vars procedure NewSenseHardness;
vars procedure NewSenseOrganic;

vars procedure NewSenseBrightness;
vars procedure NewSenseEye;
vars procedure NewSenseFoot;

/***************************************************************************
External functions accessed by this module.
Specify through module public interface include files or define explicitly.
***************************************************************************/

/* -- gl_agent -- */

vars GlNameAgent;
vars GlGrid;

/* -- abbott.p -- */
vars sys_suspend_ruleset;
vars blackboard;

/* -- control.p -- */
vars procedure ExtractConditionKeys;
vars procedure ShowEye;

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

/* -- Body State -- */

vars sense_pain_rulesystem;
vars sense_pain_rulefam;
vars sense_pain_ruleset;
vars sense_blood_pressure_rulesystem;
vars sense_blood_pressure_rulefam;
vars sense_blood_pressure_ruleset;
vars sense_blood_sugar_rulesystem;
vars sense_blood_sugar_rulefam;
vars sense_blood_sugar_ruleset;
vars sense_energy_rulesystem;
vars sense_energy_rulefam;
vars sense_energy_ruleset;
vars sense_heart_rate_rulesystem;
vars sense_heart_rate_rulefam;
vars sense_heart_rate_ruleset;
vars sense_respiration_rate_rulesystem;
vars sense_respiration_rate_rulefam;
vars sense_respiration_rate_ruleset;
vars sense_temperature_rulesystem;
vars sense_temperature_rulefam;
vars sense_temperature_ruleset;
vars sense_vascular_volume_rulesystem;
vars sense_vascular_volume_rulefam;
vars sense_vascular_volume_ruleset;

/* -- Hormones -- */

vars sense_adrenaline_rulesystem;
vars sense_adrenaline_rulefam;
vars sense_adrenaline_ruleset;
vars sense_dopamine_rulesystem;
vars sense_noradrenaline_rulesystem;
vars sense_noradrenaline_rulefam;
vars sense_noradrenaline_ruleset;
vars sense_dopamine_rulefam;
vars sense_dopamine_ruleset;
vars sense_endorphine_rulesystem;
vars sense_endorphine_rulefam;
vars sense_endorphine_ruleset;

/* -- Tactile Sensors -- */

vars sense_gravity_rulesystem;
vars sense_gravity_rulefam;
vars sense_gravity_ruleset;
vars sense_occupancy_rulesystem;
vars sense_occupancy_rulefam;
vars sense_occupancy_ruleset;
vars sense_hardness_rulesystem;
vars sense_hardness_rulefam;
vars sense_hardness_ruleset;
vars sense_organic_rulesystem;
vars sense_organic_rulefam;
vars sense_organic_ruleset;

/* -- Visual Sensors -- */

vars sense_brightness_rulesystem;
vars sense_brightness_rulefam;
vars sense_brightness_ruleset;
vars sense_eye_rulesystem;
vars sense_eye_rulefam;
vars sense_eye_ruleset;

/* -- Proprioceptive Feedback -- */

vars sense_foot_rulesystem;
vars sense_foot_rulefam;
vars sense_foot_ruleset;

/* -- Sim Agent -- */

vars sim_parent;
vars sim_myself;
vars sim_cycle_number;

/* -- temp variables -- */
lvars value;
lvars diff;
lvars change;
lvars i, j, x, y;

lconstant eyemask = [
        [^true ^true ^false ^false ^false ^false ^false ^true]
        [^false ^true ^true ^true ^false ^false ^false ^false]
        [^false ^false ^false ^true ^true ^true ^false ^false]
        [^false ^false ^false ^false ^false ^true ^true ^true]];


/* -- Sensor Eye -- */
lconstant distance = {2 4 9 16};
lconstant horizontal = {8 4 4 8};
lconstant diagonal = {1 3 5 7};
lconstant vertical = {2 2 6 6};
lconstant rays = [
        [^false ^false ^false ^false]
        [^false ^true  ^false ^false]
        [^false ^true  ^true  ^false]
        [^true  ^true  ^true  ^false]];

lvars ray;
lvars steps;
lvars stepx;
lvars stepy;

lvars relx, rely, a_relx, a_rely;
lvars item, old_item;
lvars dist, val;
lvars eye_position, mask;

/**************************************************************************
Functions

***************************************************************************/

/* ====================================================================== */

define :method sim_run_sensors(agent:gl_sensor, agents)
                                                    /* -> sensor_data */;
    [];
enddefine;

define :method sim_do_actions(agent:gl_sensor, agents, cycle_number);
enddefine;

/* ====================================================================== */

/***************************************************************************
NAME
    NewSensePain

SYNOPSIS
    NewSensePain(parent, name);

FUNCTION

RETURNS
    None
***************************************************************************/
define vars procedure NewSensePain(parent, name) /* -> agent */;
    lvars parent, name;
    lvars agent;

    newgl_sensor() -> agent;
    parent -> gl_parent(agent);
    "alive" -> sim_status(agent);
    GlNameAgent(agent, name);

    "Pain" -> gl_id(agent);

    gl_pain(parent) -> gl_value(agent);
    2 -> gl_range(agent);
    gl_value(agent) - gl_pain_sp(parent) -> gl_diff(agent);

    sense_pain_rulesystem -> sim_rulesystem(agent);
    ExtractConditionKeys(agent) -> gl_cond_filter(agent);
    [[sensor pain]] -> gl_act_filter(agent);
    return(agent);
enddefine;

/* -- Rulesystem -- */

define :rulesystem sense_pain_rulesystem;
    include: sense_pain_rulefam
enddefine;

/* -- Rulefamilies -- */

define :rulefamily sense_pain_rulefam;
    ruleset: sense_pain_ruleset
    ruleset: sys_suspend_ruleset
enddefine;

/* -- Rulesets -- */

define :ruleset sense_pain_ruleset;

    [VARS blackboard];

    RULE clear
        [INDATA ?blackboard [cycle_count 0]]
        [INDATA ?blackboard [sensor pain ==]]
        ==>
        [INDATA ?blackboard [NOT sensor pain ==]]

    RULE clear
        [INDATA ?blackboard [cycle_count 0]]
        [INDATA ?blackboard [sensor asifpain ==]]
        ==>
        [INDATA ?blackboard [NOT sensor asifpain ==]]

    RULE sense_pain
        ==>
        [POP11
            lvars endorphine_range, endorphine_diff, dir;
            gl_pain(sim_parent) -> value;

            /* take into account the effect of hormone */
            if sim_present_data(![sensor endorphine == range
                    ?endorphine_range diff ?endorphine_diff ==],
                                                            blackboard) then
                if endorphine_diff > 0 then
                     value * (1 + (endorphine_diff * gl_range(sim_myself)
                                 / endorphine_range)) -> value;
                endif;
            endif;

            value - gl_pain_sp(sim_parent) -> diff;
            diff - gl_diff(sim_myself) -> change;
            diff -> gl_diff(sim_myself);

            if change /= 0 then
                sim_eval_data([REPLACE [sensor pain ==] [sensor pain value ^value direction
                        ^(gl_pain_dir(sim_parent))
                            range ^(gl_range(sim_myself))
                                diff ^diff change ^change]], blackboard);
            endif;

            if gl_asifpain(sim_parent) /= 0 then
                sim_eval_data([REPLACE [sensor asifpain ==] [sensor asifpain value
                    ^(gl_asifpain(sim_parent)) direction
                        ^(gl_asifpain_dir(sim_parent))]], blackboard);
            endif;
        ]
        [STOP]
enddefine;

/* ====================================================================== */

/***************************************************************************
NAME
    NewSenseBloodPressure

SYNOPSIS
    NewSenseBloodPressure(parent, name);

FUNCTION

RETURNS
    None
***************************************************************************/
define vars procedure NewSenseBloodPressure(parent, name) /* -> agent */;
    lvars parent, name, agent;

    newgl_sensor() -> agent;
    parent -> gl_parent(agent);
    "alive" -> sim_status(agent);
    GlNameAgent(agent, name);

    "BloodPressure" -> gl_id(agent);

    gl_blood_pressure(parent) -> gl_value(agent);
    4 -> gl_range(agent);
    gl_value(agent) - gl_blood_pressure_sp(parent) -> gl_diff(agent);

    sense_blood_pressure_rulesystem -> sim_rulesystem(agent);
    ExtractConditionKeys(agent) -> gl_cond_filter(agent);
    [[sensor blood_pressure]] -> gl_act_filter(agent);
    return(agent);
enddefine;

/* -- Rulesystem -- */

define :rulesystem sense_blood_pressure_rulesystem;
    include: sense_blood_pressure_rulefam
enddefine;

/* -- Rulefamilies -- */

define :rulefamily sense_blood_pressure_rulefam;
    ruleset: sense_blood_pressure_ruleset
    ruleset: sys_suspend_ruleset
enddefine;

/* -- Rulesets -- */

define :ruleset sense_blood_pressure_ruleset;

    RULE sense_blood_pressure
        ==>
        [POP11
            gl_blood_pressure(sim_parent) -> value;
            value - gl_blood_pressure_sp(sim_parent) -> diff;
            diff - gl_diff(sim_myself) -> change;
            diff -> gl_diff(sim_myself);

            prb_eval([INDATA ^blackboard [REPLACE [sensor blood_pressure ==]
                    [sensor blood_pressure value ^value
                            range ^(gl_range(sim_myself)) diff ^diff
                                                    change ^change]]]);
        ]
        [PUSHRULESET sys_suspend_ruleset]
        [STOP]
enddefine;


/* ====================================================================== */

/***************************************************************************
NAME
    NewSenseBloodSugar

SYNOPSIS
    NewSenseBloodSugar(parent, name);

FUNCTION

RETURNS
    None
***************************************************************************/
define vars procedure NewSenseBloodSugar(parent, name) /* -> agent */;
    lvars parent, name, agent;

    newgl_sensor() -> agent;
    parent -> gl_parent(agent);
    "alive" -> sim_status(agent);
    GlNameAgent(agent, name);

    "BloodSugar" -> gl_id(agent);

    gl_blood_sugar(parent) -> gl_value(agent);
    10 -> gl_range(agent);
    gl_value(agent) - gl_blood_sugar_sp(parent) -> gl_diff(agent);

    sense_blood_sugar_rulesystem -> sim_rulesystem(agent);
    ExtractConditionKeys(agent) -> gl_cond_filter(agent);
    [[sensor blood_sugar]] -> gl_act_filter(agent);
    return(agent);
enddefine;

/* -- Rulesystem -- */

define :rulesystem sense_blood_sugar_rulesystem;
    include: sense_blood_sugar_rulefam
enddefine;

/* -- Rulefamilies -- */

define :rulefamily sense_blood_sugar_rulefam;
    ruleset: sense_blood_sugar_ruleset
    ruleset: sys_suspend_ruleset
enddefine;

/* -- Rulesets -- */

define :ruleset sense_blood_sugar_ruleset;

    RULE sense_blood_sugar
        ==>
        [POP11
            lvars adrenalineDiff;

            gl_blood_sugar(sim_parent) -> value;
            value - gl_blood_sugar_sp(sim_parent) -> diff;

            /* adjust if adrenaline present */
            if sim_present_data(![sensor adrenaline ==
                                diff ^adrenalineDiff ==], blackboard) then
                if adrenalineDiff > 0.5 then
                    diff / 4 -> diff;
                    gl_blood_sugar(sim_parent) + diff -> value;
                endif;
            endif;

            diff - gl_diff(sim_myself) -> change;
            diff -> gl_diff(sim_myself);

            prb_eval([INDATA ^blackboard [REPLACE [sensor blood_sugar ==]
                    [sensor blood_sugar value ^value
                            range ^(gl_range(sim_myself)) diff ^diff
                                                    change ^change]]]);
        ]
        [PUSHRULESET sys_suspend_ruleset]
        [STOP]
enddefine;

/* ====================================================================== */

/***************************************************************************
NAME
    NewSenseEnergy

SYNOPSIS
    NewSenseEnergy(parent, name);

FUNCTION

RETURNS
    None
***************************************************************************/
define vars procedure NewSenseEnergy(parent, name) /* -> agent */;
    lvars parent, name, agent;

    newgl_sensor() -> agent;
    parent -> gl_parent(agent);
    "alive" -> sim_status(agent);
    GlNameAgent(agent, name);

    "Energy" -> gl_id(agent);

    gl_energy(parent) -> gl_value(agent);
    50 -> gl_range(agent);
    gl_value(agent) - gl_energy_sp(parent) -> gl_diff(agent);

    sense_energy_rulesystem -> sim_rulesystem(agent);
    ExtractConditionKeys(agent) -> gl_cond_filter(agent);
    [[sensor energy]] -> gl_act_filter(agent);
    return(agent);
enddefine;

/* -- Rulesystem -- */

define :rulesystem sense_energy_rulesystem;
    include: sense_energy_rulefam
enddefine;

/* -- Rulefamilies -- */

define :rulefamily sense_energy_rulefam;
    ruleset: sense_energy_ruleset
    ruleset: sys_suspend_ruleset
enddefine;

/* -- Rulesets -- */

define :ruleset sense_energy_ruleset;

    RULE sense_energy
        ==>
        [POP11
            gl_energy(sim_parent) -> value;
            value - gl_energy_sp(sim_parent) -> diff;
            diff - gl_diff(sim_myself) -> change;
            diff -> gl_diff(sim_myself);

            prb_eval([INDATA ^blackboard [REPLACE [sensor energy ==]
                    [sensor energy value ^value
                            range ^(gl_range(sim_myself)) diff ^diff
                                                    change ^change]]]);
        ]
        [PUSHRULESET sys_suspend_ruleset]
        [STOP]
enddefine;

/* ====================================================================== */

/***************************************************************************
NAME
    NewSenseHeartRate

SYNOPSIS
    NewSenseHeartRate(parent, name);

FUNCTION

RETURNS
    None
***************************************************************************/
define vars procedure NewSenseHeartRate(parent, name) /* -> agent */;
    lvars parent, name, agent;

    newgl_sensor() -> agent;
    parent -> gl_parent(agent);
    "alive" -> sim_status(agent);
    GlNameAgent(agent, name);

    "HeartRate" -> gl_id(agent);

    75 -> gl_value(agent);
    25 -> gl_range(agent);
    gl_value(agent) - gl_heart_rate_sp(parent) -> gl_diff(agent);

    sense_heart_rate_rulesystem -> sim_rulesystem(agent);
    ExtractConditionKeys(agent) -> gl_cond_filter(agent);
    [[sensor heart_rate]] -> gl_act_filter(agent);
    return(agent);
enddefine;

/* -- Rulesystem -- */

define :rulesystem sense_heart_rate_rulesystem;
    include: sense_heart_rate_rulefam
enddefine;

/* -- Rulefamilies -- */

define :rulefamily sense_heart_rate_rulefam;
    ruleset: sense_heart_rate_ruleset
    ruleset: sys_suspend_ruleset
enddefine;

/* -- Rulesets -- */

define :ruleset sense_heart_rate_ruleset;

    RULE sense_heart_rate
        ==>
        [POP11
            gl_heart_rate(sim_parent) -> value;
            value - gl_heart_rate_sp(sim_parent) -> diff;
            diff - gl_diff(sim_myself) -> change;
            diff -> gl_diff(sim_myself);

            prb_eval([INDATA ^blackboard [REPLACE [sensor heart_rate ==]
                    [sensor heart_rate value ^value
                            range ^(gl_range(sim_myself)) diff ^diff
                                                    change ^change]]]);
        ]
        [PUSHRULESET sys_suspend_ruleset]
        [STOP]
enddefine;

/* ====================================================================== */

/***************************************************************************
NAME
    NewSenseRespirationRate

SYNOPSIS
    NewSenseRespirationRate(parent, name);

FUNCTION

RETURNS
    None
***************************************************************************/
define vars procedure NewSenseRespirationRate(parent, name) /* -> agent */;
    lvars parent, name, agent;

    newgl_sensor() -> agent;
    parent -> gl_parent(agent);
    "alive" -> sim_status(agent);
    GlNameAgent(agent, name);

    "RespirationRate" -> gl_id(agent);

    gl_respiration_rate(parent) -> gl_value(agent);
    7 -> gl_range(agent);
    gl_value(agent) - gl_respiration_rate_sp(parent) -> gl_diff(agent);

    sense_respiration_rate_rulesystem -> sim_rulesystem(agent);
    ExtractConditionKeys(agent) -> gl_cond_filter(agent);
    [[sensor respiration_rate]] -> gl_act_filter(agent);
    return(agent);
enddefine;

/* -- Rulesystem -- */

define :rulesystem sense_respiration_rate_rulesystem;
    include: sense_respiration_rate_rulefam
enddefine;

/* -- Rulefamilies -- */

define :rulefamily sense_respiration_rate_rulefam;
    ruleset: sense_respiration_rate_ruleset
    ruleset: sys_suspend_ruleset
enddefine;

/* -- Rulesets -- */

define :ruleset sense_respiration_rate_ruleset;

    RULE sense_respiration_rate
        ==>
        [POP11
            gl_respiration_rate(sim_parent) -> value;
            value - gl_respiration_rate_sp(sim_parent) -> diff;
            diff - gl_diff(sim_myself) -> change;
            diff -> gl_diff(sim_myself);

            prb_eval([INDATA ^blackboard [REPLACE [sensor respiration_rate ==]
                    [sensor respiration_rate value ^value
                            range ^(gl_range(sim_myself)) diff ^diff
                                                    change ^change]]]);
        ]
        [PUSHRULESET sys_suspend_ruleset]
        [STOP]
enddefine;

/* ====================================================================== */

/***************************************************************************
NAME
    NewSenseTemperature

SYNOPSIS
    NewSenseTemperature(parent, name);

FUNCTION

RETURNS
    None
***************************************************************************/

define vars procedure NewSenseTemperature(parent, name) /* -> agent */;
    lvars parent, name, agent;

    newgl_sensor() -> agent;
    parent -> gl_parent(agent);
    "alive" -> sim_status(agent);
    GlNameAgent(agent, name);

    "Temperature" -> gl_id(agent);

    gl_temperature(parent) -> gl_value(agent);
    3 -> gl_range(agent);
    gl_value(agent) - gl_temperature_sp(parent) -> gl_diff(agent);

    sense_temperature_rulesystem -> sim_rulesystem(agent);
    ExtractConditionKeys(agent) -> gl_cond_filter(agent);
    [[sensor temperature]] -> gl_act_filter(agent);
    return(agent);
enddefine;

/* -- Rulesystem -- */

define :rulesystem sense_temperature_rulesystem;
    include: sense_temperature_rulefam
enddefine;

/* -- Rulefamilies -- */

define :rulefamily sense_temperature_rulefam;
    ruleset: sense_temperature_ruleset
    ruleset: sys_suspend_ruleset
enddefine;

/* -- RuleSets -- */

define :ruleset sense_temperature_ruleset;

    RULE sense_temperature
        ==>
        [POP11
            lvars adrenalineDiff;
            gl_temperature(sim_parent) -> value;
            value - gl_temperature_sp(sim_parent) -> diff;

            /* adjust if adrenaline present */
            if sim_present_data(![sensor adrenaline ==
                         diff ^adrenalineDiff ==], blackboard) then
                if adrenalineDiff > 0.5 then
                    diff / 4 -> diff;
                    gl_temperature(sim_parent) + diff -> value;
                endif;
            endif;

            diff - gl_diff(sim_myself) -> change;
            diff -> gl_diff(sim_myself);

            prb_eval([INDATA ^blackboard [REPLACE [sensor temperature ==]
                    [sensor temperature value ^value
                            range ^(gl_range(sim_myself)) diff ^diff
                                                    change ^change]]]);
        ]
        [PUSHRULESET sys_suspend_ruleset]
        [STOP]
enddefine;

/* ====================================================================== */

/***************************************************************************
NAME
    NewSenseVascularVolume

SYNOPSIS
    NewSenseVascularVolume(parent, name);

FUNCTION

RETURNS
    None
***************************************************************************/
define vars procedure NewSenseVascularVolume(parent, name) /* -> agent */;
    lvars parent, name, agent;

    newgl_sensor() -> agent;
    parent -> gl_parent(agent);
    "alive" -> sim_status(agent);
    GlNameAgent(agent, name);

    "VascularVolume" -> gl_id(agent);

    gl_vascular_volume(parent) -> gl_value(agent);
    10 -> gl_range(agent);
    gl_value(agent) - gl_vascular_volume_sp(parent) -> gl_diff(agent);

    sense_vascular_volume_rulesystem -> sim_rulesystem(agent);
    ExtractConditionKeys(agent) -> gl_cond_filter(agent);
    [[sensor vascular_volume]] -> gl_act_filter(agent);
    return(agent);
enddefine;

/* -- Rulesystem -- */

define :rulesystem sense_vascular_volume_rulesystem;
    include: sense_vascular_volume_rulefam
enddefine;

/* -- Rulefamilies -- */

define :rulefamily sense_vascular_volume_rulefam;
    ruleset: sense_vascular_volume_ruleset
    ruleset: sys_suspend_ruleset
enddefine;

/* -- Rulesets -- */

define :ruleset sense_vascular_volume_ruleset;

    RULE sense_vascular_volume
        ==>
        [POP11
            lvars adrenalineDiff;

            gl_vascular_volume(sim_parent) -> value;
            value - gl_vascular_volume_sp(sim_parent) -> diff;


            /* adjust if adrenaline present */
            if sim_present_data(![sensor adrenaline ==
                          diff ^adrenalineDiff ==], blackboard) then
                if adrenalineDiff > 0.5 then
                    diff / 4 -> diff;
                    gl_vascular_volume(sim_parent) + diff -> value;
                endif;
            endif;

            diff - gl_diff(sim_myself) -> change;
            diff -> gl_diff(sim_myself);

            prb_eval([INDATA ^blackboard [REPLACE [sensor vascular_volume ==]
                    [sensor vascular_volume value ^value
                            range ^(gl_range(sim_myself)) diff ^diff
                                                    change ^change]]]);
        ]
        [PUSHRULESET sys_suspend_ruleset]
        [STOP]
enddefine;

/* ====================================================================== */

/***************************************************************************
NAME
    NewSenseAdrenaline

SYNOPSIS
    NewSenseAdrenaline(parent, name);

FUNCTION
    Associated with fear

RETURNS
    None
***************************************************************************/
define vars procedure NewSenseAdrenaline(parent, name) /* -> agent */;
    lvars parent, name, agent;

    newgl_sensor() -> agent;
    parent -> gl_parent(agent);
    "alive" -> sim_status(agent);
    GlNameAgent(agent, name);

    "Adrenaline" -> gl_id(agent);

    gl_adrenaline(parent) -> gl_value(agent);
    5 -> gl_range(agent);
    gl_value(agent) - gl_adrenaline_sp(parent) -> gl_diff(agent);

    sense_adrenaline_rulesystem -> sim_rulesystem(agent);
    ExtractConditionKeys(agent) -> gl_cond_filter(agent);
    [[sensor adrenaline]] -> gl_act_filter(agent);
    return(agent);
enddefine;

/* -- Rulesystem -- */

define :rulesystem sense_adrenaline_rulesystem;
    include: sense_adrenaline_rulefam
enddefine;

/* -- Rulefamilies -- */

define :rulefamily sense_adrenaline_rulefam;
    ruleset: sense_adrenaline_ruleset
    ruleset: sys_suspend_ruleset
enddefine;

/* -- Rulesets -- */

define :ruleset sense_adrenaline_ruleset;

    RULE sense_adrenaline
        ==>
        [POP11
            gl_adrenaline(sim_parent) + gl_asif_adrenaline(sim_parent)
                                                                -> value;
            value - gl_adrenaline_sp(sim_parent) -> diff;
            diff - gl_diff(sim_myself) -> change;
            diff -> gl_diff(sim_myself);

            prb_eval([INDATA ^blackboard [REPLACE [sensor adrenaline ==]
                    [sensor adrenaline value ^value
                            range ^(gl_range(sim_myself)) diff ^diff
                                                    change ^change]]]);
        ]
        [PUSHRULESET sys_suspend_ruleset]
        [STOP]
enddefine;

/* ====================================================================== */

/***************************************************************************
NAME
    NewSenseNorAdrenaline

SYNOPSIS
    NewSenseNorAdrenaline(parent, name);

FUNCTION
    Associated with anger

RETURNS
    None
***************************************************************************/
define vars procedure NewSenseNorAdrenaline(parent, name) /* -> agent */;
    lvars parent, name, agent;

    newgl_sensor() -> agent;
    parent -> gl_parent(agent);
    "alive" -> sim_status(agent);
    GlNameAgent(agent, name);

    "NorAdrenaline" -> gl_id(agent);

    gl_noradrenaline(parent) -> gl_value(agent);
    5 -> gl_range(agent);
    gl_value(agent) - gl_noradrenaline_sp(parent) -> gl_diff(agent);

    sense_noradrenaline_rulesystem -> sim_rulesystem(agent);
    ExtractConditionKeys(agent) -> gl_cond_filter(agent);
    [[sensor noradrenaline]] -> gl_act_filter(agent);
    return(agent);
enddefine;

/* -- Rulesystem -- */

define :rulesystem sense_noradrenaline_rulesystem;
    include: sense_noradrenaline_rulefam
enddefine;

/* -- Rulefamilies -- */

define :rulefamily sense_noradrenaline_rulefam;
    ruleset: sense_noradrenaline_ruleset
    ruleset: sys_suspend_ruleset
enddefine;

/* -- Rulesets -- */

define :ruleset sense_noradrenaline_ruleset;

    RULE sense_noradrenaline
        ==>
        [POP11
            gl_noradrenaline(sim_parent) + gl_asif_noradrenaline(sim_parent)
                                                                -> value;
            value - gl_noradrenaline_sp(sim_parent) -> diff;
            diff - gl_diff(sim_myself) -> change;
            diff -> gl_diff(sim_myself);

            prb_eval([INDATA ^blackboard [REPLACE [sensor noradrenaline ==]
                    [sensor noradrenaline value ^value
                            range ^(gl_range(sim_myself)) diff ^diff
                                                    change ^change]]]);
        ]
        [PUSHRULESET sys_suspend_ruleset]
        [STOP]
enddefine;

/* ====================================================================== */

/***************************************************************************
NAME
    NewSenseDopamine

SYNOPSIS
    NewSenseDopamine(parent, name);

FUNCTION

RETURNS
    None
***************************************************************************/
define vars procedure NewSenseDopamine(parent, name) /* -> agent */;
    lvars parent, name, agent;

    newgl_sensor() -> agent;
    parent -> gl_parent(agent);
    "alive" -> sim_status(agent);
    GlNameAgent(agent, name);

    "Dopamine" -> gl_id(agent);

    gl_dopamine(parent) -> gl_value(agent);
    5 -> gl_range(agent);
    gl_value(agent) - gl_dopamine_sp(parent) -> gl_diff(agent);

    sense_dopamine_rulesystem -> sim_rulesystem(agent);
    ExtractConditionKeys(agent) -> gl_cond_filter(agent);
    [[sensor dopamine]] -> gl_act_filter(agent);
    return(agent);
enddefine;

/* -- Rulesystem -- */

define :rulesystem sense_dopamine_rulesystem;
    include: sense_dopamine_rulefam
enddefine;

/* -- Rulefamilies -- */

define :rulefamily sense_dopamine_rulefam;
    ruleset: sense_dopamine_ruleset
    ruleset: sys_suspend_ruleset
enddefine;

/* -- Rulesets -- */

define :ruleset sense_dopamine_ruleset;

    RULE sense_dopamine
        ==>
        [POP11
            gl_dopamine(sim_parent) + gl_asif_dopamine(sim_parent) -> value;
            value - gl_dopamine_sp(sim_parent) -> diff;
            diff - gl_diff(sim_myself) -> change;
            diff -> gl_diff(sim_myself);

            prb_eval([INDATA ^blackboard [REPLACE [sensor dopamine ==]
                    [sensor dopamine value ^value
                            range ^(gl_range(sim_myself)) diff ^diff
                                                    change ^change]]]);
        ]
        [PUSHRULESET sys_suspend_ruleset]
        [STOP]
enddefine;

/* ====================================================================== */

/***************************************************************************
NAME
    NewSenseEndorphine

SYNOPSIS
    NewSenseEndorphine(parent, name);

FUNCTION

RETURNS
    None
***************************************************************************/
define vars procedure NewSenseEndorphine(parent, name) /* -> agent */;
    lvars parent, name, agent;

    newgl_sensor() -> agent;
    parent -> gl_parent(agent);
    "alive" -> sim_status(agent);
    GlNameAgent(agent, name);

    "Endorphine" -> gl_id(agent);

    gl_endorphine(parent) -> gl_value(agent);
    5 -> gl_range(agent);
    gl_value(agent) - gl_endorphine_sp(parent) -> gl_diff(agent);

    sense_endorphine_rulesystem -> sim_rulesystem(agent);
    ExtractConditionKeys(agent) -> gl_cond_filter(agent);
    [[sensor endorphine]] -> gl_act_filter(agent);
    return(agent);
enddefine;

/* -- Rulesystem -- */

define :rulesystem sense_endorphine_rulesystem;
    include: sense_endorphine_rulefam
enddefine;

/* -- Rulefamilies -- */

define :rulefamily sense_endorphine_rulefam;
    ruleset: sense_endorphine_ruleset
    ruleset: sys_suspend_ruleset
enddefine;

/* -- Rulesets -- */

define :ruleset sense_endorphine_ruleset;

    RULE sense_endorphine
        ==>
        [POP11
            gl_endorphine(sim_parent) + gl_asif_endorphine(sim_parent)
                                                                -> value;
            value - gl_endorphine_sp(sim_parent) -> diff;
            diff - gl_diff(sim_myself) -> change;
            diff -> gl_diff(sim_myself);

            prb_eval([INDATA ^blackboard [REPLACE [sensor endorphine ==]
                    [sensor endorphine value ^value
                            range ^(gl_range(sim_myself)) diff ^diff
                                                    change ^change]]]);
        ]
        [PUSHRULESET sys_suspend_ruleset]
        [STOP]
enddefine;

/* ====================================================================== */

/***************************************************************************
NAME
    NewSenseOccupancy

SYNOPSIS
    NewSenseOccupancy(parent, name);

FUNCTION

RETURNS
    None
***************************************************************************/
define vars procedure NewSenseOccupancy(parent, name) /* -> agent */;
    lvars parent, name, agent;

    newgl_sensor() -> agent;
    parent -> gl_parent(agent);
    "alive" -> sim_status(agent);
    GlNameAgent(agent, name);

    "Occupancy" -> gl_id(agent);
    initnibblevector(9) -> gl_value(agent);

    sense_occupancy_rulesystem -> sim_rulesystem(agent);
    ExtractConditionKeys(agent) -> gl_cond_filter(agent);
    [[sensor occupancy]] -> gl_act_filter(agent);
    return(agent);
enddefine;

/* -- Rulesystem -- */

define :rulesystem sense_occupancy_rulesystem;
    include: sense_occupancy_rulefam
enddefine;

/* -- Rulefamilies -- */

define :rulefamily sense_occupancy_rulefam;
    ruleset: sense_occupancy_ruleset
    ruleset: sys_suspend_ruleset
enddefine;

/* -- Rulesets -- */

define :ruleset sense_occupancy_ruleset;

    RULE sense_occupancy
        ==>
        [POP11
            explode(gl_loc(sim_parent)) -> (x, y);
            gl_occupancy(GlGrid(x, y)) -> gl_value(sim_myself)(9);
            fast_for i from 1 to 8 do
                gl_occupancy(GlGrid(x+cell_to_x(i), y+cell_to_y(i)))
                                            -> gl_value(sim_myself)(i);
            endfor;
            prb_eval([INDATA ^blackboard [REPLACE [sensor occupancy ==]
                        [sensor occupancy value ^(gl_value(sim_myself))]]]);
        ]
        [PUSHRULESET sys_suspend_ruleset]
        [STOP]
enddefine;

/* ====================================================================== */

/***************************************************************************
NAME
    NewSenseHardness

SYNOPSIS
    NewSenseHardness(parent, name);

FUNCTION

RETURNS
    None
***************************************************************************/
define vars procedure NewSenseHardness(parent, name) /* -> agent */;
    lvars parent, name, agent;

    newgl_sensor() -> agent;
    parent -> gl_parent(agent);
    "alive" -> sim_status(agent);
    GlNameAgent(agent, name);

    "Hardness" -> gl_id(agent);
    initnibblevector(9) -> gl_value(agent);

    sense_hardness_rulesystem -> sim_rulesystem(agent);
    ExtractConditionKeys(agent) -> gl_cond_filter(agent);
    [[sensor hardness]] -> gl_act_filter(agent);
    return(agent);
enddefine;

/* -- Rulesystem -- */

define :rulesystem sense_hardness_rulesystem;
    include: sense_hardness_rulefam
enddefine;

/* -- Rulefamilies -- */

define :rulefamily sense_hardness_rulefam;
    ruleset: sense_hardness_ruleset
    ruleset: sys_suspend_ruleset
enddefine;

/* -- Rulesets -- */

define :ruleset sense_hardness_ruleset;

    RULE sense_hardness
        ==>
        [POP11
            explode(gl_loc(sim_parent)) -> (x, y);
            gl_hardness(GlGrid(x, y)) -> gl_value(sim_myself)(9);
            fast_for i from 1 to 8 do
                gl_hardness(GlGrid(x+cell_to_x(i), y+cell_to_y(i)))
                                            -> gl_value(sim_myself)(i);
            endfor;
            prb_eval([INDATA ^blackboard [REPLACE [sensor hardness ==]
                        [sensor hardness value ^(gl_value(sim_myself))]]]);
        ]
        [PUSHRULESET sys_suspend_ruleset]
        [STOP]
enddefine;


/* ====================================================================== */

/***************************************************************************
NAME
    NewSenseOrganic

SYNOPSIS
    NewSenseOrganic(parent, name);

FUNCTION

RETURNS
    None
***************************************************************************/
define vars procedure NewSenseOrganic(parent, name) /* -> agent */;
    lvars parent, name, agent;

    newgl_sensor() -> agent;
    parent -> gl_parent(agent);
    "alive" -> sim_status(agent);
    GlNameAgent(agent, name);

    "Organic" -> gl_id(agent);
    initnibblevector(9) -> gl_value(agent);

    sense_organic_rulesystem -> sim_rulesystem(agent);
    ExtractConditionKeys(agent) -> gl_cond_filter(agent);
    [[sensor organic]] -> gl_act_filter(agent);
    return(agent);
enddefine;

/* -- Rulesystem -- */

define :rulesystem sense_organic_rulesystem;
    include: sense_organic_rulefam
enddefine;

/* -- Rulefamilies -- */

define :rulefamily sense_organic_rulefam;
    ruleset: sense_organic_ruleset
    ruleset: sys_suspend_ruleset
enddefine;

/* -- Rulesets -- */

define :ruleset sense_organic_ruleset;

    RULE sense_organic
        ==>
        [POP11
            explode(gl_loc(sim_parent)) -> (x, y);
            gl_organic(GlGrid(x, y)) -> gl_value(sim_myself)(9);
            fast_for i from 1 to 8 do
                gl_organic(GlGrid(x+cell_to_x(i), y+cell_to_y(i)))
                                            -> gl_value(sim_myself)(i);
            endfor;
            prb_eval([INDATA ^blackboard [REPLACE [sensor organic ==]
                        [sensor organic value ^(gl_value(sim_myself))]]]);
        ]
        [PUSHRULESET sys_suspend_ruleset]
        [STOP]
enddefine;

/* ====================================================================== */

/***************************************************************************
NAME
    NewSenseBrightness

SYNOPSIS
    NewSenseBrightness(parent, name);

FUNCTION

RETURNS
    None
***************************************************************************/
define vars procedure NewSenseBrightness(parent, name) /* -> agent */;
    lvars parent, name, agent;

    newgl_sensor() -> agent;
    parent -> gl_parent(agent);
    "alive" -> sim_status(agent);
    GlNameAgent(agent, name);

    "Brightness" -> gl_id(agent);
    initnibblevector(9) -> gl_value(agent);

    sense_brightness_rulesystem -> sim_rulesystem(agent);
    ExtractConditionKeys(agent) -> gl_cond_filter(agent);
    [[sensor brightness]] -> gl_act_filter(agent);
    return(agent);
enddefine;

/* -- Rulesystem -- */

define :rulesystem sense_brightness_rulesystem;
    include: sense_brightness_rulefam
enddefine;

/* -- Rulefamilies -- */

define :rulefamily sense_brightness_rulefam;
    ruleset: sense_brightness_ruleset
    ruleset: sys_suspend_ruleset
enddefine;

/* -- Rulesets -- */

define :ruleset sense_brightness_ruleset;

    [VARS blackboard];

    RULE sense_brightness
        [INDATA ?blackboard [eye_position ?eye_position]]
        ==>
        [POP11
            eyemask(eye_position) -> mask;
            explode(gl_loc(sim_parent)) -> (x, y);

            fast_for i from 1 to 8 do
                if mask(i) then
                    gl_brightness(GlGrid(x+cell_to_x(i), y+cell_to_y(i)));
                else
                    0;
                endif -> gl_value(sim_myself)(i);
            endfor;

            prb_eval([INDATA ^blackboard [REPLACE [sensor brightness ==]
                    [sensor brightness value ^(gl_value(sim_myself))]]]);
        ]
        [PUSHRULESET sys_suspend_ruleset]
        [STOP]
enddefine;


/* ====================================================================== */

/***************************************************************************
NAME
    NewSenseEye

SYNOPSIS
    NewSenseEye(parent, name);

FUNCTION

RETURNS
    None
***************************************************************************/
define vars procedure NewSenseEye(parent, name) /* -> agent */;
    lvars parent, name, agent;

    newgl_sensor() -> agent;
    parent -> gl_parent(agent);
    "alive" -> sim_status(agent);
    GlNameAgent(agent, name);

    "Eye" -> gl_id(agent);

    sense_eye_rulesystem -> sim_rulesystem(agent);
    ExtractConditionKeys(agent) -> gl_cond_filter(agent);
    [[sensor eye]] -> gl_act_filter(agent);
    return(agent);
enddefine;

/* -- Rulesystem -- */

define :rulesystem sense_eye_rulesystem;
    include: sense_eye_ruleset
enddefine;

/* -- Rulefamilies -- */

define :rulefamily sense_eye_rulefam;
    ruleset: sense_eye_ruleset
    ruleset: sys_suspend_ruleset
enddefine;

/* -- Rulesets -- */


define :ruleset sense_eye_ruleset;

    [VARS blackboard];

    RULE sense_eye
        [INDATA ?blackboard [sense eye]]
        [INDATA ?blackboard [NOT sensor eye update]]
        [INDATA ?blackboard [cycle_count ?count]]
        [WHERE count == 1 or count == 3]
        ==>
        [INDATA ?blackboard [NOT sense eye ==]]
        [POP11
            gl_eye_position(sim_parent) ->> eye_position ->
                                        gl_eye_last_position(sim_parent);

            /* set background to "unknown" */

            fast_for stepx from 1 to 5 do
                fast_for stepy from 1 to 5 do
                    15 -> gl_eye_view(sim_parent)(stepx,stepy);
                endfor;
            endfor;

            /* set up step directions for eye position */

            explode(gl_loc(sim_parent)) -> (x,y);
            (1,1) -> (stepx, stepy);

            if eye_position == 1 or eye_position == 4 then
                -1 -> stepx;
            endif;
            if eye_position == 3 or eye_position == 4 then
                -1 -> stepy;
            endif;

            /* ray trace so that only the accessible objects are seen.
               The objects are sorted such that the closest are placed
               at the head of the list and objects of equal distance are
               sorted according to brightness */

            prb_eval([INDATA ^blackboard [REPLACE [sensor eye value ==]
                    ^(conspair("sensor", conspair("eye",
                                            conspair("value", [%
            false -> old_item;
            for item in nc_listsort(
                [%
                fast_for ray in rays do
                    0 -> relx;
                    0 -> rely;
                    fast_for steps in ray do
                        relx + stepx -> relx;
                        if steps then rely + stepy -> rely endif;
                        abs(relx) -> a_relx;
                        abs(rely) -> a_rely;
                        if (gl_brightness(GlGrid(x+relx,y+rely)) ->>
                            gl_eye_view(sim_parent)
                                    (1+a_relx,1+a_rely)) > 0 then

                            /* build vector with {bright, dist, dir} */

                            {%
                                gl_eye_view(sim_parent)(1+a_relx,1+a_rely),
                                distance(max(a_relx,a_rely)),
                                if a_relx > a_rely then
                                    horizontal(eye_position)
                                elseif a_relx == a_rely then
                                    diagonal(eye_position)
                                else
                                    vertical(eye_position)
                                endif
                            %};
                            quitloop;
                        endif;
                    endfor;
                endfor;

                fast_for ray in rays do
                    0 -> relx;
                    0 -> rely;
                    fast_for steps in ray do
                        rely + stepy -> rely;
                        if steps then relx + stepx -> relx endif;
                        abs(relx) -> a_relx;
                        abs(rely) -> a_rely;
                        if (gl_brightness(GlGrid(x+relx,y+rely)) ->>
                                gl_eye_view(sim_parent)
                                    (1+a_relx,1+a_rely)) > 0 then

                            /* build vector with {bright, dist, dir} */

                            {%
                                gl_eye_view(sim_parent)(1+a_relx,1+a_rely),
                                distance(max(a_relx,a_rely)),
                                if a_relx > a_rely then
                                    horizontal(eye_position)
                                elseif a_relx == a_rely then
                                    diagonal(eye_position)
                                else
                                    vertical(eye_position)
                                endif
                            %};
                            quitloop;
                        endif;
                    endfor;
                endfor;

                0 -> relx;
                0 -> rely;
                fast_for steps from 2 to 5 do
                    relx + stepx -> relx;
                    rely + stepy -> rely;
                    if (gl_brightness(GlGrid(x+relx,y+rely)) ->>
                        gl_eye_view(sim_parent)(steps,steps)) > 0 then

                        /* build vector with {bright, dist, dir} */

                        {%
                            gl_eye_view(sim_parent)(steps,steps),
                            distance(steps-1),
                            diagonal(eye_position)
                        %};
                        quitloop;
                    endif;
                endfor;
                %], procedure(i1, i2);
                        /* sort according to distance and brightness */
                        i1(2)*1000 + (15-i1(1))*100 + i1(3) <=
                            i2(2)*1000 + (15-i2(1))*100 + i2(3);
                    endprocedure) do

                if item /= old_item then
                    item;
                    item -> old_item;
                endif;
            endfor;
            %] ->> gl_eye_last_values(sim_parent)))))]]);
            sim_cycle_number -> gl_eye_last_timestamp(sim_parent);

            /* if sensor tracing flag is set, show data */

            if gl_sensor_trace(gl_window) == sim_parent then
                ShowEye(sim_parent)
            endif;
        ]
        [INDATA ?blackboard [sensor eye update]]
        [STOP]

    RULE desensitise
        [INDATA ?blackboard [sensor eye update]][->> it]
        ==>
        [INDATA ?blackboard [DEL ?it]]
        [STOP]
enddefine;

/* ====================================================================== */

/***************************************************************************
NAME
    NewSenseFoot

SYNOPSIS
    NewSenseFoot(parent, name);

FUNCTION
    Proprioceptive feedback for the foot effector.

RETURNS
    None
***************************************************************************/
define vars procedure NewSenseFoot(parent, name) /* -> agent */;
    lvars parent, name, agent;

    newgl_sensor() -> agent;
    parent -> gl_parent(agent);
    "alive" -> sim_status(agent);
    GlNameAgent(agent, name);

    "Foot" -> gl_id(agent);

    sense_foot_rulesystem -> sim_rulesystem(agent);
    ExtractConditionKeys(agent) -> gl_cond_filter(agent);
    [[sensor foot]] -> gl_act_filter(agent);
    return(agent);
enddefine;

/* -- Rulesystem -- */

define :rulesystem sense_foot_rulesystem;
    include: sense_foot_rulefam
enddefine;

/* -- Rulefamilies -- */

define :rulefamily sense_foot_rulefam;
    ruleset: sense_foot_ruleset
    ruleset: sys_suspend_ruleset
enddefine;

/* -- Rulesets -- */

define :ruleset sense_foot_ruleset;

    [VARS blackboard];

    RULE sense_foot
        [INDATA ?blackboard [sense foot]]
        ==>
        [INDATA ?blackboard [NOT sense foot]]
        [LVARS [heading = gl_foot_heading(sim_parent)]]
        [INDATA ?blackboard [REPLACE [sensor foot ==] [sensor foot heading ?heading]]]
        [INDATA ?blackboard [sensor foot update]]
        [STOP]

    RULE desensitise
        [INDATA ?blackboard [sensor foot update]][->> it]
        ==>
        [INDATA ?blackboard [DEL ?it]]
        [PUSHRULESET sys_suspend_ruleset]
        [STOP]

enddefine;


/* ====================================================================== */


/* --- Revision History ---------------------------------------------------

--- Steve Allen, Aug 4 2000
    uses INDATA and new SIM_AGENT toolkit

--- Steve Allen, Nov 19 1998
    Standardised headers.

--- Steve Allen, Jun 1 1998
    First written.
*/
