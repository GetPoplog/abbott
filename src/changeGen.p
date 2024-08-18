/* -------------------------------------------------------------------------
   ---       Concern Processing in Autonomous Agents - PhD Thesis        ---
   ---                                                                   ---
   ---       Copyright (c) Steve Allen, 1998. All rights reserved.       ---
   -------------------------------------------------------------------------

   File:            changeGen.p
   Author           Steve Allen, 12 Nov 2000 - (see revisions at EOF)
   Purpose:         Rules to define Abbott's physiological change agents.

   Libraries:       LIB sim_agent, poprulebase, objectclass, rc_graphic
                    LIB (*local) gl_agent, gl_abbott

   Related Files:   abbott.p

*/

/* --- Introduction --------------------------------------------------------

This file contains the rules that define the physiological change agents
for the Abbott SoM model.

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

vars procedure NewNoradrenalineChangeGen;
vars procedure NewAdrenalineChangeGen;
vars procedure NewDopamineChangeGen;

/***************************************************************************
External functions accessed by this module.
Specify through module public interface include files or define explicitly.
***************************************************************************/

/* -- gl_agent -- */

vars GlNameAgent;

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
vars sim_myID;
vars blackboard;

/* -- Change Generator Rulesystems -- */

vars noradrenalineChangeGen_rulesystem;
vars adrenalineChangeGen_rulesystem;
vars dopamineChangeGen_rulesystem;

/* temp data */
lvars max_activation;
lvars item;

/**************************************************************************
Functions

***************************************************************************/

/* ====================================================================== */

/* -- Ruleset Vars -- */

vars noradrenalineChangeGen_rulefam;
vars noradrenalineChangeGen_ruleset;

/***************************************************************************
NAME
    NewNoradrenalineChangeGen

SYNOPSIS
    NewNoradrenalineChangeGen(parent, name);

FUNCTION

RETURNS
    None
***************************************************************************/

define vars procedure NewNoradrenalineChangeGen(parent, name) /* -> agent */;
    lvars parent, name;
    lvars agent;

    newgl_changeGen() -> agent;
    parent -> gl_parent(agent);
    "alive" -> sim_status(agent);
    GlNameAgent(agent, name);

    "noradrenalineChangeGen" -> gl_id(agent);

    noradrenalineChangeGen_rulesystem -> sim_rulesystem(agent);

    ExtractConditionKeys(agent) -> gl_cond_filter(agent);
    [] -> gl_act_filter(agent);
    return(agent);
enddefine;

/* -- Rulesystem -- */

define :rulesystem noradrenalineChangeGen_rulesystem;
    include: noradrenalineChangeGen_rulefam
enddefine;

/* -- Rulefamilies -- */

define :rulefamily noradrenalineChangeGen_rulefam;
    ruleset: noradrenalineChangeGen_ruleset
    ruleset: sys_suspend_ruleset
enddefine;

/* -- Rulesets -- */

define :ruleset noradrenalineChangeGen_ruleset;

    [VARS sim_myID blackboard];

    RULE releaseNoradrenaline_activate
        [INDATA ?blackboard [activate = > ?sim_myID ?strength]] [->> it]
        ==>
        [INDATA ?blackboard [DEL ?it]]
        [POP11
            true -> gl_act_status(sim_myself);
            strength -> gl_act_level(sim_myself);

            if gl_act_level(sim_myself) > 0 then
                GlIncBodyState(sim_myself, gl_noradrenaline,
                      0.1 * gl_act_level(sim_myself));
                GlIncBodyState(sim_myself, gl_endorphine,
                      0.1 * gl_act_level(sim_myself));
            endif;
        ]
        [PUSHRULESET sys_suspend_ruleset]
        [STOP]
enddefine;

/* ====================================================================== */

/* -- Ruleset Vars -- */

vars adrenalineChangeGen_rulefam;
vars adrenalineChangeGen_ruleset;

/***************************************************************************
NAME
    NewAdrenalineChangeGen

SYNOPSIS
    NewAdrenalineChangeGen(parent, name);

FUNCTION

RETURNS
    None
***************************************************************************/

define vars procedure NewAdrenalineChangeGen(parent, name) /* -> agent */;
    lvars parent, name;
    lvars agent;

    newgl_changeGen() -> agent;
    parent -> gl_parent(agent);
    "alive" -> sim_status(agent);
    GlNameAgent(agent, name);

    "adrenalineChangeGen" -> gl_id(agent);

    adrenalineChangeGen_rulesystem -> sim_rulesystem(agent);

    ExtractConditionKeys(agent) -> gl_cond_filter(agent);
    [] -> gl_act_filter(agent);
    return(agent);
enddefine;

/* -- Rulesystem -- */

define :rulesystem adrenalineChangeGen_rulesystem;
    include: adrenalineChangeGen_rulefam
enddefine;

/* -- Rulefamilies -- */

define :rulefamily adrenalineChangeGen_rulefam;
    ruleset: adrenalineChangeGen_ruleset
    ruleset: sys_suspend_ruleset
enddefine;

/* -- Rulesets -- */

define :ruleset adrenalineChangeGen_ruleset;

    [VARS sim_myID blackboard];

    RULE releaseAdrenaline_activate
        [INDATA ?blackboard [activate = > ?sim_myID ?strength]] [->> it]
        ==>
        [INDATA ?blackboard [DEL ?it]]
        [POP11
            true -> gl_act_status(sim_myself);
            strength -> gl_act_level(sim_myself);

            if gl_act_level(sim_myself) > 0 then
                GlIncBodyState(sim_myself, gl_adrenaline,
                                    gl_act_level(sim_myself));
            endif;
        ]
        [PUSHRULESET sys_suspend_ruleset]
        [STOP]
enddefine;

/* ====================================================================== */

/* -- Ruleset Vars -- */

vars dopamineChangeGen_rulefam;
vars dopamineChangeGen_ruleset;

/***************************************************************************
NAME
    NewDopamineChangeGen

SYNOPSIS
    NewDopamineChangeGen(parent, name);

FUNCTION

RETURNS
    None
***************************************************************************/

define vars procedure NewDopamineChangeGen(parent, name) /* -> agent */;
    lvars parent, name;
    lvars agent;

    newgl_changeGen() -> agent;
    parent -> gl_parent(agent);
    "alive" -> sim_status(agent);
    GlNameAgent(agent, name);

    "dopamineChangeGen" -> gl_id(agent);

    dopamineChangeGen_rulesystem -> sim_rulesystem(agent);

    ExtractConditionKeys(agent) -> gl_cond_filter(agent);
    [] -> gl_act_filter(agent);
    return(agent);
enddefine;

/* -- Rulesystem -- */

define :rulesystem dopamineChangeGen_rulesystem;
    include: dopamineChangeGen_rulefam
enddefine;

/* -- Rulefamilies -- */

define :rulefamily dopamineChangeGen_rulefam;
    ruleset: dopamineChangeGen_ruleset
    ruleset: sys_suspend_ruleset
enddefine;

/* -- Rulesets -- */

define :ruleset dopamineChangeGen_ruleset;
    [VARS sim_myID blackboard];

    RULE pri_happy_activate
        [INDATA ?blackboard [activate = > ?sim_myID ?strength]] [->> it]
        ==>
        [INDATA ?blackboard [DEL ?it]]
        [POP11
            true -> gl_act_status(sim_myself);
            strength -> gl_act_level(sim_myself);

            if gl_act_level(sim_myself) > 0 then
                GlIncBodyState(sim_myself, gl_endorphine,
                                    0.1 * gl_act_level(sim_myself));

                GlIncBodyState(sim_myself, gl_dopamine,
                                    0.1 * gl_act_level(sim_myself));
            endif;
        ]
        [PUSHRULESET sys_suspend_ruleset]
        [STOP]
enddefine;

/* ====================================================================== */


/* --- Revision History ---------------------------------------------------

--- Steve Allen, Nov 12 2000
    Converted emotion.p into changeGen.p

--- Steve Allen, Aug 4 2000
    Added support for new SIM_AGENT toolkit
    uses sim_shared_data().

--- Steve Allen, Nov 19 1998
    Standardised headers.

--- Steve Allen, Nov 6 1998
    First written.
*/
