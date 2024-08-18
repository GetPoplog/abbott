/* -------------------------------------------------------------------------
   ---       Concern Processing in Autonomous Agents - PhD Thesis        ---
   ---                                                                   ---
   ---       Copyright (c) Steve Allen, 1998. All rights reserved.       ---
   -------------------------------------------------------------------------

   File:            filter.p
   Author           Steve Allen, 5 Aug 2000 - (see revisions at EOF)
   Purpose:         Rules to define Abbott's attention filter agent.

   Libraries:       LIB sim_agent, poprulebase, objectclass, rc_graphic
                    LIB (*local) gl_agent, gl_abbott

   Related Files:   abbott.p

*/

/* --- Introduction --------------------------------------------------------

This file contains the rules that define the attention filter agent for
the Abbott SoM model.

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

vars attention_filter_rulesystem;

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

lvars maxActivation;
lvars activeMotivator, oldMotivator;
lvars activationLevel, item;

vars sim_parent;
vars sim_myID;

/**************************************************************************
Functions

***************************************************************************/

/* ====================================================================== */

/* -- Ruleset Vars -- */

vars attention_filter_ruleset;
vars attention_filter_relaxation_rulefam;
vars attention_filter_relaxation_ruleset;

/***************************************************************************
NAME
    NewAttentionFilter

SYNOPSIS
    NewAttentionFilter(parent, name);

FUNCTION
    A Winner-Take-All attention filter for the society of agents.

RETURNS
    None
***************************************************************************/

define vars procedure NewAttentionFilter(parent, name) /* -> agent */;
    lvars parent, name;
    lvars agent;

    /* -- Initialisation -- */

    newgl_filter() -> agent;
    parent -> gl_parent(agent);
    "alive" -> sim_status(agent);
    GlNameAgent(agent, name);

    "attentionFilter" -> gl_id(agent);

    attention_filter_rulesystem -> sim_rulesystem(agent);

    prb_add_to_db([attentionThreshold 0], sim_get_data(parent));
    prb_add_to_db([filterSettings 0.02 0.05], sim_get_data(parent));
    ;;;prb_add_to_db([filterSettings 0 0.02], sim_get_data(parent));

    ExtractConditionKeys(agent) -> gl_cond_filter(agent);
    sort([activate deactivate]) -> gl_act_filter(agent);
    return(agent);
enddefine;

/* -- Rulesystem -- */

define :rulesystem attention_filter_rulesystem;
    include: attention_filter_relaxation_rulefam
    include: attention_filter_ruleset
enddefine;

define :rulefamily attention_filter_relaxation_rulefam;
    ruleset: attention_filter_relaxation_ruleset
    ruleset: sys_suspend_ruleset
enddefine;


/* -- Rulesets -- */

define :ruleset attention_filter_relaxation_ruleset;

    [VARS blackboard];

    RULE filter_relaxation

        [INDATA ?blackboard [attentionThreshold ?threshold]] [->>it]
        [INDATA ?blackboard [filterSettings ?percent ?fixed]]
        ==>
        [POP11
            threshold - max(threshold*percent, fixed) ->> threshold
                -> gl_filter_threshold(sim_parent);
        ]
        [INDATA ?blackboard [REPLACE ?it [attentionThreshold ?threshold]]]
        [PUSHRULESET sys_suspend_ruleset]
        [STOP]
enddefine;

define :ruleset attention_filter_ruleset;

    [VARS blackboard];

    RULE filter
        [INDATA ?blackboard [activationLevels ??levels]] [->> it]
        [WHERE levels /== []]
        [INDATA ?blackboard [attentionThreshold ?threshold]]
        [INDATA ?blackboard [cycle_count ?count]]
        [WHERE count > 1]
        ==>
        [INDATA ?blackboard [REPLACE ?it [activationLevels]]]
        [POP11
            lvars selectedMotivators, maxActivation;

            -100 -> maxActivation;
            [%
            for item in levels do
                item(2) -> activationLevel;
                if activationLevel > threshold then
                    item;
                endif;
                max (activationLevel,  maxActivation) -> maxActivation;
            endfor;
            %] -> selectedMotivators;

            1+maxActivation -> maxActivation;


            if selectedMotivators /== [] then
                sim_add_data([activate ^sim_myID > motivatorManager
                    ^^selectedMotivators], blackboard);
                sim_eval_data([REPLACE [attentionThreshold ==]
                        [attentionThreshold ^maxActivation]], blackboard);
            endif;
        ]
        [INDATA ?blackboard [REPLACE [old activation ==]
                                    [old activation levels ?levels]]]
        [STOP]
enddefine;


/* ====================================================================== */


/* --- Revision History ---------------------------------------------------

--- Steve Allen, Dec 12, 2000
    Added a variable filter (i.e. not winner-takes-all)

--- Steve Allen, Aug 5 2000
    Added support for new SIM_AGENT toolkit.

--- Steve Allen, Nov 19 1998
    Standardised headers.

--- Steve Allen, Jun 10 1998
    First written.
*/
