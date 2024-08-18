/* -------------------------------------------------------------------------
   ---       Concern Processing in Autonomous Agents - PhD Thesis        ---
   ---                                                                   ---
   ---       Copyright (c) Steve Allen, 1998. All rights reserved.       ---
   -------------------------------------------------------------------------

   File:            motivatorManager.p
   Author           Steve Allen, 26 Nov 2000 - (see revisions at EOF)
   Purpose:         Rules to define Abbott's motivation agents.

   Libraries:       LIB sim_agent, poprulebase, objectclass, rc_graphic
                    LIB (*local) gl_agent, gl_abbott

   Related Files:   abbott.p

*/

/* --- Introduction --------------------------------------------------------

This file contains the rules that define the motivation agents for the
Abbott SoM model.

Motivation agents have two separate levels of operation: (i) pre-attentive
activation energy calculation; and (ii) attentive behaviour selection. At
a pre-attentive level, motivation agents calculate their current
activation level as a function of the error signal (drive) produced by
sensor agents responsible for monitoring their controlled variable.
The resultant drives can then be amplified by relevant external stimuli
detected by man and recogniser agents. Once selected (by the attention
filter agent), motivation agents then select the manager and behaviour
agents they need to satisfy their drives.

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

vars procedure NewMotivatorManager;

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

vars motivatorManager_rulesystem;


lvars item;

/**************************************************************************
Functions

***************************************************************************/

/* -- Ruleset Vars -- */

vars motivatorManager_rulesystem;
vars motivatorManager_rulefam;
vars motivatorManager_mananger_rulefam;

vars motivatorManager_manager_ruleset;
vars motivatorManager_activation_ruleset;
vars motivatorManager_processing_ruleset;
vars motivatorManager_finder_ruleset;

/***************************************************************************
NAME
    NewMotivatorManager

SYNOPSIS
    NewMotivatorManger(parent, name);

FUNCTION
    Motivator manager agent.

RETURNS
    None
***************************************************************************/

define vars procedure NewMotivatorManager(parent, name) /* -> agent */;
    lvars parent, name;
    lvars agent;

    newgl_motivatorManager() -> agent;
    parent -> gl_parent(agent);
    "alive" -> sim_status(agent);
    GlNameAgent(agent, name);

    "motivatorManager" -> gl_id(agent);

    false -> gl_drive(agent);

    motivatorManager_rulesystem -> sim_rulesystem(agent);
    prb_add_to_db([activeMotivators], sim_get_data(parent));
    prb_add_to_db([highFilter 0], sim_get_data(agent));
    prb_add_to_db([motivatorChange 0 false 0], sim_get_data(agent));

    return(agent);
enddefine;

/* -- Rulesystem -- */

define :rulesystem motivatorManager_rulesystem;
    include: motivatorManager_manager_rulefam
    include: motivatorManager_rulefam
enddefine;

/* -- Rulefamilies -- */

define :rulefamily motivatorManager_manager_rulefam;
    ruleset: motivatorManager_manager_ruleset
    ruleset: sys_suspend_ruleset
enddefine;

define :rulefamily motivatorManager_rulefam;
    ruleset: motivatorManager_activation_ruleset
    ruleset: motivatorManager_processing_ruleset
    ruleset: motivatorManager_finder_ruleset
    ruleset: sys_suspend_ruleset
enddefine;

/*
    Perform some simple motivator management activities.

    We maintain the list of active and pending motivators, removing all
    motivators that time-out (motivators have a fixed lifetime from the
    moment they penetrate the filter, which is updated whenever they
    resurface).

    If no active motivators are present, we reset the filter to zero
    to allow new motivators to surface.
*/

define :ruleset motivatorManager_manager_ruleset;

    [VARS sim_myID blackboard];

    RULE manageMotivators
        [INDATA ?blackboard [activeMotivators ??motivators]] [->>it]
        [WHERE motivators /== []]
        [INDATA ?blackboard [attentionThreshold ?threshold]]
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
            [%
            for item in motivators do
                if item(5) > sim_cycle_number then
                    item;
                    unless item(4) == "rejected" then
                        item :: activeMotivators -> activeMotivators;
                    endunless
                else
                    if item(4) == "adopted" then
                        /* removing adopted motivator so re-initialise things */
                        sim_add_data([activate ^sim_myID > motivatorManager],
                                                blackboard);
                    endif;
                    unless member(item(3), drives) then
                        item(3) :: drives -> drives;
                    endunless;
                endif;
            endfor;
            %] -> motivators;

            /* remove match_drive for removed motivators */
            for item in motivators do
                if member(item(3), drives) then
                    delete(item(3), drives) -> drives;
                endif;
            endfor;

            for item in drives do
                sim_delete_data([match_drive ^item], blackboard);
                prb_delete([match_drive ^item]);
                prb_delete([active_drive ^item]);
            endfor;


            /* reset threshold if no active motivators */
            if activeMotivators == nil and threshold > 0 then
                sim_eval_data([REPLACE [attentionThreshold ==]
                        [attentionThreshold 0.1]], blackboard);
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

/*
    Perform some simple motivator deciding/scheduling activities.

    Find the most/least urgent new motivator and add them to the
    list of active motivators (updating the activation energy of
    the existing motivators).

    Remove existing motivators musch less than the min activation
    level of the new motivators.

    Deselect existing behaviours (consumatory or appetitive).

    Activate the search for consumatory behaviours that match active
    motivators (irrespective of adopted motivator). This allows Abbott
    to take advantage of oportunistic situations if any exist.

    Stop moving the eye.
*/

define :ruleset motivatorManager_activation_ruleset;

    [VARS sim_myID blackboard];

    RULE activate
        [INDATA ?blackboard [activate ?sender > ?sim_myID ??motivators]][->> cmd]
        [INDATA ?blackboard [activeMotivators ??activeMotivators]][->>it]
        ==>
        [INDATA ?blackboard [DEL ?cmd]]
        [NOT match_drive ==]
        [INDATA ?blackboard [NOT match_drive ==]]
        [NOT active_drive ==]
        [POP11
            lvars position, drives, maxActivation, maxNewMot;
            lvars newItem, mots, minActivation;

            [cycle ^sim_cycle_number: considering motivators] =>

            /* motivators format: [{motivator activation drive} ... ] */

            /* find most/least urgent new motivator */
            -100 -> maxActivation;
            1000 -> minActivation;
            false -> maxNewMot;
            for item in motivators do
                if item(2) > maxActivation then
                    item -> maxNewMot;
                    item(2) -> maxActivation;
                endif;
                min(item(2), minActivation) -> minActivation;
            endfor;

            /* if no new motivators */
            if minActivation == 1000 then -1000 -> minActivation endif;

            /* if new motivator rejected then update times */
            for item in activeMotivators do
                /* update times and activation level */
                for newItem in motivators do
                    if item(1) == newItem(1) and item(4) /== "rejected" then
                        newItem(2) -> item(2);                          /* activation */
                        max(sim_cycle_number+50, item(5)) -> item(5);   /* time       */
                    endif;
                endfor;
            endfor;

            /* remove active motivators much less than min Activation */
            [%
            for item in activeMotivators do
                if item(2) > (minActivation - 2) then
                    item;
                endif;
            endfor;
            %] -> activeMotivators;

            /* retrieve all active motivators */
            [%for item in activeMotivators do item(1); endfor%] -> mots;

            /* add any new motivators to active motivators */
            for newItem in motivators do
                if member(newItem(1), mots) then
                    for item in mots do
                        if newItem(1) == item(1) then
                            newItem(2) -> item(2);
                            quitloop;
                        endif;
                    endfor;
                else
                    consvector(newItem(1), newItem(2), newItem(3),
                        "pending", sim_cycle_number+50, 5) :: activeMotivators ->
                                                activeMotivators;
                    newItem(1) :: mots -> mots;
                endif;
            endfor;

            /* deselect any selected behaviours */
            if gl_selected_behaviour(sim_myself) then
                sim_add_data([deactivate ^sim_myID >
                            ^(gl_selected_behaviour(sim_myself))], blackboard);
                false -> gl_selected_behaviour(sim_myself);
            endif;

            /* find all active drives */
            nil -> drives;
            for item in activeMotivators do
                if item(4) /== "rejected" and
                                not(member(item(3), drives)) then
                    item(3) :: drives -> drives;
                endif;
            endfor;
            drives -> gl_drive(sim_myself);

            /* lookfor appetitive behaviours to match drives */
            for item in gl_drive(sim_myself) do
                prb_add([active_drive ^item]);
            endfor;

            /* mark as active */
            true -> gl_act_status(sim_myself);
            sender -> gl_act_source(sim_myself);

            /* find activation energy (max) */
            -100 -> maxActivation;
            for item in activeMotivators do
                if item(2) > maxActivation then
                    item(2) -> maxActivation;
                endif;
            endfor;
            maxActivation -> gl_act_level(sim_myself);

            /* stop moving eye */
            if sim_present_data(![eye_position ?position], blackboard) then
                sim_eval_data([PUSH {[EyeLook ^position]
                    ^(gl_act_level(sim_myself) * 0.9)} effector_eye], blackboard);
            endif;
        ]
        [INDATA ?blackboard [REPLACE ?it [activeMotivators ??activeMotivators]]]
        [RESTORERULESET motivatorManager_processing_ruleset]
enddefine;

define :ruleset motivatorManager_processing_ruleset;

    [VARS sim_myself sim_myID blackboard];

    RULE deactivate1
        [INDATA ?blackboard [activate ?sender > ?sim_myID ==]][->> cmd]
        ==>
        [POP11
            false -> gl_act_status(sim_myself);
        ]
        [NOT selected ==]
        [RESTORERULESET motivatorManager_activation_ruleset]

    RULE failed_behaviour
        [LVARS [bev = gl_selected_behaviour(sim_myself)]]
        [INDATA ?blackboard [message ?bev > ?sim_myID failed]][->> ack]
        ==>
        [INDATA ?blackboard [DEL ?ack]]
        [POP11
            sim_add_data([deactivate ^sim_myID >
                        ^(gl_selected_behaviour(sim_myself))], blackboard);
            false -> gl_selected_behaviour(sim_myself);
        ]
        [NOT selected ?bev ==]

    RULE select_primary_behaviour
        [NOT selected ==]
        [active_drive ?drive]
        [INDATA ?blackboard [behaviour_stimulus_observed ?bev == effects ?drive ==]]
        [INDATA ?blackboard [activeMotivators ??motivators]]
        [motivatorChange = ?lastMot =]
        ==>
        [POP11
            bev -> gl_selected_behaviour(sim_myself);

            sim_add_data([activate ^sim_myID > ^bev
                                        ^(gl_act_level(sim_myself))], blackboard);

            for item in motivators do
                if item(3) == drive then
                    "adopted" -> item(4);
                    if drive /== "decrease_pain" then
                        sim_cycle_number + 150 -> item(5);
                    endif;

                    /* check for change of motivator */
                    if item(1) /== lastMot then
                        [cycle ^sim_cycle_number: adopt new motivator
                                ^(item(1)) ^(gl_act_level(sim_myself))] =>
                        prb_eval([REPLACE [motivatorChange ==]
                            [motivatorChange ^sim_cycle_number ^(item(1))
                                            ^(gl_act_level(sim_myself))]]);
                    endif;
                elseif item(4) == "adopted" then
                    "pending" -> item(4);
                endif;
            endfor;
        ]
        [selected ?bev ?drive]
        [STOP]

    RULE select_secondary_behaviour
        [NOT selected ==]
        [active_drive ?drive]
        [INDATA ?blackboard [behaviour_stimulus_observed ?bev == effects == ?drive ==]]
        [INDATA ?blackboard [activeMotivators ??motivators]]
        [motivatorChange = ?lastMot =]
        ==>
        [POP11
            bev -> gl_selected_behaviour(sim_myself);

            sim_add_data([activate ^sim_myID > ^bev
                                        ^(gl_act_level(sim_myself))], blackboard);

            for item in motivators do
                if item(3) == drive then
                    "adopted" -> item(4);
                    if drive /== "decrease_pain" then
                        sim_cycle_number + 150 -> item(5);
                    endif;

                    /* check for change of motivator */
                    if item(1) /== lastMot then
                        [cycle ^sim_cycle_number: adopt new motivator
                                ^(item(1)) ^(gl_act_level(sim_myself))] =>
                        prb_eval([REPLACE [motivatorChange ==]
                            [motivatorChange ^sim_cycle_number ^(item(1))
                                            ^(gl_act_level(sim_myself))]]);
                    endif;
                elseif item(4) == "adopted" then
                    "pending" -> item(4);
                endif;
            endfor;
        ]
        [selected ?bev ?drive]
        [STOP]

    RULE match_drive
        [NOT selected ==]
        [active_drive ?drive] [->>it]
        [NOT match_drive ?drive]
        ==>
        [DEL ?it]
        [INDATA ?blackboard [match_drive ?drive]]
        [match_drive ?drive]

    RULE find_primary_drive
        [NOT selected ==]
        [match_drive ?drive] [->> it]
        [INDATA ?blackboard [behaviour_drive_matched ?bev stimulus ?stimulus effects ?drive ==]]
        [INDATA ?blackboard [activeMotivators ??motivators]]
        [motivatorChange = ?lastMot =]
        ==>
        [DEL ?it]
        [INDATA ?blackboard [NOT match_drive ?drive]]
        [POP11
            "Finder" -> gl_selected_behaviour(sim_myself);
            sim_add_data([activate ^sim_myID >
                ^(gl_selected_behaviour(sim_myself))
                    ^stimulus ^(0.9 *gl_act_level(sim_myself))], blackboard);
            prb_add([selected ^(gl_selected_behaviour(sim_myself))]);

            for item in motivators do
                if item(3) == drive then
                    "adopted" -> item(4);
                    if drive /== "decrease_pain" then
                        sim_cycle_number + 150 -> item(5);
                    endif;

                    /* check for change of motivator */
                    if item(1) /== lastMot then
                        [cycle ^sim_cycle_number: adopt new motivator
                                ^(item(1)) ^(gl_act_level(sim_myself))] =>
                        prb_eval([REPLACE [motivatorChange ==]
                            [motivatorChange ^sim_cycle_number ^(item(1))
                                            ^(gl_act_level(sim_myself))]]);
                    endif;
                elseif item(4) == "adopted" then
                    "pending" -> item(4);
                endif;
            endfor;
        ]
        [active_drive ?drive]
        [RESTORERULESET motivatorManager_finder_ruleset]
        [STOP]

    RULE find_secondary_drive
        [NOT selected ==]
        [match_drive ?drive] [->> it]
        [INDATA ?blackboard [behaviour_drive_matched ?bev stimulus ?stimulus == ?drive ==]]
        [INDATA ?blackboard [activeMotivators ??motivators]]
        [NOT failed ?bev]
        [motivatorChange = ?lastMot =]
        ==>
        [DEL ?it]
        [INDATA ?blackboard [NOT match_drive ?drive]]
        [POP11
            "Finder" -> gl_selected_behaviour(sim_myself);
            sim_add_data([activate ^sim_myID >
                    ^(gl_selected_behaviour(sim_myself))
                        ^stimulus ^(0.9 * gl_act_level(sim_myself))],
                                                                blackboard);
            prb_add([selected ^(gl_selected_behaviour(sim_myself))]);

            for item in motivators do
                if item(3) == drive then
                    "adopted" -> item(4);
                    if drive /== "decrease_pain" then
                        sim_cycle_number + 150 -> item(5);
                    endif;

                    /* check for change of motivator */
                    if item(1) /== lastMot then
                        [cycle ^sim_cycle_number: adopt new motivator
                                ^(item(1)) ^(gl_act_level(sim_myself))] =>
                        prb_eval([REPLACE [motivatorChange ==]
                            [motivatorChange ^sim_cycle_number ^(item(1))
                                            ^(gl_act_level(sim_myself))]]);
                    endif;

                elseif item(4) == "adopted" then
                    "pending" -> item(4);
                endif;
            endfor;
        ]
        [active_drive ?drive]
        [RESTORERULESET motivatorManager_finder_ruleset]
        [STOP]
enddefine;

define :ruleset motivatorManager_finder_ruleset;

    [VARS sim_myself sim_myID blackboard sim_cycle_number];

    RULE deactivate
        [INDATA ?blackboard [activate ?sender > ?sim_myID ==]]
        ==>
        [POP11
            false -> gl_act_status(sim_myself);
        ]
        [NOT selected ==]
        [RESTORERULESET motivatorManager_activation_ruleset]

    RULE behaviour_observed
        [active_drive ?drive]
        [INDATA ?blackboard [behaviour_stimulus_observed == ?drive ==]]
        ==>
        [POP11
            if gl_selected_behaviour(sim_myself) then
                sim_add_data([deactivate ^sim_myID >
                                ^(gl_selected_behaviour(sim_myself))],
                                                                blackboard);
                false -> gl_selected_behaviour(sim_myself);
            endif;
        ]
        [NOT selected ==]
        [RESTORERULESET motivatorManager_processing_ruleset]

enddefine;

/* ====================================================================== */


/* --- Revision History ---------------------------------------------------

--- Steve Allen, Dec 27, 2000
    Better separated management and meta-management activities.

--- Steve Allen, Nov 27, 2000
    Implement simple management functionality.

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
