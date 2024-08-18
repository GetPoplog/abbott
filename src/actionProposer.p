/* -------------------------------------------------------------------------
   ---       Concern Processing in Autonomous Agents - PhD Thesis        ---
   ---                                                                   ---
   ---       Copyright (c) Steve Allen, 1998. All rights reserved.       ---
   -------------------------------------------------------------------------

   File:            actionProposer.p
   Author           Steve Allen, 19 Nov 2000 - (see revisions at EOF)
   Purpose:         Rules to define Abbott's action proposer agent.

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

vars actionProposer_rulesystem;

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

lvars max_activation;
lvars active_motivation, old_motivation;
lvars activationLevel, item;

vars sim_parent;
vars sim_myself;
vars sim_myID;
vars sys_suspend_ruleset1;

/**************************************************************************
Functions

***************************************************************************/

/* ====================================================================== */

/* -- Ruleset Vars -- */

vars actionProposer_ruleset;

/***************************************************************************
NAME
    NewActionProposer

SYNOPSIS
    NewActionProposer(parent, name);

FUNCTION
    A simple action proposer for the society of agents.

RETURNS
    None
***************************************************************************/

define vars procedure NewActionProposer(parent, name) /* -> agent */;
    lvars parent, name;
    lvars agent;

    /* -- Initialisation -- */

    newgl_actionProposer() -> agent;
    parent -> gl_parent(agent);
    "alive" -> sim_status(agent);
    GlNameAgent(agent, name);

    "actionProposer" -> gl_id(agent);

    actionProposer_rulesystem -> sim_rulesystem(agent);

    ExtractConditionKeys(agent) -> gl_cond_filter(agent);
    sort([activate]) -> gl_act_filter(agent);

    prb_add_to_db([skillChange 0 false 0], sim_get_data(agent));

    return(agent);
enddefine;

/* -- Rulesystem -- */

define :rulesystem actionProposer_rulesystem;
    include: actionProposer_rulefam
enddefine;

define :rulefamily actionProposer_rulefam;
    ruleset: actionProposer_ruleset
    ruleset: sys_suspend_ruleset1
enddefine;


/* -- Rulesets -- */

define :ruleset actionProposer_ruleset;

    [VARS blackboard];

    RULE filter
        [INDATA ?blackboard [activationLevels ??levels]]
        [WHERE levels /== []]
        [skillChange ?changeTime ?lastSkill =]
        ==>
        [POP11
            lvars activeDrive, max_activation;
            lvars activeSkill;

            false -> activeDrive;

            /* look for new most urgent drive above threshold */
            -100 -> max_activation;
            for item in levels do
                item(2) -> activationLevel;
                if activationLevel > max_activation then
                    activationLevel -> max_activation;
                    item(1) -> activeDrive;
                endif;
            endfor;

            if activeDrive == "driveThirst" then
                "skillFindWater" -> activeSkill;
            elseif activeDrive == "driveHunger" then
                "skillFindFood" -> activeSkill;
            elseif activeDrive == "driveFatigue" then
                "skillFindRest" -> activeSkill;
            elseif activeDrive == "driveSelfProtection" then
                "skillWithdraw" -> activeSkill;
            else
                "skillWalk" -> activeSkill;
            endif;


            if max_activation < 5 then
                /* inhibit skills if management layer present */
                if gl_motivatorManager(sim_parent) /== nil then
                    false -> activeSkill;
                endif;
                max_activation * 0.8 -> max_activation;
            else
                max_activation * 1.1 -> max_activation;
            endif;

            if sim_present_data(![stressed], blackboard) then
                max_activation * 1.5 -> max_activation;
            endif;

            /* check for relevanceEval */
            if sim_present_data(![relevanceEval danger ==], blackboard) then
                "relevanceEval" -> activeDrive;
                "skillWithdraw" -> activeSkill;
                20 -> max_activation;
                sim_add_data([activate ^sim_myID > adrenalineChangeGen 10],
                                    blackboard);
                [cycle ^sim_cycle_number: release adrenaline] =>
            endif;

            lvars val, dir, type;
            if sim_present_data(![relevanceEval somaticMarkerPain ?val ?dir ?type], blackboard) then
                max(gl_asifpain(sim_parent), val) -> gl_asifpain(sim_parent);
                dir -> gl_asifpain_dir(sim_parent);
                [cycle ^sim_cycle_number: ^type generated bad memory of pain ^(gl_asifpain(sim_parent))] =>
            endif;

            sim_eval_data([REPLACE [activeDrive ==] [activeDrive ^activeDrive]],
                                        blackboard);

            if activeSkill then
                sim_add_data([activate ^sim_myID > ^activeSkill ^max_activation],
                                                    blackboard);
                activeDrive ->> gl_active_mot(sim_myself)
                            ->gl_active_mot(sim_parent);

                /* check for change of skill */
                if activeSkill /== lastSkill then
                    [cycle ^sim_cycle_number: adopt new skill ^activeSkill ^max_activation] =>
                    prb_eval([REPLACE [skillChange ==]
                        [skillChange ^sim_cycle_number ^activeSkill ^max_activation]]);
                    endif;
            endif;

            lvars position;

            /* stop moving eye */
            if sim_present_data(![eye_position ?position], blackboard) then
                sim_eval_data([PUSH {[EyeLook ^position]
                    ^(max_activation * 0.9)} effector_eye], blackboard);
            endif;
        ]
        [PUSHRULESET sys_suspend_ruleset1]
        [STOP]
enddefine;


/* ====================================================================== */


/* --- Revision History ---------------------------------------------------

--- Steve Allen, Aug 5 2000
    Added support for new SIM_AGENT toolkit.

--- Steve Allen, Nov 19 1998
    Standardised headers.

--- Steve Allen, Jun 10 1998
    First written.
*/
