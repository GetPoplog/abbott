/* -------------------------------------------------------------------------
   ---       Concern Processing in Autonomous Agents - PhD Thesis        ---
   ---                                                                   ---
   ---       Copyright (c) Steve Allen, 1998. All rights reserved.       ---
   -------------------------------------------------------------------------

   File:            behaviours.p
   Author           Steve Allen, 4 Aug 2000 - (see revisions at EOF)
   Purpose:         Rules to define Abbott's consumatory behaviour agents.

   Libraries:       LIB sim_agent, poprulebase, objectclass, rc_graphic
                    LIB (*local) gl_agent, gl_abbott

   Related Files:   abbott.p

*/

/* --- Introduction --------------------------------------------------------

This file contains the rules that define the consumatory behaviour agents
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

vars procedure NewBehaviourAttack;
vars procedure NewBehaviourDrink;
vars procedure NewBehaviourEat;
vars procedure NewBehaviourPlay;
vars procedure NewBehaviourRest;
vars procedure NewBehaviourWalk;
vars procedure NewBehaviourWithdraw;

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
vars blackboard;
vars sim_cycle_number;
vars sys_suspend_ruleset;
vars sys_suspend_ruleset1;
vars sys_suspend_ruleset4;

/* -- Behaviour Rulesystems -- */

vars behaviour_attack_rulesystem;
vars behaviour_drink_rulesystem;
vars behaviour_eat_rulesystem;
vars behaviour_play_rulesystem;
vars behaviour_rest_rulesystem;
vars behaviour_walk_rulesystem;
vars behaviour_withdraw_rulesystem;

/* temp data */
lvars item;

/**************************************************************************
Functions

***************************************************************************/

/* ====================================================================== */

define :ruleset behaviours_update_ruleset;

    [VARS sim_myself sim_myID blackboard];

    RULE behaviour_update
        [INDATA ?blackboard [update ?sender > ?sim_myID ?strength]] [->> cmd]
        ==>
        [INDATA ?blackboard [DEL ?cmd]]
        [POP11
            if sender == gl_act_source(sim_myself) then
                strength -> gl_act_level(sim_myself);
            endif;
        ]
        [STOP]
enddefine;

define :ruleset behaviours_match_drive_ruleset;

    [VARS sim_myself sim_myID blackboard];

    RULE match_drive
        [INDATA ?blackboard [match_drive ?drive]]
        [WHERE lmember(drive, gl_effects(sim_myself))]
        [NOT drive_matched ?drive]
        ==>
        [drive_matched ?drive]
        [POP11
            sim_add_data([behaviour_drive_matched
                ^sim_myID stimulus ^(gl_stimulus(sim_myself))
                    effects ^^(gl_effects(sim_myself))], blackboard);
        ]
        [STOP]

    RULE not_match_drive
        [drive_matched ?drive] [->> it]
        [INDATA ?blackboard [NOT match_drive ?drive]]
        ==>
        [DEL ?it]
        [INDATA ?blackboard [NOT behaviour_drive_matched ?sim_myID ==]]
        [STOP]
enddefine;

/* ====================================================================== */

/* -- Ruleset Vars -- */

vars behaviour_attack_ruleset;
vars behaviour_attack_stimulus_found_ruleset;
vars behaviour_attack_active_ruleset;
vars behaviour_attack_rulefam;

/***************************************************************************
NAME
    NewBehaviourAttack

SYNOPSIS
    NewBehaviourAttack(parent, name);

FUNCTION
    Attack behaviour agent. This agent recognises the presence of a
    living-being (or enemy) and attacks using the mouth effector. The
    main effect of this behaviour is to reduce the noradrenaline level.

RETURNS
    None
***************************************************************************/

define vars procedure NewBehaviourAttack(parent, name) /* -> agent */;
    lvars parent, name;
    lvars agent;

    newgl_behaviour() -> agent;
    parent -> gl_parent(agent);
    "alive" -> sim_status(agent);
    GlNameAgent(agent, name);

    "behaviourAttack" -> gl_id(agent);

    "enemy" -> gl_stimulus(agent);
    [decrease_noradrenaline decrease_energy increase_temperature]
                                                    -> gl_effects(agent);

    behaviour_attack_rulesystem -> sim_rulesystem(agent);

    ExtractConditionKeys(agent) -> gl_cond_filter(agent);
    [behaviour_stimulus_observed] -> gl_act_filter(agent);
    return(agent);
enddefine;

/* -- Rulesystem -- */

define :rulesystem behaviour_attack_rulesystem;
    include: behaviours_update_ruleset
    include: behaviours_match_drive_ruleset
    include: behaviour_attack_rulefam
enddefine;

/* -- Rulefamilies -- */

define :rulefamily behaviour_attack_rulefam;
    ruleset: behaviour_attack_ruleset
    ruleset: behaviour_attack_stimulus_found_ruleset
    ruleset: behaviour_attack_active_ruleset
    ruleset: sys_suspend_ruleset1
enddefine;

/* -- Rulesets -- */

define :ruleset behaviour_attack_ruleset;

    [VARS sim_myself sim_myID blackboard];

    RULE attack_stimulus_found
        [INDATA ?blackboard [map living_being ==]]
        ==>
        [stimulus_observed]
        [POP11
            sim_add_data([behaviour_stimulus_observed
                ^sim_myID stimulus ^(gl_stimulus(sim_myself))
                    effects ^^(gl_effects(sim_myself))], blackboard);
        ]
        [PUSHRULESET behaviour_attack_stimulus_found_ruleset]
enddefine;

define :ruleset behaviour_attack_stimulus_found_ruleset;

    [VARS sim_myself sim_myID blackboard];

    RULE attack_activate
        [INDATA ?blackboard [activate ?sender > ?sim_myID ?strength]] [->> cmd]
        ==>
        [INDATA ?blackboard [DEL ?cmd]]
        [POP11
            true -> gl_act_status(sim_myself);
            strength -> gl_act_level(sim_myself);
            sender -> gl_act_source(sim_myself);
        ]
        [PUSHRULESET behaviour_attack_active_ruleset]

    RULE attack_stimulus_removed
        [INDATA ?blackboard [NOT map living_being ==]]
        ==>
        [INDATA ?blackboard [NOT behaviour_stimulus_observed ?sim_myID ==]]
        [NOT stimulus_observed]
        [POPRULESET]
enddefine;

define :ruleset behaviour_attack_active_ruleset;

    [VARS sim_myself sim_myID blackboard];

    RULE attack_deactivate
        [INDATA ?blackboard [deactivate ?sender > ?sim_myID]] [->> cmd]
        ==>
        [INDATA ?blackboard [DEL ?cmd]]
        [POP11
            false -> gl_act_status(sim_myself);
            0 -> gl_act_level(sim_myself);
        ]
        [POPRULESET]

    RULE attack_valid
        [INDATA ?blackboard [map living_being ?map]]
        ==>
        [POP11
            lvars heading;

            /* find a living being to attack */
            for heading from 1 to 8 do
                if map(heading) == 1 then
                    quitloop;
                endif;
            endfor;

            /* give priority to attacking enemies */
            if sim_present_data(![map enemy ?map], blackboard) then
                for heading from 1 to 8 do
                    if map(heading) == 1 then
                        quitloop;
                    endif;
                endfor;
            endif;

            if heading <= 8 then
                sim_eval_data([PUSH {[MouthIngest ^heading]
                    ^(gl_act_level(sim_myself))} effector_mouth], blackboard);
                sim_eval_data([PUSH {[EyeLook ^(round(heading/2))]
                    ^(gl_act_level(sim_myself))} effector_eye], blackboard);
            endif;
        ]
        [PUSHRULESET sys_suspend_ruleset1]
        [STOP]

    RULE attack_invalid
        [stimulus_observed] [->> it]
        ==>
        [DEL ?it]
        [INDATA ?blackboard [NOT behaviour_stimulus_observed ?sim_myID ==]]
        [LVARS [sender = gl_act_source(sim_myself)]]
        [INDATA ?blackboard [message ?sim_myID > ?sender failed]]
        [STOP]

enddefine;

/* ====================================================================== */

/* -- Ruleset Vars -- */

vars behaviour_drink_ruleset;
vars behaviour_drink_stimulus_found_ruleset;
vars behaviour_drink_active_ruleset;
vars behaviour_drink_rulefam;

/***************************************************************************
NAME
    NewBehaviourDrink

SYNOPSIS
    NewBehaviourDrink(parent, name);

FUNCTION
    Drink behaviour agent. This agent recognises the presence of a
    map_water and drinks using the mouth effector. The main effect of
    this behaviour is to increase the vascular_volume level.

RETURNS
    None
***************************************************************************/

define vars procedure NewBehaviourDrink(parent, name) /* -> agent */;
    lvars parent, name;
    lvars agent;

    newgl_behaviour() -> agent;
    parent -> gl_parent(agent);
    "alive" -> sim_status(agent);
    GlNameAgent(agent, name);

    "behaviourDrink" -> gl_id(agent);

    "water" -> gl_stimulus(agent);
    [increase_vascular_volume increase_endorphine
        decrease_temperature] -> gl_effects(agent);

    behaviour_drink_rulesystem -> sim_rulesystem(agent);

    ExtractConditionKeys(agent) -> gl_cond_filter(agent);
    [behaviour_stimulus_observed effector_mouth effector_eye]
                                                    -> gl_act_filter(agent);
    return(agent);
enddefine;

/* -- Rulesystem -- */

define :rulesystem behaviour_drink_rulesystem;
    include: behaviours_update_ruleset
    include: behaviours_match_drive_ruleset
    include: behaviour_drink_rulefam
enddefine;

/* -- Rulefamilies -- */

define :rulefamily behaviour_drink_rulefam;
    ruleset: behaviour_drink_ruleset
    ruleset: behaviour_drink_stimulus_found_ruleset
    ruleset: behaviour_drink_active_ruleset
    ruleset: sys_suspend_ruleset1
enddefine;

/* -- Rulesets -- */

define :ruleset behaviour_drink_ruleset;

    [VARS sim_myself sim_myID blackboard];

    RULE drink_sense_stimulus
        [INDATA ?blackboard [map water ==]]
        ==>
        [stimulus_observed]
        [POP11
            sim_add_data([behaviour_stimulus_observed
                ^sim_myID stimulus ^(gl_stimulus(sim_myself))
                       effects ^^(gl_effects(sim_myself))], blackboard);
        ]
        [PUSHRULESET behaviour_drink_stimulus_found_ruleset]
enddefine;

define :ruleset behaviour_drink_stimulus_found_ruleset;

    [VARS sim_myself sim_myID blackboard];

    RULE drink_activate
        [INDATA ?blackboard [activate ?sender > ?sim_myID ?strength]] [->> cmd]
        ==>
        [INDATA ?blackboard [DEL ?cmd]]
        [POP11
            true -> gl_act_status(sim_myself);
            strength -> gl_act_level(sim_myself);
            sender -> gl_act_source(sim_myself);
        ]
        [PUSHRULESET behaviour_drink_active_ruleset]

    RULE drink_stimulus_not_found
        [INDATA ?blackboard [NOT map water ==]]
        ==>
        [INDATA ?blackboard [NOT behaviour_stimulus_observed ?sim_myID ==]]
        [NOT stimulus_observed]
        [POPRULESET]
        [STOP]

enddefine;

define :ruleset behaviour_drink_active_ruleset;

    [VARS sim_myself sim_myID blackboard];

    RULE drink_deactivate
        [INDATA ?blackboard [deactivate ?sender > ?sim_myID ==]] [->> cmd]
        ==>
        [INDATA ?blackboard [DEL ?cmd]]
        [POP11
            false -> gl_act_status(sim_myself);
            0 -> gl_act_level(sim_myself);
        ]
        [POPRULESET]

    RULE drink_valid
        [INDATA ?blackboard [map water ?map]]
        ==>
        [POP11
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

    RULE drink_invalid
        [stimulus_observed] [->> it]
        ==>
        [DEL ?it]
        [INDATA ?blackboard [NOT behaviour_stimulus_observed ?sim_myID ==]]
        [LVARS [sender = gl_act_source(sim_myself)]]
        [INDATA ?blackboard [message ?sim_myID > ?sender failed]]
        [STOP]

enddefine;

/* ====================================================================== */

/* -- Ruleset Vars -- */

vars behaviour_eat_ruleset;
vars behaviour_eat_stimulus_found_ruleset;
vars behaviour_eat_active_ruleset;
vars behaviour_eat_rulefam;

/***************************************************************************
NAME
    NewBehaviourEat

SYNOPSIS
    NewBehaviourEat(parent, name);

FUNCTION
    Eat behaviour agent. This agent recognises the presence of a
    map_food and eats using the mouth effector. The main effect of
    this behaviour is to increase the blood_sugar level.

RETURNS
    None
***************************************************************************/

define vars procedure NewBehaviourEat(parent, name) /* -> agent */;
    lvars parent, name;
    lvars agent;

    newgl_behaviour() -> agent;
    parent -> gl_parent(agent);
    "alive" -> sim_status(agent);
    GlNameAgent(agent, name);

    "behaviourEat" -> gl_id(agent);

    "food" -> gl_stimulus(agent);
    [increase_blood_sugar increase_temperature]
                                                    -> gl_effects(agent);

    behaviour_eat_rulesystem -> sim_rulesystem(agent);

    ExtractConditionKeys(agent) -> gl_cond_filter(agent);
    [behaviour_stimulus_observed effector_mouth effector_eye]
                                                    -> gl_act_filter(agent);
    return(agent);
enddefine;

/* -- Rulesystem -- */

define :rulesystem behaviour_eat_rulesystem;
    include: behaviours_update_ruleset
    include: behaviours_match_drive_ruleset
    include: behaviour_eat_rulefam
enddefine;

/* -- Rulefamilies -- */

define :rulefamily behaviour_eat_rulefam;
    ruleset: behaviour_eat_ruleset
    ruleset: behaviour_eat_stimulus_found_ruleset
    ruleset: behaviour_eat_active_ruleset
    ruleset: sys_suspend_ruleset1
enddefine;

/* -- Rulesets -- */

define :ruleset behaviour_eat_ruleset;

    [VARS sim_myself sim_myID blackboard];

    RULE eat_sense_stimulus
        [INDATA ?blackboard [map food ==]]
        ==>
        [stimulus_observed]
        [POP11
            sim_add_data([behaviour_stimulus_observed
                ^sim_myID stimulus ^(gl_stimulus(sim_myself))
                    effects ^^(gl_effects(sim_myself))], blackboard);
        ]
        [PUSHRULESET behaviour_eat_stimulus_found_ruleset]
enddefine;

define :ruleset behaviour_eat_stimulus_found_ruleset;

    [VARS sim_myself sim_myID blackboard];

    RULE eat_activate
        [INDATA ?blackboard [activate ?sender > ?sim_myID ?strength]] [->> cmd]
        ==>
        [INDATA ?blackboard [DEL ?cmd]]
        [POP11
            true -> gl_act_status(sim_myself);
            strength -> gl_act_level(sim_myself);
            sender -> gl_act_source(sim_myself);
        ]
        [PUSHRULESET behaviour_eat_active_ruleset]

    RULE eat_stimulus_not_found
        [INDATA ?blackboard [NOT map food ==]]
        ==>
        [INDATA ?blackboard [NOT behaviour_stimulus_observed ?sim_myID ==]]
        [NOT stimulus_observed]
        [POPRULESET]
        [STOP]

enddefine;

define :ruleset behaviour_eat_active_ruleset;

    [VARS sim_myself sim_myID blackboard];

    RULE eat_deactivate
        [INDATA ?blackboard [deactivate ?sender > ?sim_myID]] [->> cmd]
        ==>
        [INDATA ?blackboard [DEL ?cmd]]
        [POP11
            false -> gl_act_status(sim_myself);
            0 -> gl_act_level(sim_myself);
        ]
        [INDATA ?blackboard [NOT message ?sim_myID ==]]
        [POPRULESET]

    RULE eat_valid
        [INDATA ?blackboard [map food ?map]]
        ==>
        [POP11
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

    RULE eat_invalid
        [stimulus_observed] [->> it]
        ==>
        [DEL ?it]
        [INDATA ?blackboard [NOT behaviour_stimulus_observed ?sim_myID ==]]
        [LVARS [sender = gl_act_source(sim_myself)]]
        [INDATA ?blackboard [message ?sim_myID > ?sender failed]]
        [STOP]
enddefine;

/* ====================================================================== */

/* -- Ruleset Vars -- */

vars behaviour_play_ruleset;
vars behaviour_play_stimulus_found_ruleset;
vars behaviour_play_active_ruleset;
vars behaviour_play_rulefam;

/***************************************************************************
NAME
    NewBehaviourPlay

SYNOPSIS
    NewBehaviourPlay(parent, name);

FUNCTION
    Play behaviour agent. This agent recognises the presence of a
    map_block and plays using the hand effector. The main effect of
    this behaviour is to increase the endorphine level.

RETURNS
    None
***************************************************************************/

define vars procedure NewBehaviourPlay(parent, name) /* -> agent */;
    lvars parent, name;
    lvars agent;

    newgl_behaviour() -> agent;
    parent -> gl_parent(agent);
    "alive" -> sim_status(agent);
    GlNameAgent(agent, name);

    "behaviourPlay" -> gl_id(agent);

    "block" -> gl_stimulus(agent);
    [increase_dopamine] -> gl_effects(agent);

    behaviour_play_rulesystem -> sim_rulesystem(agent);

    ExtractConditionKeys(agent) -> gl_cond_filter(agent);
    [behaviour_stimulus_observed effector_hand effector_eye]
                                                    -> gl_act_filter(agent);
    return(agent);
enddefine;

/* -- Rulesystem -- */

define :rulesystem behaviour_play_rulesystem;
    include: behaviours_update_ruleset
    include: behaviours_match_drive_ruleset
    include: behaviour_play_rulefam
enddefine;

/* -- Rulefamilies -- */

define :rulefamily behaviour_play_rulefam;
    ruleset: behaviour_play_ruleset
    ruleset: behaviour_play_stimulus_found_ruleset
    ruleset: behaviour_play_active_ruleset
    ruleset: sys_suspend_ruleset1
enddefine;

/* -- Rulesets -- */

define :ruleset behaviour_play_ruleset;

    [VARS sim_myself sim_myID blackboard];

    RULE play_sense_stimulus
        [INDATA ?blackboard [map block ==]]
        ==>
        [stimulus_observed]
        [POP11
            sim_add_data([behaviour_stimulus_observed
                ^sim_myID stimulus ^(gl_stimulus(sim_myself))
                    effects ^^(gl_effects(sim_myself))], blackboard);
        ]
        [PUSHRULESET behaviour_play_stimulus_found_ruleset]
enddefine;

define :ruleset behaviour_play_stimulus_found_ruleset;

    [VARS sim_myself sim_myID blackboard];

    RULE play_activate
        [INDATA ?blackboard [activate ?sender > ?sim_myID ?strength]] [->> cmd]
        ==>
        [INDATA ?blackboard [DEL ?cmd]]
        [POP11
            true -> gl_act_status(sim_myself);
            strength -> gl_act_level(sim_myself);
            sender -> gl_act_source(sim_myself);
        ]
        [PUSHRULESET behaviour_play_active_ruleset]

    RULE play_stimulus_not_found
        [INDATA ?blackboard [NOT map block ==]]
        ==>
        [INDATA ?blackboard [NOT behaviour_stimulus_observed ?sim_myID ==]]
        [NOT stimulus_observed]
        [POPRULESET]
        [STOP]
enddefine;

define :ruleset behaviour_play_active_ruleset;

    [VARS sim_myself sim_myID blackboard];

    RULE play_deactivate
        [INDATA ?blackboard [deactivate ?sender > ?sim_myID]] [->> cmd]
        ==>
        [INDATA ?blackboard [DEL ?cmd]]
        [POP11
            false -> gl_act_status(sim_myself);
            0 -> gl_act_level(sim_myself);
        ]
        [INDATA ?blackboard [NOT message ?sim_myID ==]]
        [POPRULESET]

    RULE play_valid
        [INDATA ?blackboard [map block ?map]]
        ==>
        [POP11
            lvars heading;

            for heading from 1 to 8 do
                if map(heading) == 1 then
                    quitloop;
                endif;
            endfor;

            if heading <= 8 then
                sim_eval_data([PUSH {[HandPlay ^heading]
                    ^(gl_act_level(sim_myself))} effector_hand], blackboard);
                sim_eval_data([PUSH {[EyeLook ^(round(heading/2))]
                    ^(gl_act_level(sim_myself))} effector_eye], blackboard);
                sim_eval_data([PUSH {[FootMove 0] ^(gl_act_level(sim_myself))}
                    effector_foot], blackboard);
            endif;
        ]
        [PUSHRULESET sys_suspend_ruleset1]
        [STOP]

    RULE play_invalid
        [stimulus_observed] [->> it]
        ==>
        [DEL ?it]
        [INDATA ?blackboard [NOT behaviour_stimulus_observed ?sim_myID ==]]
        [LVARS [sender = gl_act_source(sim_myself)]]
        [INDATA ?blackboard [message ?sim_myID > ?sender failed]]
        [STOP]
enddefine;

/* ====================================================================== */
/* -- Ruleset Vars -- */

vars behaviour_withdraw_ruleset;
vars behaviour_withdraw_stimulus_found_ruleset;
vars behaviour_withdraw_active_ruleset;
vars behaviour_withdraw_rulefam;


/***************************************************************************
NAME
    NewBehaviourWithdraw

SYNOPSIS
    NewBehaviourWithdraw(parent, name);

FUNCTION
    Withdraw behaviour agent. This agent recognises the presence of
    pain and withdraws using the foot effector. The main effect of
    this behaviour is to decrease the pain level.

RETURNS
    None
***************************************************************************/

define vars procedure NewBehaviourWithdraw(parent, name) /* -> agent */;
    lvars parent, name;
    lvars agent;

    newgl_behaviour() -> agent;
    parent -> gl_parent(agent);
    "alive" -> sim_status(agent);
    GlNameAgent(agent, name);

    "behaviourWithdraw" -> gl_id(agent);

    "freespace" -> gl_stimulus(agent);
    [decrease_pain] -> gl_effects(agent);

    behaviour_withdraw_rulesystem -> sim_rulesystem(agent);

    ExtractConditionKeys(agent) -> gl_cond_filter(agent);
    [behaviour_stimulus_observed effector_foot effector_eye]
                                                    -> gl_act_filter(agent);
    return(agent);
enddefine;

/* -- Rulesystem -- */

define :rulesystem behaviour_withdraw_rulesystem;
    include: behaviours_update_ruleset
    include: behaviours_match_drive_ruleset
    include: behaviour_withdraw_rulefam
enddefine;

/* -- Rulefamilies -- */

define :rulefamily behaviour_withdraw_rulefam;
    ruleset: behaviour_withdraw_ruleset
    ruleset: behaviour_withdraw_stimulus_found_ruleset
    ruleset: behaviour_withdraw_active_ruleset
    ruleset: sys_suspend_ruleset1
    ruleset: sys_suspend_ruleset4
enddefine;

/* -- Rulesets -- */

define :ruleset behaviour_withdraw_ruleset;

    [VARS sim_myself sim_myID blackboard];

    RULE sense_stimulus
        [INDATA ?blackboard [sensor pain value ?val ==]]
        [WHERE val > 0]
        ==>
        [stimulus_observed]
        [POP11
            sim_add_data([behaviour_stimulus_observed
                ^sim_myID stimulus ^(gl_stimulus(sim_myself))
                    effects ^^(gl_effects(sim_myself))], blackboard);
        ]
        [PUSHRULESET behaviour_withdraw_stimulus_found_ruleset]

    RULE sense_stimulus2
        [INDATA ?blackboard [sensor asifpain value ?val ==]]
        [WHERE val > 0]
        ==>
        [stimulus_observed]
        [POP11
            sim_add_data([behaviour_stimulus_observed
                ^sim_myID stimulus ^(gl_stimulus(sim_myself))
                    effects ^^(gl_effects(sim_myself))], blackboard);
        ]
        [PUSHRULESET behaviour_withdraw_stimulus_found_ruleset]
enddefine;

define :ruleset behaviour_withdraw_stimulus_found_ruleset;

    [VARS sim_myself sim_myID blackboard];

    RULE withdraw_activate
        [INDATA ?blackboard [activate ?sender > ?sim_myID ?strength]] [->> cmd]
        ==>
        [INDATA ?blackboard [DEL ?cmd]]
        [POP11
            true -> gl_act_status(sim_myself);
            strength -> gl_act_level(sim_myself);
            sender -> gl_act_source(sim_myself);
        ]
        [PUSHRULESET behaviour_withdraw_active_ruleset]

    RULE withdraw_stimulus_removed
        [INDATA ?blackboard [NOT sensor pain ==]]
        [INDATA ?blackboard [NOT sensor asifpain ==]]
        ==>
        [INDATA ?blackboard [NOT behaviour_stimulus_observed ?sim_myID ==]]
        [NOT stimulus_observed]
        [POPRULESET]
enddefine;

define :ruleset behaviour_withdraw_active_ruleset;

    [VARS sim_myself sim_myID blackboard];

    RULE withdraw_deactivate
        [INDATA ?blackboard [deactivate ?sender > ?sim_myID]] [->> cmd]
        ==>
        [INDATA ?blackboard [DEL ?cmd]]
        [NOT nextLookDir ==]
        [POP11
            false -> gl_act_status(sim_myself);
            0 -> gl_act_level(sim_myself);
        ]
        [POPRULESET]

    RULE withdraw_valid1
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
        [POP11
            sim_eval_data([PUSH {[FootMove ^heading]
                ^(gl_act_level(sim_myself))} effector_foot], blackboard);
            sim_eval_data([PUSH {[EyeLook ^nextLookDir]
                ^(gl_act_level(sim_myself))} effector_eye], blackboard);
        ]
        [NOT nextLookDir ==]
        [PUSHRULESET sys_suspend_ruleset1]
        [STOP]

    RULE withdraw_valid2
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
        [POP11
            sim_eval_data([PUSH {[FootMove ^heading]
                ^(gl_act_level(sim_myself))} effector_foot], blackboard);
            sim_eval_data([PUSH {[EyeLook ^(round(direct/2))]
                ^(gl_act_level(sim_myself))} effector_eye], blackboard);

            /* look in related direction */
            prb_add([nextLookDir ^(((direct/2) mod 4)+1)]);
        ]
        [PUSHRULESET sys_suspend_ruleset4]
        [STOP]

    RULE withdraw_valid3
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
        [POP11
            sim_eval_data([PUSH {[FootMove ^heading]
                ^(gl_act_level(sim_myself))} effector_foot], blackboard);
            sim_eval_data([PUSH {[EyeLook ^(round(direct/2))]
                ^(gl_act_level(sim_myself))} effector_eye], blackboard);
        ]
        [PUSHRULESET sys_suspend_ruleset1]
        [STOP]

    RULE withdraw_valid
        [INDATA ?blackboard [sensor pain value = direction ?direct ==]]
        [INDATA ?blackboard [NOT map freespace ==]]
        ==>
        [POP11
            sim_eval_data([PUSH {[FootMove ^((3 + direct) mod 8 + 1)]
                ^(gl_act_level(sim_myself))} effector_foot], blackboard);
            sim_eval_data([PUSH {[EyeLook ^(round(direct/2))]
                ^(gl_act_level(sim_myself))} effector_eye], blackboard);
        ]
        [PUSHRULESET sys_suspend_ruleset1]
        [STOP]

    RULE withdraw_valid1b
        [INDATA ?blackboard [sensor asifpain value = direction ?direct ==]]
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
        [POP11
            sim_eval_data([PUSH {[FootMove ^heading]
                ^(gl_act_level(sim_myself))} effector_foot], blackboard);
            sim_eval_data([PUSH {[EyeLook ^nextLookDir]
                ^(gl_act_level(sim_myself))} effector_eye], blackboard);
        ]
        [NOT nextLookDir ==]
        [PUSHRULESET sys_suspend_ruleset1]
        [STOP]

    RULE withdraw_valid2b
        [INDATA ?blackboard [sensor asifpain value = direction ?direct ==]]
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
        [POP11
            sim_eval_data([PUSH {[FootMove ^heading]
                ^(gl_act_level(sim_myself))} effector_foot], blackboard);
            sim_eval_data([PUSH {[EyeLook ^(round(direct/2))]
                ^(gl_act_level(sim_myself))} effector_eye], blackboard);

            /* look in related direction */
            prb_add([nextLookDir ^(((direct/2) mod 4)+1)]);
        ]
        [PUSHRULESET sys_suspend_ruleset4]
        [STOP]

    RULE withdraw_valid3b
        [INDATA ?blackboard [sensor asifpain value = direction ?direct ==]]
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
        [POP11
            sim_eval_data([PUSH {[FootMove ^heading]
                ^(gl_act_level(sim_myself))} effector_foot], blackboard);
            sim_eval_data([PUSH {[EyeLook ^(round(direct/2))]
                ^(gl_act_level(sim_myself))} effector_eye], blackboard);
        ]
        [PUSHRULESET sys_suspend_ruleset1]
        [STOP]

    RULE withdraw_validb
        [INDATA ?blackboard [sensor asifpain value = direction ?direct ==]]
        [INDATA ?blackboard [NOT map freespace ==]]
        ==>
        [POP11
            sim_eval_data([PUSH {[FootMove ^((3 + direct) mod 8 + 1)]
                ^(gl_act_level(sim_myself))} effector_foot], blackboard);
            sim_eval_data([PUSH {[EyeLook ^(round(direct/2))]
                ^(gl_act_level(sim_myself))} effector_eye], blackboard);
        ]
        [PUSHRULESET sys_suspend_ruleset1]
        [STOP]

    RULE withdraw_invalid
        [stimulus_observed] [->> it]
        ==>
        [DEL ?it]
        [INDATA ?blackboard [NOT behaviour_stimulus_observed ?sim_myID ==]]
        [LVARS [sender = gl_act_source(sim_myself)]]
        [INDATA ?blackboard [message ?sim_myID > ?sender failed]]
        [STOP]

enddefine;



/* ====================================================================== */

/* -- Ruleset Vars -- */

vars behaviour_rest_ruleset;
vars behaviour_rest_stimulus_found_ruleset;
vars behaviour_rest_active_ruleset;
vars behaviour_rest_rulefam;


/***************************************************************************
NAME
    NewBehaviourRest

SYNOPSIS
    NewBehaviourRest(parent, name);

FUNCTION
    Rest behaviour agent. This agent recognises the presence of
    map_block and rests against it. The main effect of
    this behaviour is to increase the energy level.

RETURNS
    None
***************************************************************************/

define vars procedure NewBehaviourRest(parent, name) /* -> agent */;
    lvars parent, name;
    lvars agent;

    newgl_behaviour() -> agent;
    parent -> gl_parent(agent);
    "alive" -> sim_status(agent);
    GlNameAgent(agent, name);

    "behaviourRest" -> gl_id(agent);

    "block" -> gl_stimulus(agent);
    [increase_energy] -> gl_effects(agent);

    behaviour_rest_rulesystem -> sim_rulesystem(agent);

    ExtractConditionKeys(agent) -> gl_cond_filter(agent);
    [behaviour_stimulus_observed] -> gl_act_filter(agent);
    return(agent);
enddefine;

/* -- Rulesystem -- */

define :rulesystem behaviour_rest_rulesystem;
    include: behaviours_update_ruleset
    include: behaviours_match_drive_ruleset
    include: behaviour_rest_rulefam
enddefine;

/* -- Rulefamilies -- */

define :rulefamily behaviour_rest_rulefam;
    ruleset: behaviour_rest_ruleset
    ruleset: behaviour_rest_stimulus_found_ruleset
    ruleset: behaviour_rest_active_ruleset
    ruleset: sys_suspend_ruleset1
    ruleset: sys_suspend_ruleset4
enddefine;

/* -- Rulesets -- */

define :ruleset behaviour_rest_ruleset;

    [VARS sim_myself sim_myID blackboard];

    RULE rest_sense_stimulus
        [INDATA ?blackboard [map block ?map]]
        [WHERE map(6) /== 0]
        ==>
        [stimulus_observed]
        [POP11
            sim_add_data([behaviour_stimulus_observed
                ^sim_myID stimulus ^(gl_stimulus(sim_myself))
                        effects ^^(gl_effects(sim_myself))], blackboard);
        ]
        [PUSHRULESET behaviour_rest_stimulus_found_ruleset]
enddefine;

define :ruleset behaviour_rest_stimulus_found_ruleset;

    [VARS sim_myself sim_myID blackboard];

    RULE rest_activate
        [INDATA ?blackboard [activate ?sender > ?sim_myID ?strength]] [->> cmd]
        ==>
        [INDATA ?blackboard [DEL ?cmd]]
        [POP11
            true -> gl_act_status(sim_myself);
            strength -> gl_act_level(sim_myself);
            sender -> gl_act_source(sim_myself);
        ]
        [PUSHRULESET behaviour_rest_active_ruleset]

    RULE rest_stimulus_not_found
        [INDATA ?blackboard [map block ?map]]
        [WHERE map(6) == 0]
        ==>
        [INDATA ?blackboard [NOT behaviour_stimulus_observed ?sim_myID ==]]
        [NOT stimulus_observed]
        [POPRULESET]
        [STOP]

    RULE rest_stimulus_not_found2
        [INDATA ?blackboard [NOT map block ==]]
        ==>
        [INDATA ?blackboard [NOT behaviour_stimulus_observed ?sim_myID ==]]
        [NOT stimulus_observed]
        [POPRULESET]
        [STOP]

enddefine;

define :ruleset behaviour_rest_active_ruleset;

    [VARS sim_myself sim_myID blackboard];

    RULE rest_deactivate
        [INDATA ?blackboard [deactivate ?sender > ?sim_myID]] [->> cmd]
        ==>
        [INDATA ?blackboard [DEL ?cmd]]
        [POP11
            false -> gl_act_status(sim_myself);
            0 -> gl_act_level(sim_myself);
        ]
        [INDATA ?blackboard [NOT message ?sim_myID ==]]
        [POPRULESET]

    RULE rest_valid
        [INDATA ?blackboard [map block ?map]]
        [WHERE map(6) /== 0]
        [eyeLook ?direct]
        ==>
        [POP11
            /* Stop */
            sim_eval_data([PUSH {[FootMove 0] ^(gl_act_level(sim_myself))}
                        effector_foot], blackboard);
            sim_eval_data([PUSH {[EyeLook ^direct] ^(gl_act_level(sim_myself))}
                        effector_eye], blackboard);
        ]
        [NOT eyeLook ==]
        [PUSHRULESET sys_suspend_ruleset4]
        [STOP]

    RULE rest_valid
        [INDATA ?blackboard [map block ?map]]
        [WHERE map(6) /== 0]
        ==>
        [POP11
            /* Stop */
            sim_eval_data([PUSH {[FootMove 0] ^(gl_act_level(sim_myself))}
                        effector_foot], blackboard);
            sim_eval_data([PUSH {[EyeLook 2] ^(gl_act_level(sim_myself))}
                        effector_eye], blackboard);
        ]
        [eyeLook 1]
        [PUSHRULESET sys_suspend_ruleset1]
        [STOP]

    RULE rest_invalid
        [stimulus_observed] [->> it]
        ==>
        [DEL ?it]
        [INDATA ?blackboard [NOT behaviour_stimulus_observed ?sim_myID ==]]
        [LVARS [sender = gl_act_source(sim_myself)]]
        [INDATA ?blackboard [message ?sim_myID > ?sender failed]]
        [STOP]
enddefine;

/* ====================================================================== */

/* -- Ruleset Vars -- */

vars behaviour_walk_ruleset;
vars behaviour_walk_stimulus_found_ruleset;
vars behaviour_walk_active_ruleset;
vars behaviour_walk_rulefam;


/***************************************************************************
NAME
    NewBehaviourWalk

SYNOPSIS
    NewBehaviourWalk(parent, name);

FUNCTION
    Withdraw behaviour agent. This agent recognises the presence of
    free space and walks using the foot effector. The main effect
    of this behaviour is to increase the temperature level.

RETURNS
    None
***************************************************************************/

define vars procedure NewBehaviourWalk(parent, name) /* -> agent */;
    lvars parent, name;
    lvars agent;

    newgl_behaviour() -> agent;
    parent -> gl_parent(agent);
    "alive" -> sim_status(agent);
    GlNameAgent(agent, name);

    "behaviourWalk" -> gl_id(agent);

    "freespace" -> gl_stimulus(agent);
    [increase_temperature decrease_energy decrease_blood_suger
                            decrease_vascular_volume] -> gl_effects(agent);

    behaviour_walk_rulesystem -> sim_rulesystem(agent);

    ExtractConditionKeys(agent) -> gl_cond_filter(agent);
    [behaviour_stimulus_observed effector_foot effector_eye]
                                                    -> gl_act_filter(agent);
    return(agent);
enddefine;

/* -- Rulesystem -- */

define :rulesystem behaviour_walk_rulesystem;
    include: behaviours_update_ruleset
    include: behaviours_match_drive_ruleset
    include: behaviour_walk_rulefam
enddefine;

/* -- Rulefamilies -- */

define :rulefamily behaviour_walk_rulefam;
    ruleset: behaviour_walk_ruleset
    ruleset: behaviour_walk_stimulus_found_ruleset
    ruleset: behaviour_walk_active_ruleset
    ruleset: sys_suspend_ruleset1
enddefine;

/* -- Rulesets -- */

define :ruleset behaviour_walk_ruleset;

    [VARS sim_myself sim_myID blackboard];

    RULE sense_stimulus
        [INDATA ?blackboard [map freespace ?map]]
        ==>
        [stimulus_observed]
        [POP11
            sim_add_data([behaviour_stimulus_observed
                ^sim_myID stimulus ^(gl_stimulus(sim_myself))
                    effects ^^(gl_effects(sim_myself))], blackboard);
        ]
        [PUSHRULESET behaviour_walk_stimulus_found_ruleset]
enddefine;

define :ruleset behaviour_walk_stimulus_found_ruleset;

    [VARS sim_myself sim_myID blackboard];

    RULE walk_activate
        [INDATA ?blackboard [activate ?sender > ?sim_myID ?strength]] [->> cmd]
        ==>
        [INDATA ?blackboard [DEL ?cmd]]
        [POP11
            true -> gl_act_status(sim_myself);
            strength -> gl_act_level(sim_myself);
            sender -> gl_act_source(sim_myself);
        ]
        [PUSHRULESET behaviour_walk_active_ruleset]

    RULE walk_stimulus_removed
        [INDATA ?blackboard [NOT map freespace ==]]
        ==>
        [INDATA ?blackboard [NOT behaviour_stimulus_observed ?sim_myID ==]]
        [NOT stimulus_observed]
        [POPRULESET]
enddefine;

define :ruleset behaviour_walk_active_ruleset;

    [VARS sim_myself sim_myID blackboard];

    RULE walk_deactivate
        [INDATA ?blackboard [deactivate ?sender > ?sim_myID]] [->> cmd]
        ==>
        [INDATA ?blackboard [DEL ?cmd]]
        [NOT ==]
        [POP11
            false -> gl_act_status(sim_myself);
            0 -> gl_act_level(sim_myself);
        ]
        [POPRULESET]

    RULE walk_direction
        [move direction ?direction strength ?strength] [->> it]
        ==>
        [POP11
            lvars type, map;
            if strength < 1 then
                (direction + random(7) - 1) && 7 + 1 -> direction;
                max(5, intof(2 + 5*gl_act_level(sim_myself))) -> strength;
            else
                strength - 1 -> strength;
            endif;

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

            if direction <= 8 then
                sim_eval_data([PUSH {[FootMove ^direction] ^strength}
                            effector_foot], blackboard);
                sim_eval_data([PUSH {[EyeLook ^(round(direction/2))]
                        ^(gl_act_level(sim_myself))} effector_eye], blackboard);
            else
                0 -> strength;
            endif;
        ]
        [REPLACE ?it
                [move direction ?direction strength ?strength]]
        [PUSHRULESET sys_suspend_ruleset1]
        [STOP]

    RULE walk_valid
        [INDATA ?blackboard [map freespace ?map]]
        ==>
        [POP11
            lvars direction, strength;
            random(8) -> direction;
            max(5, intof(2 + 5*gl_act_level(sim_myself))) -> strength;

            if map(direction) /== 1 then
                if map(random(3) ->> direction) /== 1 then
                    for direction from 1 to 8 do
                        if map(direction) == 1 then
                            quitloop;
                        endif;
                    endfor;
                endif;
            endif;

            prb_add([move direction ^direction
                            strength ^strength]);

            sim_eval_data([PUSH {[FootMove ^direction]
                ^(gl_act_level(sim_myself))} effector_foot], blackboard);
            sim_eval_data([PUSH {[EyeLook ^(round(direction/2))]
                ^(gl_act_level(sim_myself))} effector_eye], blackboard);
        ]
        [PUSHRULESET sys_suspend_ruleset1]
        [STOP]

    RULE walk_invalid
        [stimulus_observed] [->> it]
        ==>
        [DEL ?it]
        [INDATA ?blackboard [NOT behaviour_stimulus_observed ?sim_myID ==]]
        [LVARS [sender = gl_act_source(sim_myself)]]
        [INDATA ?blackboard [message ?sim_myID > ?sender failed]]
        [STOP]

enddefine;



/* ====================================================================== */


/* --- Revision History ---------------------------------------------------

--- Steve Allen, Nov 22 2000
    uses INDATA and sim_myID

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
