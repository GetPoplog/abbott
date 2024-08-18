/* -------------------------------------------------------------------------
   ---       Concern Processing in Autonomous Agents - PhD Thesis        ---
   ---                                                                   ---
   ---       Copyright (c) Steve Allen, 1998. All rights reserved.       ---
   -------------------------------------------------------------------------

   File:            skills.p
   Author           Steve Allen, 5 Nov 2000 - (see revisions at EOF)
   Purpose:         Rules to define Abbott's consumatory skill agents.

   Libraries:       LIB sim_agent, poprulebase, objectclass, rc_graphic
                    LIB (*local) gl_agent, gl_abbott

   Related Files:   abbott.p

*/

/* --- Introduction --------------------------------------------------------

This file contains the rules that define the consumatory skill agents
of the Abbott SoM model.

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

vars procedure NewSkillAttack;
vars procedure NewSkillFindWater;
vars procedure NewSkillFindFood;
vars procedure NewSkillFindRest;
vars procedure NewSkillWalk;
vars procedure NewSkillWithdraw;

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
vars sim_myID;
vars sys_suspend_ruleset1;
vars sys_suspend_ruleset3;
vars sys_suspend_ruleset4;
vars sim_cycle_number;

/* -- Skill Rulesystems -- */

vars skill_attack_rulesystem;
vars skill_drink_rulesystem;
vars skill_eat_rulesystem;
vars skill_play_rulesystem;
vars skill_rest_rulesystem;
vars skill_walk_rulesystem;
vars skill_withdraw_rulesystem;

/* temp data */
lvars item;

/**************************************************************************
Functions

***************************************************************************/

/* ====================================================================== */


vars skill_attack_ruleset;
vars skill_attack_rulefam;

/***************************************************************************
NAME
    NewSkillAttack

SYNOPSIS
    NewSkillAttack(parent, name);

FUNCTION
    Attack skill agent. This agent recognises the presence of a
    living-being (or enemy) and attacks using the mouth effector. The
    main effect of this skill is to reduce the adrenaline level.

RETURNS
    None
***************************************************************************/

define vars procedure NewSkillAttack(parent, name) /* -> agent */;
    lvars parent, name;
    lvars agent;

    newgl_skill() -> agent;
    parent -> gl_parent(agent);
    "alive" -> sim_status(agent);
    GlNameAgent(agent, name);

    "skillAttack" -> gl_id(agent);

    skill_attack_rulesystem -> sim_rulesystem(agent);

    ExtractConditionKeys(agent) -> gl_cond_filter(agent);
    [skill_stimulus_observed] -> gl_act_filter(agent);
    return(agent);
enddefine;

/* -- Rulesystem -- */

define :rulesystem skill_attack_rulesystem;
    include: skill_attack_rulefam
enddefine;

/* -- Rulefamilies -- */

define :rulefamily skill_attack_rulefam;
    ruleset: skill_attack_ruleset
    ruleset: sys_suspend_ruleset1
enddefine;

/* -- Rulesets -- */

define :ruleset skill_attack_ruleset;

    [VARS sim_myID blackboard];

    RULE attack_activate
        [INDATA ?blackboard [activate ?sender > ?sim_myID ?strength]][->> it]
        [INDATA ?blackboard [sensor organic ?map]]
        ==>
        [INDATA ?blackboard [DEL ?it]]
        [POP11
            true -> gl_act_status(sim_myself);
            strength -> gl_act_level(sim_myself);

            lvars heading;

            /* find a living being to attack */
            for heading from 1 to 8 do
                if map(heading) == 1 then
                    quitloop;
                endif;
            endfor;

            if heading <= 8 then
                prb_eval([INDATA ^blackboard [PUSH {[MouthIngest ^heading]
                    ^(gl_act_level(sim_myself))} effector_mouth]]);
                prb_eval([INDATA ^blackboard [PUSH
                        {[EyeLook ^(round(heading/2))]
                            ^(gl_act_level(sim_myself))} effector_eye]]);
            endif;
        ]
        [PUSHRULESET sys_suspend_ruleset1]
        [STOP]
enddefine;

/* ====================================================================== */

/* -- Ruleset Vars -- */

vars skill_drink_ruleset;
vars skill_drink_rulefam;

/***************************************************************************
NAME
    NewSkillFindWater

SYNOPSIS
    NewSkillFindWater(parent, name);

FUNCTION
    Drink skill agent. This agent recognises the presence of a
    map_water and drinks using the mouth effector. The main effect of
    this skill is to increase the vascular_volume level.

RETURNS
    None
***************************************************************************/

define vars procedure NewSkillFindWater(parent, name) /* -> agent */;
    lvars parent, name;
    lvars agent;

    newgl_skill() -> agent;
    parent -> gl_parent(agent);
    "alive" -> sim_status(agent);
    GlNameAgent(agent, name);

    "skillFindWater" -> gl_id(agent);

    skill_drink_rulesystem -> sim_rulesystem(agent);

    ExtractConditionKeys(agent) -> gl_cond_filter(agent);
    [skill_stimulus_observed effector_mouth effector_eye]
                                                    -> gl_act_filter(agent);
    return(agent);
enddefine;

/* -- Rulesystem -- */

define :rulesystem skill_drink_rulesystem;
    include: skill_drink_rulefam
enddefine;

/* -- Rulefamilies -- */

define :rulefamily skill_drink_rulefam;
    ruleset: skill_drink_ruleset
    ruleset: sys_suspend_ruleset1
enddefine;

/* -- Rulesets -- */

define :ruleset skill_drink_ruleset;

    [VARS sim_myID blackboard];

    RULE drink_activate
        [INDATA ?blackboard [activate = > ?sim_myID ?strength]] [->> it]
        [INDATA ?blackboard [map water ?map]]
        ==>
        [INDATA ?blackboard [DEL ?it]]
        [POP11
            true -> gl_act_status(sim_myself);
            strength -> gl_act_level(sim_myself);

            lvars heading;

            for heading from 1 to 8 do
                if map(heading) == 1 then
                    quitloop;
                endif;
            endfor;

            if heading <= 8 then
                sim_eval_data([PUSH {[MouthIngest ^heading]
                    ^(gl_act_level(sim_myself))} effector_mouth], blackboard);
                sim_eval_data([PUSH {[EyeLook ^(round(heading/2))]
                    ^(gl_act_level(sim_myself))} effector_eye], blackboard);
                sim_eval_data([PUSH {[FootMove 0] ^(gl_act_level(sim_myself))}
                                                effector_foot], blackboard);
            endif;
        ]
        [PUSHRULESET sys_suspend_ruleset1]
        [STOP]

    RULE walk_direction
        [INDATA ?blackboard [activate = > ?sim_myID ?strength]] [->> it]
        [move direction ?direction strength ?walkStrength]
        [INDATA ?blackboard [map freespace ?map]]
        [WHERE map(direction) /== 0]
        ==>
        [INDATA ?blackboard [DEL ?it]]
        [POP11
            true -> gl_act_status(sim_myself);
            strength -> gl_act_level(sim_myself);

            lvars type, map2, count;

            if walkStrength < 1 then
                (direction + random(7) - 1) && 7 + 1 -> direction;
                max(5, intof(2 + 5*gl_act_level(sim_myself))) -> walkStrength;
            else
                walkStrength - 1 -> walkStrength;
            endif;

            if prb_present(![map occupancy ?map2]) then
                if map2(direction) /== 0 then
                    0 -> count;
                    while map2(direction) /== 1 and count < 8 do
                        ((direction mod 8) + 1) -> direction;
                        count + 1 -> count;
                    endwhile;
                endif;
            endif;

            if direction <= 8 then
                prb_eval([REPLACE [move ==]
                    [move direction ^direction strength ^walkStrength]]);

                sim_eval_data([PUSH {[FootMove ^direction]
                    ^walkStrength} effector_foot], blackboard);
                sim_eval_data([PUSH {[EyeLook ^(round(direction/2))]
                    ^(gl_act_level(sim_myself))} effector_eye], blackboard);
            else
                0 -> walkStrength;
            endif;
        ]
        [PUSHRULESET sys_suspend_ruleset1]
        [STOP]

    RULE walk_valid
        [INDATA ?blackboard [activate = > ?sim_myID ?strength]] [->> it]
        [INDATA ?blackboard [map freespace ?map]]
        ==>
        [INDATA ?blackboard [DEL ?it]]
        [POP11
            lvars direction, walkStrength;
            lvars count;

            true -> gl_act_status(sim_myself);
            strength -> gl_act_level(sim_myself);

            random(8) -> direction;
            max(5, intof(2 + 5*gl_act_level(sim_myself))) -> walkStrength;

            0 -> count;
            while map(direction) /== 1 and count < 8 do
                ((direction mod 8) + 1) -> direction;
                count + 1 -> count;
            endwhile;

            if direction <= 8 then
                prb_eval([REPLACE [move ==]
                    [move direction ^direction strength ^walkStrength]]);

                sim_eval_data([PUSH {[FootMove ^direction]
                    ^(gl_act_level(sim_myself))} effector_foot], blackboard);
                sim_eval_data([PUSH {[EyeLook ^(round(direction/2))]
                    ^(gl_act_level(sim_myself))} effector_eye], blackboard);
            endif;
        ]
        [PUSHRULESET sys_suspend_ruleset1]
        [STOP]
enddefine;

/* ====================================================================== */

/* -- Ruleset Vars -- */

vars skill_eat_ruleset;
vars skill_eat_rulefam;

/***************************************************************************
NAME
    NewSkillFindFood

SYNOPSIS
    NewSkillFindFood(parent, name);

FUNCTION
    Eat skill agent. This agent recognises the presence of a
    map_food and eats using the mouth effector. The main effect of
    this skill is to increase the blood_sugar level.

RETURNS
    None
***************************************************************************/

define vars procedure NewSkillFindFood(parent, name) /* -> agent */;
    lvars parent, name;
    lvars agent;

    newgl_skill() -> agent;
    parent -> gl_parent(agent);
    "alive" -> sim_status(agent);
    GlNameAgent(agent, name);

    "skillFindFood" -> gl_id(agent);

    skill_eat_rulesystem -> sim_rulesystem(agent);

    ExtractConditionKeys(agent) -> gl_cond_filter(agent);
    [skill_stimulus_observed effector_mouth effector_eye]
                                                    -> gl_act_filter(agent);
    return(agent);
enddefine;

/* -- Rulesystem -- */

define :rulesystem skill_eat_rulesystem;
    include: skill_eat_rulefam
enddefine;

/* -- Rulefamilies -- */

define :rulefamily skill_eat_rulefam;
    ruleset: skill_eat_ruleset
    ruleset: sys_suspend_ruleset1
enddefine;

/* -- Rulesets -- */

define :ruleset skill_eat_ruleset;

    [VARS sim_myID blackboard];

    RULE eat_activate
        [INDATA ?blackboard [activate = > ?sim_myID ?strength]] [->> it]
        [INDATA ?blackboard [map food ?map]]
        ==>
        [INDATA ?blackboard [DEL ?it]]
        [POP11
            true -> gl_act_status(sim_myself);
            strength -> gl_act_level(sim_myself);

            lvars heading;

            /* locate food */
            for heading from 1 to 8 do
                if map(heading) == 1 then
                    quitloop;
                endif;
            endfor;

            if heading <= 8 then
                sim_eval_data([PUSH {[MouthIngest ^heading]
                    ^(gl_act_level(sim_myself))} effector_mouth], blackboard);
                sim_eval_data([PUSH {[EyeLook ^(round(heading/2))]
                    ^(gl_act_level(sim_myself))} effector_eye], blackboard);
                sim_eval_data([PUSH {[FootMove 0]
                    ^(gl_act_level(sim_myself))} effector_foot], blackboard);
            endif;
        ]
        [PUSHRULESET sys_suspend_ruleset1]
        [STOP]

    RULE walk_direction
        [INDATA ?blackboard [activate = > ?sim_myID ?strength]] [->> it]
        [move direction ?direction strength ?walkStrength]
        [INDATA ?blackboard [map freespace ?map]]
        [WHERE map(direction) /== 0]
        ==>
        [INDATA ?blackboard [DEL ?it]]
        [POP11
            true -> gl_act_status(sim_myself);
            strength -> gl_act_level(sim_myself);

            lvars type, map2, count;

            if walkStrength < 1 then
                (direction + random(7) - 1) && 7 + 1 -> direction;
                max(5, intof(2 + 5*gl_act_level(sim_myself))) -> walkStrength;
            else
                walkStrength - 1 -> walkStrength;
            endif;

            if prb_present(![map occupancy ?map2]) then
                if map2(direction) /== 0 then
                    0 -> count;
                    while map2(direction) /== 1 and count < 8 do
                        ((direction mod 8) + 1) -> direction;
                        count + 1 -> count;
                    endwhile;
                endif;
            endif;

            if direction <= 8 then
                prb_eval([REPLACE [move ==]
                    [move direction ^direction strength ^walkStrength]]);

                sim_eval_data([PUSH {[FootMove ^direction]
                    ^walkStrength} effector_foot], blackboard);
                sim_eval_data([PUSH {[EyeLook ^(round(direction/2))]
                    ^(gl_act_level(sim_myself))} effector_eye], blackboard);
            else
                0 -> walkStrength;
            endif;
        ]
        [PUSHRULESET sys_suspend_ruleset1]
        [STOP]

    RULE walk_valid
        [INDATA ?blackboard [activate = > ?sim_myID ?strength]] [->> it]
        [INDATA ?blackboard [map freespace ?map]]
        ==>
        [INDATA ?blackboard [DEL ?it]]
        [POP11
            lvars direction, walkStrength;
            lvars count;

            true -> gl_act_status(sim_myself);
            strength -> gl_act_level(sim_myself);

            random(8) -> direction;
            max(5, intof(2 + 5*gl_act_level(sim_myself))) -> walkStrength;

            0 -> count;
            while map(direction) /== 1 and count < 8 do
                ((direction mod 8) + 1) -> direction;
                count + 1 -> count;
            endwhile;

            if direction <= 8 then
                prb_eval([REPLACE [move ==]
                    [move direction ^direction strength ^walkStrength]]);

                sim_eval_data([PUSH {[FootMove ^direction]
                    ^(gl_act_level(sim_myself))} effector_foot], blackboard);
                sim_eval_data([PUSH {[EyeLook ^(round(direction/2))]
                    ^(gl_act_level(sim_myself))} effector_eye], blackboard);
            endif;
        ]
        [PUSHRULESET sys_suspend_ruleset1]
        [STOP]
enddefine;

/* ====================================================================== */

/* -- Ruleset Vars -- */

vars skill_play_ruleset;
vars skill_play_rulefam;

/***************************************************************************
NAME
    NewSkillPlay

SYNOPSIS
    NewSkillPlay(parent, name);

FUNCTION
    Play skill agent. This agent recognises the presence of a
    map_block and plays using the hand effector. The main effect of
    this skill is to increase the endorphine level.

RETURNS
    None
***************************************************************************/

define vars procedure NewSkillPlay(parent, name) /* -> agent */;
    lvars parent, name;
    lvars agent;

    newgl_skill() -> agent;
    parent -> gl_parent(agent);
    "alive" -> sim_status(agent);
    GlNameAgent(agent, name);

    "skillPlay" -> gl_id(agent);

    skill_play_rulesystem -> sim_rulesystem(agent);

    ExtractConditionKeys(agent) -> gl_cond_filter(agent);
    [skill_stimulus_observed effector_hand effector_eye]
                                                    -> gl_act_filter(agent);
    return(agent);
enddefine;

/* -- Rulesystem -- */

define :rulesystem skill_play_rulesystem;
    include: skill_play_rulefam
enddefine;

/* -- Rulefamilies -- */

define :rulefamily skill_play_rulefam;
    ruleset: skill_play_ruleset
    ruleset: sys_suspend_ruleset1
enddefine;

/* -- Rulesets -- */

define :ruleset skill_play_ruleset;

    [VARS sim_myID blackboard];

    RULE play_activate
        [INDATA ?blackboard [activate = > ?sim_myID ?strength]] [->> it]
        [INDATA ?blackboard [map block ?map]]
        ==>
        [INDATA ?blackboard [DEL ?it]]
        [POP11
            true -> gl_act_status(sim_myself);
            strength -> gl_act_level(sim_myself);

            lvars heading;

            for heading from 1 to 8 do
                if map(heading) == 1 then
                    quitloop;
                endif;
            endfor;

            if heading <= 8 then
                prb_eval([INDATA ^blackboard [PUSH {[HandPlay ^heading]
                    ^(gl_act_level(sim_myself))} effector_hand]]);
                prb_eval([INDATA ^blackboard [PUSH {[EyeLook ^(round(heading/2))]
                    ^(gl_act_level(sim_myself))} effector_eye]]);
                prb_eval([INDATA ^blackboard [PUSH {[FootMove 0] ^(gl_act_level(sim_myself))}
                                   effector_foot]]);
            endif;
        ]
        [PUSHRULESET sys_suspend_ruleset1]
        [STOP]

enddefine;

/* ====================================================================== */
/* -- Ruleset Vars -- */

vars skill_withdraw_ruleset;
vars skill_withdraw_rulefam;


/***************************************************************************
NAME
    NewSkillWithdraw

SYNOPSIS
    NewSkillWithdraw(parent, name);

FUNCTION
    Withdraw skill agent. This agent recognises the presence of
    pain and withdraws using the foot effector. The main effect of
    this skill is to decrease the pain level.

RETURNS
    None
***************************************************************************/

define vars procedure NewSkillWithdraw(parent, name) /* -> agent */;
    lvars parent, name;
    lvars agent;

    newgl_skill() -> agent;
    parent -> gl_parent(agent);
    "alive" -> sim_status(agent);
    GlNameAgent(agent, name);

    "skillWithdraw" -> gl_id(agent);

    skill_withdraw_rulesystem -> sim_rulesystem(agent);

    ExtractConditionKeys(agent) -> gl_cond_filter(agent);
    [skill_stimulus_observed effector_foot effector_eye]
                                                    -> gl_act_filter(agent);
    return(agent);
enddefine;

/* -- Rulesystem -- */

define :rulesystem skill_withdraw_rulesystem;
    include: skill_withdraw_rulefam
enddefine;

/* -- Rulefamilies -- */

define :rulefamily skill_withdraw_rulefam;
    ruleset: skill_withdraw_ruleset
    ruleset: sys_suspend_ruleset
    ruleset: sys_suspend_ruleset3
enddefine;

/* -- Rulesets -- */

define :ruleset skill_withdraw_ruleset;

    [VARS sim_myID blackboard];

    RULE withdraw_activate
        [INDATA ?blackboard [activate = > ?sim_myID ?strength]] [->> it]
        [INDATA ?blackboard [sensor pain value = direction ?direct ==]]
        [INDATA ?blackboard [map freespace ?map]]
        [nextLookDir ?nextLookDir]
        [LVARS heading]
        [POP11
            (3 + direct) mod 8 + 1 -> heading;
            if map(heading) /== 1 then
                for item from 2 to 4 do
                    if map((heading - item) mod 8 + 1) == 1 then
                        ((heading - item) mod 8 + 1) -> heading;
                        quitloop;
                    elseif map((heading + item - 2) mod 8 + 1) == 1 then
                        ((heading + item - 2) mod 8 + 1) -> heading;
                        quitloop;
                    endif;
                endfor;
            endif;
        ]
        [WHERE map(heading) == 1]
        ==>
        [INDATA ?blackboard [DEL ?it]]
        [POP11
            true -> gl_act_status(sim_myself);
            strength -> gl_act_level(sim_myself);

            prb_eval([INDATA ^blackboard [PUSH {[FootMove ^heading]
                    ^(gl_act_level(sim_myself))} effector_foot]]);
            prb_eval([INDATA ^blackboard [PUSH {[EyeLook ^nextLookDir]
                     ^(gl_act_level(sim_myself))} effector_eye]]);
        ]
        [NOT nextLookDir ==]
        [PUSHRULESET sys_suspend_ruleset]
        [STOP]

    RULE withdraw_activate2
        [INDATA ?blackboard [activate = > ?sim_myID ?strength]] [->> it]
        [INDATA ?blackboard [sensor pain value = direction ?direct ==]]
        [WHERE direct mod 2 == 0]
        [INDATA ?blackboard [map freespace ?map]]
        [LVARS heading]
        [POP11
            (3 + direct) mod 8 + 1 -> heading;
            if map(heading) /== 1 then
                for item from 2 to 4 do
                    if map((heading - item) mod 8 + 1) == 1 then
                        ((heading - item) mod 8 + 1) -> heading;
                        quitloop;
                    elseif map((heading + item - 2) mod 8 + 1) == 1 then
                        ((heading + item - 2) mod 8 + 1) -> heading;
                        quitloop;
                    endif;
                endfor;
            endif;
        ]
        [WHERE map(heading) == 1]
        ==>
        ;;;[INDATA ?blackboard [DEL ?it]]
        [POP11
            true -> gl_act_status(sim_myself);
            strength -> gl_act_level(sim_myself);

            prb_eval([INDATA ^blackboard [PUSH {[FootMove ^heading]
                    ^(gl_act_level(sim_myself))} effector_foot]]);
            prb_eval([INDATA ^blackboard [PUSH {[EyeLook ^(round(direct/2))]
                     ^(gl_act_level(sim_myself))} effector_eye]]);

            /* look in related direction */
            prb_add([nextLookDir ^(((direct/2) mod 4)+1)]);
        ]
        [PUSHRULESET sys_suspend_ruleset3]
        [STOP]

    RULE withdraw_activate3
        [INDATA ?blackboard [activate = > ?sim_myID ?strength]] [->> it]
        [INDATA ?blackboard [sensor pain value = direction ?direct ==]]
        [INDATA ?blackboard [map freespace ?map]]
        [LVARS heading]
        [POP11
            (3 + direct) mod 8 + 1 -> heading;
            if map(heading) /== 1 then
                for item from 2 to 4 do
                    if map((heading - item) mod 8 + 1) == 1 then
                        ((heading - item) mod 8 + 1) -> heading;
                        quitloop;
                    elseif map((heading + item - 2) mod 8 + 1) == 1 then
                        ((heading + item - 2) mod 8 + 1) -> heading;
                        quitloop;
                    endif;
                endfor;
            endif;
        ]
        [WHERE map(heading) == 1]
        ==>
        [INDATA ?blackboard [DEL ?it]]
        [POP11
            true -> gl_act_status(sim_myself);
            strength -> gl_act_level(sim_myself);

            prb_eval([INDATA ^blackboard [PUSH {[FootMove ^heading]
                    ^(gl_act_level(sim_myself))} effector_foot]]);
            prb_eval([INDATA ^blackboard [PUSH {[EyeLook ^(round(direct/2))]
                     ^(gl_act_level(sim_myself))} effector_eye]]);
        ]
        [PUSHRULESET sys_suspend_ruleset]
        [STOP]

    RULE withdraw_activate_relEval
        [INDATA ?blackboard [activate = > ?sim_myID ?strength]] [->> it]
        [INDATA ?blackboard [relevanceEval danger ?direct]]
        [INDATA ?blackboard [map freespace ?map]]
        [LVARS heading]
        [POP11
            (3 + direct) mod 8 + 1 -> heading;
            if map(heading) /== 1 then
                for item from 2 to 4 do
                    if map((heading - item) mod 8 + 1) == 1 then
                        ((heading - item) mod 8 + 1) -> heading;
                        quitloop;
                    elseif map((heading + item - 2) mod 8 + 1) == 1 then
                        ((heading + item - 2) mod 8 + 1) -> heading;
                        quitloop;
                    endif;
                endfor;
            endif;
        ]
        [WHERE map(heading) == 1]
        ==>
        [INDATA ?blackboard [DEL ?it]]
        [POP11
            true -> gl_act_status(sim_myself);
            strength -> gl_act_level(sim_myself);


            prb_eval([INDATA ^blackboard [PUSH {[FootMove ^heading]
                    ^(gl_act_level(sim_myself))} effector_foot]]);
            prb_eval([INDATA ^blackboard [PUSH {[EyeLook ^(round(direct/2))]
                    ^(gl_act_level(sim_myself))} effector_eye]]);
        ]
        [PUSHRULESET sys_suspend_ruleset]
        [STOP]

    RULE withdraw_not_valid
        [INDATA ?blackboard [activate = > ?sim_myID ?strength]] [->> it]
        ==>
        [INDATA ?blackboard [DEL ?it]]
        [NOT nextLookDir ==]
        [PUSHRULESET sys_suspend_ruleset]
        [STOP]

enddefine;



/* ====================================================================== */

/* -- Ruleset Vars -- */

vars skill_rest_ruleset;
vars skill_rest_rulefam;


/***************************************************************************
NAME
    NewSkillFindRest

SYNOPSIS
    NewSkillFindRest(parent, name);

FUNCTION
    Rest skill agent. This agent recognises the presence of
    map_block and rests against it. The main effect of
    this skill is to increase the energy level.

RETURNS
    None
***************************************************************************/

define vars procedure NewSkillFindRest(parent, name) /* -> agent */;
    lvars parent, name;
    lvars agent;

    newgl_skill() -> agent;
    parent -> gl_parent(agent);
    "alive" -> sim_status(agent);
    GlNameAgent(agent, name);

    "skillFindRest" -> gl_id(agent);

    skill_rest_rulesystem -> sim_rulesystem(agent);

    ExtractConditionKeys(agent) -> gl_cond_filter(agent);
    [skill_stimulus_observed] -> gl_act_filter(agent);
    return(agent);
enddefine;

/* -- Rulesystem -- */

define :rulesystem skill_rest_rulesystem;
    include: skill_rest_rulefam
enddefine;

/* -- Rulefamilies -- */

define :rulefamily skill_rest_rulefam;
    ruleset: skill_rest_ruleset
    ruleset: sys_suspend_ruleset1
enddefine;

/* -- Rulesets -- */

define :ruleset skill_rest_ruleset;

    [VARS sim_myID blackboard];

    RULE rest_activate
        [INDATA ?blackboard [activate = > ?sim_myID ?strength]] [->> it]
        [INDATA ?blackboard [map block ?map]]
        [WHERE map(6) /== 0]
        ==>
        [INDATA ?blackboard [DEL ?it]]
        [POP11
            true -> gl_act_status(sim_myself);
            strength -> gl_act_level(sim_myself);

            /* Stop */
            sim_eval_data([PUSH {[FootMove 0]
                ^(gl_act_level(sim_myself))} effector_foot], blackboard);
        ]
        [PUSHRULESET sys_suspend_ruleset1]
        [STOP]

    RULE walk_direction
        [INDATA ?blackboard [activate = > ?sim_myID ?strength]] [->> it]
        [move direction ?direction strength ?walkStrength]
        [INDATA ?blackboard [map freespace ?map]]
        [WHERE map(direction) /== 0]
        ==>
        [INDATA ?blackboard [DEL ?it]]
        [POP11
            true -> gl_act_status(sim_myself);
            strength -> gl_act_level(sim_myself);

            lvars type, map2, count;

            if walkStrength < 1 then
                (direction + random(7) - 1) && 7 + 1 -> direction;
                max(5, intof(2 + 5*gl_act_level(sim_myself))) -> walkStrength;
            else
                walkStrength - 1 -> walkStrength;
            endif;

            if prb_present(![map occupancy ?map2]) then
                if map2(direction) /== 0 then
                    0 -> count;
                    while map2(direction) /== 1 and count < 8 do
                        ((direction mod 8) + 1) -> direction;
                        count + 1 -> count;
                    endwhile;
                endif;
            endif;

            if direction <= 8 then
                prb_eval([REPLACE [move ==]
                    [move direction ^direction strength ^walkStrength]]);

                sim_eval_data([PUSH {[FootMove ^direction]
                    ^walkStrength} effector_foot], blackboard);
                sim_eval_data([PUSH {[EyeLook ^(round(direction/2))]
                    ^(gl_act_level(sim_myself))} effector_eye], blackboard);
            else
                0 -> walkStrength;
            endif;
        ]
        [PUSHRULESET sys_suspend_ruleset1]
        [STOP]

    RULE walk_valid
        [INDATA ?blackboard [activate = > ?sim_myID ?strength]] [->> it]
        [INDATA ?blackboard [map freespace ?map]]
        ==>
        [INDATA ?blackboard [DEL ?it]]
        [POP11
            lvars direction, walkStrength;
            lvars count;

            true -> gl_act_status(sim_myself);
            strength -> gl_act_level(sim_myself);

            random(8) -> direction;
            max(5, intof(2 + 5*gl_act_level(sim_myself))) -> walkStrength;

            0 -> count;
            while map(direction) /== 1 and count < 8 do
                ((direction mod 8) + 1) -> direction;
                count + 1 -> count;
            endwhile;

            if direction <= 8 then
                prb_eval([REPLACE [move ==]
                    [move direction ^direction strength ^walkStrength]]);

                sim_eval_data([PUSH {[FootMove ^direction]
                    ^(gl_act_level(sim_myself))} effector_foot], blackboard);
                sim_eval_data([PUSH {[EyeLook ^(round(direction/2))]
                    ^(gl_act_level(sim_myself))} effector_eye], blackboard);
            endif;
        ]
        [PUSHRULESET sys_suspend_ruleset1]
        [STOP]
enddefine;

/* ====================================================================== */

/* -- Ruleset Vars -- */

vars skill_walk_ruleset;
vars skill_walk_rulefam;


/***************************************************************************
NAME
    NewSkillWalk

SYNOPSIS
    NewSkillWalk(parent, name);

FUNCTION
    Withdraw skill agent. This agent recognises the presence of
    free space and walks using the foot effector. The main effect
    of this skill is to increase the temperature level.

RETURNS
    None
***************************************************************************/

define vars procedure NewSkillWalk(parent, name) /* -> agent */;
    lvars parent, name;
    lvars agent;

    newgl_skill() -> agent;
    parent -> gl_parent(agent);
    "alive" -> sim_status(agent);
    GlNameAgent(agent, name);

    "skillWalk" -> gl_id(agent);

    skill_walk_rulesystem -> sim_rulesystem(agent);

    ExtractConditionKeys(agent) -> gl_cond_filter(agent);
    [skill_stimulus_observed effector_foot effector_eye]
                                                    -> gl_act_filter(agent);
    return(agent);
enddefine;

/* -- Rulesystem -- */

define :rulesystem skill_walk_rulesystem;
    include: skill_walk_rulefam
enddefine;

/* -- Rulefamilies -- */

define :rulefamily skill_walk_rulefam;
    ruleset: skill_walk_ruleset
    ruleset: sys_suspend_ruleset1
enddefine;

/* -- Rulesets -- */

define :ruleset skill_walk_ruleset;

    [VARS sim_myID blackboard];

    RULE walk_direction
        [INDATA ?blackboard [activate = > ?sim_myID ?strength]] [->> it]
        [move direction ?direction strength ?walkStrength]
        [INDATA ?blackboard [map freespace ?map]]
        [WHERE map(direction) /== 0]
        ==>
        [INDATA ?blackboard [DEL ?it]]
        [POP11
            true -> gl_act_status(sim_myself);
            strength -> gl_act_level(sim_myself);

            lvars type, map2, count;

            if walkStrength < 1 then
                (direction + random(7) - 1) && 7 + 1 -> direction;
                max(5, intof(2 + 5*gl_act_level(sim_myself))) -> walkStrength;
            else
                walkStrength - 1 -> walkStrength;
            endif;

            if prb_present(![map occupancy ?map2]) then
                if map2(direction) /== 0 then
                    0 -> count;
                    while map2(direction) /== 1 and count < 8 do
                        ((direction mod 8) + 1) -> direction;
                        count + 1 -> count;
                    endwhile;
                endif;
            endif;

            if direction <= 8 then
                prb_eval([REPLACE [move ==]
                    [move direction ^direction strength ^walkStrength]]);

                sim_eval_data([PUSH {[FootMove ^direction]
                    ^walkStrength} effector_foot], blackboard);
                sim_eval_data([PUSH {[EyeLook ^(round(direction/2))]
                    ^(gl_act_level(sim_myself))} effector_eye], blackboard);
            else
                0 -> walkStrength;
            endif;
        ]
        [PUSHRULESET sys_suspend_ruleset1]
        [STOP]

    RULE walk_valid
        [INDATA ?blackboard [activate = > ?sim_myID ?strength]] [->> it]
        [INDATA ?blackboard [map freespace ?map]]
        ==>
        [INDATA ?blackboard [DEL ?it]]
        [POP11
            lvars direction, walkStrength;
            lvars count;

            true -> gl_act_status(sim_myself);
            strength -> gl_act_level(sim_myself);

            random(8) -> direction;
            max(5, intof(2 + 5*gl_act_level(sim_myself))) -> walkStrength;

            0 -> count;
            while map(direction) /== 1 and count < 8 do
                ((direction mod 8) + 1) -> direction;
                count + 1 -> count;
            endwhile;

            if direction <= 8 then
                prb_eval([REPLACE [move ==]
                    [move direction ^direction strength ^walkStrength]]);

                sim_eval_data([PUSH {[FootMove ^direction]
                    ^(gl_act_level(sim_myself))} effector_foot], blackboard);
                sim_eval_data([PUSH {[EyeLook ^(round(direction/2))]
                    ^(gl_act_level(sim_myself))} effector_eye], blackboard);
            endif;
        ]
        [PUSHRULESET sys_suspend_ruleset1]
        [STOP]

enddefine;



/* ====================================================================== */


/* --- Revision History ---------------------------------------------------

--- Steve Allen, Nov 13 2000
    Created skill agents based on old behaviour agents

--- Steve Allen, Aug 4 2000
    Preliminary support for new SIM_AGENT toolkit
    uses sim_shared_data().

--- Steve Allen, Nov 19 1998
    Standardised headers.

--- Steve Allen, Nov 8 1998
    Added Exp2 behaviour agents.

--- Steve Allen, Oct 3 1998
    Uses a single blackboard architecture.

--- Steve Allen, Aug 6 1998
    Changed to use separate database and sim_agent types - with message
    passing.

--- Steve Allen, Jun 1 1998
    First written.
*/
