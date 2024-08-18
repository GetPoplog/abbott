/* -------------------------------------------------------------------------
   ---       Concern Processing in Autonomous Agents - PhD Thesis        ---
   ---                                                                   ---
   ---       Copyright (c) Steve Allen, 1998. All rights reserved.       ---
   -------------------------------------------------------------------------

   File:            enemy.p
   Author           Steve Allen, 19 Nov 1998 - (see revisions at EOF)
   Purpose:         Rules to define the actions of "enemy" agents.

   Libraries:       LIB sim_agent, poprulebase, objectclass, rc_graphic
                    LIB (*local) gl_agent, gl_abbott

   Related Files:   control.p

*/

/* --- Introduction --------------------------------------------------------

This file contains the rules that define the actions of "enemy" agents in
the Gridland world. Enemies have three basic behaviours: (i) walking; (ii)
eating; and (iii) withdrawing when bitten.

--------------------------------------------------------------------------*/

/* -- System includes -- */

include gridland.ph;

uses gl_agent;
uses gl_abbott3;

/***************************************************************************
Public functions writen in this module.

    :rulesystem enemy_rulesystem
        :ruleset en_cleanup_ruleset
        :ruleset en_motor_map_ruleset
        :ruleset en_behaviour_ruleset

    define vars procedure EnMove(agent, heading);
    define vars procedure EnEat(agent, organic_svec);
***************************************************************************/

vars procedure EnMove;
vars procedure EnEat;

/***************************************************************************
External functions accessed by this module.
Specify through module public interface include files or define explicitly.
***************************************************************************/

/* -- agent.p -- */

vars procedure GlMoveAgent;
vars procedure GlRefreshAgent;
vars procedure GlGrid;

/***************************************************************************
Private functions in this module.
Define as lexical.
***************************************************************************/


/***************************************************************************
Private macros and constants.
***************************************************************************/

/***************************************************************************
Global data declared in this module.
Extern definitions for any external global data used by this module.
File wide static dtata.

***************************************************************************/


/**************************************************************************
Public Functions
***************************************************************************/

define :rulesystem enemy_rulesystem;

    cycle_limit = 1;                ;;; default cycle limit

    include: en_sensors_ruleset
    include: en_motor_map_ruleset
    include: en_behaviour_ruleset
    include: en_cleanup
enddefine;

lconstant orgvec = initnibblevector(8);
lconstant occvec = initnibblevector(8);
define :ruleset en_sensors_ruleset;

    RULE en_sensors
        [clock_tick]
        ==>
        [POP11
            lvars i, x, y;
            lvars (oldx, oldy) = explode(gl_loc(sim_myself));

            if gl_pain(sim_myself) > 0 then
                prb_add([new_sense_data pain ^(gl_pain(sim_myself))
                                heading ^(gl_pain_dir(sim_myself))]);
            endif;

            fast_for i from 1 to 8 do
                oldx + cell_to_x(i) -> x;
                oldy + cell_to_y(i) -> y;
                if (i && 1) == 0 then
                    gl_organic(GlGrid(x, y)) -> orgvec(i);
                endif;
                gl_occupancy(GlGrid(x, y)) -> occvec(i);
            endfor;

            if fast_subscrbit32vector(1, occvec) /== 0 then
                prb_add([new_sense_data occupancy ^occvec]);
            endif;

            if fast_subscrbit32vector(1, orgvec) /== 0 then
                prb_add([new_sense_data organic ^orgvec]);
            endif;
        ]
        [STOP]
enddefine;

define :ruleset en_cleanup;

    RULE en_cleanup_rule
        [clock_tick]
        ==>
        [NOT new_sense_data ==]
        [NOT map ==]
        [NOT clock_tick]
        [STOP]
enddefine;

/***************************************************************************
NAME
    en_motor_map_ruleset

FUNCTION
    Generates a map of cell occupancy in the four allowed motor headings.

    The ruleset transcribes the object sensor vector into the corresponding
    object map format for each of the allowed motor headings. If no objects
    are detected (i.e. no "new_sense_data") then a {0 0 0 0} map is posted.

    The "en_cleanup_ruleset" removes the [map {}] entry from the database
    at the start of the next simulator cycle.


        CELLs              SENSOR VECTOR FORMAT
     -----------
    | 1 | 2 | 3 |
     -----------
    | 8 | * | 4 |   <==>   {1 2 3 4 5 6 7 8}
     -----------
    | 7 | 6 | 5 |
     -----------


        CELLs              OBJECT MAP FORMAT
     -----------
    |   | 1 |   |
     -----------
    | 4 | * | 2 |   <==>      {1 2 3 4}
     -----------
    |   | 3 |   |
     -----------

RULES
    en_object_detected              - for [new_sense_data object ==]
    en_no_object_detected           - if no new_sense_data
***************************************************************************/

lconstant obj_map = initnibblevector(4);
lconstant blank_obj_map = consnibblevector(#|0, 0, 0, 0|#);

define :ruleset en_motor_map_ruleset;

    RULE en_object_detected
        [new_sense_data occupancy ?object_svec]
        ==>
        [POP11
            object_svec(2) -> obj_map(1);
            object_svec(4) -> obj_map(2);
            object_svec(6) -> obj_map(3);
            object_svec(8) -> obj_map(4);
            prb_add([map ^obj_map]);
        ]
        [STOP]

    RULE en_no_object_detected
        [clock_tick]
        ==>
        [POP11 prb_add([map ^blank_obj_map])]
        [STOP]
enddefine;


/***************************************************************************
NAME
    en_behaviour_ruleset

FUNCTION
    These rules animate the enemy. Enemies are endowed with 3 basic
    behaviours: withdrawing, eating, and walking.

    If enemies detect pain then they "withdraw" in a direction that is
    away from any "organic" objects (which might continue to inflict
    pain). Enemies cannot distinguish other enemies (or abbotts) from food
    and water and so avoiding all "organic" objects is the safest bet. It
    is possible to receive 2 bites in a single cycle (from two different
    agents) and so continue to feel pain after the "withdraw" behaviour has
    completed and ther are no "organic" objects around. The "withdraw"
    behaviour reduces the pain level by 1.

    If "organic" matter is detected (and the enemy is not withdrawing) then
    an "eat" action is initiated.

    Finally if there is no "pain" and nothing to eat, the agent simply
    walks around a bit. Walking continues in chosen direction for a
    random number of cycles until an object is detected, or an action occurs
    (such as getting bitten). The agent then chooses a new direction or
    performs a more urgent behaviour.


RULES
    en_withdraw                     - when pain detected withdraw
    en_eat                          - if organic matter detected eat it
    en_walk                         - if nothing else happening then walk
***************************************************************************/

define :ruleset en_behaviour_ruleset;

    RULE en_withdrawl
        [new_sense_data pain ?pain heading ?heading]
        [new_sense_data organic ?organic_svec]
        [map ?object_map]
        ==>
        [LVARS move_heading]
        [POP11
            lvars possible_headings = [];
            lvars i, loop_count;

            (heading + 2) mod 8 div 2 + 1 -> i;
            if object_map(i) == 0 then
                conspair(i, possible_headings) -> possible_headings;
            endif;

            /* find possible_headings */
            fast_for i from 1 to 4 do
                if object_map(i) == 0 then
                    conspair(i, possible_headings) -> possible_headings;
                endif;
            endfor;

            shuffle(possible_headings) -> possible_headings;

            1 -> move_heading;          ;;; default heading

            until possible_headings == [] do
                fast_destpair(possible_headings)
                                    -> (move_heading, possible_headings);
                if organic_svec(((move_heading - 1) mod 4)*2 + 1) == 0 and
                        organic_svec((move_heading mod 4)*2 + 1) == 0 then
                    quitloop;
                endif;
            enduntil;

            if gl_pain(sim_myself) > 0 then
                gl_pain(sim_myself) - 1 -> gl_pain(sim_myself);
            endif;

            move_heading -> gl_heading(sim_myself);
        ]
        [do_endcycle EnMove ?move_heading]
        [STOP]

    RULE en_eat
        [new_sense_data organic ?organic_svec]
        ==>
        [POP11
            lvars i;
            fast_for i from 1 to 8 do
                if organic_svec(i) /== 0 then
                    prb_add([do_lastcycle EnEat ^i]);
                    quitloop;
                endif;
            endfor;
        ]
        [STOP]

    RULE en_walk
        [map ?object_map]
        ==>
        [POP11
            lvars i,j;

            gl_heading_count(sim_myself) - 1
                                            -> gl_heading_count(sim_myself);
            if gl_heading_count(sim_myself) < 1 then
                3 + random(9) -> gl_heading_count(sim_myself);
                random(4) -> gl_heading(sim_myself)
            endif;

            if object_map(gl_heading(sim_myself) ->> i) /== 0 then
                fast_for j from 1 to 3 do
                    if object_map(i && 3 + 1 ->> i) == 0 then
                        i -> gl_heading(sim_myself);
                        quitloop;
                    endif;
                endfor;
            endif;

            prb_add([do_endcycle EnMove ^(gl_heading(sim_myself))]);
        ]
        [STOP]

enddefine;

/***************************************************************************
NAME
    EnMove

SYNOPSIS
    EnMove(agent, heading);

FUNCTION
    Move the agent in the intended direction. If the move is not allowed
    then no action is taken. The destination cells are checked as the
    world might have changed since the agent sampled it and built the
    object map.

    The "EnMove" action is performed at the end of the scheduler cycle.

RETURNS
    None
***************************************************************************/

define vars procedure EnMove(agent, heading);
    lvars agent, heading;
    lvars (x, y) = explode(gl_loc(agent));

    x + heading_to_x(heading) -> x;
    y + heading_to_y(heading) -> y;

    if gl_occupancy(GlGrid(x, y)) == 0 then
        GlMoveAgent(agent, x, y);
    endif;
enddefine;


/***************************************************************************
NAME
    EnEat

SYNOPSIS
    EnEat(agent, heading);

FUNCTION
    Eat the object in the direction provided the "heading". This has the
    effect of reducing the "organic" level of the object by 1 and if
    the object has a "body_state" then it also inflicts pain.

    Empty cells return an AGENT_ID of false which is caught by the
    isgl_attrib() check.

    The "EnEat" action is performed at the end of the scheduler cycle.

RETURNS
    None
***************************************************************************/

define vars procedure EnEat(agent, heading);
    lvars agent, heading;
    lvars obj;
    lvars (x, y) = explode(gl_loc(agent));

    /* find the organic object */

    x + cell_to_x(heading) -> x;
    y + cell_to_y(heading) -> y;

    /* bite object */

    if gl_organic((GlGrid(x, y) ->> obj)) > 0 then
        gl_energy(agent) + ENERGY_UNIT -> gl_energy(agent);

        valof(gl_agent_id(obj)) -> obj;
        gl_Organic(obj) - 1 -> gl_Organic(obj);
        if isgl_body_state(obj) then
            gl_pain(obj) + 5 -> gl_pain(obj);
            gl_adrenaline(obj) + 10 -> gl_adrenaline(obj);
            (3 + heading) mod 8 + 1 -> gl_pain_dir(obj);
        endif;

        gl_type(obj) -> obj;
        if obj == "water" then
            gl_vascular_volume(agent) + WATER_UNIT
                                            -> gl_vascular_volume(agent);
        elseif obj == "food" then
            gl_blood_sugar(agent) + FOOD_UNIT -> gl_blood_sugar(agent);
        endif;
    else
        gl_pain(agent) + 1 -> gl_pain(agent);
    endif;
enddefine;


/* ====================================================================== */


/* --- Revision History ---------------------------------------------------

--- Steve Allen, Nov 19 1998
    Standardised headers.

--- Steve Allen, May 30 1998
    Comments added.

--- Steve Allen, May 26 1998
    First written.
*/
