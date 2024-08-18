/* -------------------------------------------------------------------------
   ---       Concern Processing in Autonomous Agents - PhD Thesis        ---
   ---                                                                   ---
   ---       Copyright (c) Steve Allen, 1998. All rights reserved.       ---
   -------------------------------------------------------------------------

   File:            body.p
   Author           Steve Allen, 4 Aug 2000 - (see revisions at EOF)
   Purpose:         Rules to define Abbott's body agents.

   Libraries:       LIB sim_agent, poprulebase, objectclass, rc_graphic
                    LIB (*local) gl_agent, gl_abbott

   Related Files:   control.p

*/

/* --- Introduction --------------------------------------------------------

This file contains the rules that define the body regulation agent if the
Abbott SoM model.

--------------------------------------------------------------------------*/

/* -- Extend search lists -- */

lvars filepath = sys_fname_path(popfilename);

extend_searchlist(filepath, popincludelist) -> popincludelist;
extend_searchlist(filepath, popuseslist) -> popuseslist;

/* -- System includes -- */

include gridland.ph;

uses gl_agent;
uses gl_abbott3;
uses int_parameters;

/***************************************************************************
Public functions writen in this module.

***************************************************************************/

vars procedure NewBodyRegulation;

vars procedure FootMove;
vars procedure MouthIngest;
vars procedure HandPlay;
vars procedure EyeLook;

/***************************************************************************
External functions accessed by this module.
Specify through module public interface include files or define explicitly.
***************************************************************************/

/* -- gl_agent -- */
vars GlNameAgent;

/* -- control.p -- */
vars procedure ExtractConditionKeys;
vars procedure DisplayEye;

/* -- abbott.p -- */
vars sys_suspend_ruleset;

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

/* -- Body Rulesystems -- */

vars body_regulation_rulesystem;

/**************************************************************************
Functions

***************************************************************************/

/* ====================================================================== */

/* -- Ruleset Vars -- */

vars body_regulation_ruleset;
vars body_regulation_rulefam;

/***************************************************************************
NAME
    NewBodyRegulation

SYNOPSIS
    NewBodyRegulation(parent, name);

FUNCTION
    Regulates Abbotts body state - normalising pain and temperature levels.

RETURNS
    None
***************************************************************************/

define vars procedure NewBodyRegulation(parent, name) /* -> agent */;
    lvars parent, name;
    lvars agent;

    newgl_body() -> agent;
    parent -> gl_parent(agent);
    "alive" -> sim_status(agent);
    GlNameAgent(agent, name);

    "body_regulator" -> gl_id(agent);

    sim_get_data(parent) -> sim_shared_data(agent);
    true -> gl_use_shared_data(agent);

    body_regulation_rulesystem -> sim_rulesystem(agent);

    ExtractConditionKeys(agent) -> gl_cond_filter(agent);
    [] -> gl_act_filter(agent);

    return(agent);
enddefine;

/* -- Rulesystem -- */

define :rulesystem body_regulation_rulesystem;
    include: body_regulation_rulefam
enddefine;

/* -- Rulefamilies -- */

define :rulefamily body_regulation_rulefam;
    ruleset: body_regulation_ruleset
    ruleset: sys_suspend_ruleset
enddefine;

/* -- Rulesets -- */

define :ruleset body_regulation_ruleset;

    RULE regulate
        ==>
        [POP11
            lvars map, diff;

            /* stabilise hormones */
            gl_adrenaline(sim_parent) - gl_adrenaline_sp(sim_parent) -> diff;
            if diff < -0.1 then
                GlIncBodyState(sim_parent, gl_adrenaline, 0.1);
            elseif diff > 0.1 then
                GlIncBodyState(sim_parent, gl_adrenaline, -0.1);
            endif;

            gl_noradrenaline(sim_parent) - gl_noradrenaline_sp(sim_parent) -> diff;
            if diff < -0.1 then
                GlIncBodyState(sim_parent, gl_noradrenaline, 0.1);
            elseif diff > 0.1 then
                GlIncBodyState(sim_parent, gl_noradrenaline, -0.1);
            endif;

            gl_dopamine(sim_parent) - gl_dopamine_sp(sim_parent) -> diff;
            if diff < -0.1 then
                GlIncBodyState(sim_parent, gl_dopamine, 0.1);
            elseif diff > 0.1 then
                GlIncBodyState(sim_parent, gl_dopamine, -0.1);
            endif;

            gl_endorphine(sim_parent) - gl_endorphine_sp(sim_parent) -> diff;
            if diff < -0.1 then
                GlIncBodyState(sim_parent, gl_endorphine, 0.1);
            elseif diff > 0.1 then
                GlIncBodyState(sim_parent, gl_endorphine, -0.1);
            endif;

            /* stabilise temperature */
            if gl_temperature(sim_parent) < gl_temperature_sp(sim_parent)
                                                                        then
                GlIncBodyState(sim_parent, gl_temperature, 0.1)
            else
                GlIncBodyState(sim_parent, gl_temperature, -0.1)
            endif;

            /* constantly uses water and food */
            GlIncBodyState(sim_parent, gl_vascular_volume, -0.05);
            GlIncBodyState(sim_parent, gl_blood_sugar, -0.05);

            /* resting increases energy */
            if gl_energy(sim_parent) < 120 then
                GlIncBodyState(sim_parent, gl_energy, 0.25);
                if sim_present_data(![map block ?map], blackboard) and
                        map(6) /== 0 then
                    GlIncBodyState(sim_parent, gl_energy, 2);
                endif;
            endif;

            /* decrease pain */
            if gl_pain(sim_parent) > 0 then
                if gl_pain(sim_parent) <= 0.2 then
                    GlIncBodyState(sim_parent, gl_pain,
                                        -gl_pain(sim_parent))
                else
                    GlIncBodyState(sim_parent, gl_pain, -0.2)
                endif;
            endif;

            /* decrease asifpain */
            if gl_asifpain(sim_parent) > 0 then
                if gl_asifpain(sim_parent) <= 1 then
                    GlIncBodyState(sim_parent, gl_asifpain,
                                        -gl_asifpain(sim_parent))
                else
                    GlIncBodyState(sim_parent, gl_asifpain, -1)
                endif;
            endif;
        ]
        [PUSHRULESET sys_suspend_ruleset]
        [STOP]
enddefine;

/* ====================================================================== */

lvars obj, x, y;

define :method EyeLook(agent:gl_abbott, heading);
    if heading /== 0 then
        DisplayEye(agent, heading);

        /* proprioceptive feedback */
        sim_flush_data([eye_position ==], sim_get_data(agent));
        prb_add_to_db([eye_position ^heading], sim_get_data(agent));
    endif;

    GlIncBodyState(agent, gl_energy, -0.3);

    /* sense eye */
    prb_add_to_db([sense eye], sim_get_data(agent));
enddefine;


define :method EyeLook(agent:gl_child, heading);
    EyeLook(gl_parent(agent), heading);
enddefine;

define :method FootMove(agent:gl_parent, heading);
    lvars agent, heading;

    if heading == 0 then return endif;

    /* move the agent */

    explode(gl_loc(agent)) -> (x, y);
    x + cell_to_x(heading) -> x;
    y + cell_to_y(heading) -> y;

    if gl_occupancy(GlGrid(x, y)) == 0 then
        GlMoveAgent(agent, x, y);
        GlIncBodyState(agent, gl_energy, -0.4);
        GlIncBodyState(agent, gl_blood_sugar, -0.1);
        GlIncBodyState(agent, gl_vascular_volume, -0.1);
    else
        GlIncBodyState(agent, gl_pain, 1);
        heading -> gl_pain_dir(agent);
    endif;

    heading -> gl_foot_heading(agent);

    /* sense foot */
    dlocal prb_database = sim_get_data(agent);
    prb_add([sense foot]);
    prb_flush([effector_foot ==]);
    prb_add([effector_foot]);

    /* sense eye */
    prb_add([sense eye]);
enddefine;

define :method FootMove(agent:gl_child, heading);
    FootMove(gl_parent(agent), heading);
enddefine;

define :method MouthIngest(agent:gl_abbott, heading);
    lvars agent, heading;

    explode(gl_loc(agent)) -> (x, y);
    x + cell_to_x(heading) -> x;
    y + cell_to_y(heading) -> y;

    if gl_organic((GlGrid(x, y) ->> obj)) > 0 then

        valof(gl_agent_id(obj)) -> obj;
        gl_Organic(obj) - 1 -> gl_Organic(obj);
        if isgl_body_state(obj) then
            (3 + heading) mod 8 + 1 -> gl_pain_dir(obj);
            GlIncBodyState(obj, gl_pain, 3);
            GlIncBodyState(obj, gl_adrenaline, 10);
        endif;

        gl_type(obj) -> obj;
        if obj == "water" then
            GlIncBodyState(agent, gl_vascular_volume, 5);
            GlIncBodyState(agent, gl_energy, 2);
            GlIncBodyState(agent, gl_temperature, -0.1);
        elseif obj == "food"  then
            GlIncBodyState(agent, gl_blood_sugar, 5);
            GlIncBodyState(agent, gl_energy, 2);
            GlIncBodyState(agent, gl_temperature, 0.2);
        elseif obj == "enemy" then
        endif;
    else
        heading -> gl_pain_dir(agent);
        GlIncBodyState(agent, gl_pain, 1);
    endif;

    /* sense eye */
    prb_add_to_db([sense eye], sim_get_data(agent));
enddefine;

define :method MouthIngest(agent:gl_child, heading);
    MouthIngest(gl_parent(agent), heading);
enddefine;

define :method HandPlay(agent:gl_abbott, heading);
    lvars agent, heading;

    explode(gl_loc(agent)) -> (x, y);
    x + cell_to_x(heading) -> x;
    y + cell_to_y(heading) -> y;

    if gl_occupancy(GlGrid(x, y) ->> obj) > 0 then

        gl_type(valof(gl_agent_id(obj))) -> obj;
        if lmember(obj, [line circle square rectangle triangle]) then
            GlIncBodyState(agent, gl_endorphine, 3);
        else
            heading -> gl_pain_dir(agent);
            GlIncBodyState(agent, gl_pain, 1);
        endif;
    else
        heading -> gl_pain_dir(agent);
        GlIncBodyState(agent, gl_pain, 1);
    endif;

    /* sense eye */
    prb_add_to_db([sense eye], sim_get_data(agent));
enddefine;

define :method HandPlay(agent:gl_child, heading);
    HandPlay(gl_parent(agent), heading);
enddefine;


/* ====================================================================== */

/* --- Revision History ---------------------------------------------------

--- Steve Allen, Nov 8 2000
    Moved actions to this file, keeping all external parts together.

--- Steve Allen, Aug 4 2000
    Preliminary support for new SIM_AGENT toolkit
    uses sim_shared_data().

--- Steve Allen, Nov 21 1998
    Standardised headers.

--- Steve Allen, Nov 18 1998
    Modified pain regulation to ensure that it always remains at or above
    zero.

--- Steve Allen, Nov 3 1998
    First written.
*/
