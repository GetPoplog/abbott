/* -------------------------------------------------------------------------
   ---       Concern Processing in Autonomous Agents - PhD Thesis        ---
   ---                                                                   ---
   ---       Copyright (c) Steve Allen, 1998. All rights reserved.       ---
   -------------------------------------------------------------------------

   File:            managers.p
   Author           Steve Allen, 5 Aug 2000 - (see revisions at EOF)
   Purpose:         Rules to define Abbott's appetitive behaviour agents.

   Libraries:       LIB sim_agent, poprulebase, objectclass, rc_graphic
                    LIB (*local) gl_agent, gl_abbott

   Related Files:   abbott.p

*/

/* --- Introduction --------------------------------------------------------

This file contains the rules that define the appetitive behaviour agents
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

vars procedure NewManagerFinder;
vars procedure NewManagerLookFor;
vars procedure NewManagerGoTowards;

/* -- Manager Rulesystems -- */

vars manager_finder_ruleset;
vars manager_finder_active_ruleset;
vars manager_finder_found_ruleset;
vars manager_finder_not_found_ruleset;
vars manager_finder_rulefam;
vars manager_finder_rulesystem;

vars manager_look_for_ruleset;
vars manager_look_for_active_ruleset;
vars manager_look_for_rulefam;
vars manager_look_for_rulesystem;

vars manager_look_forward_ruleset;
vars manager_look_forward_active_ruleset;
vars manager_look_forward_rulefam;
vars manager_look_forward_rulesystem;

vars manager_go_towards_ruleset;
vars manager_go_towards_active_ruleset;
vars manager_go_towards_rulefam;
vars manager_go_towards_rulesystem;

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

/* -- dir_nemes.p -- */
vars procedure VisualIndexOf;

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

/* -- sim_agent.p -- */
vars sim_parent;
vars sim_myself;
vars sim_myID;
vars sim_cycle_number;

/* -- local variables -- */
lvars direction, strength;
lvars item;

/**************************************************************************
Functions

***************************************************************************/

/* ====================================================================== */

define :ruleset managers_update_ruleset;

    [VARS sim_myself sim_myID blackboard];

    RULE manager_update
        [INDATA ?blackboard [update ?sender > ?sim_myID ?strength]] [->> cmd]
        ==>
        [INDATA ?blackboard [DEL ?cmd]]
        [POP11
            if sender == gl_act_source(sim_myself) then
                strength -> gl_act_level(sim_myself);
                if gl_selected_behaviour(sim_myself) then
                    sim_add_data([update ^sim_myID >
                            ^(gl_selected_behaviour(sim_myself))
                                    ^(0.9 * strength)], blackboard);
                endif;
            endif;
        ]
        [STOP]
enddefine;

/* ====================================================================== */

/***************************************************************************
NAME
    NewManagerFinder

SYNOPSIS
    NewManagerFinder(parent, name);

FUNCTION
    Finder manager agent. This agent is a appetitve behaviour which will
    try and find an object. It uses other managers, behaviours and
    effectors to accomplish this task.

RETURNS
    None
***************************************************************************/
define vars procedure NewManagerFinder(parent, name) /* -> agent */;
    lvars parent, name;
    lvars agent;

    newgl_manager() -> agent;
    parent -> gl_parent(agent);
    "alive" -> sim_status(agent);
    GlNameAgent(agent, name);

    "Finder" -> gl_id(agent);

    manager_finder_rulesystem -> sim_rulesystem(agent);

    ExtractConditionKeys(agent) -> gl_cond_filter(agent);
    [attend_to move] -> gl_act_filter(agent);
    return(agent);
enddefine;

/* -- Rulesystem -- */

define :rulesystem manager_finder_rulesystem;
    include: managers_update_ruleset
    include: manager_finder_rulefam
enddefine;

/* -- Rulefamilies -- */

define :rulefamily manager_finder_rulefam;
    ruleset: manager_finder_ruleset
    ruleset: manager_finder_active_ruleset
    ruleset: manager_finder_found_ruleset
    ruleset: manager_finder_not_found_ruleset
    ruleset: sys_suspend_ruleset
enddefine;

/* -- Rulesets -- */


define :ruleset manager_finder_ruleset;

    [VARS sim_myself sim_myID blackboard];

    RULE finder_activate
        [INDATA ?blackboard [activate ?sender > ?sim_myID ?item ?strength]] [->> cmd]
        [INDATA ?blackboard [NOT percept ?item ==]]
        ==>
        [INDATA ?blackboard [DEL ?cmd]]
        [INDATA ?blackboard [REPLACE [attend_to ==] [attend_to ?item]]]
        [POP11

/*          prb_print_table(blackboard);
            [********************] => */
            true -> gl_act_status(sim_myself);
            item -> gl_attend_to(sim_myself);
            strength -> gl_act_level(sim_myself);
            sender -> gl_act_source(sim_myself);
            "LookFor" -> gl_selected_behaviour(sim_myself);
            sim_add_data([activate ^sim_myID >
                                ^(gl_selected_behaviour(sim_myself))
                                        ^item ^(0.9 * strength)], blackboard);
            prb_eval([REPLACE [selected ==]
                [selected ^(gl_selected_behaviour(sim_myself))]]);
        ]
        [move direction 5 strength 0]
        [attend_to ?item]
        [PUSHRULESET manager_finder_active_ruleset]
        [STOP]

    RULE finder_goTowards_activate
        [INDATA ?blackboard [activate ?sender > ?sim_myID ?item ?strength]] [->> cmd]
        [INDATA ?blackboard [percept ?item ==]]
        ==>
        [INDATA ?blackboard [DEL ?cmd]]
        [INDATA ?blackboard [REPLACE [attend_to ==] [attend_to ?item]]]
        [POP11
            true -> gl_act_status(sim_myself);
            item -> gl_attend_to(sim_myself);
            strength -> gl_act_level(sim_myself);
            sender -> gl_act_source(sim_myself);

            "GoTowards" -> gl_selected_behaviour(sim_myself);
            sim_add_data([activate ^sim_myID >
                                ^(gl_selected_behaviour(sim_myself))
                                        ^item ^(0.9 * strength)], blackboard);
            prb_eval([REPLACE [selected ==]
                [selected ^(gl_selected_behaviour(sim_myself))]]);
        ]
        [move direction 5 strength 0]
        [attend_to ?item]
        [PUSHRULESET manager_finder_found_ruleset]

enddefine;

define :ruleset manager_finder_active_ruleset;

    [VARS sim_myself sim_myID blackboard];

    RULE finder_deactivate
        [INDATA ?blackboard [deactivate ?sender > ?sim_myID]] [->> cmd]
        [attend_to ?item]
        ==>
        [INDATA ?blackboard [DEL ?cmd]]
        [INDATA ?blackboard [NOT attend_to ?item]]
        [POP11
            false -> gl_act_status(sim_myself);
            if gl_selected_behaviour(sim_myself) then
                sim_add_data([deactivate ^sim_myID >
                        ^(gl_selected_behaviour(sim_myself))], blackboard);
            endif;
        ]
        [NOT attend_to ==]
        [NOT move ==]
        [NOT selected ==]
        [POPRULESET]
        [STOP]

    RULE finder_wait_for_response_found
        [attend_to ?item]
        [INDATA ?blackboard [percept ?item ==]]
        ==>
        [POP11
            if gl_selected_behaviour(sim_myself) then
                sim_add_data([deactivate ^sim_myID >
                    ^(gl_selected_behaviour(sim_myself))], blackboard);
            endif;
            "GoTowards" -> gl_selected_behaviour(sim_myself);
            sim_add_data([activate ^sim_myID >
                ^(gl_selected_behaviour(sim_myself))
                        ^item ^(0.9 * gl_act_level(sim_myself))], blackboard);
            prb_eval([REPLACE [selected ==]
                [selected ^(gl_selected_behaviour(sim_myself))]]);
        ]
        [RESTORERULESET manager_finder_found_ruleset]
        [STOP]

    RULE finder_wait_for_response_not_found
        [attend_to ?item]
        [INDATA ?blackboard [message ?sender > ?sim_myID finished ?item]] [->> it]
        ==>
        [INDATA ?blackboard [DEL ?it]]
        [POP11
            if gl_selected_behaviour(sim_myself) then
                sim_add_data([deactivate ^sim_myID >
                            ^(gl_selected_behaviour(sim_myself))], blackboard);
            endif;
            "LookForward" -> gl_selected_behaviour(sim_myself);
            sim_add_data([activate ^sim_myID >
                    ^(gl_selected_behaviour(sim_myself))
                        ^item ^(0.9 * gl_act_level(sim_myself))], blackboard);
            prb_eval([REPLACE [selected ==]
                [selected ^(gl_selected_behaviour(sim_myself))]]);
        ]
        [RESTORERULESET manager_finder_not_found_ruleset]

enddefine;


define :ruleset manager_finder_found_ruleset;

    [VARS sim_myself sim_myID blackboard];

    RULE finder_deactivate
        [INDATA ?blackboard [deactivate ?sender > ?sim_myID]] [->> cmd]
        [attend_to ?item]
        ==>
        [INDATA ?blackboard [DEL ?cmd]]
        [INDATA ?blackboard [NOT attend_to ?item]]
        [POP11
            false -> gl_act_status(sim_myself);
            if gl_selected_behaviour(sim_myself) then
                sim_add_data([deactivate ^sim_myID >
                            ^(gl_selected_behaviour(sim_myself))], blackboard);
            endif;
        ]
        [NOT attend_to ==]
        [NOT move ==]
        [NOT selected ==]
        [POPRULESET]
        [STOP]

    RULE finder_nolonger_found
        [attend_to ?item]
        [INDATA ?blackboard [NOT percept ?item ==]]
        ==>
        [POP11
            if gl_selected_behaviour(sim_myself) then
                sim_add_data([deactivate ^sim_myID >
                    ^(gl_selected_behaviour(sim_myself))], blackboard);
            endif;
            "LookFor" -> gl_selected_behaviour(sim_myself);
            sim_add_data([activate ^sim_myID >
                    ^(gl_selected_behaviour(sim_myself))
                        ^item ^(0.9 * gl_act_level(sim_myself))], blackboard);
            prb_eval([REPLACE [selected ==]
                [selected ^(gl_selected_behaviour(sim_myself))]]);
        ]
        [RESTORERULESET manager_finder_active_ruleset]
enddefine;

define :ruleset manager_finder_not_found_ruleset;

    [VARS sim_myself sim_myID blackboard];

    RULE finder_deactivate
        [INDATA ?blackboard [deactivate ?sender > ?sim_myID]] [->> cmd]
        [attend_to ?item]
        ==>
        [INDATA ?blackboard [DEL ?cmd]]
        [INDATA ?blackboard [NOT attend_to ?item]]
        [POP11
            false -> gl_act_status(sim_myself);
            if gl_selected_behaviour(sim_myself) then
                sim_add_data([deactivate ^sim_myID >
                            ^(gl_selected_behaviour(sim_myself))], blackboard);
            endif;
        ]
        [NOT attend_to ==]
        [NOT move ==]
        [NOT selected ==]
        [POPRULESET]
        [STOP]

    RULE finder_found
        [attend_to ?item]
        [INDATA ?blackboard [percept ?item ==]]
        ==>
        [POP11
            sim_add_data([deactivate ^sim_myID >
                ^(gl_selected_behaviour(sim_myself))], blackboard);
            "GoTowards" -> gl_selected_behaviour(sim_myself);
            sim_add_data([activate ^sim_myID >
                ^(gl_selected_behaviour(sim_myself))
                    ^item ^(0.9 * gl_act_level(sim_myself))], blackboard);
            prb_eval([REPLACE [selected ==]
                [selected ^(gl_selected_behaviour(sim_myself))]]);
        ]
        [RESTORERULESET manager_finder_found_ruleset]
        [STOP]

    RULE finder_choose_direction
        [move direction ?direction strength ?strength] [->> it]
        ==>
        [POP11
            lvars type, map, count;
            if strength < 1 then
                (direction + random(7) - 1) && 7 + 1 -> direction;
                max(5, intof(2 + 5*gl_act_level(sim_myself))) -> strength;
            else
                strength - 1 -> strength;
            endif;

            0 -> count;
            if sim_present_data(![map occupancy ?map], blackboard) then
                if map(direction) /== 0 then
                    if map(random(3) ->> direction) /== 0 then
                        random(8) -> direction;
                        while map(direction) /== 0 and count < 8 do
                            ((direction mod 8) + 1) -> direction;
                            count + 1 -> count;
                        endwhile;
                    endif;
                endif;
            endif;

            if count < 8 then
                sim_eval_data([PUSH {[FootMove ^direction] ^strength}
                                                effector_foot], blackboard);
            else
                0 -> strength;
            endif;
        ]
        [REPLACE ?it
                [move direction ?direction strength ?strength]]
        [PUSHRULESET sys_suspend_ruleset]
        [STOP]

enddefine;

/* ====================================================================== */

/***************************************************************************
NAME
    NewManagerLookFor

SYNOPSIS
    NewManagerLookFor(parent, name);

FUNCTION
    Look for manager agent. This agent is a appetitve behaviour which will
    try and find an object using the eye. It uses other managers,
    behaviours and effectors to accomplish this task.

RETURNS
    None
***************************************************************************/
define vars procedure NewManagerLookFor(parent, name) /* -> agent */;
    lvars parent, name;
    lvars agent;

    newgl_manager() -> agent;
    parent -> gl_parent(agent);
    "alive" -> sim_status(agent);
    GlNameAgent(agent, name);

    "LookFor" -> gl_id(agent);

    manager_look_for_rulesystem -> sim_rulesystem(agent);

    ExtractConditionKeys(agent) -> gl_cond_filter(agent);
    sort([state]) -> gl_act_filter(agent);
    return(agent);
enddefine;

/* -- Rulesystem -- */

define :rulesystem manager_look_for_rulesystem;
    include: managers_update_ruleset
    include: manager_look_for_rulefam
enddefine;

/* -- Rulefamilies -- */

define :rulefamily manager_look_for_rulefam;
    ruleset: manager_look_for_ruleset
    ruleset: manager_look_for_active_ruleset
enddefine;

/* -- Rulesets -- */


define :ruleset manager_look_for_ruleset;

    [VARS sim_myself sim_myID blackboard];

    RULE look_for_activate
        [INDATA ?blackboard [activate ?sender > ?sim_myID ?item ?strength]] [->> cmd]
        ==>
        [INDATA ?blackboard [DEL ?cmd]]
        [POP11
            item -> gl_attend_to(sim_myself);
            true -> gl_act_status(sim_myself);
            strength -> gl_act_level(sim_myself);
            sender -> gl_act_source(sim_myself);
        ]
        [INDATA ?blackboard [REPLACE [effector_foot ==] [effector_foot]]]
        [INDATA ?blackboard [sense eye]]
        [REPLACE [state ==] [state 1]]
        [PUSHRULESET manager_look_for_active_ruleset]
        [STOP]

enddefine;

define :ruleset manager_look_for_active_ruleset;

    [VARS sim_myself sim_myID blackboard];

    RULE look_for_deselected
        [INDATA ?blackboard [deactivate ?sender > ?sim_myID]] [->> cmd]
        ==>
        [INDATA ?blackboard [DEL ?cmd]]
        [POP11
            false -> gl_act_status(sim_myself);
        ]
        [NOT state ==]
        [POPRULESET]
        [STOP]

    RULE look_for_state_machine
        [INDATA ?blackboard [sensor eye value ??vals]]
        [INDATA ?blackboard [sensor eye update]]
        [INDATA ?blackboard [eye_position ?position]]
        [state ?state] [->> cmd]
        ==>
        [DEL ?cmd]
        [POP11
            if state <= 4 then
                sim_eval_data([PUSH {[EyeLook ^(position mod 4 + 1)]
                    ^(gl_act_level(sim_myself))} effector_eye], blackboard);
                prb_add([state ^(state+1)]);
            else
                sim_add_data([message ^sim_myID >
                    ^(gl_act_source(sim_myself))
                        finished ^(gl_attend_to(sim_myself))], blackboard);
            endif;
        ]
        [STOP]

enddefine;


/* ====================================================================== */

/***************************************************************************
NAME
    NewManagerLookForward

SYNOPSIS
    NewManagerLookForward(parent, name);

FUNCTION
    Look forward manager agent. This agent is a appetitve behaviour which
    will look in the direction of movement using the eye. It uses other
    managers, behaviours and effectors to accomplish this task.

RETURNS
    None
***************************************************************************/
define vars procedure NewManagerLookForward(parent, name) /* -> agent */;
    lvars parent, name;
    lvars agent;

    newgl_manager() -> agent;
    parent -> gl_parent(agent);
    "alive" -> sim_status(agent);
    GlNameAgent(agent, name);

    "LookForward" -> gl_id(agent);

    manager_look_forward_rulesystem -> sim_rulesystem(agent);

    ExtractConditionKeys(agent) -> gl_cond_filter(agent);
    [effector_eye sense] -> gl_act_filter(agent);
    return(agent);
enddefine;

/* -- Rulesystem -- */

define :rulesystem manager_look_forward_rulesystem;
    include: managers_update_ruleset
    include: manager_look_forward_rulefam
enddefine;

/* -- Rulefamilies -- */

define :rulefamily manager_look_forward_rulefam;
    ruleset: manager_look_forward_ruleset
    ruleset: manager_look_forward_active_ruleset
enddefine;

/* -- Rulesets -- */

define :ruleset manager_look_forward_ruleset;

    [VARS sim_myself sim_myID blackboard];

    RULE look_forward_activate
        [INDATA ?blackboard [activate ?sender > ?sim_myID ?item ?strength]] [->> cmd]
        [INDATA ?blackboard [sensor foot heading ?heading]]
        ==>
        [INDATA ?blackboard [DEL ?cmd]]
        [POP11
            item -> gl_attend_to(sim_myself);
            true -> gl_act_status(sim_myself);
            strength -> gl_act_level(sim_myself);
            sender -> gl_act_source(sim_myself);
            if heading && 1 == 1 then
                sim_eval_data([PUSH {[EyeLook ^((heading + 1) div 2)]
                                            ^strength} effector_eye], blackboard);
            else
                sim_eval_data([PUSH {[EyeLook ^(heading div 2)]
                                            ^strength} effector_eye], blackboard);
            endif;
        ]
        [REPLACE [state ==] [state 1]]
        [PUSHRULESET manager_look_forward_active_ruleset]
enddefine;

define :ruleset manager_look_forward_active_ruleset;

    [VARS sim_myself sim_myID blackboard];

    RULE look_forward_deactivate
        [INDATA ?blackboard [deactivate ?sender > ?sim_myID]] [->> cmd]
        ==>
        [INDATA ?blackboard [DEL ?cmd]]
        [POP11
            false -> gl_act_status(sim_myself);
        ]
        [NOT state ==]
        [POPRULESET]
        [STOP]

    RULE look_forward_wait_for_response
        [INDATA ?blackboard [sensor eye value ??vals]]
        [INDATA ?blackboard [sensor eye update]]
        [INDATA ?blackboard [sensor foot heading ?heading]]
        [state ?state] [->> cmd]
        ==>
        [DEL ?cmd]
        [POP11
            if heading && 1 == 1 then
                sim_eval_data([PUSH {[EyeLook ^((heading + 1) div 2)]
                    ^(gl_act_level(sim_myself))} effector_eye], blackboard);
                prb_add([state 0]);
            elseif state == 1 then
                sim_eval_data([PUSH {[EyeLook ^((heading div 2) mod 4 + 1)]
                    ^(gl_act_level(sim_myself))} effector_eye], blackboard);
                prb_add([state 0]);
            else
                sim_eval_data([PUSH {[EyeLook ^(heading div 2)]
                    ^(gl_act_level(sim_myself))} effector_eye], blackboard);
                prb_add([state 1]);
            endif;
        ]
        [STOP]

enddefine;

/* ====================================================================== */

/***************************************************************************
NAME
    NewManagerGoTowards

SYNOPSIS
    NewManagerGoTowards(parent, name);

FUNCTION
    GoTowards manager agent. This agent is a appetitve behaviour which
    will move towards an object using the eye. It uses other managers,
    behaviours and effectors to accomplish this task.

RETURNS
    None
***************************************************************************/
define vars procedure NewManagerGoTowards(parent, name) /* -> agent */;
    lvars parent, name;
    lvars agent;

    newgl_manager() -> agent;
    parent -> gl_parent(agent);
    "alive" -> sim_status(agent);
    GlNameAgent(agent, name);

    "GoTowards" -> gl_id(agent);

    manager_go_towards_rulesystem -> sim_rulesystem(agent);

    ExtractConditionKeys(agent) -> gl_cond_filter(agent);
    [effector_foot] -> gl_act_filter(agent);
    return(agent);
enddefine;

/* -- Rulesystem -- */

define :rulesystem manager_go_towards_rulesystem;
    include: managers_update_ruleset
    include: manager_go_towards_rulefam
enddefine;

/* -- Rulefamilies -- */

define :rulefamily manager_go_towards_rulefam;
    ruleset: manager_go_towards_ruleset
    ruleset: manager_go_towards_active_ruleset
    ruleset: sys_suspend_ruleset
enddefine;

/* -- Rulesets -- */

define :ruleset manager_go_towards_ruleset;

    [VARS sim_myself sim_myID blackboard];

    RULE go_towards_activate
        [INDATA ?blackboard [activate ?sender > ?sim_myID ?item ?strength]] [->> cmd]
        ==>
        [INDATA ?blackboard [DEL ?cmd]]
        [POP11
            item -> gl_attend_to(sim_myself);
            true -> gl_act_status(sim_myself);
            strength -> gl_act_level(sim_myself);
            sender -> gl_act_source(sim_myself);
        ]
        [PUSHRULESET manager_go_towards_active_ruleset]
        [STOP]
enddefine;

define :ruleset manager_go_towards_active_ruleset;

    [VARS sim_myself sim_myID blackboard];

    RULE look_forward_deactivate
        [INDATA ?blackboard [deactivate ?sender > ?sim_myID]] [->> cmd]
        ==>
        [INDATA ?blackboard [DEL ?cmd]]
        [POP11
            false -> gl_act_status(sim_myself);
        ]
        [POPRULESET]
        [STOP]

    RULE go_towards_wait_for_response
        [INDATA ?blackboard [attend_to ?item]]
        [INDATA ?blackboard [percept ?item ?dist ?direction =]]
        ==>
        [POP11
            lvars map;
            if sim_present_data(![map occupancy ?map], blackboard) then
                if map(direction) /== 0 then
                    if map(random(3) ->> direction) /== 0 then
                        for direction from 1 to 8 do
                            if map(direction) == 0 then
                                quitloop;
                            endif;
                        endfor;
                    endif;
                endif;
            endif;

            if direction < 9 then
                sim_eval_data([PUSH {[FootMove ^direction]
                    ^(gl_act_level(sim_myself))} effector_foot], blackboard);
            endif;
        ]
        [STOP]

enddefine;


/* ====================================================================== */


/* --- Revision History ---------------------------------------------------

--- Steve Allen, Nob 22 2000
    Changed to INDATA and removed gl_prop dependence

--- Steve Allen, Aug 5 2000
    Added support for new SIM_AGENT toolkit.

--- Steve Allen, Nov 19 1998
    Standardised headers.

--- Steve Allen, Jun 15 1998
    First written.
*/
