/* -------------------------------------------------------------------------
   ---       Concern Processing in Autonomous Agents - PhD Thesis        ---
   ---                                                                   ---
   ---       Copyright (c) Steve Allen, 1998. All rights reserved.       ---
   -------------------------------------------------------------------------

   File:            control.p
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

    define :method rc_button_1_up(pic:rc_window_object, newx, newy,
                                                                modifiers);
    define :method rc_button_1_up(agent:gl_attrib, newx, newy, modifiers);
    define :method rc_button_1_down(pic:gl_agent, x, y, modifiers);
    define :method rc_button_1_drag(pic:rc_window_object, x, y, modifiers);
    define :method rc_button_1_drag(pic:gl_attrib, x, y, modifiers);

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

/* -- Mouse Events -- */

;;;vars rc_button_1_up;                    /* mouse button 1 released events */
;;;vars rc_button_1_down;                  /* mouse button 1 pushed events   */
;;;vars rc_button_1_drag;                  /* mouse button 1 drag events     */

/* -- Sensors -- */

vars procedure SimSensePain;            /* sense pain events              */
vars procedure SimSenseEaten;           /* sense eaten events             */
vars procedure sim_run_sensors;         /* run the agent sensors          */

/* -- Menus -- */

vars procedure GlBuildPopup;            /* insert name etc. into title    */
vars procedure GlPopupMenu;             /* returns the popup menu for obj */

/* -- Status Windows -- */

vars procedure GlManageStatusWindow;    /* select a new status window     */
vars procedure ShowEye;                 /* display contents of eye sensor */
vars procedure GlPrWin;                 /* print the data in the window   */

/* -- SIM_AGENT Tracing -- */

vars sim_scheduler_pausing_trace;       /* called at end of scheduler     */
vars sim_agent_running_trace;           /* called before running rules    */
vars sim_agent_rulefamily_trace;        /* called before each rulefamily  */
vars sim_agent_terminated_trace;        /* called after running rules     */
vars sim_agent_endrun_trace;            /* called after actions processed */
vars ExtractConditionKeys;              /* extract condition keys         */

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

uses gl_agent;
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

/* -- gl_agent.p --*/

vars procedure GlResizeGraphic;
vars procedure DisplayGrid;
vars procedure GlUpdateCycleCount;

vars procedure GlRefreshFileDir;
vars procedure PopupMenu;

/***************************************************************************
Private functions in this module.
Define as lexical.

    define lvars procedure GridlandSetup();
    define lvars procedure GridlandInitialise();
    define lvars procedure GridlandScheduler();

    define lvars procedure AddPopupMenu(name, parent) -> popup;
    define lvars procedure AddParentPopupMenu(name, parent) -> popup;
    define lvars procedure AddMenuBar(menu_bar);

    define :method lvars ShowActivation(agent:gl_agent, clear);
    define :method lvars ShowActivation(agent:gl_abbott, clear);
    define :method lvars ShowData(agent:gl_agent, clear);
    define lvars procedure ActivationSort(i1, i2) -> bool;
    define :method lvars ShowInternalStatus(agent:gl_parent, clear);
    define :method lvars ShowStatus(agent:gl_agent, clear);
    define :method lvars ShowStatus(agent:gl_abbott, clear);
    define :method lvars ShowStatus(agent:gl_child, clear);
    define lvars procedure ShowSensors(agent);

    define lvars procedure AddGotoDialog() -> dialog;
    define lvars procedure AddAboutDialog() -> dialog;
    define lvars procedure AddGettingStartedDialog() -> dialog;

    define lvars procedure HelpAbout();
    define lvars procedure HelpGettingStarted();

    define lvars procedure InitAgent(attribs, obj) -> obj;
    define lvars procedure SetupAgentRcGraphic(obj);
    define lvars procedure CrossWallSelected(x, y, picx, picy, pic)
                                                                -> boole;
    define lvars procedure ResizeGrid(x, y, c, type);

    define lvars procedure MenuCB(w, client_data, call_data);
    define lvars procedure GlPopupCB(w, client_data, call_data);
    define lvars procedure GotoCycleCB(w, client_data, call_data);

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
lvars procedure SetupAgentRcGraphic;    /* define graphical chars of obj  */
lvars procedure CrossWallSelected;      /* define boundary of cross wall  */
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

/* -- Status Window Definitions -- */

/*
    The format of a Status Window defintion is:

First Row:

    Status Window Title     Widget Name     Number of Columns


Rest of Structure:

     Title String           Window            Column  Height  History
                                               Num             Size

    If only 4 arguments are given then a duplicate window is created,
    displaying the same source as an existing window.

     Title String           Window            Column  Height
                                               Num
*/

lconstant agent_layout = [
    {'Agent Status'         agent_win           2}

    {'Sim Agent'            sim_agent_out       1       380     10}
    {'Gl Agent'             gl_agent_out        1       70      10}
    {'Gl Attrib'            gl_attrib_out       2       200     10}
    {'Body State'           body_state_out      2       250     10}
    ];

lconstant parent_layout = [
    {'Parent Status'        parent_win          1}

    {'Gl Parent'            parent_out          1       250     10}
    {'Gl Children'          children_out        1       200     10}
    ];

lconstant child_layout = [
    {'Child Status'         child_win           1}

    {'Gl Child'             child_out           1       100     10}
    {'Gl Specialist'        specialist_out      1       350     10}
    ];

lconstant internal_layout = [
    {'Internal Status'      internal_win        2}

    {'Motivations'          motivations_out     1       200     10}
    {'Emotion'              emotion_out         1       170     10}
    {'Drive'                drive_out           1        40     10}
    {'Selected Behaviour'   behaviour_out       2        80     10}
    {'Incentive Stimulus'   stimulus_out        2        80     10}
    {'Effect of Emotion'
                            e_effect_out        2       100     10}
    {'Effect of Behaviour'  b_effect_out        2       130     10}
    ];

lconstant sensors_layout = [
    {'Sensors'              sensors_win         1}
    ];

lconstant activation_layout = [
    {'Activation Trace'     activation_win      1}

    {'Activation Data'      activation_out      1       480     50}
    ];

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

/* -- File Dialogs -- */

lvars open_dialog;                  /* for loading new experiments        */
lvars save_dialog;                  /* for saving existing experiments    */
lvars trace_dialog;                 /* for saving the trace window        */
lvars goto_dialog;                  /* for entering the goto cycle number */
lvars about_dialog;                 /* for displaying about message       */
lvars getting_started_dialog;       /* for displaying help message        */

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

vars my_cycle_number;				/* global var tracking cycle number */

/* -- Scrollable Status Window Displays -- */

vars motivations_out;               /* for "Internal" status window     */
vars emotion_out;
vars e_effect_out;
vars drive_out;
vars behaviour_out;
vars stimulus_out;
vars b_effect_out;

vars body_state_out;                /* for "Sim Agent" status window    */

vars parent_out;                    /* for "Parent" status window       */
vars children_out;

vars child_out;                     /* for "Child" status window        */
vars specialist_out;

vars activation_out;                /* for "Activation" status window   */

/* -- Status Windows -- */

vars sensors_win;
vars internal_win;
vars child_win;
vars parent_win;
vars activation_win;

/* -- gl_agent.p Status Windows -- */

vars blank_win;
vars debug_win;
vars agent_win;
vars sim_data_win;

/* -- gl_agent.p Output Streams -- */
vars debug_out;
vars sim_agent_out;
vars sim_data_out;
vars gl_agent_out;
vars gl_attrib_out;

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

    if new_eye_position == gl_eye_position(agent) then return endif;

    if gl_display(gl_window) and GlValidLoc(explode(gl_loc(agent)))
            and lmember(agent, rc_window_contents
                                    (gl_gridland_widget(gl_window))) then

        rc_pic_lines(agent);            /* save rc_pic_lines */

        gl_eye_pic(agent) -> rc_pic_lines(agent);
        rc_draw_linepic(agent);

        new_eye_position -> gl_eye_position(agent);
        rc_draw_linepic(agent);

        -> rc_pic_lines(agent);         /* restore rc_pic_lines */
    else
        new_eye_position -> gl_eye_position(agent);
    endif;
enddefine;

/* -- Title Strings -- */

lconstant phd_str   = '"Concern Processing in Autonomous Agents" ' ><
                            '- PhD Thesis';
lconstant ver_str   = 'Steve Allen, 1 Nov 2000';
lconstant exp_str   = 'Exp3a - Compentence Level 0';

lconstant message_str = [
    'Experiment 3a concentrates on the base competence layer of the '
    'Abbott3 architecture.'
    ];

lconstant help_str = [
    'The easiest way to get started is simply to select "Run" from the '
    'Run Menu and sit back and watch. Other options under the Run Menu '
    'allow you "pause", "single step", or "goto" a specific cycle '
    'number. Experiments (runs of the scenario) can be loaded/saved '
    'under the File Menu or restarted using the "reset" command.\n\n'
    'However, the real power of the Gridland Scenario, lies in its '
    'ability to interact, in real-time, with the SIM_AGENT toolkit. '
    'The Gridland world has a mouse driven graphical interface. This '
    'allows objects to be dragged around the screen (select the agent '
    'with the left mouse button), or the status, trace, and debug '
    'options to be set for a specific agent (select the agent with the '
    'right mouse button). By working down the hierarchy of debug '
    'options with the mouse ("Set Trace", "Debug", "Chatty", ...) it is '
    'also possible to set individual debug/trace flags for each '
    'agent.\n\n'
    'Abbott3 is implemented as a parent/child Society of Mind model. '
    'To access the child society agents use the "List" then "Children" '
    'commands in the popup menu (to get the popup menu select Abbott '
    'with the right mouse button).\n\n'
    'The default number, and type, of objects is set in the "control.p" '
    'file. Happy experimenting.\n\n\n'
    'File Menu\n=========\n'
    '  New   - start a new experiment\n'
    '  Reset - reset an existing experiment\n'
    '  Open  - open an experiment from disk\n'
    '  Save  - save an experiment to disk\n'
    '  Quit  - quit the program\n\n'
    'Run Menu\n========\n'
    '  Pause    - pause the current experiment\n'
    '  Single   - single step the experiment\n'
    '  Big Step - go to the next world cycle time\n'
    '  Run      - run the experiment\n'
    '  Goto     - go to a specific cycle number\n\n'
    'System Menu\n===========\n'
    '  CPU Cycle Time - set the scheduler cycle time in ms\n'
    '  Save Trace     - save writes to Trace window to disk\n'
    '  Trace          - switch debug trace display on/off \n'
    '  Display        - switch display on/off\n\n'
    'Status Menu (repeated on the status window menu bar)\n'
    '===========\n'
    '  No Status    - don\'t display a status window\n'
    '  Debug Trace  - display debug trace window\n'
    '  Agent Status - display agent status window\n'
    '  Sim Data     - display database status window\n'
    '  Activation Trace - display activation trace window\n'
    '  Parent       - display parent specific status window\n'
    '  Child        - display child specific status window\n'
    ;;;'  Internal     - display internal status window\n'
    '  Sensors      - display the agent (Abbott) sensors\n\n'
    'Use the right mouse button, over the agent of interest, to: (i) '
    '"show" data in the trace window; or (ii) "set trace" for '
    'continual updates. Selecting a window whilst the experiment is '
    'running will set the trace flag of the active Abbott for that '
    'window.\n\n'
    'Gridsize\n========\n'
    '  Select different grid size arrangements.\n\n'
    'Agents\n======\n'
    '  List all the agents active in Gridland in a popup scrollable '
    'menu. Use the mouse to select the agent of interest and display '
    'status info and/or set trace and debug flags. Abbott agents also '
    'give you an option to list the select the child agents that make '
    'up the Society of Mind architecture.\n\n'
    'Test\n====\n'
    '  A hook to hang simple test routines off.'
    ];

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

    dlocal cucharout = StatusCharout;               /* redirect output */

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

    /* destroy the window */

    XtDestroyWidget(gl_shell_widget(gl_window));
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
            30, 30, 8, "array", [450 ^activation_layout ^agent_layout
                ^parent_layout ^child_layout
                    ^sensors_layout]);

    AddMenuBar(gl_menu_widget(gl_window));

    /* add file selection boxes */

    GlAddFileSelectionDialog(filepath, FILE_MASK, "open") -> open_dialog;
    XtUnmanageChild(XtNameToWidget(open_dialog, 'Help'));
    XtAddCallback(open_dialog, XmN cancelCallback, GlPopdownCB, NONE);
    XtAddCallback(open_dialog, XmN okCallback, GlFileSelectionCB, "open");

    GlAddFileSelectionDialog(filepath, FILE_MASK, "save") -> save_dialog;
    XtUnmanageChild(XtNameToWidget(save_dialog, 'Help'));
    XtAddCallback(save_dialog, XmN cancelCallback, GlPopdownCB, NONE);
    XtAddCallback(save_dialog, XmN okCallback, GlFileSelectionCB, "save");

    GlAddFileSelectionDialog(filepath, '*.txt', "save") -> trace_dialog;
    XtUnmanageChild(XtNameToWidget(trace_dialog, 'Help'));
    XtAddCallback(trace_dialog, XmN cancelCallback, GlPopdownCB, NONE);
    XtAddCallback(trace_dialog, XmN okCallback, GlFileSelectionCB,
															"trace_file");

    /* add goto dialog */

    AddGotoDialog() -> goto_dialog;
    XtAddCallback(goto_dialog, XmN okCallback, GotoCycleCB, "ok");

    /* add help dialogs */

    AddAboutDialog() -> about_dialog;
    AddGettingStartedDialog() -> getting_started_dialog;

    /* add sensors */

    lvars window_xsize = 49;
    lvars window_ysize = 49;
    lvars eye_title, eye_values_title, eye_timestamp_title;

    XptVal[fast] (gl_widget(sensors_win))(XtN background)
                                                    -> gl_eye_background;

    XtCreateManagedWidget('sensor_window',
                xpwGraphicWidget, gl_form_widget(sensors_win),
                XptArgList([
                {leftAttachment ^XmATTACH_FORM}
                {leftOffset 20}
                {topAttachment ^XmATTACH_FORM}
                {topOffset 70}
                {bottomAttachment ^XmATTACH_FORM}
                {bottomOffset 30}
                {width ^window_xsize} {height ^window_ysize}])
                ) -> gl_eye_widget;

    syssleep(rc_window_sync_time);

    GlManageStatusWindow(sensors_win);

    XtCreateManagedWidget('Eye',
                xmLabelWidget, gl_form_widget(sensors_win),
                XptArgList([
                {leftAttachment ^XmATTACH_OPPOSITE_WIDGET}
                {leftWidget ^gl_eye_widget}
                {bottomAttachment ^XmATTACH_WIDGET}
                {bottomWidget ^gl_eye_widget}
                {bottomOffset 10}
                ]) ) -> eye_title;

    XtCreateManagedWidget('Cycle:',
                xmLabelWidget, gl_form_widget(sensors_win),
                XptArgList([
                {leftAttachment ^XmATTACH_WIDGET}
                {leftWidget ^gl_eye_widget}
                {leftOffset 10}
                {bottomAttachment ^XmATTACH_OPPOSITE_WIDGET}
                {bottomWidget ^gl_eye_widget}
                ]) ) -> eye_timestamp_title;

    XtCreateManagedWidget('Value:',
                xmLabelWidget, gl_form_widget(sensors_win),
                XptArgList([
                {rightAttachment ^XmATTACH_OPPOSITE_WIDGET}
                {rightWidget ^eye_timestamp_title}
                {bottomAttachment ^XmATTACH_WIDGET}
                {bottomWidget ^eye_timestamp_title}
                ]) ) -> eye_values_title;

    XtCreateManagedWidget('',
                xmLabelWidget, gl_form_widget(sensors_win),
                XptArgList([
                {leftAttachment ^XmATTACH_WIDGET}
                {leftWidget ^eye_values_title}
                {bottomAttachment ^XmATTACH_OPPOSITE_WIDGET}
                {bottomWidget ^eye_values_title}
                ]) ) -> gl_eye_values;

    XtCreateManagedWidget('0',
                xmLabelWidget, gl_form_widget(sensors_win),
                XptArgList([
                {leftAttachment ^XmATTACH_WIDGET}
                {leftWidget ^eye_timestamp_title}
                {bottomAttachment ^XmATTACH_OPPOSITE_WIDGET}
                {bottomWidget ^eye_timestamp_title}
                ]) ) -> gl_eye_timestamp;

    syssleep(rc_window_sync_time);

    rc_new_window_object( 0, 0, window_xsize, window_ysize,
                    {-1 ^window_ysize 1 -1}, "hidden") -> gl_eye_win;

	;;; The next two commands are needed for new format of windows.
	;;; Heaven knows if it will always work. [A.S. Tue May 18 12:23:20 BST 1999]
    gl_eye_widget -> rc_widget(gl_eye_win);
	gl_form_widget(sensors_win) -> rc_window_shell(gl_eye_win);

    true -> rc_window_realized(gl_eye_win);
    true -> rc_window_visible(gl_eye_win);

    gl_eye_win -> rc_window_object_of(gl_eye_widget);
    gl_eye_win -> rc_current_window_object;

    lvars x;
    'black' -> rc_foreground(rc_window);
    for x from 10 by 10 to 40 do
        rc_drawline( x, 0, x, window_ysize);
        rc_drawline( 0, x, window_xsize, x);
    endfor;

    gl_gridland_widget(gl_window) -> rc_current_window_object;

    GlManageStatusWindow(debug_win);

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

    unless rc_window_contents(gl_gridland_widget(gl_window)) == [] then
        GlSetupGrid("array");
    endunless;

    if XptIsLiveType(gl_list_widget(gl_window), "Widget") then
        XtDestroyWidget(XtParent(gl_list_widget(gl_window)));
    endif;

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

    /* clear status windows */

    GlClrWin(activation_win);
    GlClrWin(debug_win);
    GlClrWin(sim_data_win);
    GlClrWin(agent_win);
    ;;;GlClrWin(internal_win);
    GlClrWin(child_win);
    GlClrWin(parent_win);

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

    GlUpdateCycleCount();
    GlUpdateStatusBanner();

	sim_cycle_number -> my_cycle_number;

    if gridland_state == "goto" and sim_cycle_number >= goto_cycle then
        old_display -> GlDisplayAgents();
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
                ;;;GlClrWin(internal_win);
            endif;
        endif;
    endif;

    /* perform any trace actions before running the agent */

    if isgl_agent(gl_status_trace(gl_window) ->> obj) then
        ShowStatus(obj, false);
    endif;

    if isgl_agent(gl_data_trace(gl_window) ->> obj) then
        ShowData(obj, false);
    endif;

    /* process new commands and wait for cycle timer */

    repeat

        /* synchronise with timer if cycle_time is set */

        if gridland_state == "run" and cycle_time then
            until cycle_done then syshibernate() enduntil;
            false -> cycle_done;
        else
            syssleep(1);
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

                case == "save" then
					if isstring(data) then
        				if sys_fname_extn(data) == nullstring then
            				data >< sys_fname_extn(FILE_MASK) -> data;
        				endif;
        				WriteExperiment(NewExperiment(data));
					else
                    	true -> GlDisplayAgents();
                    	"pause" -> gridland_state;
                    	false -> sys_timer(CycleTimer);
                    	GlRefreshFileDir(save_dialog);
                    	XtManageChild(save_dialog);
					endif;

                case == "open" then
					if isstring(data) then
        				if sys_fname_extn(data) == nullstring then
            				data >< sys_fname_extn(FILE_MASK) -> data;
        				endif;
        				if readable(data) then
            				NewExperiment(data) -> data;
            				if ReadExperiment(data) then
                				data -> NewExperiment();
								"new_expt" -> gridland_state;
                				exitto(sim_scheduler);
            				endif;
        				endif;
					else
                    	true -> GlDisplayAgents();
                    	false -> sys_timer(CycleTimer);
                    	"pause" -> gridland_state;
                    	GlRefreshFileDir(open_dialog);
                    	XtManageChild(open_dialog);
					endif;

                case == "quit" then
                    "quit" -> gridland_state;
                    false -> sys_timer(CycleTimer);
                    exitto(sim_scheduler);

                case == "set_count" then
					if isinteger(data) then
                    	data -> sim_cycle_number;
                    	GlUpdateCycleCount();
                    	GlUpdateStatusBanner();
					endif;

                case == "goto" then
					if data == false then
						/* ask for cycle number */
			        	XmTextSetString(XtNameToWidget(goto_dialog,
                                        'Message.Text'), nullstring);
        				XtManageChild(goto_dialog);
                    elseif isinteger(data) and data > sim_cycle_number then
						data -> goto_cycle;
						unless "goto" == gridland_state then
                        	GlDisplayAgents() -> old_display;
                        	gl_trace(gl_window) -> old_trace;
                        	gl_active_agent(gl_window) -> old_active_agent;
						endunless;
                        false -> GlDisplayAgents();
                        false -> gl_trace(gl_window);
                        false -> gl_active_agent(gl_window);
                        "goto" -> gridland_state;
                    elseif isinteger(data) and data < sim_cycle_number then
                    	if gridland_state == "goto" then
                        	old_display -> GlDisplayAgents();
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
                        old_display -> GlDisplayAgents();
                        old_trace -> gl_trace(gl_window);
                        old_active_agent -> gl_active_agent(gl_window);
                    endif;
                    GlDisplayAgents() -> old_display;
                    gl_trace(gl_window) -> old_trace;
                    gl_active_agent(gl_window) -> old_active_agent;
                    ((sim_cycle_number - 1) div WORLD_CYCLE_TIME + 1)
                        * WORLD_CYCLE_TIME + 1 -> goto_cycle;
                    "goto" -> gridland_state;

                case == "step" then
					if isinteger(data) and data > 1 then
						sim_cycle_number + data -> goto_cycle;
						unless gridland_state == "goto" then
                        	GlDisplayAgents() -> old_display;
                        	gl_trace(gl_window) -> old_trace;
                        	gl_active_agent(gl_window) -> old_active_agent;
						endunless;
                        false -> GlDisplayAgents();
                        false -> gl_trace(gl_window);
                        false -> gl_active_agent(gl_window);
                        "goto" -> gridland_state;
					else
                    	if gridland_state == "goto" then
                        	old_display -> GlDisplayAgents();
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
                        old_display -> GlDisplayAgents();
                        old_trace -> gl_trace(gl_window);
                        old_active_agent -> gl_active_agent(gl_window);
                    endif;
                    "pause" -> gridland_state;
                    false -> sys_timer(CycleTimer);

                case == "run" then
                    if gridland_state == "goto" then
                        old_display -> GlDisplayAgents();
                        old_trace -> gl_trace(gl_window);
                        old_active_agent -> gl_active_agent(gl_window);
                    endif;
                    "run" -> gridland_state;
                    if cycle_time then
                        false -> cycle_done;
                        cycle_time -> sys_timer(CycleTimer);
                    endif;

                case == "display" then
					if isboolean(data) then
                    	data ->> old_display -> GlDisplayAgents();
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

    			case == "trace_file" then
			        if data == "close_file" then
            			if isdevice(gl_trace_dev(gl_window)) then
                			sysflush(gl_trace_dev(gl_window));
                			sysclose(gl_trace_dev(gl_window));
                			false -> gl_trace_dev(gl_window);
                			false -> gl_trace_file(gl_window);
            			endif;
					elseif isstring(data) then
        				"file" -> gl_trace(gl_window);
        				if sys_fname_extn(data) == nullstring then
            				data >< sys_fname_extn('*.txt') -> data;
        				endif;
        				syscreate(data, 1, "line")
											-> gl_trace_dev(gl_window);
        			elseif isgl_status_win(data) then
            			data -> gl_trace_file(gl_window);
            			unless isdevice(gl_trace_dev(gl_window)) then
                			GlRefreshFileDir(trace_dialog);
                			XtManageChild(trace_dialog);
            			endunless
        			endif;

			   	case == "trace" then
        			if isboolean(data) then
						data -> gl_trace(gl_window);
					endif;
        			if data then GlManageStatusWindow(debug_win) endif;

				case == "exec" then
					if isvector(data) then explode(data) -> data endif;
					if isword(data) then valof(data) -> data; endif;
        			if isprocedure(data) then data(); endif;

				case == "list_agents" then
        			unless XptIsLiveType(gl_list_widget(gl_window),
																"Widget") then
            			GlAddAgentListDialog('Agents', gl_agents(gl_window))
                                            	-> gl_list_widget(gl_window);
        			endunless;
        			XtManageChild(gl_list_widget(gl_window));

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
            			;;;GlClrWin(internal_win);
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

						/* destroy popup menu */
                        if XptIsLiveType(gl_list_widget(parent),
															"Widget") then
                            XtDestroyWidget(
										XtParent(gl_list_widget(parent)));
                        endif;

					/* process agents with world presence */
                    elseif isgl_attrib(obj) then
                        GlRemoveAgent(obj);
                        delete(obj, gl_agents(gl_window))
                                                    -> gl_agents(gl_window);
                        delete(obj, active_agents) -> active_agents;
                        delete(obj, sim_objects) -> sim_objects;

						/* destroy popup menu */
                        if XptIsLiveType(gl_list_widget(gl_window),
                                                       		"Widget") then
                            XtDestroyWidget(
									XtParent(gl_list_widget(gl_window)));
                        endif;
                    endif;

				/*
					commands from the popup menu call back
				*/

		        case == "active" then
		            if isgl_abbott(obj) then
        		        obj -> gl_active_agent(gl_window);
                		GlManageStatusWindow(debug_win);
            		endif;

				case == "show_blank" then
            			GlManageStatusWindow(blank_win);
					
        		case == "show_debug" then
					GlManageStatusWindow(debug_win);

        		case == "show_status" then
    				if isgl_agent(obj) then
						/* clears the window first */
            			ShowStatus(obj, true);
            			GlManageStatusWindow(agent_win);
						endif;

        		case == "show_data" then
    				if isgl_agent(obj) then
						/* clears the window first */
            			ShowData(obj, true);
            			GlManageStatusWindow(sim_data_win);
					endif;

		        case == "show_sensors" then
        		    if isgl_parent(obj) then
                		ShowSensors(obj);
                		GlManageStatusWindow(sensors_win);
            		endif;

                /*
        		case == "show_internal" then
            		if isgl_parent(obj) then
                		ShowInternalStatus(obj, true);
                		GlManageStatusWindow(internal_win);
            		endif;
                */
        		case == "trace_status" then
            		if data then
                		GlManageStatusWindow(agent_win);
                		obj;
            		else false endif -> gl_status_trace(gl_window);

        		case == "trace_data" then
            		if data then
                		GlManageStatusWindow(sim_data_win);
                		obj;
            		else false endif -> gl_data_trace(gl_window);

        		case == "trace_sensors" then
            		if data then
                		GlManageStatusWindow(sensors_win);
                		obj;
            		else false endif -> gl_sensor_trace(gl_window);
                /*
        		case == "trace_internal" then
            		if data then
                		GlManageStatusWindow(internal_win);
                		obj;
            		else false endif -> gl_internal_trace(gl_window);
                */
        		case == "trace_activation" then
            		if data then
                		GlManageStatusWindow(activation_win);
                		obj;
            		else false endif -> gl_activation_trace(gl_window);

        		case == "trace_debug" then
            		if isgl_agent(obj) then
                		GlManageStatusWindow(debug_win);
                		data -> gl_debug_level(obj);
                		false -> gl_prb_chatty(obj);
                		false -> gl_prb_show_conditions(obj);
                		if data > 0 then
                    		GlManageStatusWindow(debug_win);
                    		true -> gl_trace(gl_window);
                		else
                    		false -> gl_trace(gl_window);
                		endif;
            		endif;

        		case == "chatty" then
            		if isgl_agent(obj) then
                		2 -> gl_debug_level(obj);
                		GlManageStatusWindow(debug_win);
                		true -> gl_trace(gl_window);
                		if isnumber(gl_prb_chatty(obj)) and isnumber(data) then
                    		if gl_prb_chatty(obj) mod data == 0 then
                        		gl_prb_chatty(obj) div data ->
															gl_prb_chatty(obj);
                        		if gl_prb_chatty == 0 then
                            		false -> gl_prb_chatty(obj);
                        		endif;
                    		else
                        		gl_prb_chatty(obj) * data ->
															gl_prb_chatty(obj);
                    		endif;
                		else
                    		data -> gl_prb_chatty(obj);
                		endif;
                		if gl_prb_show_conditions(obj) == false and
                                   		gl_prb_chatty(obj) == false then
                    		0 -> gl_debug_level(obj);
                		endif;
            		endif;

        		case == "conditions" then
            		if isgl_agent(obj) then
                		2 -> gl_debug_level(obj);
                		GlManageStatusWindow(debug_win);
                		true -> gl_trace(gl_window);
                		data -> gl_prb_show_conditions(obj);
                		if gl_prb_show_conditions(obj) == false and
                                        gl_prb_chatty(obj) == false then
                    		0 -> gl_debug_level(obj);
                		endif;
            		endif;

        		case == "list_children" then
            		if isgl_parent(obj) then
                		unless XptIsLiveType(gl_list_widget(obj),
														"Widget") then
                    		GlAddAgentListDialog('Children of ' ><
									sim_name(obj), gl_children(obj))
												-> gl_list_widget(obj);
                		endunless;
                		XtManageChild(gl_list_widget(obj));
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
    dlocal prb_chatty = gl_prb_chatty(agent);
    dlocal prb_show_conditions = gl_prb_show_conditions(agent);

    if gl_debug_level(agent) == 2 and gl_trace(gl_window) then
        GlPrWin(debug_out, sprintf('=== Agent: %p, cycle %p ===',
                        [^(sim_name(agent)) ^sim_cycle_number]));
    endif;

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
            GlPrWin(debug_out, item);       /* redirect to debug window   */
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

    if XptIsLiveType(gl_list_widget(gl_window), "Widget") then
        XtDestroyWidget(XtParent(gl_list_widget(gl_window)));
    endif;

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
        false -> rc_oldx(i);
        false -> rc_oldy(i);
        SetupAgentRcGraphic(i);
        GlAddAgent(i);
        if isgl_parent(i) then
            if XptIsLiveType(gl_list_widget(i), "Widget") then
                XtDestroyWidget(XtParent(gl_list_widget(i)));
            endif;
        endif;
    endfor;

    /* clear trace values */

    false -> gl_activation_trace(gl_window);
    false -> gl_sensor_trace(gl_window);
    false -> gl_internal_trace(gl_window);
    false -> gl_status_trace(gl_window);
    false -> gl_data_trace(gl_window);

    /* clear status windows */

    GlClrWin(activation_win);
    GlClrWin(debug_win);
    GlClrWin(sim_data_win);
    GlClrWin(agent_win);
    ;;;GlClrWin(internal_win);
    GlClrWin(child_win);
    GlClrWin(parent_win);

    /* set new position */

    GlUpdateCycleCount();
    GlUpdateStatusBanner();

enddefine;


/* ====================================================================== */


/*
    Mouse Events
    ============

    rc_button_1_up(pic, newx, newy, modifiers);
    rc_button_1_down(pic, newx, newy, modifiers);
    rc_button_1_drag(pic, newx, newy, modifiers);
*/

/***************************************************************************
NAME
    rc_button_1_up

SYNOPSIS
    rc_button_1_up(pic, newx, newy, modifiers);

FUNCTION
    Deals with actions when the mouse button 1 is released. This causes
    the object that has been selected / dragged to be updated in the
    world in the new position (i.e. the physical gridland world is
    updated to reflect the change). If the current position is occupied
    the the object springs back to its original location. It is
    therefore important that the old location hasn't been occupied in
    the meantime (i.e. the simulation is stopped). The object is first
    removed before being re-added to allow for possible overlap between
    the old and new positions.

    If the mouse is moved off the gridland window, but the object is
    still selected then rc_button_1_up() needs to be called with the
    rc_mouse-selected(rc_active_window_object).

RETURNS
    None.
***************************************************************************/
define :method rc_button_1_up(pic:rc_window_object, newx, newy, modifiers);
    lvars picm newx, newy, modifiers;

    lvars active_pic = rc_mouse_selected(rc_active_window_object);
    if isgl_attrib(active_pic) then
        rc_button_1_up(active_pic, newx, newy, modifiers);
    endif;
enddefine;

define :method rc_button_1_up(agent:gl_attrib, newx, newy, modifiers);
    lvars agent, newx, newy, modifiers;
    lvars x, y;

    if obj_dragged then
        GlRcToGridX(newx) -> newx;
        GlRcToGridY(newy) -> newy;

        if GlCellUnoccupied(agent, newx, newy) then
            GlRemoveAgent(agent);
            {^newx ^newy} -> gl_loc(agent);
            GlAddAgent(agent);
        else
            /* move agent back to original location */
            explode(gl_loc(agent)) -> (x, y);
            rc_move_to(agent, GlGridXToRc(x), GlGridYToRc(y), true);
        endif;
    endif;
enddefine;


/***************************************************************************
NAME
    rc_button_1_down

SYNOPSIS
    rc_button_1_down(pic, newx, newy, modifiers);

FUNCTION
    Pauses the simulation and calls the next method to select the
    object under the mouse.

RETURNS
    None.
***************************************************************************/
define :method rc_button_1_down(pic:gl_agent, x, y, modifiers);
    lvars pic, x, y, modifiers;

    [pause] -> new_commands;
    false -> obj_dragged;
    call_next_method(pic, x, y, modifiers);
enddefine;


/***************************************************************************
NAME
    rc_button_1_drag

SYNOPSIS
    rc_button_1_drag(pic, newx, newy, modifiers);

FUNCTION

    Calls the next method with the rc_mouse-selected(rc_active_window
    _object). This catches the case when one object is dragged over
    another such that the object under the mouse is not necessarily
    the same as the one being dragged.

RETURNS
    None.
***************************************************************************/
define :method rc_button_1_drag(pic:rc_window_object, x, y, modifiers);
    if modifiers = 's' or modifiers = nullstring then
        lvars current_selected = rc_mouse_selected(rc_active_window_object);

        if isgl_attrib(current_selected) then
            true -> obj_dragged;
            rc_set_front(current_selected);
            rc_move_to(current_selected, x, y, true);
        endif
    endif
enddefine;

define :method rc_button_1_drag(pic:gl_attrib, x, y, modifiers);
    lvars pic, x, y, modifiers;

    lvars active_pic = rc_mouse_selected(rc_active_window_object);
    if isgl_attrib(active_pic) then
        true -> obj_dragged;
        call_next_method(active_pic, x, y, modifiers);
    endif;

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
            ;;;GlClrWin(internal_win);
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

/* ====================================================================== */

/*
    Menus
    =====

    GlBuildPopup(obj, popup);               - insert name etc. into title
    AddPopupMenu(name, parent, x, y)
								-> popup;   - add a popup menu
    AddParentPopupMenu(name, parent, x, y)
                                -> popup;   - add a popup menu for a parent
    GlPopupMenu(obj, x, y) -> popup;        - returns the popup menu for obj
    AddMenuBar(parent);                     - add a menu bar
*/

/***************************************************************************
NAME
    GlBuildPopup;

SYNOPSIS
    GlBuildPopup(obj, popup);

FUNCTION
    Customises the popup menu for each agent adding flag info and agent
    name to the popup title. The agent "obj" is added to the "gl_obj"
    slot of the menu.

RETURNS
    None.
***************************************************************************/
define vars procedure GlBuildPopup(obj, popup);
    lvars obj, popup, num;

    lvars flags = [%
        if gl_status_trace(gl_window) == obj then 'St' endif;
        if gl_activation_trace(gl_window) == obj then 'Act' endif;
        if gl_sensor_trace(gl_window) == obj then 'Sn' endif;
        if gl_data_trace(gl_window) == obj then 'Da' endif;
        ;;;if gl_internal_trace(gl_window) == obj then 'In' endif;
        if gl_active_agent(gl_window) == obj then 'Mon' endif;
        if gl_debug_level(obj) == 1 then 'DaF' endif;
        if gl_debug_level(obj) == 2 then
            if isnumber(gl_prb_chatty(obj) ->> num) then
                if num mod 2 == 0 then 'Ins' endif;
                if num mod 3 == 0 then 'WhT' endif;
                if num mod 5 == 0 then 'Dat' endif;
                if num mod 7 == 0 then 'Apy' endif;
                if num mod 11 == 0 then 'App' endif;
                if num mod 13 == 0 then 'DaC' endif;
                if num mod 17 == 0 then 'Rul' endif;
            elseif isboolean(gl_prb_chatty(obj)) and gl_prb_chatty(obj) then
                'Cha'
            endif;
            if gl_prb_show_conditions(obj) then 'Con' endif;
        endif;
        %];

    if flags == [] then
        '' -> flags
    else
        '\n' >< flags -> flags;
    endif;

    lvars str = GlXmString('Agent: ' >< sim_name(obj) >< flags);
    str -> XptValue(gl_title_widget(popup), XmN labelString, TYPESPEC(:XmString));
    XmStringFree(str);


    obj -> gl_obj(popup);
enddefine;


/***************************************************************************
NAME
    AddPopupMenu;

SYNOPSIS
    AddPopupMenu(name, parent, x, y) -> popup;

FUNCTION
    Add a popup menu to display agent status info and set debug levels.

    The menu is held in a "menu" object to allow access to the title and
    popup widgets. The "menu" object also has a slot to hold the current
    agent.

RETURNS
    Popup "menu" object.
***************************************************************************/
define lvars procedure AddPopupMenu(name, parent, x, y) /* -> popup */;
    lvars name, parent;
    lvars x, y;
    lvars popup, menu;

    GlNewPopupMenu(name, parent, x, y) -> popup;
    gl_widget(popup) -> menu;

    GlAddMenu('Show', menu, GlPopupCB, [
        {'Status'   {show_status ^popup}}
        {'Data'     {show_data ^popup}}
        ]);

    GlAddMenu('Set Trace', menu, GlPopupCB, [
        {'Status' ^GlPopupCB
            [{'On' {trace_status {^popup ^true}}}
                {'Off' {trace_status {^popup ^false}}}]}
        {'Data' ^GlPopupCB
            [{'On' {trace_data {^popup ^true}}}
                {'Off' {trace_data {^popup ^false}}}]}
        {'Debug' ^GlPopupCB
            [{'No debug' {trace_debug {^popup 0}}}
             {'Database Filter' {trace_debug {^popup 1}}}
             {'Show Conditions' ^GlPopupCB [
                    {'True' {conditions {^popup ^true}}}
                    {'False' {conditions {^popup ^false}}}]}
             {'Chatty' ^GlPopupCB [
                    {'True' {chatty {^popup ^true}}}
                    {'False' {chatty {^popup ^false}}}
                    {'Instances' {chatty {^popup 2}}}
                    {'Where Tests' {chatty {^popup 3}}}
                    {'Database' {chatty {^popup 5}}}
                    {'Applicability' {chatty {^popup 7}}}
                    {'Applicable' {chatty {^popup 11}}}
                    {'Database Change' {chatty {^popup 13}}}
                    {'Show Rules' {chatty {^popup 17}}}]}
        ]} ]);

    GlAddMenu('List', menu, GlPopupCB, [
        {'Agents'   {list_agents ^popup}}
        ]);

    GlAddSeparator(menu);
    GlAddPushButton('Database Filter', menu, GlPopupCB,
                                            {trace_debug {^popup 1}});
    GlAddSeparator(menu);

    GlAddPushButton('Remove Agent', menu, GlPopupCB, {remove ^popup});
    return(popup);
enddefine;


/***************************************************************************
NAME
    AddParentPopupMenu;

SYNOPSIS
    AddParentPopupMenu(name, parent, x, y) -> popup;

FUNCTION
    Add a popup menu to display agent status info and set debug levels.
    A button is added to the end of the standard popup menu to display
    information about the agents composite children.

    The menu is held in a "menu" object to allow access to the title and
    popup gl_widgets. The "menu" object also has a slot to hold the current
    agent.

RETURNS
    Popup "menu" object.
***************************************************************************/
define lvars procedure AddParentPopupMenu(name, parent, x, y) /* -> popup */;
    lvars name, parent;
    lvars x, y;
    lvars popup, menu;

    GlNewPopupMenu(name, parent, x, y) -> popup;
    gl_widget(popup) -> menu;

    GlAddPushButton('Monitor', menu, GlPopupCB, {active ^popup});

    GlAddMenu('Show', menu, GlPopupCB, [
        {'Status'   {show_status ^popup}}
        {'Data'     {show_data ^popup}}
        {'Sensors'  {show_sensors ^popup}}
        ;;;{'Internal Status' {show_internal ^popup}}
        ]);

    GlAddMenu('Set Trace', menu, GlPopupCB, [
        {'Status' ^GlPopupCB
            [{'On' {trace_status {^popup ^true}}}
                {'Off' {trace_status {^popup ^false}}}]}
        {'Data' ^GlPopupCB
            [{'On' {trace_data {^popup ^true}}}
                {'Off' {trace_data {^popup ^false}}}]}
        {'Sensors' ^GlPopupCB
            [{'On' {trace_sensors {^popup ^true}}}
                {'Off' {trace_sensors {^popup ^false}}}]}
        /*{'Internal Status' ^GlPopupCB
            [{'On' {trace_internal {^popup ^true}}}
                {'Off' {trace_internal {^popup ^false}}}]}*/
        {'Activation' ^GlPopupCB
            [{'On' {trace_activation {^popup ^true}}}
                {'Off' {trace_activation {^popup ^false}}}]}
        {'Debug' ^GlPopupCB
            [{'No debug' {trace_debug {^popup 0}}}
             {'Database Filter' {trace_debug {^popup 1}}}
             {'Show Conditions' ^GlPopupCB [
                    {'True' {conditions {^popup ^true}}}
                    {'False' {conditions {^popup ^false}}}]}
             {'Chatty' ^GlPopupCB [
                    {'True' {chatty {^popup ^true}}}
                    {'False' {chatty {^popup ^false}}}
                    {'Instances' {chatty {^popup 2}}}
                    {'Where Tests' {chatty {^popup 3}}}
                    {'Database' {chatty {^popup 5}}}
                    {'Applicability' {chatty {^popup 7}}}
                    {'Applicable' {chatty {^popup 11}}}
                    {'Database Change' {chatty {^popup 13}}}
                    {'Show Rules' {chatty {^popup 17}}}]}
        ]} ]);

    GlAddMenu('List', menu, GlPopupCB, [
        {'Agents'   {list_agents ^popup}}
        {'Children' {list_children ^popup}}
        ]);

    GlAddSeparator(menu);
    GlAddPushButton('Database Filter', menu, GlPopupCB,
                                            {trace_debug {^popup 1}});

    GlAddSeparator(menu);
    GlAddPushButton('Remove Agent', menu, GlPopupCB, {remove ^popup});
    return(popup);
enddefine;

/***************************************************************************
NAME
    GlPopupMenu;

SYNOPSIS
    GlPopupMenu(obj, x, y) -> popup;

FUNCTION
    Returns or creates a popup menu for a gl_parent agent.

RETURNS
    Popup "menu" object.
***************************************************************************/
lvars agent_popup = false;
define :method vars GlPopupMenu(obj:gl_agent, x, y);
    if isgl_menu(agent_popup) and
                    XptIsLiveType(gl_widget(agent_popup), "Widget") then
		XtSetValues(gl_widget(agent_popup), XptArgList([{x ^x} {y ^y}]));
        return(agent_popup);
    else
        return(AddPopupMenu('agent_popup', gl_title_widget(gl_window), x, y)
                                                        ->> agent_popup);
    endif;
enddefine;

lvars parent_popup = false;
define :method vars GlPopupMenu(obj:gl_parent, x, y);
	lvars x, y;

    if isgl_menu(parent_popup) and
                    XptIsLiveType(gl_widget(parent_popup), "Widget") then
		XtSetValues(gl_widget(parent_popup), XptArgList([{x ^x} {y ^y}]));
        return(parent_popup);
    else
        return(AddParentPopupMenu('parent_popup',
                        gl_title_widget(gl_window), x, y) ->> parent_popup);
    endif;
enddefine;


/***************************************************************************
NAME
    AddMenuBar

SYNOPSIS
    AddMenuBar(parent);

FUNCTION
    Creates the menu bar on which various gadets are hung. The menu bar is
    attached to the "parent".

RETURNS
    menu bar widget.
***************************************************************************/
define lvars procedure AddMenuBar(menu_bar);
    lvars menu_bar;
    lvars menu;

    GlAddMenu('File', menu_bar, MenuCB, [{'New' new}
        {'Reset' reset} {'Open' open} {'Save' save}
            separator {'Quit' quit}]);

    GlAddMenu('Run', menu_bar, MenuCB, [{'Pause' pause}
        {'Single Step' step} {'Big Step' big_step}
            {'Run' run} separator {'Goto' goto}]);

    GlAddMenu('System', menu_bar, MenuCB, [
        {'CPU Cycle Time' ^MenuCB [{'No Delay' {cycle ^false}}
            {'20ms' {cycle 20e3}} {'50ms' {cycle 50e3}}
                {'70ms' {cycle 70e3}} {'100ms' {cycle 100e3}}
                    {'200ms' {cycle 200e3}}]}
        {'Save Trace' ^MenuCB [{'Data ->> File' {trace_file ^sim_data_win}}
            {'Debug ->> File' {trace_file ^debug_win}}
                {'Activation ->> File' {trace_file ^activation_win}}
                    {'Close File' {trace_file close_file}}]}
        {'Trace' ^MenuCB [{'Debug On' {trace ^true}}
            {'Debug Off' {trace ^false}}]}
        {'Display' ^MenuCB [{'Display On' {display ^true}}
            {'Display Off' {display ^false}}]} ]);

    GlAddStatusMenu('Status', menu_bar);

    GlAddMenu('Grid Size', menu_bar, MenuCB, [
        {'30x30 by 16' {grid {30 30 16 array}}}
            {'30x30 by 12' {grid {30 30 12 array}}}
                {'30x30 by 10' {grid {30 30 10 array}}}
                  {'30x30 by 8' {grid {30 30 8 array}}}
                    {'15x30 by 10' {grid {15 30 10 array}}}
                        {'15x15 by 32' {grid {15 15 32 array}}}
                            {'60x60 by 8' {grid {60 60 8 nonarray}}}]);

    GlAddMenu('Agents', menu_bar, MenuCB, [{'List Agents' list_agents}]);

    GlAddMenu('Test', menu_bar, MenuCB, [{'Test 1' {exec ^Test1}}
        {'Test 2' {exec ^Test2}} {'Kill Window' {exec ^Test3}}]);

    GlAddMenu('Help', menu_bar, MenuCB, [
        {'Getting Started' {exec ^HelpGettingStarted}}
            {'About' {exec ^HelpAbout}}]);

    /* assign Help menu bar */

    if XptIsLiveType(menu_bar, "Widget") then
        XtUnmanageChild(menu_bar);
    endif;

    XtNameToWidget(menu_bar, 'Help')
            -> XptValue(menu_bar, XmN menuHelpWidget, TYPESPEC(:XptWidget));

    /* manage menu */

    XtManageChild(menu_bar);
enddefine;


/* ====================================================================== */

/*
    Status Windows
    ==============

    GlManageStatusWindow(new);          - select a new status window
    ShowActivation(agent, clear);       - display activation data in window
    ShowData(agent, clear);             - display database table in window
    ActivationSort(i1, i2);             - test for activation level i1 >= i2
    ShowInternalStatus(agent, clear);   - display internal status in window
    ShowStatus(agent, clear);           - display general agent status info
    ShowEye(agent);                     - display contents of eye sensor
    ShowSensors(agent);                 - display all sensor readings
    PrWin(win, data);                   - print the data in the window
*/


/***************************************************************************
NAME
    GlManageStatusWindow

SYNOPSIS
    GlManageStatusWindow(new_status_window);

FUNCTION
    Manage the status windows. If the new window is different to the old,
    then unmanage the old window and display the new. If the scenario is
    running then set the trace to the new window.

RETURNS
    None.
***************************************************************************/
define vars procedure GlManageStatusWindow(new_status_window);
    lvars new_status_window;

    if new_status_window /== gl_current_status_window(gl_window) then

        if gridland_state == "run" then
            false -> gl_sensor_trace(gl_window);
            false -> gl_status_trace(gl_window);
            false -> gl_data_trace(gl_window);
            switchon new_status_window
                case == sensors_win then
                    gl_active_agent(gl_window)
                                            -> gl_sensor_trace(gl_window);
                case == agent_win orcase == parent_win
                                                orcase == child_win then
                    gl_active_agent(gl_window)
                                            -> gl_status_trace(gl_window);
                case == sim_data_win then
                    gl_active_agent(gl_window)
                                            -> gl_data_trace(gl_window);
            endswitchon;
        endif;

        XtUnmanageChild(gl_widget(gl_current_status_window(gl_window)));
        XtManageChild(gl_widget(new_status_window));
        new_status_window -> gl_current_status_window(gl_window);
    endif;
enddefine;


/***************************************************************************
NAME
    ShowActivation

SYNOPSIS
    ShowActivation(agent, clear);

FUNCTION
    Display the activation levels of the various socitity members in the
    Activation status window. This window is mainly used to output data
    to disk for later analysis off-line.

RETURNS
    None.
***************************************************************************/
define :method lvars ShowActivation(agent:gl_agent, clear);
enddefine;

define :method lvars ShowActivation(agent:gl_abbott, clear);
    lvars agent, clear;
    lvars child, temp;

    dlocal pop_pr_ratios = false;
    dlocal pop_=>_flag = '';
    dlocal cucharout = identfn;

    GlTextDisableRedisplay(activation_out);
    stacklength() -> temp;
    ppr(
        [ %
        sim_cycle_number;
        gl_adrenaline(agent);
        gl_pain(agent);
        gl_active_mot(agent);
        for child in gl_drives(agent) do
            gl_act_level(child);
        endfor;
        for child in gl_behaviours(agent) do
            gl_act_level(child);
        endfor;
        %]);
    consstring(stacklength() - temp) -> temp;

    if clear then GlClrWin(activation_out) endif;

    false -> gl_top(activation_out);
    GlPrWin(activation_out, temp);
    GlMkWin(activation_out);
    GlTextEnableRedisplay(activation_out);
enddefine;


/***************************************************************************
NAME
    ShowData

SYNOPSIS
    ShowData(agent, clear);

FUNCTION
    Display the agent database entries in the Data window.

RETURNS
    None.
***************************************************************************/
define :method lvars ShowData(agent:gl_agent, clear);

    lvars agent, clear;
    dlocal pop_pr_places = 3;
    dlocal pop_pr_ratios = false;
    lvars j, data;

    GlTextDisableRedisplay(sim_data_out);

    if clear then GlClrWin(sim_data_out) endif;

    GlMkWin(sim_data_out);
    GlPrWinStatusBanner(sim_data_out);

    GlPrWin(sim_data_out, sprintf('sim_name = %p', [^(sim_name(agent))]));
    if (GlDbtable(sim_data(agent)) ->> data) == [] then
        GlPrWin(sim_data_out, 'sim_data = []');
    else
        GlPrWin(sim_data_out, 'sim_data = [');
        for j in data do
            GlPrWin(sim_data_out, '  ' >< j);
        endfor;
        GlPrWin(sim_data_out, '  ]');
    endif;

	if isproperty(sim_shared_data(agent)) then
  		if (GlDbtable(sim_shared_data(agent)) ->> data) == [] then
      		GlPrWin(sim_data_out, 'sim_shared_data = []');
    	else
       		GlPrWin(sim_data_out, 'sim_shared_data = [');
       		for j in data do
           		GlPrWin(sim_data_out, '  ' >< j);
       		endfor;
       		GlPrWin(sim_data_out, '  ]');
		endif;
	endif;

    GlTopWin(sim_data_out);
    GlTextEnableRedisplay(sim_data_out);

enddefine;


/***************************************************************************
NAME
    ActivationSort

SYNOPSIS
    ActivationSort(i1, i2);

FUNCTION
    Comparison function of activation levels for the sort routine.

RETURNS
    True if activation level of i1 >= i2.
***************************************************************************/
define lvars procedure ActivationSort(i1, i2) /* -> bool */;
    lvars i1, i2;
    gl_act_level(i1) >= gl_act_level(i2);
enddefine;


/***************************************************************************
NAME
    ShowInternalStatus

SYNOPSIS
    ShowInternalStatus(agent, clear);

FUNCTION
    Display the agent internal status entries in the Internal Status window.
    Changes in the internal state of Abbott are attributed to either
    behaviours or emotions dependent on the type of child agent that
    initiated the change. These effects are displayed in separate windows
    and then reset.

RETURNS
    None.
***************************************************************************/
define :method lvars ShowInternalStatus(agent:gl_parent, clear);
    lvars agent, clear;
    dlocal pop_pr_places = 3;
    dlocal pop_pr_ratios = false;
    lvars i, val, obj, slots;

    GlTextDisableRedisplay(internal_win);

    /* clear windows */

    if clear then
        GlClrWin(internal_win);
        GlMkWin(internal_win);
        GlPrWinStatusBanner(motivations_out);
    else
        GlMkWin(internal_win);
        GlPrWinStatusBanner(internal_win);
    endif;

    GlTextEnableRedisplay(internal_win);
enddefine;


/***************************************************************************
NAME
    ShowStatus

SYNOPSIS
    ShowStatus(agent, clear);

FUNCTION
    Display the agent status entries in the Status windows. The generic
    routine displays the sim_agent/sim_object slots, the gl_agent slots,
    the gl_attrib slots and the gl_body_state slots. Seprate methods also
    add parent and child specific slots to the list.

RETURNS
    None.
***************************************************************************/
define :method lvars ShowStatus(agent:gl_agent, clear);
    lvars agent, clear;
    dlocal pop_pr_places = 3;
    dlocal pop_pr_ratios = false;
    lvars i, j, data, slots;

    GlTextDisableRedisplay(agent_win);

    /* clear windows */

    if clear then
        GlClrWin(agent_win);
        GlClrWin(child_win);
        GlClrWin(parent_win);
    endif;

    /* sim agent slots */

    GlMkWin(agent_win);

    if issim_agent(agent) then
        class_slots(sim_agent_key) -> slots;
    elseif issim_object(agent) then
        class_slots(sim_object_key) -> slots;
    else
        [] -> slots;
    endif;
    unless slots == [] then
        GlPrWinStatusBanner(sim_agent_out);
        for i in slots do
         	GlPrWin(sim_agent_out, sprintf('%p = %p',
                                              [% pdprops(i),  i(agent) %]));
        endfor;
    endunless;

    /* gl_agent slots */

    if isgl_agent(agent) then
        class_slots(gl_agent_key) -> slots;
        GlPrWinStatusBanner(gl_agent_out);
        for i in slots do
            GlPrWin(gl_agent_out, sprintf('%p = %p',
                                              [% pdprops(i),  i(agent) %]));
        endfor;
    endif;

    /* gl_attrib slots */

    if isgl_attrib(agent) then
        class_slots(gl_attrib_key) -> slots;
        GlPrWinStatusBanner(gl_attrib_out);
        for i in slots do
            GlPrWin(gl_attrib_out, sprintf('%p = %p',
                                              [% pdprops(i),  i(agent) %]));
        endfor;
    endif;

    /* body state slots */

    if isgl_body_state(agent) then
        GlPrWinStatusBanner(body_state_out);
        class_slots(gl_body_state_key) -> slots;
        for i in slots do
            GlPrWin(body_state_out, sprintf('%p = %p',
                                              [% pdprops(i),  i(agent) %]));
        endfor;
    endif;

    GlTopWin(body_state_out);
    GlTopWin(gl_attrib_out);
    GlTopWin(gl_agent_out);
    GlTopWin(sim_agent_out);
    GlTextEnableRedisplay(agent_win);
enddefine;

define :method lvars ShowStatus(agent:gl_abbott, clear);
    lvars agent, clear;
    dlocal pop_pr_places = 3;
    dlocal pop_pr_ratios = false;
    lvars i, j, slots, data;

    call_next_method(agent, clear);

    /* parent slots */

    GlMkWin(parent_win);

    class_slots(gl_abbott_mixin_key) -> slots;
    GlPrWinStatusBanner(parent_out);
    for i in slots do
        GlPrWin(parent_out, sprintf('%p = %p', [% pdprops(i), i(agent) %]));
    endfor;
    if clear then GlTopWin(parent_out) endif;

    /* children slots */

    if isgl_children(agent) then
        class_slots(gl_children_key) -> slots;
        GlPrWinStatusBanner(children_out);
        for i in slots do
            GlPrWin(children_out, sprintf('%p = %p',
                                            [% pdprops(i),  i(agent) %]));
        endfor;
        if clear then GlTopWin(children_out) endif;
    endif;
enddefine;

define :method lvars ShowStatus(agent:gl_child, clear);
    lvars agent, clear;
    lvars i, slots;
    dlocal pop_pr_places = 3;
    dlocal pop_pr_ratios = false;

    call_next_method(agent, clear);

    /* child slots */

    GlMkWin(child_win);

    class_slots(gl_child_key) -> slots;
    GlPrWinStatusBanner(child_out);
    for i in slots do
        if isgl_agent(i(agent)) then
            GlPrWin(child_out, sprintf('%p = %p', [% pdprops(i),
                                            sim_name(i(agent)) %]));
        else
            GlPrWin(child_out, sprintf('%p = %p', [% pdprops(i),
                                                i(agent) %]));
        endif;
    endfor;
    if clear then GlTopWin(child_out) endif;

    /* specialist slots */

    class_slots(valof(dataword(agent) <> "_mixin_key")) -> slots;
    GlPrWinStatusBanner(specialist_out);
    for i in slots do
        GlPrWin(specialist_out, sprintf('%p = %p',
                                            [% pdprops(i),  i(agent) %]));
    endfor;
    if clear then GlTopWin(specialist_out) endif;
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
    lvars agent;
    dlocal rc_current_window_object;
    lvars x, y, relx, rely;
    lvars stepx = 1;
    lvars stepy = 1;
    lvars eye_position = gl_eye_last_position(agent);
    lvars str;

    GlXmString(sprintf('%p', [^(gl_eye_last_timestamp(agent))])) -> str;
    str -> XptVal[fast] (gl_eye_timestamp)(XmN labelString:XmString);
    XmStringFree(str);

    GlXmString(sprintf('%p', [^(gl_eye_last_values(agent))])) -> str;
    str -> XptVal[fast] (gl_eye_values)(XmN labelString:XmString);
    XmStringFree(str);

    gl_eye_win -> rc_current_window_object;

    (0, 0) -> (x,y);

    if eye_position == 1 or eye_position == 4 then
        -1 -> stepx;
        4 -> x
    endif;
    if eye_position == 3 or eye_position == 4 then
        -1 -> stepy;
        4 -> y;
    endif;

    8 -> rc_line_width(rc_window);
    for relx from 1 to 5 do
        y;
        for rely from 1 to 5 do
            if dup(gl_eye_view(agent)(relx,rely)) /== 15 then
                + 1, colours();
            else
                ->, gl_eye_background;
            endif -> rc_foreground(rc_window);

            rc_draw_rect(10*x+5, 10*y+5, 1, 1);
            y + stepy -> y;
        endfor;
        x + stepx -> x;
        -> y;
    endfor;

    (0, 0) -> (x, y);
    if eye_position == 1 or eye_position == 4 then
        x + 40 -> x;
    endif;
    if eye_position == 3 or eye_position == 4 then
        y + 40 -> y;
    endif;

    'purple' -> rc_foreground(rc_window);
    5 -> rc_line_width(rc_window);
    rc_draw_circle(x+5, y+5, 2);
    'white' -> rc_foreground(rc_window);
    3 -> rc_line_width(rc_window);
    rc_draw_rect(x+eyes(eye_position)(1), y+eyes(eye_position)(2), 1, 1);
enddefine;


/***************************************************************************
NAME
    ShowSensors

SYNOPSIS
    ShowSensors(agent);

FUNCTION
    Display the agent sensors.

RETURNS
    None.
***************************************************************************/
define lvars procedure ShowSensors(agent);
    if isgl_abbott(agent) and GlValidLoc(explode(gl_loc(agent))) then
        ShowEye(agent);
    endif;
enddefine;


/***************************************************************************
NAME
    GlPrWin

SYNOPSIS
    GPlrWin(win, data);

FUNCTION
    Prints "data" in the window "win". The routine converts the data to
    a string using sprintf() and adds a new line before printing.

RETURNS
    None.
***************************************************************************/
define vars procedure GlPrWin(win, data);
    lvars win, data;
    lvars ok, delete_pt, str, len;

    /* add a newline, and convert non-strings into strings */

    sprintf('%p\n', [^data]) -> str;
    length(str) -> len;

    /* write to file if need be */

    if isdevice(gl_trace_dev(gl_window)) and
        	member(win,datalist(
				gl_text_wins(gl_trace_file(gl_window)))) then
        syswrite(gl_trace_dev(gl_window), str, len);
    endif;

    /* add new text */

    XmTextInsert(gl_text_widget(win), gl_pos(win), str);
    gl_pos(win) + len -> gl_pos(win);
    unless gl_top(win) then
        XmTextShowPosition(gl_text_widget(win), gl_pos(win));
    endunless;
enddefine;


/* ====================================================================== */

/*
    SIM_AGENT Tracing
    =================

    sim_scheduler_pausing_trace;        - called at end of scheduler loop
    sim_agent_running_trace;            - called before running rules
    sim_agent_rulefamily_trace;         - called before each rulefamily
    sim_agent_terminated_trace;         - called after running rules
    sim_agent_endrun_trace;             - called after actions are processed
    ExtractConditionKeys;               - extract condition keys from dbase

*/


/***************************************************************************
NAME
    sim_scheduler_pausing_trace

SYNOPSIS
    sim_scheduler_pausing_trace(objects, cycle);

FUNCTION
    This funtion is called at the end of each SIM_AGENT scheduler loop. Itt
    is used to mark the end of the current cycle and process any trace
    options that need to run at the end of cycles.

RETURNS
    None.
***************************************************************************/
define vars procedure sim_scheduler_pausing_trace(objects, cycle);
    lvars objects, cycle;

    if gl_trace(gl_window) then
        GlTextDisableRedisplay(debug_out);
        false -> gl_top(debug_out);
        GlPrWin(debug_out, '=== end of cycle ' >< cycle >< ' ===');
        GlMkWin(debug_out);
        GlTextEnableRedisplay(debug_out);
    endif;

    /* process Activation trace */
    if isgl_agent(gl_activation_trace(gl_window)) then
        ShowActivation(gl_activation_trace(gl_window), false);
    endif;
enddefine;


/***************************************************************************
NAME
    sim_agent_running_trace

SYNOPSIS
    sim_agent_running_trace(object);

FUNCTION
    This funtion is called before running the agent rules. It is used to
    clear "old_data" and thus mark a "condition" loop in the Filtered
    Database trace (gl_debug_level == 1).

RETURNS
    None.
***************************************************************************/
define :method sim_agent_running_trace(object:gl_child);
    lvars object;
    false -> old_data;
enddefine;


/***************************************************************************
NAME
    sim_agent_running_trace

SYNOPSIS
    sim_agent_rulefamily_trace(object, rulefamily);

FUNCTION
    This funtion is called before running each rulefamily in the agent
    ruleset. It is used to display the database items relevant to the
    condtions and actions of each rule. The database entries are
    compared against gl_cond_filter() and gl_act_filter() - allowing
    relevant enties to be filtered before display.

    The "old_data" flag is used to determine if a rule has already been
    processed and hence the need to display the effects of the actions
    of the last rule.

RETURNS
    None.
***************************************************************************/
define :method vars sim_agent_rulefamily_trace(object:gl_child, rulefamily);
    lvars object, rulefamily;
    dlocal pop_pr_ratios = false;
    lvars j, data, key;

    if gl_debug_level(object) > 0 and gl_trace(gl_window) then
        if gl_debug_level(object) == 1 then
            sim_get_data(object) -> dbtable;
            prb_database_keys(dbtable) -> keys;

            if old_data then
                for j in [%
                            act_str,
                            fast_for key in gl_act_filter(object) do
                                if lmember(key, keys) then
                                    explode(dbtable(key))
                                endif;
                            endfor
                          %] do
                    GlPrWin(debug_out, '  ' >< j);
                endfor;

                GlPrWin(debug_out, '  ]');
            endif;
            GlPrWin(debug_out, sprintf('Try rulefamily %p with %p',
                                    [^rulefamily ^(sim_name(object))]));

            GlPrWin(debug_out, '  with data: [');
            for j in [%
                        cond_str,
                        fast_for key in gl_cond_filter(object) do
                            if lmember(key, keys) then
                                explode(dbtable(key))
                            endif;
                        endfor
                     %] do
                GlPrWin(debug_out, '  ' >< j);
            endfor;
            true -> old_data;
        endif;
    endif;
enddefine;


/***************************************************************************
NAME
    sim_agent_terminated_trace

SYNOPSIS
    sim_agent_terminated_trace(object, number_run, runs, max_cycles);

FUNCTION
    This funtion is called after running the agent rules.

    The "old_data" flag is used to determine if a rule has already been
    processed and hence the need to display the effects of the actions
    of the last rule.

RETURNS
    None.
***************************************************************************/
define :method sim_agent_terminated_trace(object:gl_child,
                                            number_run, runs, max_cycles);
    if number_run == 0 then
        true -> sim_stop_this_agent;
    endif;

    if gl_debug_level(object) > 0 and gl_trace(gl_window) and
                                        gl_debug_level(object) == 1 then
        sim_get_data(object) -> dbtable;
        prb_database_keys(dbtable) -> keys;
        lvars j, key;

        if old_data then
            for j in [%
                        act_str,
                        fast_for key in gl_act_filter(object) do
                            if lmember(key, keys) then
                                explode(dbtable(key))
                            endif;
                        endfor
                      %] do
                GlPrWin(debug_out, '  ' >< j);
            endfor;
            GlPrWin(debug_out, '  ]');
        endif;
    endif;
    false -> old_data;
enddefine;


/***************************************************************************
NAME
    sim_agent_endrun_trace

SYNOPSIS
    sim_agent_endrun_trace(agent);

FUNCTION
    This funtion is called after all agent actions have been processed.

RETURNS
    None.
***************************************************************************/
define :method vars sim_agent_endrun_trace(agent:gl_child);
    lvars agent;
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
    Message Dialogs
    ===============

    AddGotoDialog;                      - popup window to enter goto cycle
    AddAboutDialog;                     - gives info about program
    AddGettingStartedDialog;            - gives info about getting started
*/

/***************************************************************************
NAME
    AddGotoDialog

SYNOPSIS
    AddGotoDialog() -> dialog;

FUNCTION
    Creates a popup shell to enter the cycle number the scheduler should
    run to. If the new cycle is less than the current cycle then the
    scheduler resets the experiment and runs from the start.

RETURNS
    Goto dialog gl_widget.
***************************************************************************/
define lvars procedure AddGotoDialog() /* -> dialog */;
    lvars box, dialog_shell, dialog, title_widget, text_widget;


    XtCreatePopupShell('dialog shell', xmDialogShellWidget,
                gl_shell_widget(gl_window),
                XptArgList([
                ]) ) -> dialog_shell;

    XtCreateWidget('dialog',
                xmMessageBoxWidget, dialog_shell,
                XptArgList([
                {dialogType ^XmDIALOG_MESSAGE}
                {dialogStyle ^XmDIALOG_SYSTEM_MODAL}
                ]) ) -> dialog;

    XtUnmanageChild(XtNameToWidget(dialog, 'Cancel'));
    XtUnmanageChild(XtNameToWidget(dialog, 'Help'));
    XtUnmanageChild(XtNameToWidget(dialog, 'Message'));
    XtUnmanageChild(XtNameToWidget(dialog, 'OK'));


    XtCreateManagedWidget('Message',
                xmRowColumnWidget, dialog,
                XptArgList([
                {orientation ^XmHORIZONTAL}
                ]) ) -> box;

    XtCreateManagedWidget('Please Enter New Cycle Number:',
                xmLabelWidget, box,
                XptArgList([
                ]) ) -> title_widget;

    XtCreateManagedWidget('Text',
                xmTextWidget, box,
                XptArgList([
                    {cursorPositionVisible ^true}
                    {highlightThickness 0}
                ]) ) -> text_widget;

    return (dialog);
enddefine;

/***************************************************************************
NAME
    AddAboutDialog

SYNOPSIS
    AddAboutDialog() -> dialog;

FUNCTION
    Creates a popup shell to display info about the scenario. The message
    strings are held in local constants defined at the start of this
    file.

RETURNS
    about_dialog gl_widget.
***************************************************************************/
define lvars procedure AddAboutDialog() /* -> dialog */;
    lvars box, dialog_shell, dialog;
    lvars frame, scroll, title_widget, text_widget;
    lvars i, pos;


    XtCreatePopupShell('dialog shell', xmDialogShellWidget,
                gl_shell_widget(gl_window),
                XptArgList([
                ]) ) -> dialog_shell;

    XtCreateWidget('dialog',
                xmMessageBoxWidget, dialog_shell,
                XptArgList([
                {dialogType ^XmDIALOG_MESSAGE}
                {dialogStyle ^XmDIALOG_SYSTEM_MODAL}
                {width 450}
                ]) ) -> dialog;

    XtUnmanageChild(XtNameToWidget(dialog, 'Cancel'));
    XtUnmanageChild(XtNameToWidget(dialog, 'Help'));
    XtUnmanageChild(XtNameToWidget(dialog, 'Message'));


    XtCreateManagedWidget('Message',
                xmRowColumnWidget, dialog,
                XptArgList([
                {orientation ^XmVERTICAL}
                ]) ) -> box;

    XtCreateManagedWidget(phd_str,
                xmLabelWidget, box,
                XptArgList([
                ]) ) -> title_widget;

    XtCreateManagedWidget(ver_str,
                xmLabelWidget, box,
                XptArgList([
                ]) ) -> title_widget;

    XtCreateManagedWidget(exp_str,
                xmLabelWidget, box,
                XptArgList([
                ]) ) -> title_widget;

    XtCreateManagedWidget('Frame',
                xmFrameWidget, box,
                XptArgList([
                {bordorWidth 1}
                {shadowType ^XmSHADOW_ETCHED_IN}
                ]) ) -> frame;

    XtCreateManagedWidget('Box2',
                xmRowColumnWidget, frame,
                XptArgList([
                {orientation ^XmVERTICAL}
                ]) ) -> box;

    XtCreateManagedWidget('About This Program ... ',
                xmLabelWidget, box,
                XptArgList([
                {height 30}
                ]) ) -> title_widget;

    XtCreateManagedWidget('Message',
                xmScrolledWindowWidget, box,
                XptArgList([
                ]) ) -> scroll;

    XtCreateManagedWidget('Text',
                xmTextWidget, scroll,
                XptArgList([
                    {height 150}
                    {editMode ^XmMULTI_LINE_EDIT}
                    {wordWrap ^true}
                    {scrollVertical ^true}
                    {scrollHorizontal ^false}
                    {editable ^false}
                    {resizeHeight ^false}
                    {cursorPositionVisible ^false}
                    {highlightOnEnter ^false}
                    {highlightThickness 0}
                    {traversalOn ^false}
                ]) ) -> text_widget;

    if islist(message_str) then
        0 -> pos;
        for i in message_str do
            XmTextInsert(text_widget, pos, i);
            pos + length(i) -> pos;
        endfor;
    else
        XmTextInsert(text_widget, 0, message_str);
    endif;
    XmTextShowPosition(text_widget, 0);

    return (dialog);
enddefine;

/***************************************************************************
NAME
    AddGettingStartedDialog

SYNOPSIS
    AddGettingStartedDialog() -> dialog;

FUNCTION
    Creates a popup shell to display info about getting started with the
    Gridland scenario. The message strings are held in local constants
    defined at the start of this file.

RETURNS
    getting_started_dialog gl_widget.
***************************************************************************/
define lvars procedure AddGettingStartedDialog() /* -> dialog */;
    lvars box, dialog_shell, dialog;
    lvars frame, scroll, title_widget, text_widget;
    lvars i, pos;


    XtCreatePopupShell('dialog shell', xmDialogShellWidget,
                gl_shell_widget(gl_window),
                XptArgList([
                ]) ) -> dialog_shell;

    XtCreateWidget('dialog',
                xmMessageBoxWidget, dialog_shell,
                XptArgList([
                {dialogType ^XmDIALOG_MESSAGE}
                {dialogStyle ^XmDIALOG_SYSTEM_MODAL}
                {width 450}
                ]) ) -> dialog;

    XtUnmanageChild(XtNameToWidget(dialog, 'Cancel'));
    XtUnmanageChild(XtNameToWidget(dialog, 'Help'));
    XtUnmanageChild(XtNameToWidget(dialog, 'Message'));


    XtCreateManagedWidget('Message',
                xmRowColumnWidget, dialog,
                XptArgList([
                {orientation ^XmVERTICAL}
                ]) ) -> box;

    XtCreateManagedWidget(phd_str,
                xmLabelWidget, box,
                XptArgList([
                ]) ) -> title_widget;

    XtCreateManagedWidget(ver_str,
                xmLabelWidget, box,
                XptArgList([
                ]) ) -> title_widget;

    XtCreateManagedWidget(exp_str,
                xmLabelWidget, box,
                XptArgList([
                ]) ) -> title_widget;

    XtCreateManagedWidget('Frame',
                xmFrameWidget, box,
                XptArgList([
                {bordorWidth 1}
                {shadowType ^XmSHADOW_ETCHED_IN}
                ]) ) -> frame;

    XtCreateManagedWidget('Box2',
                xmRowColumnWidget, frame,
                XptArgList([
                {orientation ^XmVERTICAL}
                ]) ) -> box;

    XtCreateManagedWidget('Getting Started ...',
                xmLabelWidget, box,
                XptArgList([
                {height 30}
                ]) ) -> title_widget;

    XtCreateManagedWidget('Message',
                xmScrolledWindowWidget, box,
                XptArgList([
                ]) ) -> scroll;

    XtCreateManagedWidget('Text',
                xmTextWidget, scroll,
                XptArgList([
                    {height 150}
                    {editMode ^XmMULTI_LINE_EDIT}
                    {wordWrap ^true}
                    {scrollVertical ^true}
                    {scrollHorizontal ^false}
                    {editable ^false}
                    {resizeHeight ^false}
                    {cursorPositionVisible ^false}
                    {highlightOnEnter ^false}
                    {highlightThickness 0}
                    {traversalOn ^false}
                ]) ) -> text_widget;

    if islist(help_str) then
        0 -> pos;
        for i in help_str do
            XmTextInsert(text_widget, pos, i);
            length(i) + pos -> pos;
        endfor;
    else
        XmTextInsert(text_widget, 0, help_str);
    endif;
    XmTextShowPosition(text_widget, 0);

    return (dialog);
enddefine;


/* ====================================================================== */

/*
    Help
    ====

    HelpAbout();                - display info about current system
    HelpGettingStarted();       - help about getting started
*/


/***************************************************************************
NAME
    HelpAbout

SYNOPSIS
    HelpAbout();

FUNCTION
    Calls the message dialog box to display info about the program.

RETURNS
    None
***************************************************************************/
define lvars procedure HelpAbout();
    XtManageChild(about_dialog);
enddefine;


/***************************************************************************
NAME
    HelpGettingStarted

SYNOPSIS
    HelpGettingStarted();

FUNCTION
    Calls the message dialog box to display info about getting started
    with using the Gridland Toolkit.

RETURNS
    None
***************************************************************************/
define lvars procedure HelpGettingStarted();
    XtManageChild(getting_started_dialog);
enddefine;


/* ====================================================================== */


/*
    Gridland Agents
    ===============

    InitAgent(attribs, obj) -> obj;         - initialise an instance of obj
    SetupAgentRcGraphic(obj);               - define graphical chars of obj
    CrossWallSelected(x, y, picx,           - define boundary of cross wall
                    picy, pic) -> boole;
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

    /* define rc_graphic details */
    SetupAgentRcGraphic(obj);

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
    SetupAgentRcGraphic;

SYNOPSIS
    SetupAgentRcGraphic(obj);

FUNCTION
    Builds a graphical presence for agents in Gridland.

RETURNS
    None.
***************************************************************************/
define lvars procedure SetupAgentRcGraphic(obj);
    lvars obj;
    lvars type = gl_type(obj);
    lvars cellsize;

    GlCellSize() -> cellsize;

    switchon type
        case == "line" then
            {% 0, 0, cellsize-1, 2*cellsize-1 %} -> rc_mouse_limit(obj);
            [WIDTH 3 COLOUR 'blue' [RECT {% 2, 2*cellsize-2,
                    cellsize-4, 2*cellsize-4 %}]] -> rc_pic_lines(obj);

        case == "circle" then
            {% 0, 0, 2*cellsize-1, 2*cellsize-1 %} -> rc_mouse_limit(obj);
            [WIDTH 3 COLOUR 'blue'
                [CIRCLE {% 2*cellsize div 2, 2*cellsize div 2,
                    (2*cellsize div 2)-2 %}]] -> rc_pic_lines(obj);

        case == "rectangle" then
            {% 0, 0, 4*cellsize-1, 2*cellsize-1 %} -> rc_mouse_limit(obj);
            [WIDTH 3 COLOUR 'blue' [RECT {% 2, 2*cellsize-2,
                4*cellsize-4, 2*cellsize-4 %}]] -> rc_pic_lines(obj);

        case == "square" then
            {% 0, 0, 2*cellsize-1, 2*cellsize-1 %} -> rc_mouse_limit(obj);
            [WIDTH 3 COLOUR 'blue' [SQUARE {% 2, 2*cellsize-2,
                2*cellsize-4 %}]] -> rc_pic_lines(obj);

        case == "triangle" then
            {% 0, 0, 3*cellsize-1, 2*cellsize-1 %} -> rc_mouse_limit(obj);
            [WIDTH 3 COLOUR 'blue' [CLOSED {2 2} {% 3*cellsize-2, 2 %}
                {% 3*cellsize div 2, 2*cellsize - 2 %}]]
                    -> rc_pic_lines(obj);

        case == "vertical_wall4" then
            {% 0, 0, cellsize-1, 4*cellsize-1 %} -> rc_mouse_limit(obj);
            [WIDTH ^(cellsize-2) COLOUR 'black'
                [SQUARE {% cellsize div 2, (cellsize+1) div 2, 1 %}]
                [SQUARE {% cellsize div 2, (3*cellsize+1) div 2, 1 %}]
                [SQUARE {% cellsize div 2, (5*cellsize+1) div 2, 1 %}]
                [SQUARE {% cellsize div 2, (7*cellsize+1) div 2, 1 %}]
                ] -> rc_pic_lines(obj);

        case == "vertical_wall3" then
            {% 0, 0, cellsize-1, 3*cellsize-1 %} -> rc_mouse_limit(obj);
            [WIDTH ^(cellsize-2) COLOUR 'black'
                [SQUARE {% cellsize div 2, (cellsize+1) div 2, 1 %}]
                [SQUARE {% cellsize div 2, (3*cellsize+1) div 2, 1 %}]
                [SQUARE {% cellsize div 2, (5*cellsize+1) div 2, 1 %}]
                ] -> rc_pic_lines(obj);

        case == "horizontal_wall4" then
            {% 0, 0, 4*cellsize-1, cellsize-1 %} -> rc_mouse_limit(obj);
            [WIDTH ^(cellsize-2) COLOUR 'black'
                [SQUARE {% cellsize div 2, (cellsize+1) div 2, 1 %}]
                [SQUARE {% (3*cellsize) div 2, (cellsize+1) div 2, 1 %}]
                [SQUARE {% (5*cellsize) div 2, (cellsize+1) div 2, 1 %}]
                [SQUARE {% (7*cellsize) div 2, (cellsize+1) div 2, 1 %}]
                ] -> rc_pic_lines(obj);

        case == "horizontal_wall3" then
            {% 0, 0, 3*cellsize-1, cellsize-1 %} -> rc_mouse_limit(obj);
            [WIDTH ^(cellsize-2) COLOUR 'black'
                [SQUARE {% cellsize div 2, (cellsize+1) div 2, 1 %}]
                [SQUARE {% (3*cellsize) div 2, (cellsize+1) div 2, 1 %}]
                [SQUARE {% (5*cellsize) div 2, (cellsize+1) div 2, 1 %}]
                ] -> rc_pic_lines(obj);

        case == "cross_wall" then
            CrossWallSelected -> rc_mouse_limit(obj);
            [WIDTH ^(cellsize-2) COLOUR 'black'
                [SQUARE {% cellsize div 2, (cellsize+1) div 2, 1 %}]
                [SQUARE {% (3*cellsize) div 2, (cellsize+1) div 2, 1 %}]
                [SQUARE {% (5*cellsize) div 2, (cellsize+1) div 2, 1 %}]
                [SQUARE {% (7*cellsize) div 2, (cellsize+1) div 2, 1 %}]
                [SQUARE {% (9*cellsize) div 2, (cellsize+1) div 2, 1 %}]
                [SQUARE {% (5*cellsize) div 2, (3*cellsize+1) div 2, 1 %}]
                [SQUARE {% (5*cellsize) div 2, (5*cellsize+1) div 2, 1 %}]
                [SQUARE {% (5*cellsize) div 2, (-cellsize) div 2, 1 %}]
                [SQUARE {% (5*cellsize) div 2, (-3*cellsize) div 2, 1 %}]
                ] -> rc_pic_lines(obj);

        case == "food" then
            {% 0, 0, cellsize-1, cellsize-1 %} -> rc_mouse_limit(obj);
            [WIDTH ^(cellsize-2) COLOUR 'darkgreen'
                [SQUARE {% cellsize div 2, (cellsize+1) div 2, 1 %}]
                ] -> rc_pic_lines(obj);

        case == "water" then
            {% 0, 0, cellsize-1, cellsize-1 %} -> rc_mouse_limit(obj);
            [WIDTH ^(cellsize-2) COLOUR 'skyblue'
                [SQUARE {% cellsize div 2, (cellsize+1) div 2, 1 %}]
                ] -> rc_pic_lines(obj);

        case == "enemy" then
            {% 0, 0, cellsize-1, cellsize-1 %} -> rc_mouse_limit(obj);
            [WIDTH ^(cellsize div 2) COLOUR 'red'
                [CIRCLE {% cellsize div 2, cellsize div 2,
                                cellsize div 4 %}]] -> rc_pic_lines(obj);

        case == "abbott" then
            {% 0, 0, cellsize-1, cellsize-1 %} -> rc_mouse_limit(obj);
            {% cellsize div 4, (3*cellsize+3) div 4, 1, 1,
                                rc_draw_rect %} -> gl_eyes(obj)(1);
            {% 3*cellsize div 4, (3*cellsize+3) div 4, 1, 1,
                                rc_draw_rect %} -> gl_eyes(obj)(2);
            {% 3*cellsize div 4, (cellsize+3) div 4, 1, 1,
                                rc_draw_rect %} -> gl_eyes(obj)(3);
            {% cellsize div 4, (cellsize+3) div 4, 1, 1,
                                rc_draw_rect %} -> gl_eyes(obj)(4);
            [WIDTH ^(cellsize div 3) COLOUR 'purple' gl_eye {^obj}]
                                                    -> gl_eye_pic(obj);
            [WIDTH ^(cellsize div 2) COLOUR 'purple' [CIRCLE
                {% cellsize div 2, cellsize div 2, cellsize div 4 %}]
                    [WIDTH ^(cellsize div 3) gl_eye {^obj}]]
                                                    -> rc_pic_lines(obj);
        else
            mishap('Attempting to initialise unknown agent', [^type]);
    endswitchon;
enddefine;


/***************************************************************************
NAME
    CrossWallSelected;

SYNOPSIS
    CrossWallSelected(x, y, picx, picy, pic);

FUNCTION
    Defines the x and y boundaries for the cross-wall. Used by rc_graphic
    when selecting objects with the mouse.

RETURNS
    None.
***************************************************************************/
define lvars procedure CrossWallSelected(x, y, picx, picy, pic)
                                                            /* -> boole */;
    lvars x, y, picx, picy, pic;
    lvars cellsize;

    GlCellSize() -> cellsize;

    (picx <= x and picy <= y and
    picx + (5*cellsize-1) >= x and picy + cellsize-1 >= y) or
    (picx + (2*cellsize) <= x and picy - (2*cellsize) <= y and
    picx + (3*cellsize-1) >= x and picy + (3*cellsize-1) >= y)
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
        false -> rc_oldx(i);
        false -> rc_oldy(i);
        SetupAgentRcGraphic(i);
        GlAddAgent(i);
        unless GlValidLoc(explode(gl_loc(i))) then
            delete(i, active_agents) -> active_agents;
            delete(i, sim_objects) -> sim_objects;
        endunless
    endfor;

enddefine;


/* ====================================================================== */

/*
    Callbacks
    =========

    MenuCB(w, client_data, call_data);      - menu bar callback
    GlPopupCB(w, client_data, call_data);   - popup menu callback
    GotoCycleCB(w, client_data, call_data); - goto dialog callback
    GlFileSelectionCB(w, client, call);     - file selection callback
*/

/***************************************************************************
NAME
    GlFileSelectionCB

SYNOPSIS
    GlFileSelectionCB(x, client_data, call_data);

FUNCTION
    File selection dialog callback. This routine opens or saves experiments
    form the file selection widget. The callback autounmanages the dialog
    on exit.

RETURNS
    None.
***************************************************************************/
define vars procedure GlFileSelectionCB(w, client_data, call_data);
    lvars w, client_data, call_data;

    l_typespec call_data :XmFileSelectionBoxCallbackStruct;
    lvars filename;

    XpmCoerceString(exacc call_data.value) -> filename;

    cons({^client_data ^filename}, new_commands) -> new_commands;

    XtUnmanageChild(w);
enddefine;

/***************************************************************************
NAME
    MenuCB

SYNOPSIS
    lvars procedure MenuCB(w, client_data, call_data);

FUNCTION
    Menu call back routines. Defines the actions of the individual menu
    items on the menu bar.

RETURNS
    None
***************************************************************************/
define lvars procedure MenuCB(w, client_data, call_data);
    lvars w, client_data, call_data;
	lvars cmd, data;

	false ->> cmd -> data;

	if length(client_data) == 2 then
		explode(client_data) -> (cmd, data);
	else
		client_data -> cmd;
	endif;

	/* we would like to execute procedures directly - to kill window etc. */
	if cmd == "exec" then
		if isvector(data) then explode(data) -> data endif;
		if isword(data) then valof(data) -> data; endif;
       	if isprocedure(data) then data(); endif;
	elseif cmd == "pause" or cmd == "step" or
				cmd == "big_step" or cmd == "run" then
	    [^cmd] -> new_commands;
	else
	    cons(client_data, new_commands) -> new_commands;
	endif;
enddefine;


/***************************************************************************
NAME
    GlPopupCB;

SYNOPSIS
    GlPopupCB(w, client_data, call_data);

FUNCTION
    Callback for popup menu allowing agent status to be printed as well
    as setting debug and trace options.

RETURNS
    None.
***************************************************************************/
define lvars procedure GlPopupCB(w, client_data, call_data);
    lvars w, client_data, call_data;
    lvars obj, popup, menu_id, data;

    explode(client_data) -> (menu_id, popup);
	false -> data;

    unless isgl_menu(popup) then
        explode(popup) -> (popup, data)
    endunless;

	if (isgl_agent(gl_obj(popup))) then
    	sim_name(gl_obj(popup)) -> obj;
		cons({^menu_id ^obj ^data}, new_commands) -> new_commands;
	endif;

	/*

    if isgl_agent(obj) then

        switchon menu_id

        case == "active" then
            if isgl_abbott(obj) then
                obj -> gl_active_agent(gl_window);
                GlManageStatusWindow(debug_win);
            endif;

        case == "show_status" then
    		if isgl_agent(obj) then
            	ShowStatus(obj, true);       /* clears the window first */
            	GlManageStatusWindow(agent_win);
			endif;

        case == "show_data" then
    		if isgl_agent(obj) then
            	ShowData(obj, true);       /* clears the window first */
            	GlManageStatusWindow(sim_data_win);
			endif;

        case == "show_sensors" then
            if isgl_parent(obj) then
                ShowSensors(obj);
                GlManageStatusWindow(sensors_win);
            endif;

        case == "show_internal" then
            if isgl_parent(obj) then
                ShowInternalStatus(obj, true);
                GlManageStatusWindow(internal_win);
            endif;

        case == "trace_status" then
            if data then
                GlManageStatusWindow(agent_win);
                obj;
            else false endif -> gl_status_trace(gl_window);

        case == "trace_data" then
            if data then
                GlManageStatusWindow(sim_data_win);
                obj;
            else false endif -> gl_data_trace(gl_window);

        case == "trace_sensors" then
            if data then
                GlManageStatusWindow(sensors_win);
                obj;
            else false endif -> gl_sensor_trace(gl_window);

        case == "trace_internal" then
            if data then
                GlManageStatusWindow(internal_win);
                obj;
            else false endif -> gl_internal_trace(gl_window);

        case == "trace_activation" then
            if data then
                GlManageStatusWindow(activation_win);
                obj;
            else false endif -> gl_activation_trace(gl_window);

        case == "trace_debug" then
            if isgl_agent(obj) then
                GlManageStatusWindow(debug_win);
                data -> gl_debug_level(obj);
                false -> gl_prb_chatty(obj);
                false -> gl_prb_show_conditions(obj);
                if data > 0 then
                    GlManageStatusWindow(debug_win);
                    true -> gl_trace(gl_window);
                else
                    false -> gl_trace(gl_window);
                endif;
            endif;

        case == "chatty" then
            if isgl_agent(obj) then
                2 -> gl_debug_level(obj);
                GlManageStatusWindow(debug_win);
                true -> gl_trace(gl_window);
                if isnumber(gl_prb_chatty(obj)) and isnumber(data) then
                    if gl_prb_chatty(obj) mod data == 0 then
                        gl_prb_chatty(obj) div data -> gl_prb_chatty(obj);
                        if gl_prb_chatty == 0 then
                            false -> gl_prb_chatty(obj);
                        endif;
                    else
                        gl_prb_chatty(obj) * data -> gl_prb_chatty(obj);
                    endif;
                else
                    data -> gl_prb_chatty(obj);
                endif;
                if gl_prb_show_conditions(obj) == false and
                                        gl_prb_chatty(obj) == false then
                    0 -> gl_debug_level(obj);
                endif;
            endif;

        case == "conditions" then
            if isgl_agent(obj) then
                2 -> gl_debug_level(obj);
                GlManageStatusWindow(debug_win);
                true -> gl_trace(gl_window);
                data -> gl_prb_show_conditions(obj);
                if gl_prb_show_conditions(obj) == false and
                                        gl_prb_chatty(obj) == false then
                    0 -> gl_debug_level(obj);
                endif;
            endif;

        case == "list_agents" then
			cons(list_agents, new_commands) -> new_commands;

        case == "list_children" then
            if isgl_parent(obj) then
                unless XptIsLiveType(gl_list_widget(obj), "Widget") then
                    GlAddAgentListDialog('Children of ' >< sim_name(obj),
                                gl_children(obj)) -> gl_list_widget(obj);
                endunless;
                XtManageChild(gl_list_widget(obj));
            endif;

        case == "remove" then
            cons({remove ^obj}, new_commands) -> new_commands;

        else
            ;;;output('unexpected tag in GlPopupCB');
        endswitchon
    endif;

	*/
enddefine;


/***************************************************************************
NAME
    GotoCycleCB;

SYNOPSIS
    GotoCycleCB(w, client_data, call_data);

FUNCTION
    Callback for Goto Cycle dialog box. This routine takes the cycle number
    entered by the user, stores it in "goto_cycle", and issues a "goto"
    command.

RETURNS
    None.
***************************************************************************/
define lvars procedure GotoCycleCB(w, client_data, call_data);
    lvars w, client_data, call_data;
    lvars num;

    if (strnumber(XmTextGetString(XtNameToWidget(w, 'Message.Text')))
                ->> num) and num > 0 then
        cons({goto ^num}, new_commands) -> new_commands;
    endif;
    XtUnmanageChild(w);
enddefine;


/* ====================================================================== */

/*
    Tests
    =====

    Test1;                              - hook for first test
    Test2;                              - hook for second test
    Test3;                              - destroy the window
*/


/***************************************************************************
NAME
    Test1;

SYNOPSIS
    Test1();

FUNCTION
    Shell in which to place test routines called from the main menu bar.

RETURNS
    None.
***************************************************************************/
define lvars procedure Test1();
enddefine;

/***************************************************************************
NAME
    Test2;

SYNOPSIS
    Test2();

FUNCTION
    Shell in which to place test routines called from the main menu bar.

RETURNS
    None.
***************************************************************************/
define lvars procedure Test2();
enddefine;


/***************************************************************************
NAME
    Test3;

SYNOPSIS
    Test3();

FUNCTION
    Shell in which to place test routines called from the main menu bar.
    This routine destroys the Gridland window - useful if the program
    crashes during development.

RETURNS
    None.
***************************************************************************/
define lvars procedure Test3();
    XtDestroyWidget(gl_shell_widget(gl_window));
	exitfrom(BatchStart);
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
