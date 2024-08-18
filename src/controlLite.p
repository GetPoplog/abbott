/* -------------------------------------------------------------------------
   ---       Concern Processing in Autonomous Agents - PhD Thesis        ---
   ---                                                                   ---
   ---       Copyright (c) Steve Allen, 1998. All rights reserved.       ---
   -------------------------------------------------------------------------

   File:            controlLite.p
   Author           Steve Allen, 1 Nov 2000 - (see revisions at EOF)
   Purpose:         Uses gl_agent and sim_agent to create a Gridland
                    Scenario in which to experiment with Society of Mind
                    models of motivational agent architecture.

   Libraries:       LIB sim_agent, poprulebase, objectclass, rc_graphic
                    LIB (*local) gl_agent, gl_abbott

   Related Files:   file.p, enemy.p, abbott3a.p, sensors3a.p drive3a.p
                    maps.p recognisers.p motivations.p emotions.p filter.p
                    managers.p behaviours.p effectors.p body.p
*/

/* --- Introduction --------------------------------------------------------

This program forms the second experiment in a series of investigations into
"Concern Processing in Autonomous Agents". These experiments centre around
a Gridland scenario and "Abbott3" Society of Mind motivational agent
architecture.

--------------------------------------------------------------------------*/

uses newkit
true -> pop_debugging;

/* -- Extend search lists -- */

lvars filepath = sys_fname_path(popfilename);

extend_searchlist(filepath, popincludelist) -> popincludelist;
extend_searchlist(filepath, popuseslist) -> popuseslist;

/* -- System includes -- */

include gridland.ph;
loadinclude XmConstants;
include xpt_coretypes;

/* -- Some initialisation stuff -- */

;;;sys_unlock_heap();                      ;;; unlock heap
true -> popgctrace;                     ;;; trace garbage collections
sysgarbage();
random(10000) -> ranseed;

/***************************************************************************
Public functions writen in this module.

    define vars procedure Start();

    define vars procedure sim_setup_scheduler(objects, cycle_number);
    define :method sim_run_agent(agent:gl_agent, agents);

    define vars procedure CycleTimer();
    define vars procedure StatusCharout(item);

    define vars procedure NewExperiment(filename) -> new_expt;
    define updaterof vars procedure NewExperiment(expt);

    define :method SimSensePain(agent:gl_body_state);
    define :method SimSenseEaten(agent:gl_consumable);
    define :method SimSenseEaten(agent:gl_enemy);
    define :method SimSenseEaten(agent:gl_abbott);
    define :method sim_run_sensors(agent:sim_object, agents) -> sensor_data;

    define vars procedure GlBuildPopup(obj, popup);
    define :method vars GlPopupMenu(obj:gl_agent);
    define :method vars GlPopupMenu(obj:gl_parent);

    define vars procedure GlManageStatusWindow(new_status_window);
    define vars procedure ShowEye(agent);
    define vars procedure GlPrWin(win, data);

    define vars procedure sim_scheduler_pausing_trace(objects, cycle);
    define :method sim_agent_running_trace(object:gl_child);
    define :method vars sim_agent_rulefamily_trace(object:gl_child,
                                            rulefamily);
    define :method sim_agent_terminated_trace(object:gl_child,
                                            number_run, runs, max_cycles);
    define :method vars sim_agent_endrun_trace(agent:gl_child);
    define vars procedure ExtractConditionKeys(agent);

***************************************************************************/

/* -- Main Entry Point -- */

vars procedure Start;                   /* main entry point */
vars procedure BatchStart;              /* main entry point with args*/

/* -- SIM_AGENT routines -- */

vars procedure sim_setup_scheduler;     /* Gridland scheduler             */
vars procedure sim_run_agent;           /* run an agent                   */

/* -- Main Entry Support Routines -- */

vars procedure CycleTimer;              /* timer for scheduler loop       */
vars procedure StatusCharout;           /* redirect output to window      */

/* -- Experiments -- */

vars procedure NewExperiment;           /* create-read an experiment obj  */

/* -- Sensors -- */

vars procedure SimSensePain;            /* sense pain events              */
vars procedure SimSenseEaten;           /* sense eaten events             */
vars procedure sim_run_sensors;         /* run the agent sensors          */

/***************************************************************************
External functions accessed by this module.
Specify through module public interface include files or define explicitly.

    define vars procedure GlResizeGraphic(x, y, c, type);
    define vars procedure DisplayGrid(gridx, gridy, cellsize);
    define vars procedure GlUpdateCycleCount();
***************************************************************************/

/* -- Standard library routines -- */

uses time;

/* -- Gridland routines -- */

uses gl_agentLite;
uses gl_abbott3;

max(popmemlim, 8000000) -> popmemlim;   ;;; Increase popmemlim to reduce
                                        ;;; garbage collection time.
                                        ;;; Experiment with the number.

/* -- Now compile the code -- */

compile(sys_fname_path(popfilename) dir_>< 'enemy.p');
compile(sys_fname_path(popfilename) dir_>< 'abbott3a.p');
compile(sys_fname_path(popfilename) dir_>< 'file.p');

/* -- abbott.p -- */

vars procedure InitAbbott;

/***************************************************************************
Private functions in this module.
Define as lexical.

    define lvars procedure GridlandSetup();
    define lvars procedure GridlandInitialise();
    define lvars procedure GridlandScheduler();

    define lvars procedure InitAgent(attribs, obj) -> obj;
    define lvars procedure Test1();
    define lvars procedure Test2();
    define lvars procedure Test3();

***************************************************************************/

/* -- Main Entry Point -- */

lvars procedure GridlandSetup;          /* initialise the Gridland shell  */
lvars procedure GridlandInitialise;     /* initialise the Agent World     */
lvars procedure GridlandScheduler;      /* Gridland world scheduler       */

/* -- Menus -- */

lvars procedure AddPopupMenu;           /* add a popup menu               */
lvars procedure AddParentPopupMenu;     /* add a popup menu for a parent  */
lvars procedure AddMenuBar;             /* add a menu bar                 */

/* -- Status Windows -- */

lvars procedure ShowActivation;         /* display activation data        */
lvars procedure ShowData;               /* display database table         */
lvars procedure ActivationSort;         /* test activation level i1 >= i2 */
lvars procedure ShowInternalStatus;     /* display internal status        */
lvars procedure ShowStatus;             /* display general agent status   */
lvars procedure ShowSensors;            /* display all sensor readings    */

/* -- Message Dialogs -- */

lvars procedure AddGotoDialog;          /* dialog to enter goto cycle     */
lvars procedure AddAboutDialog;         /* gives info about program       */
lvars procedure AddGettingStartedDialog;/* dialog to get started          */

/* -- Help -- */

lvars procedure HelpAbout;              /* display info about system      */
lvars procedure HelpGettingStarted;     /* help about getting started     */

/* -- Gridland Agents -- */

lvars procedure InitAgent;              /* initialise an instance of obj  */
lvars procedure ResizeGrid;             /* resize the Gridland world      */

/* -- Callbacks -- */

lvars procedure MenuCB;                 /* menu bar callback              */
lvars procedure GlPopupCB;              /* popup menu callback            */
lvars procedure GotoCycleCB;            /* goto dialog callback           */

/* -- Tests -- */

lvars procedure Test1;                  /* hook for first test            */
lvars procedure Test2;                  /* hook for second test           */
lvars procedure Test3;                  /* destroy the Gridland window    */

/***************************************************************************
Private macros and constants.
Define as lexical.
***************************************************************************/

/* -- Gridland Objects -- */

lconstant
    the_objects = [
        line line
        circle circle circle
        rectangle
        square square square
        triangle triangle
        ];

lconstant
    the_consumables = [
        food food food food food food
        water water water water
        ];

lconstant
    the_enemies = [
        enemy enemy enemy
    ];

lconstant
    the_abbotts = [
        abbott
    ];

lvars new_enemies, new_abbotts, new_consumables, new_objects;

/* -- Scheduler -- */

lconstant macro (
    WORLD_CYCLE_TIME    = 5         /* number of cycles in World tick     */
    );

lvars active_agents = [];           /* list of active agents              */
lvars alive_abbotts = [];           /* list of abbotts still running      */
lvars all_abbotts_dead = false;     /* flag set when all abbots dead      */

lvars gridland_state = "pause";     /* Gridland scheduler state           */
lvars new_commands = [];            /* commands for scheduler             */

lvars cycle_done = false;           /* set by interrupt driven timer      */
lvars cycle_time = false;           /* cycle time in usec for scheduler   */

lvars goto_cycle = 1;
lvars old_display = true;
lvars old_trace = true;
lvars old_active_agent = false;

/* -- Mouse -- */

lvars obj_dragged = false;          /* set when obj dragged by mouse */

/* -- SIM_AGENT Tracing -- */

lvars cond_str = '-- Conditions -- ';   /* trace dbase conditions string  */
lvars act_str = '-- Actions --';        /* trace dbase actions string     */
lvars keys;                             /* temp var to hold dbase keys    */
lvars dbtable;                          /* temp var to hold dbase table   */
lvars old_data;                         /* flag used to track tracing     */
lvars key_words =
    [->> ? LVARS WHERE NOT POP11];

/***************************************************************************
Global data declared in this module.
Extern definitions for any external global data used by this module.
File wide static dtata.
***************************************************************************/

vars my_cycle_number;               /* global var tracking cycle number */

/* -- Eye -- */
vars gl_eye_win;
vars gl_eye_widget;
vars gl_eye_background;             /* background pixel of eye_widget */
vars gl_eye_values;                 /* label widget for values        */
vars gl_eye_timestamp;              /* label widget for timestamp     */

lconstant eyes = {{2 8} {7 8} {7 3} {2 3}};
lconstant colours = {
    'white' 'black' 'grey10' 'grey15'
    'grey25' 'grey30' 'darkgreen' 'grey35'
    'skyblue' 'grey40' 'grey50' 'purple'
    'grey60' 'grey70' 'red' 'grey90'};

define vars procedure DisplayEye(agent, new_eye_position);
    lvars agent, new_eye_position;
    new_eye_position -> gl_eye_position(agent);
enddefine;

/**************************************************************************
Functions
***************************************************************************/

/*
    Main Entry Point
    ================

    Start();                            - main entry poin
    GridlandSetup();                    - initialise the Gridland shell
    GridlandInitialise();               - initialise the Agent World
    GridlandScheduler();                - Gridland world scheduler
*/


/***************************************************************************
NAME
    Start

SYNOPSIS
    Start();

FUNCTION
    This provides the main entry point. Initialising the display and
    calling the scheduler.

    The GridlandScheduler() runs independently to the main SIM_AGENT
    sim_scheduler() - through the hook provided by sim_setup_scheduler().

     Start()
       |
       |----->GridlandSetup()
    -->|                                                Popup      Pulldown
   |   |----->GridlandInitialise()                      Menus       Menus
   |   |                                                  |           |
   |   |----->sim_scheduler()                             |           |
   |   :            |                                      \_________/
   |   :            |----->sim_setup()                          |
   |   :       ---->|                                           |
   |   :      |     |----->sim_setup_scheduler()                |
   |   :      |     :           |                               |
   |   :      |     :           |-------->GridlandScheduler()   |
   |   :      |     :           :                 |             v
   |   :      |     :           :               ->|      +--------------+
   |   :      |     :           :              |  |----->| new_commands |
   |   :      |     :           :              |  :      +--------------+
   |   :      |     :           :              |  :             |
   |   :      |     :           :              |  |<------------
   |   :      |     :           :              |  |
   |   :      |     :           :              |  |- "quit","new","reset" -
   |   :      |     :           :               --|                        |
   |   :      |     :           :                 |                        |
   |   :      |     :           |<- "run","goto" -                         |
   |   :      |     |<----------                                           |
   |   :      |   ->|                                                      |
   |   :      |  |  |----->sim_run_agent()                                 |
   |   :      |  |  :           |                                          |
   |   :      |  |  :           |                                          |
   |   :      |  |  :           |                                          |
   |   :      |  |  :           |                                          |
   |   :      |  |  |<----------                                           |
   |   :      |   --|                                                      |
   |   :      |    new                                                     |
   |   :      |   cycle                                                    |
   |   :      |     |                                                      |
   |   :       -----|                                                      |
   |   :                                                                   |
   |   :            |<------------- exitto(sim_scheduler) -----------------
 "new" :            |
"reset":            |-----> sim_scheduler_finished()
   |   |<-----------
    ---|
     "quit"
       |


RETURNS
    None.
***************************************************************************/
define vars procedure Start();
    BatchStart([]);
enddefine;

define vars procedure BatchStart(myCommands);
    lvars myCommands;

    /* make sure it is a list */
    unless islist(myCommands) then [%myCommands%] -> myCommands; endunless;

    [] -> new_enemies;
    [] -> new_abbotts;
    [] -> new_objects;
    [] -> new_consumables;

    GridlandSetup();

    ;;;dlocal cucharout = StatusCharout;               /* redirect output */
    dlocal cucharout = erase;

    /* initialise the variables */
    [] -> active_agents;
    [] -> alive_abbotts;
    [] -> new_commands;
    false -> all_abbotts_dead;
    false -> cycle_done;
    false -> cycle_time;
    1 -> goto_cycle;
    true -> old_display;
    true -> old_trace;
    false -> old_active_agent;
    false -> obj_dragged;
    0 -> my_cycle_number;

    "new" -> gridland_state;
    myCommands -> new_commands;
    false -> all_abbotts_dead;

    /* call the SIM_AGENT scheduler */

    until gridland_state == "quit" do
        if gridland_state == "new" then GridlandInitialise() endif;
        sim_scheduler(active_agents, false);
    enduntil;

    /* close the trace file if open */

    if isdevice(gl_trace_dev(gl_window)) then
        sysflush(gl_trace_dev(gl_window));
        sysclose(gl_trace_dev(gl_window));
        false -> gl_trace_dev(gl_window);
    endif;

enddefine;


/***************************************************************************
NAME
    GridlandSetup

SYNOPSIS
    GridlandSetup();

FUNCTION
    Creates the shell onto which all the gridland agent world is drawn.

RETURNS
    None
***************************************************************************/
define lvars procedure GridlandSetup();


    GlSetup('Gridland Scenario', 'Gridland',
            30, 30, 8, "array", []);

    /* clear debug flags */

    false -> prb_chatty;
    false -> prb_show_conditions;

enddefine;


/***************************************************************************
NAME
    GridlandInitialise

SYNOPSIS
    GridlandInitialise();

FUNCTION
    Initialises the gridland array which holds the physical characteristics
    of the world, then draws the Grid and adds the agents.

    active_agents   - contains a list of agents processed by the toolkit.

RETURNS
    None.
***************************************************************************/
define lvars procedure GridlandInitialise();
    lvars obj;

    ranseed -> gl_ranseed(gl_window);

    /* not sure */
    GlSetupGrid("array");

    clearproperty(gensym_property);

    lvars objects = maplist(the_objects, newgl_object<>InitAgent);
    [^^(maplist(new_objects, newgl_object<>InitAgent)) ^^objects] -> objects;

    lvars consumables = maplist(the_consumables,
                                            newgl_consumable<>InitAgent);
    [^^(maplist(new_consumables, newgl_consumable<>InitAgent)) ^^consumables]
                                                -> consumables;

    lvars enemies = maplist(the_enemies, newgl_enemy<>InitAgent);
    [^^(maplist(new_enemies, newgl_enemy<>InitAgent)) ^^enemies] -> enemies;

    lvars abbotts = maplist(the_abbotts, newgl_abbott<>InitAgent);
    [^^(maplist(new_abbotts, newgl_abbott<>InitAgent)) ^^abbotts] -> abbotts;

    abbotts -> alive_abbotts;

    [^^objects ^^consumables ^^enemies ^^abbotts]
                                            -> gl_agents(gl_window);
    [^^consumables ^^enemies ^^abbotts] -> active_agents;

    for obj in gl_agents(gl_window) do
        unless GlCellUnoccupied(obj, explode(gl_loc(obj))) then
            {% GlFindFreeLoc(obj) %} -> gl_loc(obj);
        endunless;
        GlAddAgent(obj);
        unless GlValidLoc(explode(gl_loc(obj))) then
            delete(obj, active_agents) -> active_agents;
        endunless
    endfor;

    /* clear trace values */

    false -> gl_activation_trace(gl_window);
    false -> gl_sensor_trace(gl_window);
    false -> gl_internal_trace(gl_window);
    false -> gl_status_trace(gl_window);
    false -> gl_data_trace(gl_window);

    /* reset cycle timer */

    false -> sys_timer(CycleTimer);

enddefine;


/***************************************************************************
NAME
    GridlandScheduler

SYNOPSIS
    GridlandScheduler();

FUNCTION
    This routine is called by the sim_agent toolkit at the Start of every
    cycle. If the simulation is running the routine makes use of the
    regular clock tick provided by CycleTimer() to regulate the speed
    of the simulation. By calling syshibernate() the scheduler allows
    general X house-keeping tasks to be performed such as moving objects
    and selecting menus.

    New commands (issued by menu items) are processed, synchonising menu
    events with the SIM_AGENT scheduler.

    "new"       - start new scenario.
    "reset"     - reset existing scenario.
    "open"      - open experiment from disk.
    "save"      - save experiment to disk.
    "quit"      - quit toolkit.
    "set_count" - update the cycle counter.
    "run"       - run the scenario.
    "pause"     - pause the scenario.
    "step [n]"  - single step the scenario (or step n steps).
    "big_step"  - goto next world cycle.
    "goto [n]"  - goto a specific cycle, ask if no cycle number.
    "display"   - toggle the display setting.
    "grid"      - resize the grid.
    "remove"    - remove an agent from the scenario.

RETURNS
    None.
***************************************************************************/
define lvars procedure GridlandScheduler();
    lvars cmd, data, commands, obj;
    lvars parent, child_type;

    /* reset the cycle_number for new experiments */
    if gridland_state == "new_expt" then
        flatlistify(new_commands) -> commands;
        if islist(lmember("set_count", commands) ->> cmd) then
            if length(cmd) > 1 then
                subscrl(2, cmd) -> data;
                if isinteger(data) then
                    data -> sim_cycle_number;
                    delete({set_count ^data}, new_commands)
                                                        -> new_commands;
                endif;
            endif;
        endif;
    endif;

    sim_cycle_number -> my_cycle_number;

    if gridland_state == "goto" and sim_cycle_number >= goto_cycle then
        old_trace -> gl_trace(gl_window);
        old_active_agent -> gl_active_agent(gl_window);
        cons("pause", new_commands) -> new_commands;
    endif;

    /* perform actions */

    if sim_cycle_number mod WORLD_CYCLE_TIME == 1 then
        for obj in sim_objects do
            unless isgl_consumable(obj) then
                (sim_get_data(obj))("do_lastcycle") -> sim_actions(obj);
                if sim_actions(obj) /== [] then
                    obj -> sim_myself;
                    []->(sim_get_data(obj))("do_lastcycle");
                    sim_do_actions(obj, sim_objects, sim_cycle_number);
                endif;
            endunless;
        endfor;

        for obj in sim_objects do
            unless isgl_consumable(obj) then
                (sim_get_data(obj))("do_endcycle") -> sim_actions(obj);
                if sim_actions(obj) /== [] then
                    obj -> sim_myself;
                    []->(sim_get_data(obj))("do_endcycle");
                    sim_do_actions(obj, sim_objects, sim_cycle_number);
                endif;
            endunless;
        endfor;

        if isgl_abbott(gl_active_agent(gl_window) ->> obj) then
            if sim_status(obj) == "dead" then
                false -> gl_active_agent(gl_window);
            endif;
        endif;
    endif;

    /* process new commands and wait for cycle timer */

    repeat

        /* synchronise with timer if cycle_time is set */

        if gridland_state == "run" and cycle_time then
            until cycle_done then syshibernate() enduntil;
            false -> cycle_done;
        endif;

        /* extract new commands */

        new_commands -> commands;
        [] -> new_commands;

        /* check for change of Abbott state - i.e. dead */
        for obj in alive_abbotts do
            if sim_status(obj) /== "alive" then
                delete(obj, alive_abbotts) -> alive_abbotts;    
            endif;
        endfor;

        if not(all_abbotts_dead) and alive_abbotts == [] then
            true -> all_abbotts_dead;
            cons("pause", new_commands) -> new_commands;
        endif;

        /* process new commands */
        repeat

            "none" -> cmd;
            false ->> data -> obj;
            unless null(commands) then
                dest(commands) -> commands -> cmd;
            endunless;

            unless isword(cmd) or isnumber(cmd) then
                if (length(cmd) == 2) then
                    explode(cmd) -> (cmd, data);
                    /* copy data to obj if an gl_agent */
                    if isgl_agent(data) then
                        data -> obj;
                        false -> data;
                    elseif isword(data) and isgl_agent(valof(data)) then
                        valof(data) -> obj;
                        false -> data;
                    endif;
                elseif (length(cmd) == 3) then
                    explode(cmd) -> (cmd, obj, data);

                    /* find the valof(obj) if defined */
                    if isword(obj) and not(isundef(valof(obj))) then
                        valof(obj) -> obj
                    endif;
                endif;
            endunless;

            switchon cmd
                case == "new" then
                    "new" -> gridland_state;
                    false -> sys_timer(CycleTimer);
                    exitto(sim_scheduler);

                case == "reset" then
                    "new" -> gridland_state;
                    false -> sys_timer(CycleTimer);
                    gl_ranseed(gl_window) -> ranseed;
                    [^^new_commands ^^commands] -> new_commands;
                    exitto(sim_scheduler);

                case == "ranseed" then
                    data ->> gl_ranseed(gl_window) -> ranseed;
                    "new" -> gridland_state;
                    false -> sys_timer(CycleTimer);
                    [^^new_commands ^^commands] -> new_commands;
                    exitto(sim_scheduler);

                case == "quit" then
                    "quit" -> gridland_state;
                    false -> sys_timer(CycleTimer);
                    exitto(sim_scheduler);

                case == "set_count" then
                    if isinteger(data) then
                        data -> sim_cycle_number;
                    endif;

                case == "goto" then
                    if data == false then
                    elseif isinteger(data) and data > sim_cycle_number then
                        data -> goto_cycle;
                        unless "goto" == gridland_state then
                            gl_trace(gl_window) -> old_trace;
                            gl_active_agent(gl_window) -> old_active_agent;
                        endunless;
                        false -> gl_trace(gl_window);
                        false -> gl_active_agent(gl_window);
                        "goto" -> gridland_state;
                    elseif isinteger(data) and data < sim_cycle_number then
                        if gridland_state == "goto" then
                            old_trace -> gl_trace(gl_window);
                            old_active_agent -> gl_active_agent(gl_window);
                        endif;
                        "new" -> gridland_state;
                        false -> sys_timer(CycleTimer);
                        gl_ranseed(gl_window) -> ranseed;
                        cons({goto ^data}, new_commands) -> new_commands;
                        exitto(sim_scheduler);
                    endif;

                case == "big_step" then
                    if gridland_state == "goto" then
                        old_trace -> gl_trace(gl_window);
                        old_active_agent -> gl_active_agent(gl_window);
                    endif;
                    gl_trace(gl_window) -> old_trace;
                    gl_active_agent(gl_window) -> old_active_agent;
                    ((sim_cycle_number - 1) div WORLD_CYCLE_TIME + 1)
                        * WORLD_CYCLE_TIME + 1 -> goto_cycle;
                    "goto" -> gridland_state;

                case == "step" then
                    if isinteger(data) and data > 1 then
                        sim_cycle_number + data -> goto_cycle;
                        unless gridland_state == "goto" then
                            gl_trace(gl_window) -> old_trace;
                            gl_active_agent(gl_window) -> old_active_agent;
                        endunless;
                        false -> gl_trace(gl_window);
                        false -> gl_active_agent(gl_window);
                        "goto" -> gridland_state;
                    else
                        if gridland_state == "goto" then
                            old_trace -> gl_trace(gl_window);
                            old_active_agent -> gl_active_agent(gl_window);
                        endif;
                        "run" -> gridland_state;
                        cons("pause", new_commands) -> new_commands;
                        if cycle_time then
                            false -> cycle_done;
                            cycle_time -> sys_timer(CycleTimer);
                        endif;
                    endif;

                case == "pause" then
                    if gridland_state == "goto" then
                        old_trace -> gl_trace(gl_window);
                        old_active_agent -> gl_active_agent(gl_window);
                    endif;
                    "pause" -> gridland_state;
                    false -> sys_timer(CycleTimer);

                case == "run" then
                    if gridland_state == "goto" then
                        old_trace -> gl_trace(gl_window);
                        old_active_agent -> gl_active_agent(gl_window);
                    endif;
                    "run" -> gridland_state;
                    if cycle_time then
                        false -> cycle_done;
                        cycle_time -> sys_timer(CycleTimer);
                    endif;

                case == "grid" then
                    if not(isword(data)) and length(data) == 4 then
                        ResizeGrid(explode(data));
                    endif;

                case == "cycle" then
                    if isboolean(data) or isinteger(data) then
                        data -> cycle_time;
                        if cycle_time then
                            cycle_time -> sys_timer(CycleTimer);
                        endif;
                    endif;

                case == "exec" then
                    if isvector(data) then explode(data) -> data endif;
                    if isword(data) then valof(data) -> data; endif;
                    if isprocedure(data) then data(); endif;

                case == "enemy" then
                    "enemy" :: new_enemies -> new_enemies;

                case == "food" then
                    "food" :: new_consumables -> new_consumables;

                case == "water" then
                    "water" :: new_consumables -> new_consumables;

                case == "line" then
                    "line" :: new_objects -> new_objects;

                case == "circle" then
                    "circle" :: new_objects -> new_objects;

                case == "square" then
                    "square" :: new_objects -> new_objects;

                case == "line" then
                    "line" :: new_objects -> new_objects;

                case == "rectangle" then
                    "rectangle" :: new_objects -> new_objects;

                case == "triangle" then
                    "triangle" :: new_objects -> new_objects;

                case == "abbott" then
                    "abbott" :: new_abbotts -> new_abbotts;

                case == "remove" then
                    /* check if obj is active agent */
                    if gl_active_agent(gl_window) == obj then
                        false -> gl_active_agent(gl_window);
                    endif;

                    /* process child agents */
                    if isgl_child(obj) then
                        gl_parent(obj) -> parent;
                        delete(obj, gl_children(parent))
                                                    -> gl_children(parent);
                        for child_type in class_slots(gl_children_key) do
                            delete(obj, child_type(parent))
                                                    -> child_type(parent);
                        endfor;

                    /* process agents with world presence */
                    elseif isgl_attrib(obj) then
                        GlRemoveAgent(obj);
                        delete(obj, gl_agents(gl_window))
                                                    -> gl_agents(gl_window);
                        delete(obj, active_agents) -> active_agents;
                        delete(obj, sim_objects) -> sim_objects;
                    endif;
            endswitchon;

            quitif ((cmd == "wait" and gridland_state /== "pause")
                                                        or cmd == "none");
        endrepeat;

        if cmd == "wait" then
            [^^new_commands wait ^^commands] -> new_commands;
        endif;
        quitif (gridland_state == "run" or gridland_state == "goto");
    endrepeat;

    /* process gridland world */

    if sim_cycle_number mod WORLD_CYCLE_TIME == 1 then
        for obj in sim_objects do
            unless isgl_consumable(obj) then
                prb_add_to_db([clock_tick], sim_get_data(obj));
            endunless;
        endfor;
    endif;

enddefine;

/* ====================================================================== */

/*
    SIM_AGENT routines
    ==================

    sim_setup_scheduler(objs, cycle);   - called on each scheduler loop
    sim_run_agent(agent, agents);       - run an agent
*/


/***************************************************************************
NAME
    sim_setup_scheduler

SYNOPSIS
    sim_setup_scheduler(objects, cycle_number);

FUNCTION
    This routine is called by the sim_agent toolkit at the Start of every
    cycle and is used as the hook for the Gridland Scheduler.

RETURNS
    None.
***************************************************************************/
define vars procedure sim_setup_scheduler(objects, cycle_number);
    lvars objects, cycle_number;

    GridlandScheduler();
enddefine;


/***************************************************************************
NAME
    sim_run_agent

SYNOPSIS
    sim_run_agent(agent, agents);

FUNCTION
    Calls the SIM_AGENT method to run the rules that define the agent.
    Each agent has its own debug settings that can be set using the
    mouse.

RETURNS
    None
***************************************************************************/
define :method sim_run_agent(agent:gl_agent, agents);
    call_next_method(agent, agents);
enddefine;

/* ====================================================================== */

/*
    Main Entry Support Routines
    ===========================

    CycleTimer();               - timer for scheduler loop
    StatusCharout();            - redirect output to debug status window
*/


/***************************************************************************
NAME
    CycleTimer

SYNOPSIS
    CycleTimer();

FUNCTION
    Provides a regular clock tick at the required cycle rate to control
    the speed of the simulation. The timer sets a flag ("cycle_done") and
    re-arms itself every "cycle_time" usec. Cycle times less that 1ms are
    ignored.

RETURNS
    None, but sets cycle_done to <true> whenever the timer fires.
***************************************************************************/
define vars procedure CycleTimer();
    true -> cycle_done;
    if cycle_time then
        cycle_time -> sys_timer(CycleTimer);
    endif;
enddefine;

/***************************************************************************
NAME
    StatusCharout

SYNOPSIS
    StatusCharout();

FUNCTION
    Redirects general output to the debug window. Comments (those lines
    starting with `;` - such as garbage collection reports) are sent to
    the standard output.p file.

    Lines are built up a character at a time and stored locally until a
    control character < 32 is encountered, or the line length exceeds 1023.

RETURNS
    None.
***************************************************************************/
lvars char_count = 1;
lvars char_str = inits(1024);

define vars procedure StatusCharout(item);
    item -> char_str(char_count);
    if item < 32 or char_count == 1023 then
        char_count - 1 -> char_count;
        substring(1, char_count, char_str) -> item;
        if item(1) == `;` then
            dlocal cucharout = charout;     /* send comments to output.p  */
            npr(item);
        else
            ;;;GlPrWin(debug_out, item);       /* redirect to debug window   */
        endif;
        1 -> char_count;
    else
        char_count + 1 -> char_count;
    endif;
enddefine;

/* ====================================================================== */

/*
    Experiments
    ===========

    NewExperiment();            - create/read an experiment object
*/


/***************************************************************************
NAME
    NewExperiment

SYNOPSIS
    NewExperiment(filename);

FUNCTION

RETURNS
    None.
***************************************************************************/
define vars procedure NewExperiment(filename) /* -> new_expt */;
    lvars filename;

    lvars name = "expt_" <> consword(sys_fname_nam(filename));
    lvars sname = word_string(name);
    lvars new_expt;

    if identprops(name) == "undef" then
        sysSYNTAX(name, 0, false);
    endif;

    if isgl_experiment(valof(name)) then
        valof(name) -> new_expt;
    else
        newgl_experiment() -> new_expt;
        new_expt -> valof(name);
    endif;

    sname -> gl_name(new_expt);
    filename     -> gl_filename(new_expt);
    sysdaytime() -> gl_created(new_expt);

    GlCellSize() -> gl_cellsize(new_expt);
    GlGridXSize() -> gl_gridxsize(new_expt);
    GlGridYSize() -> gl_gridysize(new_expt);
    GlGridType() -> gl_gridtype(new_expt);

    gl_agents(gl_window) -> gl_all_agents(new_expt);
    active_agents -> gl_active_agents(new_expt);

    sim_cycle_number -> gl_cycle_number(new_expt);
    ranseed          -> gl_ranseed(new_expt);
    gl_ranseed(gl_window) -> gl_iranseed(new_expt);

    true    -> gl_eof(new_expt);
    false   -> gl_io(new_expt);

    return(new_expt);
enddefine;

define updaterof vars procedure NewExperiment(expt);
    lvars expt;
    lvars i;

    gl_all_agents(expt)    -> gl_agents(gl_window);
    gl_active_agents(expt) ->> active_agents -> sim_objects;
    cons({set_count ^(gl_cycle_number(expt))}, new_commands)
                                                    -> new_commands;
    gl_ranseed(expt)       -> ranseed;
    gl_iranseed(expt)      -> gl_ranseed(gl_window);

    GlResizeGraphic(gl_gridxsize(expt), gl_gridysize(expt),
                                gl_cellsize(expt), gl_gridtype(expt));

    GlSetupGrid();

    for i in gl_agents(gl_window) do
        GlAddAgent(i);
    endfor;

    /* clear trace values */

    false -> gl_activation_trace(gl_window);
    false -> gl_sensor_trace(gl_window);
    false -> gl_internal_trace(gl_window);
    false -> gl_status_trace(gl_window);
    false -> gl_data_trace(gl_window);
enddefine;


/* ====================================================================== */

/*
    Sensors
    =======

    SimSensePain(agent:body_state);
    SimSenseEaten(agent:consumable);
    SimSenseEaten(agent:enemy);
    SimSenseEaten(agent:abbott);
    sim_run_sensors(agent:sim_object, agents) -> sensor_data;

*/


/***************************************************************************
NAME
    SimSensePain

SYNOPSIS
    SimSensePain(agent);

FUNCTION
    Inserts "[new_sense_data pain ==]" into the agent database when
    the agent's "pain" level is > 0.

RETURNS
    None
***************************************************************************/

define :method SimSensePain(agent:gl_body_state);
    lvars agent;

    if sim_in_database([clock_tick], sim_get_data(gl_parent(agent))) and
                                                gl_pain(agent) > 0 then
        [new_sense_data pain ^(gl_pain(agent))];
    endif;
enddefine;


/***************************************************************************
NAME
    SimSenseEaten

SYNOPSIS
    SimSenseEaten(agent)

FUNCTION
    Detects when an agent's "organic" level has dropped to 0. Consumable
    agents regenerate appearing at a new (empty) location. Enemies and
    Abbotts die.

RETURNS
    None
***************************************************************************/

define :method SimSenseEaten(agent:gl_consumable);
    lvars agent;

    if gl_Organic(agent) < 1 then
        /* regenerate consumable somewhere else */
        5 -> gl_Organic(agent);
        GlMoveAgent(agent, GlFindFreeLoc(agent));
    endif;
enddefine;

define :method SimSenseEaten(agent:gl_enemy);
    lvars agent;

    if gl_Organic(agent) < 1 then
        GlRemoveAgent(agent);            ;;; remove agent from Grid
        "dead" -> sim_status(agent);
        delete(agent, active_agents) -> active_agents;
        delete(agent, sim_objects) -> sim_objects;
    endif;
enddefine;

define :method SimSenseEaten(agent:gl_abbott);
    lvars agent;

    if gl_Organic(agent) < 1 then
        GlRemoveAgent(agent);            ;;; remove agent from Grid
        "dead" -> sim_status(agent);
        delete(agent, active_agents) -> active_agents;
        delete(agent, sim_objects) -> sim_objects;
        if gl_active_agent(gl_window) == agent then
            false -> gl_active_agent(gl_window);
        endif;
    endif;
enddefine;

/***************************************************************************
NAME
    sim_run_sensors

SYNOPSIS
    sim_run_sensors(agent, agents) -> sensor_data;

FUNCTION
    Replaces the standard sim_run_sensors() routine found in the Sim_Agent
    Toolkit. Gridland sensors all operate over a single range, and detect
    attributes in the physical Grid() rather than other agents.

RETURNS
    Sensor data.
***************************************************************************/

define :method sim_run_sensors(agent:sim_object, agents) -> sensor_data;
    lvars agent, agents, sensor_data;

    /*  Default method for running all the sensors associated with an
        agent. Done just before an agent is "run" by the scheduler.     */

    lvars
        sensor, sensor_proc,
        sensors = sim_sensors(agent);

    if null(sensors) then [] -> sensor_data;
    else
        ;;; make a list of records of detected agents
        [%
            for sensor in sensors do
                ;;; assume each sensor is a vector in format
                ;;; {sensorname}, where sensorname is name of a method
                ;;; of form: sensor(agent1)
                ;;; ??? should this use recursive_valof on the args ???
                appdata(sensor, recursive_valof)
                        -> (sensor_proc);
                sensor_proc(agent);
            endfor
        %] -> sensor_data
    endif
enddefine;


/***************************************************************************
NAME
    ShowEye

SYNOPSIS
    ShowEye(agent);

FUNCTION
    Displays the Eye sensor view in the sensor window. The last values read
    and a timestamp are also displayed.

RETURNS
    None.
***************************************************************************/
define vars procedure ShowEye(agent);
enddefine;



/***************************************************************************
NAME
    ExtractConditionKeys

SYNOPSIS
    ExtractConditionKeys(agent);

FUNCTION
    This funtion extracts the condition keys from a rulefamily. These keys
    can then be used to filter the parent database for only those items
    relevant to the rulefamily.

RETURNS
    None.
***************************************************************************/
define vars procedure ExtractConditionKeys(agent);
    lvars agent;
    lvars item, rule, condition, sorted_list, old_item;
    lvars rulesystem = sim_rulesystem(agent);

    /* allow for newkit format */
    if not(islist(rulesystem)) then
        return([]);
    endif;

    /* oldkit format */
    sort([%
        for item in rulesystem do
            recursive_valof(item) -> item;
            if datakey(item) == prb_rulefamily_key then
                appproperty(
                    prb_family_prop(item),
                    procedure(key, val);
                        unless not(islist(key)) then
                            recursive_valof(key) -> key;
                            for rule in key do
                                if isprbrule(rule) then
                                    for condition in prb_conditions(rule) do
                                        if hd(condition) == "NOT" then
                                            hd(tl(condition));
                                        else
                                            hd(condition);
                                        endif;
                                    endfor;
                                endif;
                            endfor;
                        endunless;
                    endprocedure
                );
            else
                if not(islist(item)) then nextloop endif;
                for rule in item do
                    if isprbrule(rule) then
                        for condition in prb_conditions(rule) do
                            hd(condition);
                        endfor;
                    endif;
                endfor;
            endif;
        endfor;
    %]) -> sorted_list;

    return([%
        false -> old_item;
        for item in sorted_list do
            if item /== old_item and not(lmember(item, key_words)) then
                item;
                item -> old_item;
            endif;
        endfor;
    %]);
enddefine;


/* ====================================================================== */


/*
    Gridland Agents
    ===============

    InitAgent(attribs, obj) -> obj;         - initialise an instance of obj
    ResizeGrid(x, y, c, type);              - resize the Gridland world

*/


/***************************************************************************
NAME
    InitAgent;

SYNOPSIS
    InitAgent(attribs, obj);

FUNCTION
    Builds a physical presence for agents in Gridland. The "attribs"
    variable can either contain just the agent type or a full vector with
    x, y co-ords and the agent type.

RETURNS
    None.
***************************************************************************/
define lvars procedure InitAgent(attribs, obj) /* -> obj */;
    lvars attribs, obj;

    lvars x, y, name, type, w, h;

    if isvector(attribs) then
        explode(attribs);
    else
        (0, 0, attribs);
    endif -> (x, y, type);


    /* general Gridland attribs */
    {^x ^y} -> gl_loc(obj);
    type  -> gl_type(obj);

    /* define physical presence in grid */
    switchon type
        case == "line" then
            gensym("l") -> name;
            [{0 0} {0 1}] -> gl_surface(obj);
            [%repeat 2 times conscell(0,0,0,0,0) endrepeat%]
                                                    -> gl_physical(obj);
            FULL -> gl_Occupancy(obj);
            4 -> gl_Hardness(obj);
            3 -> gl_Brightness(obj);
            0 -> gl_Organic(obj);
            name -> gl_Agent_ID(obj);

        case == "circle" then
            gensym("c") -> name;
            [{0 0} {1 0} {0 1} {1 1}] -> gl_surface(obj);
            [%repeat 4 times conscell(0,0,0,0,0) endrepeat%]
                                                    -> gl_physical(obj);
            PARTIAL -> gl_Occupancy(obj);
            4 -> gl_Hardness(obj);
            4 -> gl_Brightness(obj);
            0 -> gl_Organic(obj);
            name -> gl_Agent_ID(obj);

        case == "rectangle" then
            gensym("r") -> name;
            [{0 0} {1 0} {2 0} {3 0}
                    {0 1} {1 1} {2 1} {3 1}] -> gl_surface(obj);
            [%repeat 8 times conscell(0,0,0,0,0) endrepeat%]
                                                    -> gl_physical(obj);
            FULL -> gl_Occupancy(obj);
            4 -> gl_Hardness(obj);
            3 -> gl_Brightness(obj);
            0 -> gl_Organic(obj);
            name -> gl_Agent_ID(obj);

        case == "square" then
            gensym("s") -> name;
            [{0 0} {1 0} {0 1} {1 1}] -> gl_surface(obj);
            [%repeat 4 times conscell(0,0,0,0,0) endrepeat%]
                                                    -> gl_physical(obj);
            FULL -> gl_Occupancy(obj);
            4 -> gl_Hardness(obj);
            3 -> gl_Brightness(obj);
            0 -> gl_Organic(obj);
            name -> gl_Agent_ID(obj);

        case == "triangle" then
            gensym("t") -> name;
            [{0 0} {1 0} {2 0}
                {0 1} {1 1} {2 1}] -> gl_surface(obj);
            [%repeat 6 times conscell(0,0,0,0,0) endrepeat%]
                                                    -> gl_physical(obj);
            PARTIAL -> gl_Occupancy(obj);
            FULL -> gl_occupancy(gl_physical(obj)(2));
            4 -> gl_Hardness(obj);
            4 -> gl_Brightness(obj);
            3 -> gl_brightness(gl_physical(obj)(2));
            0 -> gl_Organic(obj);
            name -> gl_Agent_ID(obj);

        case == "vertical_wall4" then
            gensym("v") -> name;
            [{0 0} {0 1} {0 2} {0 3}] -> gl_surface(obj);
            [%repeat 4 times conscell(0,0,0,0,0) endrepeat%]
                                                    -> gl_physical(obj);
            FULL -> gl_Occupancy(obj);
            5 -> gl_Hardness(obj);
            1 -> gl_Brightness(obj);
            0 -> gl_Organic(obj);
            name -> gl_Agent_ID(obj);

        case == "vertical_wall3" then
            gensym("v") -> name;
            [{0 0} {0 1} {0 2}] -> gl_surface(obj);
            [%repeat 3 times conscell(0,0,0,0,0) endrepeat%]
                                                    -> gl_physical(obj);
            FULL -> gl_Occupancy(obj);
            5 -> gl_Hardness(obj);
            1 -> gl_Brightness(obj);
            0 -> gl_Organic(obj);
            name -> gl_Agent_ID(obj);

        case == "horizontal_wall4" then
            gensym("h") -> name;
            [{0 0} {1 0} {2 0} {3 0}] -> gl_surface(obj);
            [%repeat 4 times conscell(0,0,0,0,0) endrepeat%]
                                                    -> gl_physical(obj);
            FULL -> gl_Occupancy(obj);
            5 -> gl_Hardness(obj);
            1 -> gl_Brightness(obj);
            0 -> gl_Organic(obj);
            name -> gl_Agent_ID(obj);

        case == "horizontal_wall3" then
            gensym("h") -> name;
            [{0 0} {1 0} {2 0}] -> gl_surface(obj);
            [%repeat 3 times conscell(0,0,0,0,0) endrepeat%]
                                                    -> gl_physical(obj);
            FULL -> gl_Occupancy(obj);
            5 -> gl_Hardness(obj);
            1 -> gl_Brightness(obj);
            0 -> gl_Organic(obj);
            name -> gl_Agent_ID(obj);

        case == "cross_wall" then
            gensym("x") -> name;
            [{0 0} {1 0} {2 0} {3 0} {4 0}
                    {2 -2} {2 -1} {2 1} {2 2}] -> gl_surface(obj);
            [%repeat 9 times conscell(0,0,0,0,0) endrepeat%]
                                                    -> gl_physical(obj);
            FULL -> gl_Occupancy(obj);
            5 -> gl_Hardness(obj);
            1 -> gl_Brightness(obj);
            0 -> gl_Organic(obj);
            name -> gl_Agent_ID(obj);

        case == "food" then
            gensym("f") -> name;
            [{0 0}] -> gl_surface(obj);
            [%conscell(0,0,0,0,0)%] -> gl_physical(obj);
            FULL -> gl_Occupancy(obj);
            2 -> gl_Hardness(obj);
            6 -> gl_Brightness(obj);
            5 -> gl_Organic(obj);
            name -> gl_Agent_ID(obj);

        case == "water" then
            gensym("w") -> name;
            [{0 0}] -> gl_surface(obj);
            [%conscell(0,0,0,0,0)%] -> gl_physical(obj);
            PARTIAL -> gl_Occupancy(obj);
            1 -> gl_Hardness(obj);
            8 -> gl_Brightness(obj);
            5 -> gl_Organic(obj);
            name -> gl_Agent_ID(obj);

        case == "enemy" then
            gensym("e") -> name;
            [{0 0}] -> gl_surface(obj);
            [%conscell(0,0,0,0,0)%] -> gl_physical(obj);
            FULL -> gl_Occupancy(obj);
            3 -> gl_Hardness(obj);
            14 -> gl_Brightness(obj);
            5 -> gl_Organic(obj);
            name -> gl_Agent_ID(obj);

        case == "abbott" then
            gensym("a") -> name;
            [{0 0}] -> gl_surface(obj);
            [%conscell(0,0,0,0,0)%] -> gl_physical(obj);
            FULL -> gl_Occupancy(obj);
            3 -> gl_Hardness(obj);
            11 -> gl_Brightness(obj);
            5 -> gl_Organic(obj);
            name -> gl_Agent_ID(obj);

        else
            mishap('Attempting to initialise unknown agent', [^type]);
    endswitchon;

    /* create a new object name as a permanent identifier */
    GlNameAgent(obj, name);

    /* class specific stuff */
    if isgl_consumable(obj) then
        "alive" -> sim_status(obj);
        [{SimSenseEaten}] -> sim_sensors(obj);
        [] -> sim_rulesystem(obj)
    elseif isgl_enemy(obj) then
        "alive" -> sim_status(obj);
        1 -> gl_heading(obj);
        5 -> gl_heading_count(obj);

        30 -> gl_blood_sugar(obj);
        120 -> gl_energy(obj);
        0 -> gl_pain(obj);
        25 -> gl_vascular_volume(obj);

        [{SimSenseEaten}] -> sim_sensors(obj);
        enemy_rulesystem -> sim_rulesystem(obj);
    elseif isgl_abbott(obj) then
        InitAbbott(obj);
    endif;

    return (obj);
enddefine;

/***************************************************************************
NAME
    ResizeGrid;

SYNOPSIS
    ResizeGrid(x, y, c, type);

FUNCTION
    Resize the Gridland world. Any agents that no longer fit in the
    new gridsize are removed from the scenario.

RETURNS
    None.
***************************************************************************/
define lvars procedure ResizeGrid(x, y, c, type);
    lvars x, y, c, type;
    lvars i;

    GlResizeGraphic(x, y, c, type);

    for i in gl_agents(gl_window) do
        GlAddAgent(i);
        unless GlValidLoc(explode(gl_loc(i))) then
            delete(i, active_agents) -> active_agents;
            delete(i, sim_objects) -> sim_objects;
        endunless
    endfor;

enddefine;


define :method sim_agent_running_trace(object:sim_object);
enddefine;

define :method sim_agent_messages_out_trace(agent:sim_agent);
enddefine;

define :method sim_agent_messages_in_trace(agent:sim_agent);
enddefine;

define :method sim_agent_actions_out_trace(object:sim_object);
enddefine;


define :method sim_agent_action_trace(object:sim_object);
enddefine;


define :method sim_agent_rulefamily_trace(object:sim_object, rulefamily);
enddefine;

define :method sim_agent_endrun_trace(object:sim_object);
enddefine;

define vars procedure sim_scheduler_pausing_trace(objects, cycle);
enddefine;

define vars procedure sim_scheduler_finished(objects, cycle);
enddefine;

define :method sim_agent_terminated_trace(object:sim_object, number_run, runs, max_cycles);
enddefine;

define vars procedure no_objects_runnable_trace(objects, cycle);
enddefine;

/* ====================================================================== */

printf('\n\nTo run the demo type:\n   Start();\n');
printf('\n(then select "Run" from the Run menu)\n');
sysgarbage();

/* ====================================================================== */


/* --- Revision History ---------------------------------------------------

--- Steve Allen, Nov 4 2000
    Simulation stops if all Abbotts die - also initialised the vars
    on startup.

--- Steve Allen, Nov 1 2000
    Modified for Abbott3 experiments.

--- Steve Allen, Aug 15 2000
    Moved menu call back commands in to main Gridland scheduler.
    All commands can now be called through BatchStart().

--- Steve Allen, Aug 13 2000
    Added BatchStart().

--- Steve Allen, Aug 4 2000
    Added support for new SIM_AGENT toolkit.

--- Steve Allen, May 21 2000
    Added chages for old simkit
    Added patches for LessTif

--- Steve Allen, Nov 23 1998
    Add a title to GlAddAgentList(). Updated comments of Start() to reflect
    Gridland scheduler. Reduced number of "CPU Cycle Time" options.

--- Steve Allen, Nov 19 1998
    Tidied up code and finished adding header comments to aid readability.
    Implemented "goto" function and added save to file for Status windows.
    Added help dialog boxes to get users started.

--- Steve Allen, Jun 1 1998
    Changed filename from "agent.p" and move some routines around. Created
    library class gl_abbott.p to hold object class types.

--- Steve Allen, May 30 1998
    Comments added and enemy implemented.

--- Steve Allen, May 28 1998
    Gridland established.

--- Steve Allen, May 26 1998
    Gridland scenario started.
*/
