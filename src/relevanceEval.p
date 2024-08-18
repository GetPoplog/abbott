/* -------------------------------------------------------------------------
   ---       Concern Processing in Autonomous Agents - PhD Thesis        ---
   ---                                                                   ---
   ---       Copyright (c) Steve Allen, 2000. All rights reserved.       ---
   -------------------------------------------------------------------------

   File:            relevanceEval.p
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

vars procedure NewDangerRelEval;

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

vars sys_suspend_ruleset;

/* -- Relevance Evaluation Rulesystems -- */

vars danger_rulesystem;

/* temp data */
lvars max_activation;
lvars item;

/**************************************************************************
Functions

***************************************************************************/

/* ====================================================================== */

/* -- Ruleset Vars -- */

vars danger_rulefam;
vars painSomMarker_rulefam;
vars danger_ruleset;
vars pain_ruleset;

/***************************************************************************
NAME
    NewDangerRelEval

SYNOPSIS
    NewDangerRelEval(parent, name);

FUNCTION

RETURNS
    None
***************************************************************************/

define vars procedure NewDangerRelEval(parent, name) /* -> agent */;
    lvars parent, name;
    lvars agent;

    newgl_relevanceEval() -> agent;
    parent -> gl_parent(agent);
    "alive" -> sim_status(agent);
    GlNameAgent(agent, name);

    "DangerRelEval" -> gl_id(agent);

    danger_rulesystem -> sim_rulesystem(agent);

    ExtractConditionKeys(agent) -> gl_cond_filter(agent);
    [] -> gl_act_filter(agent);
    return(agent);
enddefine;

/* -- Rulesystem -- */

define :rulesystem danger_rulesystem;
    include: danger_rulefam
    include: painSomMarker_rulefam
enddefine;

/* -- Rulefamilies -- */

define :rulefamily danger_rulefam;
    ruleset: danger_ruleset
    ruleset: sys_suspend_ruleset
enddefine;

define :rulefamily painSomMarker_rulefam;
    ruleset: pain_ruleset
    ruleset: sys_suspend_ruleset
enddefine;

/* -- Rulesets -- */

define :ruleset danger_ruleset;

    [VARS sim_myID blackboard];

    RULE clear
        [INDATA ?blackboard [relevanceEval danger ==]] [->> it]
        ==>
        [INDATA ?blackboard [DEL ?it]]


    RULE pri_anger_activate
        [INDATA ?blackboard [sensor brightness value ?bri_value]]
        [INDATA ?blackboard [cycle_count ?count]]
        [WHERE count > 0]
        ==>
        [POP11
            lvars heading;
            /* locate the source of danger */
            for heading from 1 to 8 do
                if bri_value(heading) == 14 then
                    quitloop;
                endif;
            endfor;

            if heading <= 8 then
                sim_add_data([relevanceEval danger ^heading], blackboard);
                [cycle ^sim_cycle_number: danger in direction ^heading] =>
            endif;
        ]
        [PUSHRULESET sys_suspend_ruleset]
        [STOP]

enddefine;

define :ruleset pain_ruleset;

    [VARS sim_myID blackboard];

    RULE clear
        [INDATA ?blackboard [relevanceEval somaticMarkerPain ==]] [->> it]
        ==>
        [INDATA ?blackboard [DEL ?it]]

    RULE painSomMarker_activate
        [INDATA ?blackboard [percept ?type ?dist ?dir =]]
        [INDATA ?blackboard [somaticMarker ?type pain ?count]]
        ==>
        [LVARS [value = count*10*2/dist]]
        [INDATA ?blackboard [relevanceEval somaticMarkerPain ?value ?dir ?type]]
        [PUSHRULESET sys_suspend_ruleset]
        [STOP]

enddefine;


/* ====================================================================== */


/* --- Revision History ---------------------------------------------------

--- Steve Allen, Nov 14 2000
    First written.

*/
