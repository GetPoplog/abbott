/* -------------------------------------------------------------------------
   ---       Concern Processing in Autonomous Agents - PhD Thesis        ---
   ---                                                                   ---
   ---       Copyright (c) Steve Allen, 1998. All rights reserved.       ---
   -------------------------------------------------------------------------

   File:            motivatorMetaManager.p
   Author           Steve Allen, 25 Dec 2000 - (see revisions at EOF)
   Purpose:         Rules to define Abbott's motivation agents.

   Libraries:       LIB sim_agent, poprulebase, objectclass, rc_graphic
                    LIB (*local) gl_agent, gl_abbott

   Related Files:   abbott.p

*/

/* --- Introduction --------------------------------------------------------


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

vars procedure NewMotivatorMetaManager;

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
vars sim_myID;
vars sim_cycle_number;

/* -- Motivations -- */

vars motivatorMetaManager_rulesystem;


lvars item;

/**************************************************************************
Functions

***************************************************************************/

/* -- Ruleset Vars -- */

vars motivatorMetaManager_rulesystem;
vars motivatorMetaManager_rulefam;

vars motivatorMetaManager_ruleset;

/***************************************************************************
NAME
    NewMotivatorMetaManager

SYNOPSIS
    NewMotivatorMetaManger(parent, name);

FUNCTION
    Motivator manager agent.

RETURNS
    None
***************************************************************************/

define vars procedure NewMotivatorMetaManager(parent, name) /* -> agent */;
    lvars parent, name;
    lvars agent;

    newgl_motivatorMetaManager() -> agent;
    parent -> gl_parent(agent);
    "alive" -> sim_status(agent);
    GlNameAgent(agent, name);

    "motivatorMetaManager" -> gl_id(agent);

    motivatorMetaManager_rulesystem -> sim_rulesystem(agent);
    ;;;prb_add_to_db([highFilter 0], sim_get_data(agent));

    return(agent);
enddefine;

/* -- Rulesystem -- */

define :rulesystem motivatorMetaManager_rulesystem;
    include: motivatorMetaManager_rulefam
enddefine;

/* -- Rulefamilies -- */

define :rulefamily motivatorMetaManager_rulefam;
    ruleset: motivatorMetaManager_ruleset
    ruleset: sys_suspend_ruleset
enddefine;

/*
    Perform some simple metaManagement activities - i.e. acts as Abbott's
    MetaManagement and ContextEvaluation agents.

    Stress: If the filter remains high for a period of time then we
    mark the agent as stressed

    Frustration: If the filter remains high for a long period of time
    with the same adopted motivator then reject the motivator and reset
    the filter.
*/

define :ruleset motivatorMetaManager_ruleset;

    [VARS sim_myID blackboard];

    RULE checkRejectedMotivators
        [INDATA ?blackboard [activeMotivators ??motivators]] [->>it]
        [WHERE motivators /== []]
        [INDATA ?blackboard [attentionThreshold ?threshold]]
        [LVARS [managerDB = gl_managerDB(sim_myself)]]
        [INDATA ?managerDB [highFilter ?filterTime]]
        [INDATA ?managerDB [motivatorChange ?changeTime ?lastMot =]]
        ==>
        [POP11
            lvars drives, activeMotivators;

            /*
                Remove motivators that are passed timeout or adopted
                for too long.

                Format: [{mot activation drive state time} ...]
                   where state ::= adopted | rejected | pending
            */
            nil -> drives;
            nil -> activeMotivators;

            for item in motivators do
                if changeTime + 400 < sim_cycle_number and
                    item(1) == lastMot and item(4) == "adopted" then

                    /* cause item to be rejected */
                    "rejected" -> item(4);
                    sim_cycle_number + 50 -> item(5);
                    [cycle ^sim_cycle_number: rejecting ^lastMot as adopted too long] =>

                    /* removing adopted motivator so re-initialise things */
                    sim_add_data([activate ^sim_myID > motivatorManager],
                                                blackboard);
                endif;
            endfor;

            /* reset all motivators if requested */
            if sim_present_data(![resetMotivators], blackboard) then
                nil -> motivators;
            endif;

            /* check for high filter level - i.e. stressed */
            /* Context Evaluation */
            if threshold <= 10 and filterTime > 0 then
                sim_eval_data([REPLACE [highFilter ==]
                    [highFilter 0]], managerDB);
                sim_delete_data([stressed], blackboard);
                [cycle ^sim_cycle_number: not stressed] =>
            elseif threshold > 10 and filterTime == 0 then
                sim_eval_data([REPLACE [highFilter ==]
                    [highFilter ^(sim_cycle_number + 200)]], managerDB);
            elseif threshold > 10 and filterTime > sim_cycle_number and
                        not(sim_present_data(![stressed], blackboard)) then
                sim_add_data([stressed], blackboard);
                [cycle ^sim_cycle_number: stressed] =>
            endif;

        ]
        [INDATA ?blackboard [REPLACE ?it [activeMotivators ??motivators]]]
        [PUSHRULESET sys_suspend_ruleset]
        [STOP]

    RULE default
        ==>
        [PUSHRULESET sys_suspend_ruleset]
        [STOP]

enddefine;



/* --- Revision History ---------------------------------------------------

--- Steve Allen, Nov 25, 2000
    First written.
*/
