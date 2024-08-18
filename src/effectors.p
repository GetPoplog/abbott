/* -------------------------------------------------------------------------
   ---       Concern Processing in Autonomous Agents - PhD Thesis        ---
   ---                                                                   ---
   ---       Copyright (c) Steve Allen, 1998. All rights reserved.       ---
   -------------------------------------------------------------------------

   File:            effectors.p
   Author           Steve Allen, 4 Nov 2000 - (see revisions at EOF)
   Purpose:         Rules to define Abbott's effector agents.

   Libraries:       LIB sim_agent, poprulebase, objectclass, rc_graphic
                    LIB (*local) gl_agent, gl_abbott

   Related Files:   abbott.p

*/

/* --- Introduction --------------------------------------------------------

This file contains the rules that define the effector agents of the Abbott
SoM model.

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

vars procedure NewEffectorFoot;
vars procedure NewEffectorHand;
vars procedure NewEffectorMouth;
vars procedure NewEffectorEye;

/***************************************************************************
External functions accessed by this module.
Specify through module public interface include files or define explicitly.
***************************************************************************/

/* -- gl_agent -- */
vars GlNameAgent;

/* -- control.p -- */
vars procedure ExtractConditionKeys;

/* -- abbott.p -- */
vars sys_suspend_ruleset;

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

/* -- Effector Rulesystems -- */

vars effector_foot_rulesystem;
vars effector_hand_rulesystem;
vars effector_hand_ruleset;

vars effector_mouth_ruleset;
vars effector_mouth_rulefam;
vars effector_mouth_rulesystem;

vars effector_eye_ruleset;
vars effector_eye_relaxation_ruleset;
vars effector_eye_rulefam;
vars effector_eye_rulesystem;

lvars max_intensity;
lvars intensity_level, item;
lvars active_cmd;
lvars heading;

/**************************************************************************
Functions

***************************************************************************/

/* ====================================================================== */

/* -- Ruleset Vars -- */

vars effector_foot_ruleset;
vars effector_foot_rulefam;

/***************************************************************************
NAME
    NewEffectorFoot

SYNOPSIS
    NewEffectorFoot(parent, name);

FUNCTION
    Foot effector agent. This agent moves the parent in one of 4 directions.
    The direction on the effector_foot stack with the highest intensity is
    used.

    After issuing the "do_endcycle" command the agent clears the stack,
    pushes the winning direction (with a reduced intensity), and waits
    for the next cycle.

RETURNS
    None
***************************************************************************/

define vars procedure NewEffectorFoot(parent, name) /* -> agent */;
    lvars parent, name;
    lvars agent;

    newgl_effector() -> agent;
    parent -> gl_parent(agent);
    "alive" -> sim_status(agent);
    GlNameAgent(agent, name);

    "EffectorFoot" -> gl_id(agent);

    effector_foot_rulesystem -> sim_rulesystem(agent);

    ExtractConditionKeys(agent) -> gl_cond_filter(agent);
    [do_endcycle effector_foot] -> gl_act_filter(agent);

    prb_add_to_db([effector_foot], sim_get_data(parent));

    return(agent);
enddefine;

/* -- Rulesystem -- */

define :rulesystem effector_foot_rulesystem;
    include: effector_foot_rulefam
enddefine;

/* -- Rulefamilies -- */

define :rulefamily effector_foot_rulefam;
    ruleset: effector_foot_ruleset
    ruleset: sys_suspend_ruleset
enddefine;

/* -- Rulesets -- */

define :ruleset effector_foot_ruleset;

    [VARS blackboard];

    RULE sense_stimulus
        [INDATA ?blackboard [effector_foot ??cmds]]
        [WHERE cmds /= []]
        [INDATA ?blackboard [cycle_count ?count]]
        [WHERE count > 3]
        ==>
        [INDATA ?blackboard [REPLACE [effector_foot ==] [effector_foot]]]
        [POP11
            pop_min_int -> max_intensity;
            false -> active_cmd;
            for item in cmds do
                item(2) -> intensity_level;
                if intensity_level > max_intensity then
                    intensity_level -> max_intensity;
                    item -> active_cmd;
                endif;
            endfor;

            if active_cmd then
                sim_eval_data([do_endcycle ^^(active_cmd(1))], blackboard);
            endif;

        ]
        [PUSHRULESET sys_suspend_ruleset]
        [STOP]
enddefine;

/* ====================================================================== */

/***************************************************************************
NAME
    NewEffectorEye

SYNOPSIS
    NewEffectorEye(parent, name);

FUNCTION
    Eye effector agent. This agent moves the eye in one of 4 directions.
    The direction on the effector_eye stack with the highest intensity is
    used.

    After issuing the "do_endcycle" command the agent clears the stack,
    pushes the winning direction (with a reduced intensity), and waits
    for the next cycle.

RETURNS
    None
***************************************************************************/
define vars procedure NewEffectorEye(parent, name) /* -> agent */;
    lvars parent, name;
    lvars agent;

    newgl_effector() -> agent;
    parent -> gl_parent(agent);
    "alive" -> sim_status(agent);
    GlNameAgent(agent, name);

    "effector_eye" -> gl_id(agent);

    effector_eye_rulesystem -> sim_rulesystem(agent);

    ExtractConditionKeys(agent) -> gl_cond_filter(agent);
    [do effector_eye] -> gl_act_filter(agent);

    prb_add_to_db([effector_eye], sim_get_data(parent));

    return(agent);
enddefine;

/* -- Rulesystem -- */

define :rulesystem effector_eye_rulesystem;
    include: effector_eye_rulefam
enddefine;

/* -- Rulefamilies -- */

define :rulefamily effector_eye_rulefam;
    ruleset: effector_eye_ruleset
    ruleset: effector_eye_relaxation_ruleset
enddefine;

/* -- Rulesets -- */

define :ruleset effector_eye_ruleset;

    [VARS blackboard];

    RULE sense_stimulus
        [INDATA ?blackboard [effector_eye ??cmds]]
        ==>
        [INDATA ?blackboard [REPLACE [effector_eye ==] [effector_eye]]]
        [POP11
            pop_min_int -> max_intensity;
            false -> active_cmd;
            for item in cmds do
                item(2) -> intensity_level;
                if intensity_level > max_intensity then
                    intensity_level -> max_intensity;
                    item(1) -> active_cmd;
                endif;
            endfor;

            if active_cmd then
                prb_add(conspair("do", active_cmd));
            endif;
        ]
        [timer 2]
        [PUSHRULESET effector_eye_relaxation_ruleset]
        [STOP]
enddefine;

define :ruleset effector_eye_relaxation_ruleset;

    RULE relaxation_time
        [timer ?tval] [->> cmd]
        ==>
        [POP11
            if tval > 1 then
                prb_eval([REPLACE ^cmd [timer ^(tval-1)]]);
            else
                prb_eval([DEL ^cmd]);
                prb_eval([POPRULESET]);
            endif;
        ]
        [STOP]
enddefine;

/* ====================================================================== */


/***************************************************************************
NAME
    NewEffectorMouth

SYNOPSIS
    NewEffectorMouth(parent, name);

FUNCTION
    Mouth effector agent. This agent ingests in one of 8 directions.
    The direction on the effector_mouth stack with the highest intensity is
    used.

    After issuing the "do_endcycle" command the agent clears the stack,
    pushes the winning direction (with a reduced intensity), and waits
    for the next cycle.

RETURNS
    None
***************************************************************************/
define vars procedure NewEffectorMouth(parent, name) /* -> agent */;
    lvars parent, name;
    lvars agent;

    newgl_effector() -> agent;
    parent -> gl_parent(agent);
    "alive" -> sim_status(agent);
    GlNameAgent(agent, name);

    "EffectorMouth" -> gl_id(agent);

    effector_mouth_rulesystem -> sim_rulesystem(agent);
    ExtractConditionKeys(agent) -> gl_cond_filter(agent);
    [do effector_mouth] -> gl_act_filter(agent);

    prb_add_to_db([effector_mouth], sim_get_data(parent));

    return(agent);
enddefine;

/* -- Rulesystem -- */

define :rulesystem effector_mouth_rulesystem;
    include: effector_mouth_rulefam
enddefine;

/* -- Rulefamilies -- */

define :rulefamily effector_mouth_rulefam;
    ruleset: effector_mouth_ruleset
    ruleset: sys_suspend_ruleset
enddefine;

/* -- Rulesets -- */

define :ruleset effector_mouth_ruleset;

    [VARS blackboard];

    RULE sense_stimulus
        [INDATA ?blackboard [effector_mouth ??cmds]] [->> cmd]
        [WHERE cmds /== []]
        [INDATA ?blackboard [cycle_count ?count]]
        [WHERE count > 3]
        ==>
        [INDATA ?blackboard [REPLACE ?cmd [effector_mouth]]]
        [POP11
            pop_min_int -> max_intensity;
            false -> active_cmd;
            for item in cmds do
                item(2) -> intensity_level;
                if intensity_level > max_intensity then
                    intensity_level -> max_intensity;
                    item(1) -> active_cmd;
                endif;
            endfor;

            if active_cmd then
                prb_add(conspair("do", active_cmd));
            endif;

        ]
        [PUSHRULESET sys_suspend_ruleset]
        [STOP]
enddefine;

/* ====================================================================== */

/***************************************************************************
NAME
    NewEffectorHand

SYNOPSIS
    NewEffectorHand(parent, name);

FUNCTION
    Hand effector agent. This agent ingests in one of 8 directions.
    The direction on the effector_hand stack with the highest intensity is
    used.

    After issuing the "do" command the agent clears the stack.

RETURNS
    None
***************************************************************************/
define vars procedure NewEffectorHand(parent, name) /* -> agent */;
    lvars parent, name;
    lvars agent;

    newgl_effector() -> agent;
    parent -> gl_parent(agent);
    "alive" -> sim_status(agent);
    GlNameAgent(agent, name);

    "EffectorHand" -> gl_id(agent);

    effector_hand_rulesystem -> sim_rulesystem(agent);
    ExtractConditionKeys(agent) -> gl_cond_filter(agent);
    [do effector_hand] -> gl_act_filter(agent);

    prb_add_to_db([effector_hand], sim_get_data(parent));

    return(agent);
enddefine;

/* -- Rulesystem -- */

define :rulesystem effector_hand_rulesystem;
    include: effector_hand_rulefam
enddefine;

/* -- Rulefamilies -- */

define :rulefamily effector_hand_rulefam;
    ruleset: effector_hand_ruleset
    ruleset: sys_suspend_ruleset
enddefine;

/* -- Rulesets -- */

define :ruleset effector_hand_ruleset;

    [VARS blackboard];

    RULE sense_stimulus
        [INDATA ?blackboard [effector_hand ??cmds]][->>cmd]
        [WHERE cmds /= []]
        ==>
        [INDATA ?blackboard [REPLACE ?cmd [effector_hand]]]
        [POP11
            pop_min_int -> max_intensity;
            false -> active_cmd;
            for item in cmds do
                item(2) -> intensity_level;
                if intensity_level > max_intensity then
                    intensity_level -> max_intensity;
                    item(1) -> active_cmd;
                endif;
            endfor;

            if active_cmd then
                prb_add(conspair("do", active_cmd));
            endif;

        ]
        [PUSHRULESET sys_suspend_ruleset]
        [STOP]
enddefine;


/* ====================================================================== */


/* --- Revision History ---------------------------------------------------

--- Steve Allen, Nov 8 2000
    Removed footMove etc.

--- Steve Allen, Aug 4 2000
    Added support for new SIM_AGENT toolkit
    uses sim_shared_data().

--- Steve Allen, Nov 19 1998
    Standardised headers.

--- Steve Allen, Nov 8 1998
    Added hand effector agent.

--- Steve Allen, Jun 7 1998
    First written.
*/
