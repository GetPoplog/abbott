/* -------------------------------------------------------------------------
   ---       Concern Processing in Autonomous Agents - PhD Thesis        ---
   ---                                                                   ---
   ---       Copyright (c) Steve Allen, 1998. All rights reserved.       ---
   ---------------------------------------`.----------------------------------

   File:            gl_abbott3.p
   Author           Steve Allen, 4 Nov 2000 - (see revisions at EOF)
   Purpose:         This file contains the abbott class definitions and
                    methods for the gridland world.

   Libraries:       LIB (*local) gl_agent
*/

/* --- Introduction --------------------------------------------------------

This libary adds Abbott specific classes and methods for use in the
Gridland Sim Agent library.

--------------------------------------------------------------------------*/

section;

/* system includes */

uses gl_agent;

/***************************************************************************
Public functions writen in this module.

***************************************************************************/

/***************************************************************************
External functions accessed by this module.
Specify through module public interface include files or define explicitly.

***************************************************************************/

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

vars gl_found = false;                      /* Local Database match     */

/* ====================================================================== */

/*
    Mixins for Gridland
    ===================

    gl_attrib                   - physical presence in Gridland
    gl_body_state               - various internal body variables
    gl_body_state_sp            - set points for internal body variables
    gl_parent                   - parent specific slots
    gl_child                    - children specific slots
*/

define :class gl_body_state;
    slot gl_blood_pressure = 0;
    slot gl_blood_sugar = 0;
    slot gl_energy = 0;
    slot gl_heart_rate = 0;
    slot gl_pain = 0;
    slot gl_pain_dir = 0;
    slot gl_asifpain = 0;
    slot gl_asifpain_dir = 0;
    slot gl_respiration_rate = 0;
    slot gl_temperature = 0;
    slot gl_vascular_volume = 0;

    slot gl_adrenaline = 0;
    slot gl_noradrenaline = 0;
    slot gl_dopamine = 0;
    slot gl_endorphine = 0;

    slot gl_asif_adrenaline = 0;
    slot gl_asif_noradrenaline = 0;
    slot gl_asif_dopamine = 0;
    slot gl_asif_endorphine = 0;
enddefine;

define :class gl_body_state_sp;
    slot gl_blood_pressure_sp = 0;      /* blood pressure set point     */
    slot gl_blood_sugar_sp = 0;         /* blood sugar set point        */
    slot gl_energy_sp = 0;              /* energy set point             */
    slot gl_heart_rate_sp = 0;          /* heart rate set point         */
    slot gl_pain_sp = 0;                /* pain set point               */
    slot gl_asifpain_sp = 0;            /* pain set point               */
    slot gl_respiration_rate_sp = 0;    /* respiration rate set point   */
    slot gl_temperature_sp = 0;         /* temperature set point        */
    slot gl_vascular_volume_sp = 0;     /* vascular volume set point    */
    slot gl_adrenaline_sp = 0;          /* adrenaline set point         */
    slot gl_noradrenaline_sp = 0;       /* noradrenaline set point      */
    slot gl_dopamine_sp = 0;            /* dopamine set point           */
    slot gl_endorphine_sp = 0;          /* endorphine set point         */
enddefine;

define :mixin gl_children;
    slot gl_sensors == [];              /* sensor agents                */
    slot gl_dir_nemes == [];            /* direction neme agents        */
    slot gl_maps == [];                 /* map agents                   */
    slot gl_recognisers == [];          /* recogniser agents            */
    slot gl_drives == [];               /* drive agents                 */
    slot gl_somaticMarkers == [];       /* somatic marker agents        */
    slot gl_relevanceEvals == [];       /* relevance evaluation agents  */
    slot gl_actionProposers == [];      /* action proposer agent        */
    slot gl_skills == [];               /* skill agents                 */
    slot gl_attentionFilter == [];      /* attention filter agent       */
    slot gl_motivatorMetaManager == []; /* motivator meta manager agent */
    slot gl_motivatorManager == [];     /* motivator manager agent      */
    slot gl_managers == [];             /* manager agents               */
    slot gl_behaviours == [];           /* behaviour agents             */
    slot gl_effectors == [];            /* effector agents              */
    slot gl_changeGens == [];           /* change generator agents      */
    slot gl_body == [];                 /* body agents                  */
enddefine;

vars gl_children_slots = class_slots(gl_children_key);

define :mixin gl_shared_data_mixin;
    slot gl_use_shared_data = false;
    slot sim_shared_data = prb_newdatabase(sim_dbsize, []);
enddefine;

define :mixin gl_parent; is gl_shared_data_mixin;
    slot gl_children;                   /* children                     */
    slot gl_list_widget;                /* list widget of children      */
enddefine;

define :mixin gl_abbott_mixin;
    slot gl_active_mot;
    slot gl_filter_threshold;
    slot gl_prop = newproperty([], 8, false, "perm");
    slot gl_eye_position = 1;
    slot gl_eye_last_position = 1;      /* last sensed eye position     */
    slot gl_eye_last_values = [];       /* last sensed eye values       */
    slot gl_eye_last_timestamp = 1;     /* last sensed eye timestamp    */
    slot gl_foot_heading = false;
    slot gl_mouth_ingest = false;
enddefine;

define :mixin gl_child; is gl_shared_data_mixin;
    slot gl_parent;                     /* parent                       */
    slot gl_id;                         /* child ID                     */
    slot gl_cond_filter = [];           /* sim_data filter (conditions) */
    slot gl_act_filter = [];            /* sim_data filter (actions)    */
    slot gl_act_level == 0;             /* activation level             */
    slot gl_act_status == false;        /* activation status            */
    slot gl_act_source == false;        /* activation source            */
    slot sim_cycle_limit = 0;
enddefine;

define :mixin gl_sensor_mixin;
    slot gl_value;
    slot gl_range;
    slot gl_diff;
enddefine;

define :mixin gl_recogniser_mixin;
enddefine;

define :mixin gl_filter_mixin;
    slot gl_active_mot = false;
enddefine;

define :mixin gl_relevanceEval_mixin;
enddefine;

define :mixin gl_somaticMarker_mixin;
enddefine;

define :mixin gl_direction_mixin;
enddefine;

define :mixin gl_map_mixin;
    slot gl_value;
enddefine;

define :mixin gl_actionProposer_mixin;
    slot gl_active_mot = false;
enddefine;

define :mixin gl_changeGen_mixin;
enddefine;

define :mixin gl_drive_mixin;
    slot gl_drive;
    slot gl_sat_criterion;
    slot gl_controlled_var;
    slot gl_set_point;
    slot gl_var_range;
enddefine;

define :mixin gl_motivatorManager_mixin;
    slot gl_selected_behaviour = false;
    slot gl_drive;
enddefine;

define :mixin gl_motivatorMetaManager_mixin;
    slot gl_managerDB;
enddefine;

define :mixin gl_manager_mixin;
    slot gl_attend_to;
    slot gl_selected_behaviour = false;
enddefine;

define :mixin gl_behaviour_mixin;
    slot gl_stimulus;
    slot gl_effects;
enddefine;

define :mixin gl_skill_mixin;
    slot gl_stimulus;
    slot gl_effects;
enddefine;

define :mixin gl_effector_mixin;
enddefine;

define :mixin gl_body_mixin;
enddefine;

/* ====================================================================== */

/*
    Additional classes for Gridland
    ===============================

    gl_experiment               - Experiments
    gl_consumable               - Consumables i.e. food, water
    gl_abbott                   - Abbotts (the good guys)
    gl_enemy                    - Enemies (the bad guys)
*/

define :class gl_experiment;
    slot gl_name;
    slot gl_filename;
    slot gl_created;
    slot gl_ranseed;
    slot gl_iranseed;                   /* initial ranseed value    */
    slot gl_gridxsize;
    slot gl_gridysize;
    slot gl_cellsize;
    slot gl_gridtype;
    slot gl_all_agents;
    slot gl_active_agents;
    slot gl_cycle_number;
    slot gl_eof;
    slot gl_io;
    slot gl_iodev;
enddefine;

define :class gl_consumable; is gl_attrib gl_agent gl_sel sim_agent;
    slot sim_sensors = [];
    slot sim_rulesystem = [];
enddefine;

define :class gl_abbott; is gl_abbott_mixin gl_parent
                gl_children gl_body_state gl_body_state_sp gl_attrib gl_agent
                                                        gl_sel sim_agent;
    slot gl_eyes = initv(4);
    slot gl_eye_pic;
    slot gl_eye_view = newarray([1 5 1 5], 0);
    slot sim_sensors = [];
    slot sim_rulesystem = [];
enddefine;

define :method gl_eye(obj:gl_abbott);
    lvars obj;

    explode(gl_eyes(obj)(gl_eye_position(obj)))();
enddefine;

define :class gl_enemy; is gl_body_state gl_attrib gl_agent gl_sel
                                                                sim_agent;
    slot gl_heading;
    slot gl_heading_count;
    slot sim_sensors = [];
    slot sim_rulesystem = [];
enddefine;

define :class gl_sensor; is gl_sensor_mixin gl_child gl_agent sim_agent;
    slot sim_sensors = [];
    slot sim_rulesystem = [];
enddefine;

define :class gl_recogniser; is gl_recogniser_mixin gl_child gl_agent
                                                                sim_agent;
    slot sim_sensors = [];
    slot sim_rulesystem = [];
enddefine;

define :class gl_somaticMarker; is gl_somaticMarker_mixin gl_child gl_agent
                                                                sim_agent;
    slot sim_sensors = [];
    slot sim_rulesystem = [];
enddefine;

define :class gl_relevanceEval; is gl_relevanceEval_mixin gl_child gl_agent
                                                                sim_agent;
    slot sim_sensors = [];
    slot sim_rulesystem = [];
enddefine;

define :class gl_direction; is gl_direction_mixin gl_child gl_agent
                                                                sim_agent;
    slot sim_sensors = [];
    slot sim_rulesystem = [];
enddefine;

define :class gl_map; is gl_map_mixin gl_child gl_agent sim_agent;
    slot sim_sensors = [];
    slot sim_rulesystem = [];
enddefine;

define :class gl_filter; is gl_filter_mixin gl_child gl_agent sim_agent;
    slot sim_sensors = [];
    slot sim_rulesystem = [];
enddefine;

define :class gl_drive; is gl_drive_mixin gl_child gl_agent sim_agent;
    slot sim_sensors = [];
    slot sim_rulesystem = [];
enddefine;

define :class gl_actionProposer; is gl_actionProposer_mixin gl_child
                                                    gl_agent sim_agent;
    slot sim_sensors = [];
    slot sim_rulesystem = [];
enddefine;

define :class gl_motivatorManager; is gl_motivatorManager_mixin gl_child
                                                    gl_agent sim_agent;
    slot sim_sensors = [];
    slot sim_rulesystem = [];
enddefine;

define :class gl_motivatorMetaManager; is gl_motivatorMetaManager_mixin
                                            gl_child gl_agent sim_agent;
    slot sim_sensors = [];
    slot sim_rulesystem = [];
enddefine;

define :class gl_manager; is gl_manager_mixin gl_child gl_agent
                                                                sim_agent;
    slot sim_sensors = [];
    slot sim_rulesystem = [];
enddefine;

define :class gl_behaviour; is gl_behaviour_mixin gl_child gl_agent
                                                                sim_agent;
    slot sim_sensors = [];
    slot sim_rulesystem = [];
enddefine;

define :class gl_changeGen; is gl_changeGen_mixin gl_child gl_agent
                                                                sim_agent;
    slot sim_sensors = [];
    slot sim_rulesystem = [];
enddefine;

define :class gl_skill; is gl_skill_mixin gl_child gl_agent sim_agent;
    slot sim_sensors = [];
    slot sim_rulesystem = [];
enddefine;

define :class gl_effector; is gl_effector_mixin gl_child gl_agent sim_agent;
    slot sim_sensors = [];
    slot sim_rulesystem = [];
enddefine;

define :class gl_body; is gl_body_mixin gl_child gl_agent sim_agent;
    slot sim_sensors = [];
    slot sim_rulesystem = [];
enddefine;

/* ====================================================================== */

/*
    Additional Methods for Gridland
    ===============================

    =_instance()            - redefine "=" to "=="
    GlNameAgent()           - name agent and create permanent identifier
    gl_sensor_trace()       - trace flag for sensors

*/

define :method vars GlNameAgent(agent:gl_child, name);
    lvars agent, name;

    consword(sim_name(gl_parent(agent)) >< name) -> name;

    /* make "name" into a permanent identifier and assign "obs" to it */
    sysSYNTAX(name, 0, false);
    agent -> valof(name);
    name -> sim_name(agent);
enddefine;

/* -- Additional trace flags -- */

define :if_needed gl_sensor_trace(id:gl_window);
    lvars id;
    false
enddefine;

define :if_needed gl_internal_trace(id:gl_window);
    lvars id;
    false
enddefine;

define :if_needed gl_status_trace(id:gl_window);
    lvars id;
    false
enddefine;

define :if_needed gl_data_trace(id:gl_window);
    lvars id;
    false
enddefine;

define :if_needed gl_active_agent(id:gl_window);
    lvars id;
    false
enddefine;

define :if_needed gl_activation_trace(id:gl_window);
    lvars id;
    false
enddefine;

/* -- Increment Body State Methods -- */

define :method GlIncBodyState(agent:gl_body_state, procedure slot, val);
    lvars agent, slow, val;
    slot(agent) + val -> slot(agent);
enddefine;

define :method GlIncBodyState(agent:gl_abbott, procedure slot, val);
    lvars agent, slow, val;
    slot(agent) + val -> slot(agent);
enddefine;

define :method GlIncBodyState(agent:gl_child, procedure slot, val);
    lvars agent, slow, val;
    gl_parent(agent) -> agent;
    slot(agent) + val -> slot(agent);
enddefine;


/* ====================================================================== */

define vars procedure sim_present_data(pattern, dbtable) /* -> item */;
    lvars pattern, procedure dbtable;

    ;;; Use first item in pattern to index dbtable
    ;;; and look through that list for the given pattern.
    ;;; If the first item is not constant, search everything.

    ;;; If something matches then assign it to prb_found, and return it.
    ;;; This will set popmatchvars if anything matches.
    lvars pattern;

    define lconstant procedure found_item(/* data */);
        ;;; if something matches record it and return
        /* lvars data; */
        /* data */ ->> prb_found;   ;;; result left on stack
        exitfrom(sim_present_data)
    enddefine;

    prb_match_apply(dbtable, pattern, found_item);

    ;;; failed so
    false

enddefine;


;;; ensure that sim_get_data is not a method already
;;;true -> pop_debugging;
vars procedure sim_get_data;
identfn -> sim_get_data;

define :method sim_get_data(obj:sim_object);
    if sim_use_shared_data then
        return(sim_shared_data(obj));
    else
        return(sim_data(obj));
    endif;
enddefine;


define :method sim_get_data(obj:gl_shared_data_mixin);
    lvars obj;
    lvars data;

    if (gl_use_shared_data(obj)) then
        sim_shared_data(obj) -> data;
    else
        sim_data(obj) -> data;
    endif;
    return(data);
enddefine;

define sim_eval_data(action, prb_database);
    ;;; user interface to prb_do_action
    lvars action;
    dlocal prb_database;
    prb_do_action(action, prb_ruleof(rule_instance), rule_instance);
enddefine;

define sim_eval_list_data(actions, prb_database);
    ;;; user interface to prb_do_action applied to a list
    lvars action, actions;
    dlocal prb_database;

    for action in actions do
        prb_do_action(action, prb_ruleof(rule_instance), rule_instance);
    returnif(prb_rule_found == "QUIT")
    endfor
enddefine;

define prb_delete( /*item*/) with_nargs 1;
    prb_flush1(/*item*/);
enddefine;

/* ====================================================================== */

global vars gl_abbott3 = true;            ;;; for uses

endsection;

nil -> proglist;


/* ====================================================================== */


/* --- Revision History ---------------------------------------------------

--- Steve Allen, Nov 8 2000
    Added "as if" slots to the gl_body_state class.

--- Steve Allen, Nov 21 1998
    Standardised the header.

--- Steve Allen, Nov 3 1998
    Body agents added.

--- Steve Allen, Jun 8 1998
    First written
*/
