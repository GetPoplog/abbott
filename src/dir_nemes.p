/* -------------------------------------------------------------------------
   ---       Concern Processing in Autonomous Agents - PhD Thesis        ---
   ---                                                                   ---
   ---       Copyright (c) Steve Allen, 1998. All rights reserved.       ---
   -------------------------------------------------------------------------

   File:            dir_nemes.p
   Author           Steve Allen, 4 Aug 2000 - (see revisions at EOF)
   Purpose:         Rules to define Abbott's direction neme agents.

   Libraries:       LIB sim_agent, poprulebase, objectclass, rc_graphic
                    LIB (*local) gl_agent, gl_abbott

   Related Files:   abbott.p

*/

/* --- Introduction --------------------------------------------------------

This file contains the rules that define the direction neme agents of the
Abbott SoM model. These agents take the tactile and visual sensor
information and perform simple object recognition/classification tasks
on their respective cells.

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

vars procedure NewDirTopLeft;
vars procedure NewDirTop;
vars procedure NewDirTopRight;
vars procedure NewDirRight;
vars procedure NewDirBottomRight;
vars procedure NewDirBottom;
vars procedure NewDirBottomLeft;
vars procedure NewDirLeft;

vars procedure VisualIndexOf;
vars procedure TactileIndexOf;

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

/* -- Directions -- */

vars dir_topleft_rulesystem;
vars dir_topleft_rulefam;
vars dir_topleft_ruleset;
vars dir_top_rulesystem;
vars dir_top_rulefam;
vars dir_top_ruleset;
vars dir_topright_rulesystem;
vars dir_topright_rulefam;
vars dir_topright_ruleset;
vars dir_right_rulesystem;
vars dir_right_rulefam;
vars dir_right_ruleset;
vars dir_bottomright_rulesystem;
vars dir_bottomright_rulefam;
vars dir_bottomright_ruleset;
vars dir_bottom_rulesystem;
vars dir_bottom_rulefam;
vars dir_bottom_ruleset;
vars dir_bottomleft_rulesystem;
vars dir_bottomleft_rulefam;
vars dir_bottomleft_ruleset;
vars dir_left_rulesystem;
vars dir_left_rulefam;
vars dir_left_ruleset;

/**************************************************************************
Functions

***************************************************************************/

/* ====================================================================== */

define vars procedure VisualIndexOf(pattern) /* -> index */;
    lvars pattern;

    switchon pattern
        case == 0 then
            return("unoccupied");
        case == 1 then
            return("wall");
        case == 8 then
            return("water");
        case == 6 then
            return("food");
        case == 3 then
            return("block");
        case == 4 then
            return("block");
        case == 11 then
            return("abbott");
        case == 14 then
            return("enemy");
    endswitchon;
    return("unknown");
enddefine;

/* ====================================================================== */

define vars procedure TactileIndexOf(pattern) /* -> index */;
    lvars pattern;

    switchon pattern
        case == 18 then
            return("water");
        case == 33 then
            return("food");
        case == 49 then
            return("living_being");
        case == 65 then
            return("block");
        case == 66 then
            return("block");
        case == 81 then
            return("wall");
    endswitchon;

    if pattern && 3 == 0 then
        return("unoccupied");
    endif;

    return("unknown");
enddefine;

/* ====================================================================== */

define vars procedure NewDirTopLeft(parent, name) /* -> agent */;
    lvars parent, name;
    lvars agent;

    newgl_direction() -> agent;
    parent -> gl_parent(agent);
    "alive" -> sim_status(agent);
    GlNameAgent(agent, name);

    sim_get_data(parent) -> sim_shared_data(agent);
    true -> gl_use_shared_data(agent);

    "TopLeft" -> gl_id(agent);

    dir_topleft_rulesystem -> sim_rulesystem(agent);
    ExtractConditionKeys(agent) -> gl_cond_filter(agent);
    [[dneme topleft]] -> gl_act_filter(agent);
    return(agent);
enddefine;

/* -- Rulesystem -- */

define :rulesystem dir_topleft_rulesystem;
    include: dir_topleft_rulefam
enddefine;

/* -- Rulefamilies -- */

define :rulefamily dir_topleft_rulefam;
    ruleset: dir_topleft_ruleset
    ruleset: sys_suspend_ruleset
enddefine;

/* -- Rulesets -- */

define :ruleset dir_topleft_ruleset;

    RULE dir_topleft
        [sensor occupancy value ?occ_value]
        [sensor hardness value ?har_value]
        [sensor brightness value ?bri_value]
        ==>
        [NOT dneme topleft ==]
        [POP11
            if bri_value(1) /== 0 then
                prb_add([dneme topleft ^(VisualIndexOf(bri_value(1)))]);
            else
                prb_add([dneme topleft ^(TactileIndexOf(har_value(1) << 4
                    + occ_value(1)))]);
            endif;
        ]
        [PUSHRULESET sys_suspend_ruleset]
        [STOP]
enddefine;


/* ====================================================================== */

define vars procedure NewDirTop(parent, name) /* -> agent */;
    lvars parent, name;
    lvars agent;

    newgl_direction() -> agent;
    parent -> gl_parent(agent);
    "alive" -> sim_status(agent);
    GlNameAgent(agent, name);

    sim_get_data(parent) -> sim_shared_data(agent);
    true -> gl_use_shared_data(agent);

    "top" -> gl_id(agent);

    dir_top_rulesystem -> sim_rulesystem(agent);
    ExtractConditionKeys(agent) -> gl_cond_filter(agent);
    [[dneme top]] -> gl_act_filter(agent);
    return(agent);
enddefine;

/* -- Rulesystem -- */

define :rulesystem dir_top_rulesystem;
    include: dir_top_rulefam
enddefine;

/* -- Rulefamilies -- */

define :rulefamily dir_top_rulefam;
    ruleset: dir_top_ruleset
    ruleset: sys_suspend_ruleset
enddefine;

/* -- Rulesets -- */

define :ruleset dir_top_ruleset;

    RULE dir_top
        [sensor occupancy value ?occ_value]
        [sensor hardness value ?har_value]
        [sensor brightness value ?bri_value]
        ==>
        [NOT dneme top ==]
        [POP11
            if bri_value(2) /== 0 then
                prb_add([dneme top ^(VisualIndexOf(bri_value(2)))]);
            else
                prb_add([dneme top ^(TactileIndexOf(har_value(2) << 4 +
                    occ_value(2)))]);
            endif;
        ]
        [PUSHRULESET sys_suspend_ruleset]
        [STOP]
enddefine;

/* ====================================================================== */

define vars procedure NewDirTopRight(parent, name) /* -> agent */;
    lvars parent, name;
    lvars agent;

    newgl_direction() -> agent;
    parent -> gl_parent(agent);
    "alive" -> sim_status(agent);
    GlNameAgent(agent, name);

    sim_get_data(parent) -> sim_shared_data(agent);
    true -> gl_use_shared_data(agent);

    "top_right" -> gl_id(agent);

    dir_topright_rulesystem -> sim_rulesystem(agent);
    ExtractConditionKeys(agent) -> gl_cond_filter(agent);
    [[dneme topright]] -> gl_act_filter(agent);
    return(agent);
enddefine;

/* -- Rulesystem -- */

define :rulesystem dir_topright_rulesystem;
    include: dir_topright_rulefam
enddefine;

/* -- Rulefamilies -- */

define :rulefamily dir_topright_rulefam;
    ruleset: dir_topright_ruleset
    ruleset: sys_suspend_ruleset
enddefine;

/* -- Rulesets -- */

define :ruleset dir_topright_ruleset;

    RULE dir_topright
        [sensor occupancy value ?occ_value]
        [sensor hardness value ?har_value]
        [sensor brightness value ?bri_value]
        ==>
        [NOT dneme topright ==]
        [POP11
            if bri_value(3) /== 0 then
                prb_add([dneme topright ^(VisualIndexOf(bri_value(3)))]);
            else
                prb_add([dneme topright ^(TactileIndexOf(har_value(3) << 4
                    + occ_value(3)))]);
            endif;
        ]
        [PUSHRULESET sys_suspend_ruleset]
        [STOP]
enddefine;

/* ====================================================================== */

define vars procedure NewDirRight(parent, name) /* -> agent */;
    lvars parent, name;
    lvars agent;

    newgl_direction() -> agent;
    parent -> gl_parent(agent);
    "alive" -> sim_status(agent);
    GlNameAgent(agent, name);

    sim_get_data(parent) -> sim_shared_data(agent);
    true -> gl_use_shared_data(agent);

    "right" -> gl_id(agent);

    dir_right_rulesystem -> sim_rulesystem(agent);
    ExtractConditionKeys(agent) -> gl_cond_filter(agent);
    [[dneme right]] -> gl_act_filter(agent);
    return(agent);
enddefine;

/* -- Rulesystem -- */

define :rulesystem dir_right_rulesystem;
    include: dir_right_rulefam
enddefine;

/* -- Rulefamilies -- */

define :rulefamily dir_right_rulefam;
    ruleset: dir_right_ruleset
    ruleset: sys_suspend_ruleset
enddefine;

/* -- Rulesets -- */

define :ruleset dir_right_ruleset;

    RULE dir_right
        [sensor occupancy value ?occ_value]
        [sensor hardness value ?har_value]
        [sensor brightness value ?bri_value]
        ==>
        [NOT dneme right ==]
        [POP11
            if bri_value(4) /== 0 then
                prb_add([dneme right ^(VisualIndexOf(bri_value(4)))]);
            else
                prb_add([dneme right ^(TactileIndexOf(har_value(4) << 4
                    + occ_value(4)))]);
            endif;
        ]
        [PUSHRULESET sys_suspend_ruleset]
        [STOP]
enddefine;

/* ====================================================================== */

define vars procedure NewDirBottomRight(parent, name) /* -> agent */;
    lvars parent, name;
    lvars agent;

    newgl_direction() -> agent;
    parent -> gl_parent(agent);
    "alive" -> sim_status(agent);
    GlNameAgent(agent, name);

    sim_get_data(parent) -> sim_shared_data(agent);
    true -> gl_use_shared_data(agent);

    "bottom_right" -> gl_id(agent);

    dir_bottomright_rulesystem -> sim_rulesystem(agent);
    ExtractConditionKeys(agent) -> gl_cond_filter(agent);
    [[dneme bottomright]] -> gl_act_filter(agent);
    return(agent);
enddefine;

/* -- Rulesystem -- */

define :rulesystem dir_bottomright_rulesystem;
    include: dir_bottomright_rulefam
enddefine;

/* -- Rulefamilies -- */

define :rulefamily dir_bottomright_rulefam;
    ruleset: dir_bottomright_ruleset
    ruleset: sys_suspend_ruleset
enddefine;

/* -- Rulesets -- */

define :ruleset dir_bottomright_ruleset;

    RULE dir_bottomright
        [sensor occupancy value ?occ_value]
        [sensor hardness value ?har_value]
        [sensor brightness value ?bri_value]
        ==>
        [NOT dneme bottomright ==]
        [POP11
            if bri_value(5) /== 0 then
                prb_add([dneme bottomright ^(VisualIndexOf(bri_value(5)))]);
            else
                prb_add([dneme bottomright ^(TactileIndexOf(har_value(5)
                    << 4 + occ_value(5)))]);
            endif;
        ]
        [PUSHRULESET sys_suspend_ruleset]
        [STOP]
enddefine;

/* ====================================================================== */

define vars procedure NewDirBottom(parent, name) /* -> agent */;
    lvars parent, name;
    lvars agent;

    newgl_direction() -> agent;
    parent -> gl_parent(agent);
    "alive" -> sim_status(agent);
    GlNameAgent(agent, name);

    sim_get_data(parent) -> sim_shared_data(agent);
    true -> gl_use_shared_data(agent);

    "bottom" -> gl_id(agent);

    dir_bottom_rulesystem -> sim_rulesystem(agent);
    ExtractConditionKeys(agent) -> gl_cond_filter(agent);
    [[dneme bottom]] -> gl_act_filter(agent);
    return(agent);
enddefine;

/* -- Rulesystem -- */

define :rulesystem dir_bottom_rulesystem;
    include: dir_bottom_rulefam
enddefine;

/* -- Rulefamilies -- */

define :rulefamily dir_bottom_rulefam;
    ruleset: dir_bottom_ruleset
    ruleset: sys_suspend_ruleset
enddefine;

/* -- Rulesets -- */

define :ruleset dir_bottom_ruleset;

    RULE dir_bottom
        [sensor occupancy value ?occ_value]
        [sensor hardness value ?har_value]
        [sensor brightness value ?bri_value]
        ==>
        [NOT dneme bottom ==]
        [POP11
            if bri_value(6) /== 0 then
                prb_add([dneme bottom ^(VisualIndexOf(bri_value(6)))]);
            else
                prb_add([dneme bottom ^(TactileIndexOf(har_value(6) << 4
                    + occ_value(6)))]);
            endif;
        ]
        [PUSHRULESET sys_suspend_ruleset]
        [STOP]
enddefine;

/* ====================================================================== */

define vars procedure NewDirBottomLeft(parent, name) /* -> agent */;
    lvars parent, name;
    lvars agent;

    newgl_direction() -> agent;
    parent -> gl_parent(agent);
    "alive" -> sim_status(agent);
    GlNameAgent(agent, name);

    sim_get_data(parent) -> sim_shared_data(agent);
    true -> gl_use_shared_data(agent);

    "bottom_left" -> gl_id(agent);

    dir_bottomleft_rulesystem -> sim_rulesystem(agent);
    ExtractConditionKeys(agent) -> gl_cond_filter(agent);
    [[dneme bottomleft]] -> gl_act_filter(agent);
    return(agent);
enddefine;

/* -- Rulefamilies -- */

define :rulefamily dir_bottomleft_rulefam;
    ruleset: dir_bottomleft_ruleset
    ruleset: sys_suspend_ruleset
enddefine;

/* -- Rulesystem -- */

define :rulesystem dir_bottomleft_rulesystem;
    include: dir_bottomleft_rulefam
enddefine;

/* -- Rulesets -- */

define :ruleset dir_bottomleft_ruleset;

    RULE dir_bottomleft
        [sensor occupancy value ?occ_value]
        [sensor hardness value ?har_value]
        [sensor brightness value ?bri_value]
        ==>
        [NOT dneme bottomleft ==]
        [POP11
            if bri_value(7) /== 0 then
                prb_add([dneme bottomleft ^(VisualIndexOf(bri_value(7)))]);
            else
                prb_add([dneme bottomleft ^(TactileIndexOf(har_value(7)
                    << 4 + occ_value(7)))]);
            endif;
        ]
        [PUSHRULESET sys_suspend_ruleset]
        [STOP]
enddefine;


/* ====================================================================== */

define vars procedure NewDirLeft(parent, name) /* -> agent */;
    lvars parent, name;
    lvars agent;

    newgl_direction() -> agent;
    parent -> gl_parent(agent);
    "alive" -> sim_status(agent);
    GlNameAgent(agent, name);

    sim_get_data(parent) -> sim_shared_data(agent);
    true -> gl_use_shared_data(agent);

    "left" -> gl_id(agent);

    dir_left_rulesystem -> sim_rulesystem(agent);
    ExtractConditionKeys(agent) -> gl_cond_filter(agent);
    [[dneme left]] -> gl_act_filter(agent);
    return(agent);
enddefine;

/* -- Rulesystem -- */

define :rulesystem dir_left_rulesystem;
    include: dir_left_rulefam
enddefine;

/* -- Rulefamilies -- */

define :rulefamily dir_left_rulefam;
    ruleset: dir_left_ruleset
    ruleset: sys_suspend_ruleset
enddefine;

/* -- Rulesets -- */

define :ruleset dir_left_ruleset;

    RULE dir_left
        [sensor occupancy value ?occ_value]
        [sensor hardness value ?har_value]
        [sensor brightness value ?bri_value]
        ==>
        [NOT dneme left ==]
        [POP11
            if bri_value(8) /== 0 then
                prb_add([dneme left ^(VisualIndexOf(bri_value(8)))]);
            else
                prb_add([dneme left ^(TactileIndexOf(har_value(8) << 4
                    + occ_value(8)))]);
            endif;
        ]
        [PUSHRULESET sys_suspend_ruleset]
        [STOP]
enddefine;

/* ====================================================================== */

/* --- Revision History ---------------------------------------------------

--- Steve Allen, Aug 4 2000
    Preliminary support for new SIM_AGENT toolkit
    uses sim_shared_data().

--- Steve Allen, Nov 19 1998
    Standardised headers.

--- Steve Allen, Jun 1 1998
    First written.
*/
