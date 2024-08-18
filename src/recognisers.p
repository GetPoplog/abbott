/* -------------------------------------------------------------------------
   ---       Concern Processing in Autonomous Agents - PhD Thesis        ---
   ---                                                                   ---
   ---       Copyright (c) Steve Allen, 1998. All rights reserved.       ---
   -------------------------------------------------------------------------

   File:            recognisers.p
   Author           Steve Allen, 5 Aug 2000 - (see revisions at EOF)
   Purpose:         Rules to define Abbott's consumatory behaviour agents.

   Libraries:       LIB sim_agent, poprulebase, objectclass, rc_graphic
                    LIB (*local) gl_agent, gl_abbott

   Related Files:   abbott.p

*/

/* --- Introduction --------------------------------------------------------

This file contains the rules that define the recogniser agents for the
Abbott SoM model. The recogniser agent is capable of filtering the
eye sensor list to identify the particular object that Abbott is attending
to - if Abbott is not actually looking for a particular object then the
first (i.e. closest and brightest) object in the eye sensor list is returned
as the "percept".

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

vars procedure NewRecogniserAttendTo;

/* -- Recognisers Rulesystems -- */

vars recogniser_attend_to_rulesystem;
vars recogniser_attend_to_ruleset;

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
vars sim_cycle_number;

/* -- local variables -- */
lvars direction, strength;
lvars item;

/**************************************************************************
Functions

***************************************************************************/

/* ====================================================================== */

/***************************************************************************
NAME
    NewRecogniserAttendTo

SYNOPSIS
    NewRecogniserAttendTo(parent, name);

FUNCTION
    Recognises the attended to item and adds it to the database as a
    "percept".

RETURNS
    None
***************************************************************************/
define vars procedure NewRecogniserAttendTo(parent, name) /* -> agent */;
    lvars parent, name;
    lvars agent;

    newgl_recogniser() -> agent;
    parent -> gl_parent(agent);
    "alive" -> sim_status(agent);
    GlNameAgent(agent, name);

    "recogniser" -> gl_id(agent);

    recogniser_attend_to_rulesystem -> sim_rulesystem(agent);

    ExtractConditionKeys(agent) -> gl_cond_filter(agent);
    [] -> gl_act_filter(agent);

    prb_add_to_db([count 1], sim_get_data(agent));

    return(agent);
enddefine;

/* -- Rulesystem -- */

define :rulesystem recogniser_attend_to_rulesystem;
    include: recogniser_attend_to_rulefam
enddefine;

/* -- Rulefamilies -- */

define :rulefamily recogniser_attend_to_rulefam;
    ruleset: recogniser_attend_to_ruleset
enddefine;

/* -- Rulesets -- */

define :ruleset recogniser_attend_to_ruleset;

    [VARS sim_myID blackboard];

    RULE recognise_attend_to
        [INDATA ?blackboard [sensor eye update]]
        [INDATA ?blackboard [sensor eye value ??vals]]
        [count ?count] [->> it]
        ==>
        [INDATA ?blackboard [NOT percept = = = ?count]]
        [POP11
            lvars obj, min_dist;
            if sim_present_data(![attend_to ?obj], blackboard) then
                for item in vals do
                    if VisualIndexOf(item(1)) == obj then
                        sim_add_data([percept ^obj ^(item(2)) ^(item(3)) ^count],
                                                                    blackboard);
                    endif;
                endfor;
            endif;

            if vals /== [] then
                front(vals) -> item;
                sim_add_data([percept ^(VisualIndexOf(item(1))) ^(item(2))
                                                            ^(item(3)) ^count], blackboard);

            endif;

            (count + 1) mod 2  -> count;
        ]
        [REPLACE ?it [count ?count]]
        [STOP]


    RULE end
        ==>
        [STOP]
enddefine;

/* ====================================================================== */


/* --- Revision History ---------------------------------------------------

--- Steve Allen, Aug 5 2000
    Added support for new SIM_AGENT toolkit.

--- Steve Allen, Nov 19 1998
    Standardised headers.

--- Steve Allen, Aug 31 1998
    First written.
*/
