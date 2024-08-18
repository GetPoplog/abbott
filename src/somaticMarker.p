/* -------------------------------------------------------------------------
   ---       Concern Processing in Autonomous Agents - PhD Thesis        ---
   ---                                                                   ---
   ---       Copyright (c) Steve Allen, 2000. All rights reserved.       ---
   -------------------------------------------------------------------------

   File:            somaticMarker.p
   Author           Steve Allen, 12 Dec 2000 - (see revisions at EOF)
   Purpose:         Rules to define Abbott's somatic marker action.

   Libraries:       LIB sim_agent, poprulebase, objectclass, rc_graphic
                    LIB (*local) gl_agent, gl_abbott

   Related Files:   abbott.p

*/

/* --- Introduction --------------------------------------------------------

This file contains the rules that define the somatic marker action agents
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

vars procedure NewPainSomaticMarker;

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

/* -- Emotion Rulesystems -- */

vars asifpain_rulesystem;

/* temp data */
lvars max_activation;
lvars item;

/**************************************************************************
Functions

***************************************************************************/

/* ====================================================================== */

/* -- Ruleset Vars -- */

vars asifpain_rulefam;
vars asifpain_ruleset;
vars lookForMark_ruleset;

/***************************************************************************
NAME
    NewPainSomaticMarker

SYNOPSIS
    NewPainSomaticMarker(parent, name);

FUNCTION

RETURNS
    None
***************************************************************************/

define vars procedure NewPainSomaticMarker(parent, name) /* -> agent */;
    lvars parent, name;
    lvars agent;

    newgl_relevanceEval() -> agent;
    parent -> gl_parent(agent);
    "alive" -> sim_status(agent);
    GlNameAgent(agent, name);

    "PainSomaticMarker" -> gl_id(agent);

    asifpain_rulesystem -> sim_rulesystem(agent);

    ExtractConditionKeys(agent) -> gl_cond_filter(agent);
    [] -> gl_act_filter(agent);
    return(agent);
enddefine;

/* -- Rulesystem -- */

define :rulesystem asifpain_rulesystem;
    include: asifpain_rulefam
enddefine;

/* -- Rulefamilies -- */

define :rulefamily asifpain_rulefam;
    ruleset: asifpain_ruleset
    ruleset: lookForMark_ruleset
    ruleset: sys_suspend_ruleset
enddefine;

/* -- Rulesets -- */

define :ruleset asifpain_ruleset;

    [VARS sim_myID blackboard];

    RULE mark_activate
        [INDATA ?blackboard [sensor adrenaline == diff ?diff ==]]
        [WHERE diff > 5]
        [INDATA ?blackboard [sensor pain == direction ?dir == change ?change]]
        [WHERE change > 2]
        ==>
        [POP11 [cycle ^sim_cycle_number: ouch] =>]
        [activate]
        [POP11
            /* check for maps
            lvars type, dist, count, type2, dist2, count2;
            lvars itemCount;
            [resolving maps] =>
                if sim_present_data(![map enemy =], blackboard) then
                    if prb_present(![mark enemy ?count2]) then
                        prb_eval([REPLACE [mark enemy ^count2]
                                                [mark enemy ^(count2+1)]]);
                    else
                        prb_add([mark enemy 1]);
                        if prb_in_database(![markedItems ?itemCount]) then
                            prb_eval([REPLACE [markedItems ==]
                                    [markedItems ^(itemCount+1)]]);
                        else
                            prb_add([markedItems 1]);
                        endif;
                    endif;
                endif;

                if sim_present_data(![map food =], blackboard) then
                    if prb_present(![mark food ?count2]) then
                        prb_eval([REPLACE [mark food ^count2]
                                                [mark food ^(count2+1)]]);
                    else
                        prb_add([mark food 1]);
                        if prb_in_database(![markedItems ?itemCount]) then
                            prb_eval([REPLACE [markedItems ==]
                                    [markedItems ^(itemCount+1)]]);
                        else
                            prb_add([markedItems 1]);
                        endif;
                    endif
                endif;

                if sim_present_data(![map water =], blackboard) then
                    if prb_present(![mark water ?count2]) then
                        prb_eval([REPLACE [mark water ^count2]
                                                [mark water ^(count2+1)]]);
                    else
                        prb_add([mark water 1]);
                        if prb_in_database(![markedItems ?itemCount]) then
                            prb_eval([REPLACE [markedItems ==]
                                    [markedItems ^(itemCount+1)]]);
                        else
                            prb_add([markedItems 1]);
                        endif;
                    endif
                endif;
                */
        ]
        [PUSHRULESET lookForMark_ruleset]
        [PUSHRULESET sys_suspend_ruleset]
        [STOP]

enddefine;

define :ruleset lookForMark_ruleset;

    [VARS sim_myID blackboard];

    RULE mark_found
        [INDATA ?blackboard [cycle_count 2]]
        [activate] [->> it]
        ==>
        [DEL ?it]
        [POP11
            lvars type, dist, count, type2, dist2, count2;
            lvars itemCount;

            [cycle ^sim_cycle_number: marking percepts] =>
            ;;;prb_print_table(sim_data(sim_myself));
            ;;;prb_print_table(blackboard);

            if sim_present_data(![percept ?type ?dist == 0], blackboard) and
                                                                dist <= 16 then
                if prb_present(![mark ?type ?count]) then
                    prb_eval([REPLACE [mark ^type ^count]
                                                [mark ^type ^(count+1)]]);
                else
                    prb_add([mark ^type 1]);

                    if prb_in_database(![markedItems ?itemCount]) then
                        prb_eval([REPLACE [markedItems ==]
                                    [markedItems ^(itemCount+1)]]);
                    else
                        prb_add([markedItems 1]);
                    endif;
                endif
            else
                false -> type;
            endif;

            if sim_present_data(![percept ?type2 ?dist2 == 1], blackboard) and
                                    type2 /= type and dist2 <= 16 then
                if prb_present(![mark ?type2 ?count2]) then
                    prb_eval([REPLACE [mark ^type2 ^count2]
                                                [mark ^type2 ^(count2+1)]]);
                else
                    prb_add([mark ^type2 1]);
                    if prb_in_database(![markedItems ?itemCount]) then
                        prb_eval([REPLACE [markedItems ==]
                                    [markedItems ^(itemCount+1)]]);
                    else
                        prb_add([markedItems 1]);
                    endif;
                endif
            else
                false -> type2;
            endif;


            ;;;prb_print_table(sim_data(sim_myself));
        ]

    RULE filterMarks
        [mark ?type1 ?count1]
        [mark ?type2 ?count2] [->>it]
        [WHERE type1 /= type2]
        [WHERE count1 - count2 >  1]
        [markedItems ?itemCount] [->>items]
        ==>
        [DEL ?it]
        [POP11 itemCount - 1 -> itemCount]
        [REPLACE ?items [markedItems ?itemCount]]

    RULE singleMatch
        [markedItems 1]
        [NOT activate]
        [mark ?type ?count]
        ==>
        [POP11 [cycle ^sim_cycle_number: single mark of ^type with strength ^count] =>]
        [INDATA ?blackboard [REPLACE [somaticMarker = pain =]
                                [somaticMarker ?type pain ?count]]]
        [POPRULESET]
        [STOP]

    RULE return
        [NOT activate]
        ==>
        [POP11 [cycle ^sim_cycle_number: unable to resolve mark] =>]
        [INDATA ?blackboard [NOT somaticMarker = pain =]]
        [POPRULESET]
        [STOP]

enddefine;

/* ====================================================================== */


/* --- Revision History ---------------------------------------------------

--- Steve Allen, Nov 14 2000
    First written.

*/
