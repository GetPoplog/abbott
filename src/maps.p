/* -------------------------------------------------------------------------
   ---       Concern Processing in Autonomous Agents - PhD Thesis        ---
   ---                                                                   ---
   ---       Copyright (c) Steve Allen, 1998. All rights reserved.       ---
   -------------------------------------------------------------------------

   File:            maps.p
   Author           Steve Allen, 5 Aug 2000 - (see revisions at EOF)
   Purpose:         Rules to define Abbott's map agents.

   Libraries:       LIB sim_agent, poprulebase, objectclass, rc_graphic
                    LIB (*local) gl_agent, gl_abbott

   Related Files:   abbott.p

*/

/* --- Introduction --------------------------------------------------------

This file contains the rules that define the map agents for the Abbott
SoM model. Abbott's maps act as very simple perceptual recognisers.

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

vars procedure NewMapOccupancy;
vars procedure NewMapFreespace;
vars procedure NewMapWater;
vars procedure NewMapFood;
vars procedure NewMapLivingBeing;
vars procedure NewMapBlock;
vars procedure NewMapAbbott;
vars procedure NewMapEnemy;

/***************************************************************************
External functions accessed by this module.
Specify through module public interface include files or define explicitly.
***************************************************************************/

/* -- gl_agent -- */

vars GlNameAgent;

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
vars sim_cycle_number;

/* -- Maps -- */

vars map_occupancy_rulesystem;
vars map_freespace_rulesystem;
vars map_water_rulesystem;
vars map_food_rulesystem;
vars map_living_being_rulesystem;
vars map_block_rulesystem;
vars map_abbott_rulesystem;
vars map_enemy_rulesystem;

/**************************************************************************
Functions

***************************************************************************/

define lvars procedure BuildMap(/* data */ match, bit, len, map);
    lvars match, bit, len;
    lvars i;

    fast_for i from len by -1 to 1 do
        if lmember(match) then
            bit
        else
            bit ||/& 1
        endif -> map(i);
    endfor;
enddefine;


/* ====================================================================== */

define vars procedure NewMapOccupancy(parent, name) /* -> agent */;
    lvars parent, name;
    lvars agent;

    newgl_map() -> agent;
    parent -> gl_parent(agent);
    "alive" -> sim_status(agent);
    GlNameAgent(agent, name);

    sim_get_data(parent) -> sim_shared_data(agent);
    true -> gl_use_shared_data(agent);

    "occupancy_map" -> gl_id(agent);
    initbitvector(8) -> gl_value(agent);

    map_occupancy_rulesystem -> sim_rulesystem(agent);
    return(agent);
enddefine;

/* -- Ruleset Vars -- */

vars map_occupancy_ruleset;

/* -- Rulesystem -- */

define :rulesystem map_occupancy_rulesystem;
    include: map_occupancy_rulefam
enddefine;

/* -- Rulefamilies -- */

define :rulefamily map_occupancy_rulefam;
    ruleset: map_occupancy_ruleset
    ruleset: sys_suspend_ruleset
enddefine;

/* -- Rulesets -- */

define :ruleset map_occupancy_ruleset;

    RULE map_occupancy
        [dneme topleft ?topleft]
        [dneme top ?top]
        [dneme topright ?topright]
        [dneme right ?right]
        [dneme bottomright ?bottomright]
        [dneme bottom ?bottom]
        [dneme bottomleft ?bottomleft]
        [dneme left ?left]
        ==>
        [NOT map occupancy ==]
        [POP11
            BuildMap(topleft, top, topright, right, bottomright, bottom,
                    bottomleft, left, ["unoccupied"], 0, 8,
                        gl_value(sim_myself));

            if fast_subscrbytevector(1, gl_value(sim_myself)) /== 0 then
                prb_add([map occupancy ^(gl_value(sim_myself))]);
            endif;
        ]
        [PUSHRULESET sys_suspend_ruleset]
        [STOP]
enddefine;

/* ====================================================================== */

define vars procedure NewMapFreespace(parent, name) /* -> agent */;
    lvars parent, name;
    lvars agent;

    newgl_map() -> agent;
    parent -> gl_parent(agent);
    "alive" -> sim_status(agent);
    GlNameAgent(agent, name);

    sim_get_data(parent) -> sim_shared_data(agent);
    true -> gl_use_shared_data(agent);

    "freespace_map" -> gl_id(agent);
    initbitvector(8) -> gl_value(agent);

    map_freespace_rulesystem -> sim_rulesystem(agent);
    return(agent);
enddefine;

/* -- Ruleset Vars -- */

vars map_freespace_ruleset;

/* -- Rulesystem -- */

define :rulesystem map_freespace_rulesystem;
    include: map_freespace_rulefam
enddefine;

/* -- Rulefamilies -- */

define :rulefamily map_freespace_rulefam;
    ruleset: map_freespace_ruleset
    ruleset: sys_suspend_ruleset
enddefine;

/* -- Rulesets -- */

define :ruleset map_freespace_ruleset;

    RULE map_freespace
        [dneme topleft ?topleft]
        [dneme top ?top]
        [dneme topright ?topright]
        [dneme right ?right]
        [dneme bottomright ?bottomright]
        [dneme bottom ?bottom]
        [dneme bottomleft ?bottomleft]
        [dneme left ?left]
        ==>
        [NOT map freespace ==]
        [POP11
            BuildMap(topleft, top, topright, right, bottomright, bottom,
                    bottomleft, left, ["unoccupied"], 0, 8,
                        gl_value(sim_myself));

            255 - fast_subscrbytevector(1, gl_value(sim_myself)) ->
                            fast_subscrbytevector(1, gl_value(sim_myself));
            if fast_subscrbytevector(1, gl_value(sim_myself)) /== 0 then
                prb_add([map freespace ^(gl_value(sim_myself))]);
            endif;
        ]
        [PUSHRULESET sys_suspend_ruleset]
        [STOP]
enddefine;

/* ====================================================================== */

define vars procedure NewMapWater(parent, name) /* -> agent */;
    lvars parent, name;
    lvars agent;

    newgl_map() -> agent;
    parent -> gl_parent(agent);
    "alive" -> sim_status(agent);
    GlNameAgent(agent, name);

    sim_get_data(parent) -> sim_shared_data(agent);
    true -> gl_use_shared_data(agent);

    "water_map" -> gl_id(agent);
    initbitvector(8) -> gl_value(agent);

    map_water_rulesystem -> sim_rulesystem(agent);
    ExtractConditionKeys(agent) -> gl_cond_filter(agent);
    [[map water]] -> gl_act_filter(agent);
    return(agent);
enddefine;

/* -- Ruleset Vars -- */

vars map_water_ruleset;

/* -- Rulesystem -- */

define :rulesystem map_water_rulesystem;
    include: map_water_rulefam
enddefine;

/* -- Rulefamilies -- */

define :rulefamily map_water_rulefam;
    ruleset: map_water_ruleset
    ruleset: sys_suspend_ruleset
enddefine;

/* -- Rulesets -- */

define :ruleset map_water_ruleset;

    RULE map_water
        [dneme topleft ?topleft]
        [dneme top ?top]
        [dneme topright ?topright]
        [dneme right ?right]
        [dneme bottomright ?bottomright]
        [dneme bottom ?bottom]
        [dneme bottomleft ?bottomleft]
        [dneme left ?left]
        ==>
        [NOT map water ==]
        [POP11
            BuildMap(topleft, top, topright, right, bottomright, bottom,
                        bottomleft, left, ["water"], 1, 8,
                                            gl_value(sim_myself));

            if fast_subscrbytevector(1, gl_value(sim_myself)) /== 0 then
                prb_add([map water ^(gl_value(sim_myself))]);
            endif;
        ]
        [PUSHRULESET sys_suspend_ruleset]
        [STOP]
enddefine;
/* ====================================================================== */

define vars procedure NewMapFood(parent, name) /* -> agent */;
    lvars parent, name;
    lvars agent;

    newgl_map() -> agent;
    parent -> gl_parent(agent);
    "alive" -> sim_status(agent);
    GlNameAgent(agent, name);

    sim_get_data(parent) -> sim_shared_data(agent);
    true -> gl_use_shared_data(agent);

    "food_map" -> gl_id(agent);
    initbitvector(8) -> gl_value(agent);

    map_food_rulesystem -> sim_rulesystem(agent);
    return(agent);
enddefine;

/* -- Ruleset Vars -- */

vars map_food_ruleset;

/* -- Rulesystem -- */

define :rulesystem map_food_rulesystem;
    include: map_food_rulefam
enddefine;

/* -- Rulefamilies -- */

define :rulefamily map_food_rulefam;
    ruleset: map_food_ruleset
    ruleset: sys_suspend_ruleset
enddefine;

/* -- Rulesets -- */

define :ruleset map_food_ruleset;

    RULE map_food
        [dneme topleft ?topleft]
        [dneme top ?top]
        [dneme topright ?topright]
        [dneme right ?right]
        [dneme bottomright ?bottomright]
        [dneme bottom ?bottom]
        [dneme bottomleft ?bottomleft]
        [dneme left ?left]
        ==>
        [NOT map food ==]
        [POP11
            BuildMap(topleft, top, topright, right, bottomright, bottom,
                        bottomleft, left, ["food"], 1, 8,
                                        gl_value(sim_myself));

            if fast_subscrbytevector(1, gl_value(sim_myself)) /== 0 then
                prb_add([map food ^(gl_value(sim_myself))]);
            endif;
        ]
        [PUSHRULESET sys_suspend_ruleset]
        [STOP]
enddefine;
/* ====================================================================== */

define vars procedure NewMapLivingBeing(parent, name) /* -> agent */;
    lvars parent, name;
    lvars agent;

    newgl_map() -> agent;
    parent -> gl_parent(agent);
    "alive" -> sim_status(agent);
    GlNameAgent(agent, name);

    sim_get_data(parent) -> sim_shared_data(agent);
    true -> gl_use_shared_data(agent);

    "living_being_map" -> gl_id(agent);
    initbitvector(8) -> gl_value(agent);

    map_living_being_rulesystem -> sim_rulesystem(agent);
    return(agent);
enddefine;

/* -- Ruleset Vars -- */

vars map_living_being_ruleset;

/* -- Rulesystem -- */

define :rulesystem map_living_being_rulesystem;
    include: map_living_being_rulefam
enddefine;

/* -- Rulefamilies -- */

define :rulefamily map_living_being_rulefam;
    ruleset: map_living_being_ruleset
    ruleset: sys_suspend_ruleset
enddefine;

/* -- Rulesets -- */

define :ruleset map_living_being_ruleset;

    RULE map_living_being
        [dneme topleft ?topleft]
        [dneme top ?top]
        [dneme topright ?topright]
        [dneme right ?right]
        [dneme bottomright ?bottomright]
        [dneme bottom ?bottom]
        [dneme bottomleft ?bottomleft]
        [dneme left ?left]
        ==>
        [NOT map living_being ==]
        [POP11
            BuildMap(topleft, top, topright, right, bottomright, bottom,
                bottomleft, left, ["enemy" "abbott" "living_being"],
                                            1, 8, gl_value(sim_myself));

            if fast_subscrbytevector(1, gl_value(sim_myself)) /== 0 then
                prb_add([map living_being ^(gl_value(sim_myself))]);
            endif;
        ]
        [PUSHRULESET sys_suspend_ruleset]
        [STOP]
enddefine;
/* ====================================================================== */

define vars procedure NewMapBlock(parent, name) /* -> agent */;
    lvars parent, name;
    lvars agent;

    newgl_map() -> agent;
    parent -> gl_parent(agent);
    "alive" -> sim_status(agent);
    GlNameAgent(agent, name);

    sim_get_data(parent) -> sim_shared_data(agent);
    true -> gl_use_shared_data(agent);

    "block_map" -> gl_id(agent);
    initbitvector(8) -> gl_value(agent);

    map_block_rulesystem -> sim_rulesystem(agent);
    return(agent);
enddefine;

/* -- Ruleset Vars -- */

vars map_block_ruleset;

/* -- Rulesystem -- */

define :rulesystem map_block_rulesystem;
    include: map_block_rulefam
enddefine;

/* -- Rulefamilies -- */

define :rulefamily map_block_rulefam;
    ruleset: map_block_ruleset
    ruleset: sys_suspend_ruleset
enddefine;

/* -- Rulesets -- */

define :ruleset map_block_ruleset;

    RULE map_block
        [dneme topleft ?topleft]
        [dneme top ?top]
        [dneme topright ?topright]
        [dneme right ?right]
        [dneme bottomright ?bottomright]
        [dneme bottom ?bottom]
        [dneme bottomleft ?bottomleft]
        [dneme left ?left]
        ==>
        [NOT map block ==]
        [POP11
            BuildMap(topleft, top, topright, right, bottomright, bottom,
                bottomleft, left, ["block"], 1, 8,
                                        gl_value(sim_myself));

            if fast_subscrbytevector(1, gl_value(sim_myself)) /== 0 then
                prb_add([map block ^(gl_value(sim_myself))]);
            endif;
        ]
        [PUSHRULESET sys_suspend_ruleset]
        [STOP]
enddefine;

/* ====================================================================== */

define vars procedure NewMapEnemy(parent, name) /* -> agent */;
    lvars parent, name;
    lvars agent;

    newgl_map() -> agent;
    parent -> gl_parent(agent);
    "alive" -> sim_status(agent);
    GlNameAgent(agent, name);

    sim_get_data(parent) -> sim_shared_data(agent);
    true -> gl_use_shared_data(agent);

    "enemy_map" -> gl_id(agent);
    initbitvector(8) -> gl_value(agent);

    map_enemy_rulesystem -> sim_rulesystem(agent);
    return(agent);
enddefine;

/* -- Ruleset Vars -- */

vars map_enemy_ruleset;

/* -- Rulesystem -- */

define :rulesystem map_enemy_rulesystem;
    include: map_enemy_rulefam
enddefine;

/* -- Rulefamilies -- */

define :rulefamily map_enemy_rulefam;
    ruleset: map_enemy_ruleset
    ruleset: sys_suspend_ruleset
enddefine;

/* -- Rulesets -- */

define :ruleset map_enemy_ruleset;

    RULE map_enemy
        [dneme topleft ?topleft]
        [dneme top ?top]
        [dneme topright ?topright]
        [dneme right ?right]
        [dneme bottomright ?bottomright]
        [dneme bottom ?bottom]
        [dneme bottomleft ?bottomleft]
        [dneme left ?left]
        ==>
        [NOT map enemy ==]
        [POP11
            BuildMap(topleft, top, topright, right, bottomright, bottom,
                bottomleft, left, ["enemy"], 1, 8,
                                        gl_value(sim_myself));

            if fast_subscrbytevector(1, gl_value(sim_myself)) /== 0 then
                prb_add([map enemy ^(gl_value(sim_myself))]);
            endif;
        ]
        [PUSHRULESET sys_suspend_ruleset]
        [STOP]
enddefine;

/* ====================================================================== */

define vars procedure NewMapAbbott(parent, name) /* -> agent */;
    lvars parent, name;
    lvars agent;

    newgl_map() -> agent;
    parent -> gl_parent(agent);
    "alive" -> sim_status(agent);
    GlNameAgent(agent, name);

    sim_get_data(parent) -> sim_shared_data(agent);
    true -> gl_use_shared_data(agent);

    "abbott_map" -> gl_id(agent);
    initbitvector(8) -> gl_value(agent);

    map_abbott_rulesystem -> sim_rulesystem(agent);
    return(agent);
enddefine;

/* -- Ruleset Vars -- */

vars map_abbott_ruleset;

/* -- Rulesystem -- */

define :rulesystem map_abbott_rulesystem;
    include: map_abbott_rulefam
enddefine;

/* -- Rulefamilies -- */

define :rulefamily map_abbott_rulefam;
    ruleset: map_abbott_ruleset
    ruleset: sys_suspend_ruleset
enddefine;

/* -- Rulesets -- */

define :ruleset map_abbott_ruleset;

    RULE map_block
        [dneme topleft ?topleft]
        [dneme top ?top]
        [dneme topright ?topright]
        [dneme right ?right]
        [dneme bottomright ?bottomright]
        [dneme bottom ?bottom]
        [dneme bottomleft ?bottomleft]
        [dneme left ?left]
        ==>
        [NOT map abbott ==]
        [POP11
            BuildMap(topleft, top, topright, right, bottomright, bottom,
                bottomleft, left, ["abbott"], 1, 8,
                                        gl_value(sim_myself));

            if fast_subscrbytevector(1, gl_value(sim_myself)) /== 0 then
                prb_add([map abbott ^(gl_value(sim_myself))]);
            endif;
        ]
        [PUSHRULESET sys_suspend_ruleset]
        [STOP]
enddefine;


/* ====================================================================== */


/* --- Revision History ---------------------------------------------------

--- Steve Allen, Aug 5 2000
    Added support for SIM_AGENT toolkit

--- Steve Allen, Nov 19 1998
    Standardised headers.

--- Steve Allen, Jun 1 1998
    First written.
*/
