/* -------------------------------------------------------------------------
   ---       Concern Processing in Autonomous Agents - PhD Thesis        ---
   ---                                                                   ---
   ---       Copyright (c) Steve Allen, 1998. All rights reserved.       ---
   -------------------------------------------------------------------------

   File:            gl_agent.p
   Author           Steve Allen, 23 Jul 2000 - (see revisions at EOF)
   Purpose:         This file contains the display drivers for the
                    X-Windows Motif display and general class definitions
                    and methods for the Gridland world.

   Libraries:       LIB sim_agent, poprulebase, objectclass, rc_graphic
                    LIB rulefamily, rc_linepic, rc_window_object
                    LIB rc_mousepic
*/

/* --- Introduction --------------------------------------------------------

This library forms the core of the Gridland Sim Agent library, providing
the basic object class definitions and X-Windows Motif drivers. The libary
was produced as part of an investigation into "Concern Processing in
Autonomous Agents".

--------------------------------------------------------------------------*/

section;

/* system includes */

uses sim_agent;
uses rulefamily;
uses rc_graphic;
uses rc_linepic;
uses rc_window_object;
uses rc_mousepic;


loadinclude XmConstants;
include xt_constants;
include xpt_coretypes;
include xpt_xtypes;
include xpt_xscreen;
loadinclude xpt_xevent;

/***************************************************************************
Public functions writen in this module.

    define vars procedure GlSetup(xsize, ysize, csize, type, user_wins);

    define vars procedure GlAddAgentListDialog(title, agents) -> dialog;
    define vars procedure GlListCB(w, client_data, call_data);

    define vars procedure GlAddFileSelectionDialog(filepath, filter,
                                                        reason) -> dialog;
    define vars procedure GlRefreshFileDir(dialog);
    define vars procedure GlFileSelectionCB(w, client_data, call_data);
    define vars procedure GlPopdownCB(w, client_data, call_data);

    define vars procedure GlXmString(name) -> string;
    define vars procedure GlAddLabel(name, parent, x, y) -> label;
    define vars procedure GlAddSeparator(parent);
    define vars procedure GlAddPushButton(name, parent, callback, id);
    define vars procedure GlAddCascade(name, parent, menu) -> cascade;

    define vars procedure GlAddStatusMenu(name, parent);
    define vars procedure GlAddMenu(name, parent, callback, menu_items);

    define :method vars   GlPopupMenu(obj:gl_agent, x, y);
    define vars procedure GlAddPopupMenu(name, parent, x, y) -> popup;
    define vars procedure GlNewPopupMenu(name, parent, x, y) -> popup;
    define vars procedure GlBuildPopup(obj, popup);
    define vars procedure GlPopupCB(w, client_data, call_data);

    define vars procedure GlManageStatusWindow(new_status_window);
    define vars procedure GlAddStatusWindow(win, parent, defs);
    define vars procedure GlAddStatusSubWindows(win, parent, defs);
    define vars procedure GlAddScrollTextWindow(name, parent, title, height)
                                            -> (title_widget, text_widget);
    define vars procedure GlStatusMenuCB(w, client_data, call_data);

    define vars procedure GlSetupGrid();
    define vars procedure GlResizeGraphic(x, y, c, type);
    define vars procedure GlCellSize();
    define vars procedure GlGridXSize();
    define vars procedure GlGridYSize();
    define vars procedure GlGridType();

    define vars procedure GlUpdateCycleCount();

    define :method vars   rc_button_3_down(obj:gl_agent, x, y, modifiers);

    define :method vars   rc_move_to(pic:gl_attrib, x, y, mode);
    define vars procedure GlValidLoc(x, y) -> valid;
    define vars procedure GlGrid(x, y);
    define updaterof vars procedure GlGrid(cell, x, y);
    define :method vars   GlCellUnoccupied(agent:gl_attrib, x, y);
    define :method vars   GlAddToGrid(agent:gl_attrib);
    define :method vars   GlAddToDisplay(agent:gl_attrib);
    define :method vars   GlRemoveFromGrid(agent:gl_attrib);
    define :method vars   GlRemoveFromDisplay(agent:gl_attrib);
    define updaterof vars procedure GlDisplayAgents(display);
    define vars procedure GlDisplayAgents() -> display;
    define :method vars   GlAddAgent(agent:gl_attrib);
    define :method vars   GlRemoveAgent(agent:gl_attrib);
    define :method vars   GlMoveAgent(obj:gl_attrib, x, y);
    define :method vars   GlRefreshAgent(agent:gl_attrib);
    define :method vars   GlFindFreeLoc(agent:gl_attrib) -> (x, y);
    define vars procedure GlGridXToRc(x) -> rc;
    define vars procedure GlGridYToRc(y) -> rc;
    define vars procedure GlRcToGridX(rc) -> x;
    define vars procedure GlRcToGridY(rc);

    define :method vars   print_instance(item:gl_agent);
    define :method vars   GlPrintStatus(item:gl_agent, clear);

    define vars procedure GlUpdateStatusBanner();
    define :method vars   GlClrWin(win);
    define vars procedure GlPrWinStatusBanner(win);
    define vars procedure GlPrWin(win, data);
    define vars procedure GlTopWin(win);
    define vars procedure GlDbtable(dbtable) -> items;

    define vars procedure sim_scheduler_pausing_trace(objects, cycle);
    define vars procedure sim_scheduler_finished(objects, cycle);
    define :method vars   sim_agent_messages_out_trace(agent:gl_agent);
    define :method vars   sim_agent_messages_in_trace(agent:gl_agent);
    define :method vars   sim_agent_actions_out_trace(agent:gl_agent);
    define :method vars   sim_agent_rulefamily_trace(object:gl_agent,
                                                                rulefamily);
    define :method vars   sim_agent_endrun_trace(agent:gl_agent);
    define :method vars   sim_agent_terminated_trace(object:sim_object,
***************************************************************************/

/* -- Gridland Setup -- */
vars procedure GlSetup;

/* -- Agent List -- */
vars procedure GlAddAgentListDialog;
vars procedure GlListCB;

/* -- File Selection -- */
vars procedure GlAddFileSelectionDialog;
vars procedure GlRefreshFileDir;
vars procedure GlFileSelectionCB;
vars procedure GlPopdownCB;

/* -- Low Level Routines -- */
vars procedure GlXmString;
vars procedure GlAddLabel;
vars procedure GlAddSeparator;
vars procedure GlAddPushButton;
vars procedure GlAddCascade;

/* -- Pulldown Menus -- */
vars procedure GlAddStatusMenu;
vars procedure GlAddMenu;

/* -- Popup Menus -- */
vars procedure GlPopupMenu;
vars procedure GlAddPopupMenu;
vars procedure GlNewPopupMenu;
vars procedure GlBuildPopup;
vars procedure GlPopupCB;

/* -- Status Windows -- */
vars procedure GlManageStatusWindow;
vars procedure GlAddStatusWindow;
vars procedure GlAddStatusSubWindows;
vars procedure GlAddScrollTextWindow;
vars procedure GlStatusMenuCB;

/* -- Grid Display and Resize -- */
vars procedure GlSetupGrid;
vars procedure GlResizeGraphic;
vars procedure GlCellSize;
vars procedure GlGridXSize;
vars procedure GlGridYSize;
vars procedure GlGridType;

/* -- Cycle Counter -- */
vars procedure GlUpdateCycleCount;

/* -- Mouse Events -- */
vars procedure rc_button_3_down;

/* -- Gridland Access Mechanisms -- */
vars procedure rc_move_to;
vars procedure GlValidLoc;
vars procedure GlGrid;
vars procedure GlCellUnoccupied;
vars procedure GlAddToGrid;
vars procedure GlAddToDisplay;
vars procedure GlRemoveFromGrid;
vars procedure GlRemoveFromDisplay;
vars procedure GlDisplayAgents;
vars procedure GlAddAgent;
vars procedure GlRemoveAgent;
vars procedure GlMoveAgent;
vars procedure GlRefreshAgent;
vars procedure GlFindFreeLoc;
vars procedure GlGridXToRc;
vars procedure GlGridYToRc;
vars procedure GlRcToGridX;
vars procedure GlRcToGridY;

/* -- Print Methods -- */
vars procedure print_instance;
vars procedure GlPrintStatus;

/* -- Status Window Printing -- */
vars procedure GlUpdateStatusBanner;
vars procedure GlTextDisableRedisplay;
vars procedure GlTextEnableRedisplay;
vars procedure GlClrWin;
vars procedure GlPrWinStatusBanner;
vars procedure GlPrWin;
vars procedure GlTopWin;
vars procedure GlDbtable;

/* -- Tracing -- */
vars procedure sim_scheduler_pausing_trace;
vars procedure sim_scheduler_finished;
vars procedure sim_agent_messages_out_trace;
vars procedure sim_agent_messages_in_trace;
vars procedure sim_agent_actions_out_trace;
vars procedure sim_agent_rulefamily_trace;
vars procedure sim_agent_endrun_trace;
vars procedure sim_agent_terminated_trace;

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

lconstant blank_layout = [
    {'No Status'            blank_win           1}
    ];

lconstant trace_layout = [
    {'Debug Trace'          debug_win           1}

    {'Debug'                debug_out           1       480     10}
    ];

lconstant agent_layout = [
    {'Agent Status'         agent_win           2}

    {'Sim Agent'            sim_agent_out       1       480     10}
    {'Gl Agent'             gl_agent_out        2       70      10}
    {'Gl Attrib'            gl_attrib_out       2       380     10}
    ];

lconstant sim_data_layout = [
    {'Sim Data'             sim_data_win       1}

    {'Sim Data'             sim_data_out       1       480      10}
    ];

lconstant
    macro (
        EMPTY       = 0,
        FULL        = 1,
        PARTIAL     = 2
    );

defclass cell {
    gl_occupancy  :4,
    gl_hardness   :4,
    gl_brightness :4,
    gl_organic    :4,
    gl_agent_id
    };

defclass bitvector    :1;
defclass nibblevector :4;
defclass bytevector   :8;
defclass bit32vector  :32;

procedure(bv);
    lvars bv i;
    fast_for i from 1 to datalength(bv) do
        cucharout(fast_subscrbitvector(i, bv) fi_+ `0`)
    endfast_for;
endprocedure -> class_print(bitvector_key);

procedure(nv);
    lvars nv i;
    cucharout(`{`);
    fast_for i from 1 to datalength(nv)-1 do
        pr(fast_subscrnibblevector(i, nv));
        cucharout(` `);
    endfast_for;
    pr(fast_subscrnibblevector(i, nv));
    cucharout(`}`);
endprocedure -> class_print(nibblevector_key);

procedure(bytev);
    lvars bytev i;
    cucharout(`{`);
    fast_for i from 1 to datalength(bytev)-1 do
        pr(fast_subscrbytevector(i, bytev));
        cucharout(` `);
    endfast_for;
    pr(fast_subscrbytevector(i, bytev));
    cucharout(`}`);
endprocedure -> class_print(bytevector_key);

lvars gridxsize;                    /* temp var to hold grid x size */
lvars gridysize;                    /* temp var to hold grid y size */
lvars cellsize;                     /* temp var to hold cell size   */
lvars gridland = false;             /* gridland array or <false>    */
lvars status_banner = '===';        /* status banner                */

/* -- Popup Menus -- */

lvars agent_popup = false;          /* popup menu for gl_agents     */

/* -- Some local constants -- */

lconstant invalid_loc = conscell(FULL, 0, 1, 0, false);
lconstant empty_loc = conscell(EMPTY, 0, 0, 0, false);

/***************************************************************************
Global data declared in this module.
Extern definitions for any external global data used by this module.
File wide static data.
***************************************************************************/

vars gl_window;                     /* Gridland window          */

/* -- Status Windows -- */

vars blank_win;
vars debug_win;
vars agent_win;
vars sim_data_win;

/* -- Scrollable Status Window Displays -- */

vars debug_out;                     /* for "Debug" status window */

vars sim_agent_out;                 /* for "Agent" status window */
vars gl_agent_out;
vars gl_attrib_out;

vars sim_data_out;                  /* for "Sim Data" status window */



/* ====================================================================== */

/*
    Mixins for Gridland
    ===================

    gl_agent                        - general agent slots
    gl_sel                          - rc_graphic mouse selectable slots
    gl_attrib                       - physical presence in Gridland
*/

define :mixin gl_agent;
    slot gl_debug_level = 0;        /* debug level of agent         */
    slot gl_prb_chatty = false;     /* prb_chatty setting           */
    slot gl_prb_show_conditions
                    = false;        /* prb_show_conditions setting  */
enddefine;

define :mixin gl_sel; is rc_keysensitive rc_selectable
                                            rc_linepic_movable;
enddefine;

define :mixin gl_attrib;
    slot gl_loc;                    /* grid location  {x y}         */
    slot gl_type;                   /* type of object (word)        */
    slot gl_surface;                /* surface list   {...}         */
    slot gl_physical;               /* physical characteristics     */
    slot gl_Occupancy;              /* occupancy value of agent     */
    slot gl_Hardness;               /* hardness value of agent      */
    slot gl_Brightness;             /* brightness value of agent    */
    slot gl_Organic;                /* organic value of agent       */
    slot gl_Agent_ID;               /* agent ID                     */
enddefine;

lvars cell;

define :wrapper updaterof gl_Occupancy(val, obj:gl_attrib, p);
    min(15, max(0, val)) -> val;
    p(val, obj);
    for cell in gl_physical(obj) do
        round(val) -> gl_occupancy(cell);
    endfor;
enddefine;

define :wrapper updaterof gl_Brightness(val, obj:gl_attrib, p);
    min(15, max(0, val)) -> val;
    p(val, obj);
    for cell in gl_physical(obj) do
        round(val) -> gl_brightness(cell);
    endfor;
enddefine;

define :wrapper updaterof gl_Hardness(val, obj:gl_attrib, p);
    min(15, max(0, val)) -> val;
    p(val, obj);
    for cell in gl_physical(obj) do
        round(val) -> gl_hardness(cell);
    endfor;
enddefine;

define :wrapper updaterof gl_Organic(val, obj:gl_attrib, p);
    min(15, max(0, val)) -> val;
    p(val, obj);
    for cell in gl_physical(obj) do
        round(val) -> gl_organic(cell);
    endfor;
enddefine;

define :wrapper updaterof gl_Agent_ID(val, obj:gl_attrib, p);
    p(val, obj);
    for cell in gl_physical(obj) do
        val -> gl_agent_id(cell);
    endfor;
enddefine;

/* ====================================================================== */

/*
    Classes for Gridland
    ===============================

    gl_object                       - Gridland objects
*/

define :class gl_object; is gl_attrib gl_agent gl_sel sim_object;
    slot sim_sensors = [];          /* sensors                      */
    slot sim_rulesystem = [];       /* processing rules             */
enddefine;


/* ====================================================================== */

/*
    Methods for Gridland
    ====================

    =_instance()                    - redefine "=" to "=="
    GlNameAgent()                   - name agent and create perm identifier

*/

define :method vars =_instance(x, y:gl_agent);
    x == y or sim_name(x) == sim_name(y);
enddefine;

define :method vars =_instance(x:gl_agent, y);
    x == y or sim_name(x) == sim_name(y);
enddefine;

define :method vars GlNameAgent(agent:gl_agent, name);
    lvars agent, name;

    consword(name >< nullstring) -> name;

    /* make "name" into a permanent identifier and assign "obj" to it */
    sysSYNTAX(name, 0, false);
    agent -> valof(name);
    name -> sim_name(agent);
enddefine;

/* ====================================================================== */

/*
    Menu and Status Window classes
    ==============================

    gl_status_win                   - status windows
    gl_text_win                     - scrollable text windows
    gl_menu                         - popup menu class
    gl_window                       - gl_agent window class
*/

define :class gl_status_win;
    slot gl_title;                  /* window title                 */
    slot gl_name;                   /* window name                  */
    slot gl_widget;                 /* window widget                */
    slot gl_form_widget;            /* form widget                  */
    slot gl_menu_widget;            /* menu widget                  */
    slot gl_title_widget;           /* window title widget          */
    slot gl_num_windows;            /* number of text sub-windows   */
    slot gl_num_columns;            /* number of columns            */
    slot gl_title_widgets;          /* vector of text title widgets */
    slot gl_text_widgets;           /* vector of text widgets       */
    slot gl_text_wins;              /* vector of text windows       */
enddefine;

define :class gl_text_win;
    slot gl_pos;                    /* current line position        */
    slot gl_old_pos;                /* last line position           */
    slot gl_top;                    /* top of window marker         */
    slot gl_delete_pts;             /* vector of delete points      */
    slot gl_count;                  /* history counter              */
    slot gl_size;                   /* history size                 */
    slot gl_lims;                   /* number of limit chunks       */
    slot gl_text_widget;            /* text widget                  */
enddefine;

define :class gl_menu
    slot gl_title_widget;           /* title widget                 */
    slot gl_widget;                 /* widget                       */
    slot gl_obj;                    /* current agent                */
enddefine;

define :class gl_window
    slot gl_shell_widget;           /* shell widget                 */
    slot gl_menu_widget;            /* menu widget                  */
    slot gl_list_widget;            /* list of agents widget        */
    slot gl_title_widget;           /* title widget                 */
    slot gl_display_widget;         /* display window widget        */
    slot gl_gridland_widget;        /* gridland window widget       */
    slot gl_cycle_num_widget;       /* cycle num display widget     */
    slot gl_cycle_title_widget;     /* cycle title display widget   */
    slot gl_status_windows = [];    /* list of status windows       */
    slot gl_status_width = 400;     /* width of status window       */
    slot gl_current_status_window;  /* current status window        */
    slot gl_trace = false;          /* allow/disallow tracing       */
    slot gl_trace_dev = false;      /* file dev for tracing         */
    slot gl_trace_file = false;     /* window to file               */
    slot gl_display = true;         /* display/hide agents          */
    slot gl_agents = [];            /* list of agents               */
    slot gl_gridland;               /* holder for gridland array    */
    slot gl_ranseed = false;        /* ranseed for gridland         */
    slot lvars gl_gridxsize;        /* grid x size                  */
    slot lvars gl_gridysize;        /* grif y size                  */
    slot lvars gl_cellsize;         /* cell size                    */
    slot lvars gl_gridtype;         /* grid type "array" "nonarray" */
enddefine;

/* ====================================================================== */

;;; procedure to print a rulefamily
define prb_print_rulefamily(rulefam);
    spr('<prb_rulefamily:');
    pr(prb_rulefamily_name(rulefam));
    spr(', next:');
    pr(prb_next_ruleset(rulefam));
    spr(', stack:');
    pr(prb_family_stack(rulefam));
    pr('>');
enddefine;

prb_print_rulefamily -> class_print(prb_rulefamily_key);

/* ====================================================================== */


/*
    Gridland Setup
    ==============

    GlSetup(gridx, gridy, csize,    - initialise the gridland world
                  type, user_wins);
*/


/***************************************************************************
NAME
    GlSetup

SYNOPSIS
    GlSetup(gridx, gridy, csize, type, user_wins);

FUNCTION
    Creates the shell onto which the gridland agent world is drawn. This
    routine also sets up the gl_window object with pointers to the main
    widgets on the window.

    Slot "gl_shell_widget" contains the main shell. Menus can be attached to
    the "gl_menu_widget" slot. The "gl_gridland_widget" slot and rc_window
    are used for displaying graphics in gridland. The "gl_cycle_num_widget"
    slot points to the cycle count display, and the "gl_title_widget" points
    to the title.

    If the first item in "user_wins" is an integer, then it is used to set
    the default width of the status windows. The new width is stored in
    slot "gl_status_width".

RETURNS
    None
***************************************************************************/
define vars procedure GlSetup(name, grid_title, xsize, ysize, csize,
                                                        type, user_wins);
    lvars name, grid_title, xsize, ysize, csize, type, user_wins;
    lvars toplevelshell, toplevel_form, menu, status_wins, win;
    lvars display_win_frame, display_window;
    lvars gridland_win, win_title, cycle_title, cycle_num;
    lvars window_x, window_y, window_xsize, window_ysize;
    lvars i, j, max_height, x, y;

    newgl_window() -> gl_window;

    xsize ->> gl_gridxsize(gl_window) -> gridxsize;
    ysize ->> gl_gridysize(gl_window) -> gridysize;
    csize ->> gl_cellsize(gl_window) -> cellsize;

    XptDefaultSetup();

    XtAppCreateShell(name, 'Xpw',
                xtApplicationShellWidget,
                XptDefaultDisplay,
                XptArgList([
                ]) ) -> toplevelshell;

    XtCreateManagedWidget('toplevel_form',
                xmFormWidget, toplevelshell,
                XptArgList([])
                ) -> toplevel_form;

    XmCreateMenuBar(toplevel_form, 'menu_bar',
                XptArgList([
                {height 30}
                {leftAttachment ^XmATTACH_FORM}
                {rightAttachment ^XmATTACH_FORM}
                {topAttachment ^XmATTACH_FORM}])
                ) -> menu;

    10  -> window_x;
    30  -> window_y;
    gridxsize*cellsize-1 -> window_xsize;
    gridysize*cellsize-1 -> window_ysize;

    false -> rc_window;
    rc_new_window_object( window_x, window_y,
                window_xsize, window_ysize,
                    {-1 ^window_ysize 1 -1}, "hidden") -> gridland_win;

    /*
        Now realise the window on the form sheet instead of as a separate
        window (hense the use of "hidden" in rc_new_window_object
    */

    XtCreateManagedWidget('display_window_frame',
            xmFrameWidget, toplevel_form,
                XptArgList([
                {leftAttachment ^XmATTACH_FORM}
                {leftOffset 10}
                {topAttachment ^XmATTACH_FORM}
                {topOffset 50}
                {shadowType ^XmSHADOW_OUT}
                ]) ) -> display_win_frame;

    XtCreateManagedWidget('display_window',
            xmFormWidget, display_win_frame,
                XptArgList([
                ]) ) -> display_window;

    XtCreateManagedWidget('rc_window',
                xpwGraphicWidget, display_window,
                XptArgList([
                {leftAttachment ^XmATTACH_FORM}
                {leftOffset ^window_x}
                {rightAttachment ^XmATTACH_FORM}
                {rightOffset ^window_x}
                {topAttachment ^XmATTACH_FORM}
                {topOffset ^window_y}
                {width ^window_xsize} {height ^window_ysize}])
                ) -> rc_window;

    XtCreateManagedWidget(grid_title,
                xmLabelWidget, display_window,
                XptArgList([
                {leftAttachment ^XmATTACH_OPPOSITE_WIDGET}
                {leftWidget ^rc_window}
                {rightAttachment ^XmATTACH_OPPOSITE_WIDGET}
                {rightWidget ^rc_window}
                {bottomAttachment ^XmATTACH_WIDGET}
                {bottomWidget ^rc_window}
                {bottomOffset 10}
                {alignment ^XmALIGNMENT_BEGINNING}
                ]) ) -> win_title;

    XtCreateManagedWidget('Cycle:',
                xmLabelWidget, display_window,
                XptArgList([
                {leftAttachment ^XmATTACH_OPPOSITE_WIDGET}
                {leftWidget ^rc_window}
                {topAttachment ^XmATTACH_WIDGET}
                {topWidget ^rc_window}
                {topOffset 10}
                {bottomAttachment ^XmATTACH_FORM}
                {bottomOffset 10}
                ]) ) -> cycle_title;

    XtCreateManagedWidget('0',
                xmLabelWidget, display_window,
                XptArgList([
                {leftAttachment ^XmATTACH_WIDGET}
                {leftWidget ^cycle_title}
                {topAttachment ^XmATTACH_WIDGET}
                {topWidget ^rc_window}
                {topOffset 10}
                {bottomAttachment ^XmATTACH_FORM}
                {bottomOffset 10}
                ]) ) -> cycle_num;

    /* extract status window width from head of user_wins list */
    unless user_wins == [] or not(isinteger(hd(user_wins))) then
        dest(user_wins) -> (gl_status_width(gl_window), user_wins);
    endunless;


    /* add user status windows, replacing old definitions */
    [%
        for i in [ ^blank_layout ^trace_layout ^agent_layout
                                                    ^sim_data_layout ] do
            for j in user_wins do
                if hd(i) = hd(j) then
                    j -> i;
                    delete(j, user_wins, nonop ==) -> user_wins;
                endif;
            endfor;
            i;
        endfor;

        for i in user_wins do i endfor;
    %] -> status_wins;

    [%
        for i in status_wins do
            hd(i) -> j;
            j(2) -> win;
            sysSYNTAX(win, 0, false);
            newgl_status_win() ->> valof(win) -> win;
            j(1) -> gl_name(win);
            win;
        endfor;
    %] -> gl_status_windows(gl_window);

    for win i in gl_status_windows(gl_window), status_wins do
            GlAddStatusWindow(win, toplevel_form, i);
    endfor;

    /* manage the current status window */

    hd(gl_status_windows(gl_window)) -> gl_current_status_window(gl_window);
    XtManageChild(gl_widget(gl_current_status_window(gl_window)));


    /* realise the toplevelshell */

    XtRealizeWidget(toplevelshell);

    /*
        Set the height of the toplevelshell to be the max height of the
        graphic and status window displays. Fix the min width and height,
        then read the screen details to place the toplevelshell in the
        middle of the screen.
    */

    syssleep(rc_window_sync_time);

    XptVal[fast] (display_window)(XtN height:XptDimension) -> max_height;
    for i in gl_status_windows(gl_window) do
        max( max_height, XptVal[fast]
                (gl_widget(i))(XtN height:XptDimension)) -> max_height;
    endfor;

    lvars win_height, win_width;
    lvars scr_height, scr_width;
    lvars scr = XtScreen(toplevelshell);

    exacc :XScreen scr.width -> scr_width;
    exacc :XScreen scr.height -> scr_height;

    max_height + 70 -> win_height;
    min(gl_status_width(gl_window) + window_xsize + 50, scr_width - 20)
                                                            -> win_width;
    max(0, ((scr_width - win_width) div 2)) -> x;
    max(0, ((scr_height - win_height) div 2)) -> y;

    (win_height, win_height, win_width, win_width, x, y)
        -> XptVal[fast] toplevelshell(XtN height:XptDimension,
            XtN minHeight:XptDimension, XtN minWidth:XptDimension,
                XtN width:XptDimension, XtN x:XptDimension,
                    XtN y:XptDimension);


    /*
        set the 12 global values from the frame vector
                    (set in rc_new_window_object...)
    */

    rc_set_window_globals(gridland_win);


    /* Save the gl_widget */

    rc_window -> rc_widget(gridland_win);
	toplevelshell -> rc_window_shell(gridland_win);

    /* set origin at bottom left corner increasing upwards */

    rc_set_coordinates(0, rc_window_ysize, 1, -1);

    true -> rc_window_realized(gridland_win);
    true -> rc_window_visible(gridland_win);

    syssleep(rc_window_sync_time);

    gridland_win ->> rc_window_object_of(rc_window)
                                                -> rc_current_window_object;

    (window_x, window_y) -> (rc_window_x, rc_window_y);

    /* set mouse buttons sensitivity, etc */

    rc_mousepic(rc_window);

    menu        -> gl_menu_widget(gl_window);
    win_title   -> gl_title_widget(gl_window);
    cycle_title -> gl_cycle_title_widget(gl_window);
    cycle_num   -> gl_cycle_num_widget(gl_window);
    gridland_win  -> gl_gridland_widget(gl_window);
    toplevelshell -> gl_shell_widget(gl_window);
    display_window  -> gl_display_widget(gl_window);

    type -> gl_gridtype(gl_window);
    GlSetupGrid();

enddefine;

/* ====================================================================== */

/*
    Agent List
    ==========

    GlAddAgentListDialog(title, agents);    - add an agent list dialog
    GlListCB(w, client_data, call_data);    - list callback
*/


/***************************************************************************
NAME
    GlAddAgentListDialog

SYNOPSIS
    GlAddAgentListDialog(title, agents) -> dialog;

FUNCTION
    Creates a popup shell containing a list of agents. The agents are
    written on labels of a menu bar inside a scrollable window. The
    mouse button activates a popup window (via GlListCB) allowing status
    info to be printed and altered. The use of a menu bar allows smooth
    integration with popup menus.

RETURNS
    List dialog gl_widget.
***************************************************************************/
define vars procedure GlAddAgentListDialog(title, agents) /* -> dialog */;
    lvars title, agents;
    lvars i, scroll, dialog_shell, dialog, menu_bar, button;
    lvars box, box2, title_widget;


    lvars label = GlXmString('Done');

    XtCreatePopupShell('dialog shell', xmDialogShellWidget,
                gl_shell_widget(gl_window),
                XptArgList([
                ]) ) -> dialog_shell;

    XtCreateWidget('dialog',
                xmMessageBoxWidget, dialog_shell,
                XptArgList([
                {dialogType ^XmDIALOG_MESSAGE}
                {okLabelString ^label}
                ]) ) -> dialog;

    XmStringFree(label);

    XtUnmanageChild(XtNameToWidget(dialog, 'Cancel'));
    XtUnmanageChild(XtNameToWidget(dialog, 'Help'));
    XtUnmanageChild(XtNameToWidget(dialog, 'Message'));

    XtCreateManagedWidget('box',
                xmRowColumnWidget, dialog,
                XptArgList([
                {orientation ^XmVERTICAL}
                ]) ) -> box;

    XtCreateManagedWidget(title,
                xmLabelWidget, box,
                XptArgList([
                ]) ) -> title_widget;

    XtVaCreateManagedWidget('separator',
                xmSeparatorGadget, box,
                XptVaArgList([])
                ) -> button;

    XtCreateManagedWidget('Message',
                xmScrolledWindowWidget, box,
                XptArgList([
                {scrollingPolicy ^XmAUTOMATIC}
                {scrollBarDisplayPolicy ^XmSTATIC}
                ]) ) -> scroll;

    /*
        Create a second RowColumnWidget on which to place the the menu
        bar. Fixes a problem with Lesstif. (09/04/00 - sra)
    */

    XtCreateManagedWidget('box2',
                xmRowColumnWidget, scroll,
                XptArgList([
                {orientation ^XmVERTICAL}
                ]) ) -> box2;

    XmCreateMenuBar(box2, 'menu_bar',
                XptArgList([
                {orientation ^XmVERTICAL}
                ])) -> menu_bar;

    lvars str;
    lvars width = 0;
    lvars max_width = 0;
    lvars height = 0;

    for i in agents do
        if isstring(sim_name(i)) then
            consword(sim_name(i)) -> sim_name(i);
            warning('CONVERTING STRING TO WORD IN sim_name()', [^i]);
        endif;
        sim_name(i) >< nullstring -> str;
        GlXmString(str) -> label;
        XtCreateManagedWidget(str >< '_',
                xmCascadeButtonWidget, menu_bar,
                XptArgList([
                    {labelString ^label}
                    ]) ) -> button;

        XptVal (button)(XtN height:XptDimension, XtN width:XptDimension)
                -> width, + height -> height;
        max(width, max_width) -> max_width;
        XtAddCallback(button, XmN cascadingCallback, GlListCB,
                                       {^dialog ^button ^(sim_name(i))});
        XmStringFree(label);
    endfor;


    XtManageChild(menu_bar);

    /* compensate for the width of the menu and scroll bar */

    (min(max_width + 55, 300), min(height + 42, 150))
        -> XptVal (scroll)(XtN width:XptDimension, XtN height:XptDimension);

    return(dialog);
enddefine;


/***************************************************************************
NAME
    GlListCB

SYNOPSIS
    GlListCB(w, client_data, call_data);

FUNCTION
    Callback for list popup dialog. This routine calculates the screen
    x, y position of the mouse and manages the selected object popup
    menu at that position.

RETURNS
    None.
***************************************************************************/
define vars procedure GlListCB(w, client_data, call_data);
    lvars w, client_data, call_data;

    lvars x, y;
    lvars obj, button, win, top_level;
    lvars popup_menu;

    explode(client_data) -> (top_level, button, obj);

    valof(obj) -> obj;                  /* convert word to object */

    XptVal (button)(XtN x:XptDimension, XtN y:XptDimension) -> (x, y);
    button -> win;

    /* calculate x,y position for popup menu */

    until win == top_level do
        XtParent(win) -> win;
        XptVal[fast] (win)(XtN x:XptDimension, XtN y:XptDimension)
                                                    + y -> y, + x -> x;
    enduntil;

    XptVal[fast] (button)(XtN width:XptDimension) + x -> x;

    GlPopupMenu(obj, x, y) -> popup_menu;
    GlBuildPopup(obj, popup_menu);

    /* manage the popup menu */

    XtManageChild(gl_widget(popup_menu));
enddefine;


/* ====================================================================== */

/*
    File Selection
    ==============

    GlAddFileSelectionDialog            - add a file selection dialog
            (filepath, filter, reason);
    GlRefreshFileDir(dialog);           - refresh the directory contents
    GlFileSelectionCB(w, client, call); - file selection callback
    GlPopdownCB(w, client, call);       - "cancel" popdown callback
*/


/***************************************************************************
NAME
    GlAddFileSelectionDialog

SYNOPSIS
    GlAddFileSelectionDialog(filepath, filter, reason);

FUNCTION
    Adds a file selection dialog. The "reason" can be either "open" or
    "save". The directory contents should be refreshed by calling
    RefreshFileDir(...) before managing the dialog.

RETURNS
    List dialog gl_widget.
***************************************************************************/
define vars procedure GlAddFileSelectionDialog(filepath, filter, reason)
                                                            /* -> dialog */;
    lvars filepath, filter, reason;

    lvars dialog, dialog_shell, button, title;

    lvars directory = GlXmString(filepath);
    lvars pattern = GlXmString(filter);

    XtCreatePopupShell('FileDialogShell' >< reason, xmDialogShellWidget,
                gl_shell_widget(gl_window),
                XptArgList([
                ]) ) -> dialog_shell;

    XmCreateFileSelectionBox(dialog_shell, 'FileDialog' >< reason,
                XptArgList([
                {directory ^directory}
                {pattern ^pattern}
                ]) ) -> dialog;

    XmStringFree(pattern);
    XmStringFree(directory);

    if reason == "open" then
        GlXmString('Open') -> button;
        GlXmString('Open File') -> title;
    else
        GlXmString('Save') -> button;
        GlXmString('Save File') -> title;
    endif;

    XtSetValues(dialog, XptArgList([
        {okLabelString ^button}
        {dialogTitle ^title} ]));

    XmStringFree(button);
    XmStringFree(title);
    return(dialog);
enddefine;


/***************************************************************************
NAME
    GlRefreshFileDir

SYNOPSIS
    GlReadFileDir(dialog);

FUNCTION
    Refresh the directory contents of a file dialog widget.

RETURNS
    None.
***************************************************************************/
define vars procedure GlRefreshFileDir(dialog);
    lvars dialog;

    lvars dir_mask;

    XptVal[fast] dialog(XmN dirMask:XmString) -> dir_mask;
    XmFileSelectionDoSearch(dialog, dir_mask);
    XmStringFree(dir_mask);
enddefine;


/***************************************************************************
NAME
    GlFileSelectionCB

SYNOPSIS
    GlFileSelectionCB(x, client_data, call_data);

FUNCTION
    File selection dialog callback. This code does nothing at present.

RETURNS
    None.
***************************************************************************/
define vars procedure GlFileSelectionCB(w, client_data, call_data);
    lvars w, client_data, call_data;
    l_typespec call_data :XmFileSelectionBoxCallbackStruct;
    lvars filename;

    XpmCoerceString(exacc call_data.value) -> filename;

    if client_data == "open" then
    else
    endif;

    XtUnmanageChild(w);
enddefine;


/***************************************************************************
NAME
    GlPopdownCB

SYNOPSIS
    GlPopdownCB(x, client_data, call_data);

FUNCTION
    Popdown callback, used for cancel selection on file selection dialog.

RETURNS
    None.
***************************************************************************/
define vars procedure GlPopdownCB(w, client_data, call_data);
    lvars w, client_data, call_data;

    XtUnmanageChild(w);
enddefine;


/* ====================================================================== */

/*
    Low Level Routines
    ==================

    GlXmString(name) -> string;
    GlAddLabel(name, parent, x, y) -> label;
    GlAddSeparator(parent);
    GlAddPushButton(name, parent, callback, id);
    GlAddCascade(name, parent,  menu) -> cascade;
*/


/***************************************************************************
NAME
    GlXmString

SYNOPSIS
    GlXmString(name) -> string;

FUNCTION
    Creates a XmString from a pop11 item (string, word, list, etc.). The
    routine uses >< to create a string.

RETURNS
    string of type XmString.
***************************************************************************/
define vars procedure GlXmString(name) /* -> string */;
    lvars name;

    unless isstring(name) then
        name >< nullstring -> name;
    endunless;
    return(XmStringCreateLtoR(name, XmSTRING_DEFAULT_CHARSET))
enddefine;


/***************************************************************************
NAME
    GlAddLabel

SYNOPSIS
    GlAddLabel(name, parent, x, y) -> label;

FUNCTION
    Add a label to the "parent" at "x", "y". The routine returns the
    label gl_widget.

RETURNS
    label gl_widget.
***************************************************************************/
define vars procedure GlAddLabel(name, parent, x, y) /* -> label */;
    lvars name, parent, x, y, label;

    XtCreateManagedWidget(name,
                xmLabelWidget, parent,
                XptArgList([{x ^x} {y ^y}])
                ) -> label;
    return(label);
enddefine;


/***************************************************************************
NAME
    GlAddSeparator;

SYNOPSIS
    GlAddSeparator(parent);

FUNCTION
    Add a separator to the "parent" menu bar.

RETURNS
    None.
***************************************************************************/
define vars procedure GlAddSeparator(parent);
    lvars menu;
    lvars button;

    XtVaCreateManagedWidget('separator',
                xmSeparatorGadget, parent,
                XptVaArgList([])
                ) -> button;
enddefine;


/***************************************************************************
NAME
    GlAddPushButton;

SYNOPSIS
    GlAddPushButton(name, parent, callback, id);

FUNCTION
    Add a pushbutton with callback to the "parent" menu bar.

RETURNS
    None.
***************************************************************************/
define vars procedure GlAddPushButton(name, parent, callback, id);
    lvars name, parent, callback, id;

    lvars button = XtVaCreateManagedWidget(name,
                        xmPushButtonGadget, parent,
                        XptVaArgList([]));

    XtAddCallback(button, XmN activateCallback, callback, id);
enddefine;


/***************************************************************************
NAME
    GlAddCascade;

SYNOPSIS
    GlAddCascade(name, parent, menu) -> cascade;

FUNCTION
    Add a cascade button to the "parent" menu bar.

RETURNS
    Cascade gl_widget.
***************************************************************************/
define vars procedure GlAddCascade(name, parent, menu) /* -> cascade */;
    lvars name, parent, menu;
    lvars cascade;
    lvars label = GlXmString(name);

    XtCreateManagedWidget(name,
                xmCascadeButtonWidget, parent,
                XptArgList([
                    {labelString ^label}
                    {subMenuId ^menu}])
                ) -> cascade;
    XmStringFree(label);
    return(cascade);
enddefine;

/* ====================================================================== */

/*
    Pulldown Menus
    ==============

    GlAddStatusMenu(name, parent);
    GlAddMenu(name, parent, callback, menu_items);

*/

/***************************************************************************
NAME
    GlAddStatusMenu

SYNOPSIS
    GlAddStatusMenu(name, parent);

FUNCTION
    Creates a Pulldown status menu, with a button for each status window
    in "gl_status_windows".

RETURNS
    None.
***************************************************************************/
define vars procedure GlAddStatusMenu(name, parent);
    lvars name, parent;

    lvars i, menu, cascade;
    lvars count = 1;

    XmCreatePulldownMenu(parent, name >< 'PullDownMenu',
                XptArgList([])
                ) -> menu;

    GlAddCascade(name, parent, menu) -> cascade;

    for i in gl_status_windows(gl_window) do
        GlAddPushButton(gl_name(i), menu, GlStatusMenuCB, i);
        count + 1 -> count;
    endfor;
enddefine;


/***************************************************************************
NAME
    GlAddMenu

SYNOPSIS
    GlAddMenu(name, parent, callback, menu_items);

FUNCTION
    Creates a Pulldown menu. The call can be recursively called to add
    multiple cascading menus to a menu bar.

RETURNS
    None.
***************************************************************************/
define vars procedure GlAddMenu(name, parent, callback, menu_items);
    lvars name, parent, callback, menu_items;
    lvars i, menu, cascade;

    XmCreatePulldownMenu(parent, name >< 'PullDownMenu',
                XptArgList([])
                ) -> menu;

    GlAddCascade(name, parent, menu) -> cascade;

    for i in menu_items do
        if isword(i) then
            GlAddSeparator(menu);
        elseif length(i) == 2 then
            GlAddPushButton(i(1), menu, callback, i(2));
        else
            GlAddMenu(i(1), menu, i(2), i(3));
        endif;
    endfor;
enddefine;

/* ====================================================================== */

/*
    Popup Menus
    ===========

    GlPopupMenu(obj) -> popup;              - returns the popup menu for obj
    GlAddPopupMenu(name, parent, x, y)
								-> popup;   - add a popup menu
    GlNewPopupMenu(name, parent) -> popup;  - create a popup menu object
    GlBuildPopup(obj, popup);               - insert name etc. into title
    GlPopupCB(w, client_data, call_data);   - callback to popup menu
*/


/***************************************************************************
NAME
    GlPopupMenu;

SYNOPSIS
    GlPopupMenu(obj, x, y) -> popup;

FUNCTION
    Returns or creates a popup menu for the agent. The uses of :method
    allows different popup menus to be assigned to different classes
    of agent.

RETURNS
    Popup "menu" object.
***************************************************************************/
define :method vars GlPopupMenu(obj:gl_agent, x, y);
    if isgl_menu(agent_popup) and
                    XptIsLiveType(gl_widget(agent_popup), "Widget") then
		XtSetValues(gl_widget(agent_popup), XptArgList([{x ^x} {y ^y}]));
        return(agent_popup);
    else
        return(GlAddPopupMenu('agent_popup', gl_title_widget(gl_window),
													x, y) ->> agent_popup);
    endif;
enddefine;


/***************************************************************************
NAME
    GlAddPopupMenu;

SYNOPSIS
    GlAddPopupMenu(name, parent, x, y) -> popup;

FUNCTION
    Add a popup menu to display agent status info and set debug levels.

    The menu is held in a "menu" object to allow access to the title and
    popup gl_widgets. The "menu" object also has a slot to hold the current
    agent.

RETURNS
    Popup "menu" object.
***************************************************************************/
define vars procedure GlAddPopupMenu(name, parent, x, y) /* -> popup */;
    lvars name, parent;
    lvars popup, menu;

    GlNewPopupMenu(name, parent, x, y) -> popup;
    gl_widget(popup) -> menu;

    GlAddPushButton('Print Status', menu, GlPopupCB, {print ^popup});

    GlAddMenu('Set Status Trace', menu, GlPopupCB,
        [{'Status Trace On' {trace {^popup ^true}}}
            {'Status Trace Off' {trace {^popup ^false}}}]);

    GlAddMenu('Set Debug Trace', menu, GlPopupCB,
        [{'No debug' {debug {^popup 0}}} {'Level 1' {debug {^popup 1}}}
            {'Level 2' {debug {^popup 2}}}]);

    GlAddSeparator(menu);

    GlAddPushButton('List Agents', menu, GlPopupCB, {agents ^popup});

    return(popup);
enddefine;


/***************************************************************************
NAME
    GlNewPopupMenu;

SYNOPSIS
    GlNewPopupMenu(name, parent, x, y) -> popup;

FUNCTION
    Add a popup menu.

    The menu is held in a "menu" object to allow access to the title and
    popup gl_widgets. The "menu" object also has a slot to hold the current
    agent.

RETURNS
    Popup "menu" object.
***************************************************************************/
define vars procedure GlNewPopupMenu(name, parent, x, y) /* -> popup */;
    lvars name, parent;
    lvars popup, menu;

    newgl_menu() -> popup;

    XmCreateSimplePopupMenu(parent, name >< 'Menu',
                    XptArgList([{x ^x} {y ^y}])
                    ) ->> menu -> gl_widget(popup);

    XtCreateManagedWidget(name >< 'Title',
                xmLabelWidget, menu,
                XptArgList([{alignment ^XmALIGNMENT_BEGINNING}])
                ) -> gl_title_widget(popup);

    GlAddSeparator(menu);
    return(popup);
enddefine;


/***************************************************************************
NAME
    GlBuildPopup;

SYNOPSIS
    GlBuildPopup(obj, popup);

FUNCTION
    Custonises the popup menu for each agent adding flag info and agent
    name to the popup title. The agent "obj" is added to the "gl_obj"
    slot of the menu.

RETURNS
    None.
***************************************************************************/
define vars procedure GlBuildPopup(obj, popup);
    lvars obj, popup;

    lvars flags = [%
        if gl_trace(gl_window) == obj then 'S' endif;
        if gl_debug_level(obj) > 0 then 'D' >< gl_debug_level(obj) endif;
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
    GlPopupCB;

SYNOPSIS
    GlPopupCB(w, client_data, call_data);

FUNCTION
    Callback for popup menu allowing agent status to be printed as well
    as setting debug and trace options.

RETURNS
    None.
***************************************************************************/
define vars procedure GlPopupCB(w, client_data, call_data);
    lvars w, client_data, call_data;
    lvars obj, popup, menu_id, data;

    explode(client_data) -> (menu_id, popup);

    unless isgl_menu(popup) then
        explode(popup) -> (popup, data)
    endunless;

    gl_obj(popup) -> obj;

    if isgl_agent(obj) then

        switchon menu_id

        case == "print" then
            GlPrintStatus(obj, true);       /* clears the window first */
            if gl_current_status_window(gl_window) /== sim_data_win then
                GlManageStatusWindow(agent_win);
            endif;
        case == "trace" then
            if data then
                obj -> gl_trace(gl_window);
            elseif gl_trace(gl_window) == obj then
                true -> gl_trace(gl_window);
            else
                false -> gl_trace(gl_window);
            endif;
        case == "debug" then
            if isgl_agent(obj) then
                data -> gl_debug_level(obj);
                if not(gl_trace(gl_window)) and data > 0 then
                    true -> gl_trace(gl_window)
                endif;
            endif;
        case == "agents" then
            unless XptIsLiveType(gl_list_widget(gl_window), "Widget") then
                GlAddAgentListDialog('Agents', gl_agents(gl_window))
                                            -> gl_list_widget(gl_window);
            endunless;
            XtManageChild(gl_list_widget(gl_window));

        else
            ;;;output('unexpected tag in GlPopupCB');
        endswitchon
    endif;
enddefine;

/* ====================================================================== */

/*
    Status Windows
    ==============

    GlManageStatusWindow(new_status_window);
    GlAddStatusWindow(win, parent, defs);
    GlAddStatusSubWindows(win, parent, defs);
    GlAddScrollTextWindow(name, parent, title, height);
    GlStatusMenuCB(w, client_data, call_data);
*/


/***************************************************************************
NAME
    GlManageStatusWindow

SYNOPSIS
    GlManageStatusWindow(new_status_window);

FUNCTION
    Manage the status windows. If the new window is different to the old,
    then unmanage the old window and display the new.

RETURNS
    None.
***************************************************************************/
define vars procedure GlManageStatusWindow(new_status_window);
    lvars new_status_window;

    if new_status_window /== gl_current_status_window(gl_window) then
        XtUnmanageChild(gl_widget(gl_current_status_window(gl_window)));
        XtManageChild(gl_widget(new_status_window));
        new_status_window -> gl_current_status_window(gl_window);
    endif;
enddefine;


/***************************************************************************
NAME
    GlAddStatusWindow

SYNOPSIS
    GlAddStatusWindow(win, parent, defs);

FUNCTION
    Adds a Status window to the shell (parent). The definitions are passed
    as "defs", and used to build the object "win".

RETURNS
    None
***************************************************************************/
define vars procedure GlAddStatusWindow(win, parent, defs);
    lvars win, parents, defs;

    lvars i;

    hd(defs)(1) -> gl_title_widget(win);
    hd(defs)(3) -> gl_num_columns(win);
    length(defs) - 1 -> i;
    i -> gl_num_windows(win);
    initv(i) -> gl_title_widgets(win);
    initv(i) -> gl_text_widgets(win);
    initv(i) -> gl_text_wins(win);
    GlAddStatusSubWindows(win, parent, tl(defs));
enddefine;


/***************************************************************************
NAME
    GlAddStatusSubWindows

SYNOPSIS
    GlAddStatusSubWindows(win, parent, defs);

FUNCTION
    Adds the individual text windows to the main status window.

RETURNS
    None
***************************************************************************/
define vars procedure GlAddStatusSubWindows(win, parent, defs);
    lvars win, parent, defs;

    lvars form;

    lvars i, j, out;
    lvars status_menu, menu_bar, cascade;
    lvars col = initv(gl_num_columns(win));

    XtCreateWidget('main_frame_' >< gl_name(win),
            xmFrameWidget, parent,
                XptArgList([
                {rightAttachment ^XmATTACH_FORM}
                {rightOffset 10}
                {leftAttachment ^XmATTACH_WIDGET}
                {leftWidget ^rc_window}
                {leftOffset 10}
                {topAttachment ^XmATTACH_OPPOSITE_WIDGET}
                {topWidget ^rc_window}
                {shadowType ^XmSHADOW_OUT}
                ]) ) -> gl_widget(win);

    XtCreateManagedWidget('main_form_' >< gl_name(win),
            xmFormWidget, gl_widget(win),
                XptArgList([
                {fractionBase ^(gl_num_columns(win))}
                ]) ) ->> gl_form_widget(win) -> form;

    /* add title menu bar */

    XmCreateMenuBar(form, 'menu',
                XptArgList([
                {leftAttachment ^XmATTACH_FORM}
                {leftOffset 5}
                {rightAttachment ^XmATTACH_FORM}
                {rightOffset 5}
                {topAttachment ^XmATTACH_FORM}
                {topOffset 5}
                {height 30}
                ]) ) ->> gl_menu_widget(win) -> menu_bar;

    GlAddStatusMenu(gl_title_widget(win), menu_bar);

    XtManageChild(menu_bar);

    /* create columns */

    for i from 1 to gl_num_columns(win) do
        XtCreateManagedWidget('col' >< i >< gl_name(win),
                xmRowColumnWidget, form,
                XptArgList([
                {topAttachment ^XmATTACH_WIDGET}
                {topWidget ^menu_bar}
                {topOffset 5}
                {leftAttachment ^XmATTACH_POSITION}
                {leftPosition ^(i-1)}
                {rightAttachment ^XmATTACH_POSITION}
                {rightPosition ^i}
                ]) ) -> col(i);
    endfor;

    /* add windows */

    1 -> j;
    for i in defs do
        GlAddScrollTextWindow(gl_name(win), col(i(3)), i(1), i(4))
                        -> (gl_title_widgets(win)(j),
                                gl_text_widgets(win)(j));
        if length(i) == 5 then
            /* create a new text window */
            newgl_text_win() -> out;
            0 -> gl_pos(out);
            0 -> gl_top(out);
            0 -> gl_old_pos(out);
            i(5) -> gl_size(out);
            1 -> gl_count(out);
            (gl_text_widgets(win)(j)) -> gl_text_widget(out);
            initvectorclass(gl_size(out), 0, vector_key)
                                                -> gl_delete_pts(out);
            sysSYNTAX(i(2), 0, false);
            out -> valof(i(2));
        else
            /* map text onto old source */
            valof(i(2)) -> out;
            XptValue(gl_text_widget(out), XmN source,
                TYPESPEC(:XmTextSource)) ->
                        XptValue(gl_text_widgets(win)(j), XmN source,
                                                TYPESPEC(:XmTextSource));
        endif;
        out -> gl_text_wins(win)(j);
        j + 1 -> j;
    endfor;
enddefine;


/***************************************************************************
NAME
    GlAddScrollTextWindow

SYNOPSIS
    GlAddScrollTextWindow(name, parent, title, height);

FUNCTION
    Creates a scrollable text window for the status window pane.

RETURNS
    None
***************************************************************************/
define vars procedure GlAddScrollTextWindow(name, parent, title, height)
                                    /*  -> (title_widget, text_widget)*/;
    lvars name, parent, title, height;
    lvars title_widget, text_widget;
    lvars frame, scroll, box;

    XtCreateManagedWidget('Frame' >< name,
                xmFrameWidget, parent,
                XptArgList([
                {bordorWidth 1}
                {shadowType ^XmSHADOW_ETCHED_IN}
                ]) ) -> frame;

    XtCreateManagedWidget('Box' >< name,
                xmRowColumnWidget, frame,
                XptArgList([
                {orientation ^XmVERTICAL}
                ]) ) -> box;

    XtCreateManagedWidget(title,
                xmLabelWidget, box,
                XptArgList([
                ]) ) -> title_widget;

    XtCreateManagedWidget('Scroll' >< name,
                xmScrolledWindowWidget, box,
                XptArgList([
                ]) ) -> scroll;

    XtCreateManagedWidget('Text' >< name,
                xmTextWidget, scroll,
                XptArgList([
                    {height ^height}
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
    return(title_widget, text_widget);
enddefine;

/***************************************************************************
NAME
    GlStatusMenuCB;

SYNOPSIS
    GlStatusMenuCB(e, client_data, call_data);

FUNCTION
    Status menu callback, managing the selected status window.

RETURNS
    None
***************************************************************************/
define vars procedure GlStatusMenuCB(w, client_data, call_data);
    lvars w, client_data, call_data;

    GlManageStatusWindow(client_data);
enddefine;


/* ====================================================================== */

/*
    Grid Display and Resize
    =======================

    GlSetupGrid();                      - define and draw the grid
    GlResizeGraphic(x, y, c, type);     - resize the grid graphic
    GlCellSize();                       - returns grid cellsize;
    GlGridXSize();                      - returns grid xsize;
    GlGridYSize();                      - returns grid ysize;
    GlGridType();                       - returns grid type;
*/


/***************************************************************************
NAME
    GlSetupGrid

SYNOPSIS
    GlSetupGrid();

FUNCTION
    Sets up the grid. if "gl_gridtype()" is "array" then a new array is
    generated (if the boundslist is different) and the array is
    initialised. The rc_window is cleared and all agents removed before
    a new grid is drawn.

RETURNS
    None.
***************************************************************************/
define vars procedure GlSetupGrid();
    lvars x, y, old;

    gl_gridland_widget(gl_window) -> rc_current_window_object;

    if gl_gridtype(gl_window) == "array" then

        lvars blist = [1 ^gridxsize 1 ^gridysize 1 2];
        unless isarray(gridland) and boundslist(gridland) = blist then
            newarray(blist) ->> gridland -> gl_gridland(gl_window);
        endunless;

        for x from 1 to gridxsize do
            for y from 1 to gridysize do
                empty_loc -> GlGrid(x, y);
            endfor;
        endfor;
    else
        false -> gridland;
    endif;

    rc_clear_window();
    [] -> rc_window_contents(gl_gridland_widget(gl_window));

    rc_linestyle -> old;
    LineSolid -> rc_linestyle;

    'black' -> rc_foreground(rc_window);

    for x from 2 to gridxsize do
        rc_drawline( GlGridXToRc(x), 0, GlGridXToRc(x),
                GlGridYToRc(gridysize)+cellsize)
    endfor;

    for y from 2 to gridysize do
        rc_drawline( 0, GlGridYToRc(y),
                GlGridXToRc(gridxsize)+cellsize, GlGridYToRc(y));
    endfor;

    old -> rc_linestyle;
enddefine;


/***************************************************************************
NAME
    GlResizeGraphic

SYNOPSIS
    GlResizeGraphic(x, y, c, type);

FUNCTION
    Allows the display graphic to be resized, and sets the local copies of
    gridxsize, gridysize, cellsize and gridtype.

RETURNS
    None
***************************************************************************/
define vars procedure GlResizeGraphic(x, y, c, type);
    lvars x, y, c, type;
    lvars window_xsize, window_ysize, i;

    x ->> gl_gridxsize(gl_window) -> gridxsize;
    y ->> gl_gridysize(gl_window) -> gridysize;
    c ->> gl_cellsize(gl_window) -> cellsize;
    type -> gl_gridtype(gl_window);

    gridxsize*cellsize-1 -> window_xsize;
    gridysize*cellsize-1 -> window_ysize;

    XtUnmanageChild(gl_widget(gl_current_status_window(gl_window)));

    /* reset the gridland_window object with new values */
    {-1 ^window_ysize 1 -1} -> rc_window_origin(gl_gridland_widget(gl_window));

    {-1 ^window_ysize 1 -1 0 0 0 ^false 0 0 ^window_xsize ^window_ysize}
            -> rc_window_frame(gl_gridland_widget(gl_window));

    /* set the size of rc_window */
    (window_xsize, window_ysize) -> XptVal[fast] (rc_window)
            (XtN width:XptDimension, XtN height:XptDimension);

    XpwClearWindow(rc_window);

    lvars max_height;
    XptVal[fast] (XtParent(rc_window))(XtN height:XptDimension)
                                                            -> max_height;
    for i in gl_status_windows(gl_window) do
       max( max_height, XptVal[fast] (gl_widget(i)) (XtN height:XptDimension))
                                                            -> max_height;
    endfor;

    lvars win_height, win_width;
    lvars scr_height, scr_width;
    lvars scr = XtScreen(gl_shell_widget(gl_window));

    max_height + 70 -> win_height;


    exacc :XScreen scr.width -> scr_width;
    exacc :XScreen scr.height -> scr_height;


    min(gl_status_width(gl_window) + window_xsize + 50, scr_width - 20)
                                                            -> win_width;

    max(10, ((scr_width - win_width) div 2)) -> x;
    max(10, ((scr_height - win_height) div 2)) -> y;

    (win_width, win_width, win_height, win_height, x, y) -> XptVal[fast]
            (gl_shell_widget(gl_window))(XtN width:XptDimension,
                    XtN minWidth:XptDimension, XtN height:XptDimension,
                        XtN minHeight:XptDimension, XtN x:XptDimension,
                            XtN y:XptDimension);

    /*
        set the 12 global values from the frame vector
                    (set in rc_new_window_object...)
    */

    rc_set_window_globals(gl_gridland_widget(gl_window));
    XtManageChild(gl_widget(gl_current_status_window(gl_window)));

    GlSetupGrid();
enddefine;

/***************************************************************************
NAME
    GlCellSize, GlGridXSize, GlGridYSize, GlGridType

SYNOPSIS
    GlCellSize() -> cellsize;
    GlGridXSize() -> gridxsize;
    GlGridYSize() -> gridysize;
    GlGridType() -> gridtype;

FUNCTION
    Returns the gridland attributes.

RETURNS
    None.
***************************************************************************/
define vars procedure GlCellSize();
    gl_cellsize(gl_window);
enddefine;

define vars procedure GlGridXSize();
    gl_gridxsize(gl_window);
enddefine;

define vars procedure GlGridYSize();
    gl_gridysize(gl_window);
enddefine;

define vars procedure GlGridType();
    gl_gridtype(gl_window);
enddefine;

/* ====================================================================== */

/*
    Cycle Counter
    =============

    GlUpdateCycleCount();               - update the cycle count display
*/


/***************************************************************************
NAME
    GlUpdateCycleCount

SYNOPSIS
    GlUpdateCycleCount();

FUNCTION
    Updates the cycle counter display.

RETURNS
    None
***************************************************************************/
define vars procedure GlUpdateCycleCount();

    lvars str = GlXmString(sim_cycle_number);
    str -> XptVal[fast]
            (gl_cycle_num_widget(gl_window))(XmN labelString:XmString);
    XmStringFree(str);
enddefine;



/* ====================================================================== */


/*
    Mouse Events
    ============

    rc_button_3_down(pic, newx, newy, modifiers);

*/


/***************************************************************************
NAME
    rc_button_3_down

SYNOPSIS
    rc_button_3_down(pic, newx, newy, modifiers);

FUNCTION
    Prints status information and sets the debug level of the object
    under the mouse.

RETURNS
    None.
***************************************************************************/
define :method vars rc_button_3_down(obj:gl_agent, x, y, modifiers);
    lvars obj, x, y, modifiers;
    lvars popup;
    lvars windowx = 0, windowy = 0;
    lvars win = rc_window;

    until win == gl_shell_widget(gl_window) do
	
        XptVal[fast] (win)(XtN x:XptDimension, XtN y:XptDimension)
                + windowy -> windowy, + windowx -> windowx;
        XtParent(win) -> win;
    enduntil;

    rc_mousexyin(gl_gridland_widget(gl_window), x, y) -> (x, y);

    GlPopupMenu(obj, x+windowx, y+windowy) -> popup;
    GlBuildPopup(obj, popup);

    XtManageChild(gl_widget(popup));


enddefine;

/* ====================================================================== */

/*
    Gridland Access Mechanisms
    ==========================

    rc_move_to(pic, x, y, mode);        - snaps pic to grid

    GlValidLoc(x, y) -> valid;          - checks validity of x,y

    GlGrid(x, y ) -> cell;              - returns cell at loc (x,y)
    cell -> GlGrid(x, y);               - writes cell to loc (x,y)

    GlCellUnoccupied(agent, x, y)       - tests for unoccupied cells
                            -> boole;

    GlAddToGrid(agent);                 - add agent to grid
    GlAddToDisplay(agent);              - add agent to display
    GlRemoveFromGrid(agent);            - remove agent from grid
    GlRemoveFromDisplay(agent);         - remove agent from display

    GlDisplayAgents() -> data;          - returns display agent flag
    data -> GlDisplayAgents();          - displays/hides agents

    GlAddAgent(agent);                  - add agent to gridland
    GlRemoveAgent(agent);               - remove agent from gridland
    GlMoveAgent(agent, x, y);           - move agent to loc (x,y)

    GlRefreshAgent(agent);              - update agent attribs in grid
    GlFindFreeLoc(agent) -> (x, y);     - returns a free location big enough
                                            for the agent.

    GlGridXToRc(x) -> rc;               - convert Grid x to rc coords
    GlGridYToRc(y) -> rc;               - convert Grid y to rc coords
    GlRcToGridX(rc) -> x;               - convert rc coords to Grid x
    GlRcToGridY(rc) -> y;               - convert rc coords to Grid y
*/

/***************************************************************************
NAME
    rc_move_to

SYNOPSIS
    rc_move_to(pic, x, y, mode);

FUNCTION
    Snaps the object to Grid co-ordinates and calls the next method.

RETURNS
    None.
***************************************************************************/
define :method vars rc_move_to(pic:gl_attrib, x, y, mode);
    lvars pic, x, y, mode;
    call_next_method(pic, GlGridXToRc(GlRcToGridX(x)),
                                        GlGridYToRc(GlRcToGridY(y)), mode);
enddefine;


/***************************************************************************
NAME
    GlValidLoc

SYNOPSIS
    GlValidLoc(x, y) -> valid;

FUNCTION
    Checks the Grid loc coordinates to see if they are in range.

RETURNS
    <true> if valid GlGrid location, else <false>.
***************************************************************************/
define vars procedure GlValidLoc(x, y) /* -> valid */;
    lvars x, y;
    return(x > 0 and x <= gridxsize and y > 0 and y <= gridysize);
enddefine;


/***************************************************************************
NAME
    GlGrid

SYNOPSIS
    GlGrid(x, y) -> cell;
    cell -> GlGrid(x, y);

FUNCTION
    Returns or updates the contents of GlGrid location (x, y). Each grid
    location can take a single foreground object (one with a non-empty
    occupancy value) and a number of background objects (with an empty
    occupancy value). Backround objects are stored as a list.

RETURNS
    if valid Grid location then returns <Cell>, else vector indicating
    occupied cell with AGENT_ID entry set to <false>.
***************************************************************************/
define vars procedure GlGrid(x, y);
    lvars x, y;

    if GlValidLoc(x, y) then
        lvars cell;
        if isarray(gridland) then
            if iscell(gridland(x,y,1) ->> cell) then
                return(cell);
            else
                if ispair(gridland(x,y,2) ->> cell) then
                    return(front(cell));
                else
                    return(cell);
                endif;
            endif;
        else
            lvars i, basex, basey;
            lvars obj, count, cell;
            lvars background = empty_loc;
            for obj in gl_agents(gl_window) do
                explode(gl_loc(obj)) -> (basex, basey);
                1 -> count;
                for i in gl_surface(obj) do
                    if x == (basex + i(1)) and y == (basey + i(2)) then
                        if gl_occupancy(gl_physical(obj)(count) ->> cell)
                                                            /== EMPTY then
                            return(cell);
                        else
                            cell -> background;
                        endif;
                    endif;
                    count + 1 -> count;
                endfor;
            endfor;
            return(background);
        endif;
    else
        return(invalid_loc)
    endif;
enddefine;

define updaterof vars procedure GlGrid(cell, x, y);
    lvars cell, x, y;

    if GlValidLoc(x, y) and isarray(gridland) then
        if gl_occupancy(cell) /== EMPTY then
            cell -> gridland(x,y,1)
        else
            if cell == empty_loc then
                if iscell(gridland(x,y,1)) then
                    false -> gridland(x,y,1);
                elseif ispair(gridland(x,y,2)) then
                    back(gridland(x,y,2)) -> gridland(x,y,2);
                else
                    cell -> gridland(x,y,2);
                endif;
            else
                conspair(cell, gridland(x,y,2)) -> gridland(x,y,2);
            endif;
        endif;
    endif;
enddefine;


/***************************************************************************
NAME
    GlCellUnoccupied

SYNOPSIS
    GlCellUnoccupied(agent, x, y) -> boole;

FUNCTION
    Tests the cells to see if they are occupied by another agent. This is
    used before moving agents to new locations.

RETURNS
    True if cell is unoccupied, else false.
***************************************************************************/
define :method vars GlCellUnoccupied(agent:gl_attrib, x, y);
    lvars agent;
    lvars i, cell, count;

    0 -> count;
    for i in gl_surface(agent) do
        count + 1 -> count;
        GlGrid(x+i(1), y+i(2)) -> cell;
        if gl_occupancy(cell) /== EMPTY and
                    gl_agent_id(cell) /== sim_name(agent) and
                            gl_occupancy(gl_physical(agent)(count)) /== EMPTY then
            return(false);
        endif;
    endfor;
    return(true);
enddefine;


/***************************************************************************
NAME
    GlAddToGrid

SYNOPSIS
    GlAddToGrid(agent);

FUNCTION
    Add an agent to the physical grid.

RETURNS
    None.
***************************************************************************/
define :method vars GlAddToGrid(agent:gl_attrib);
    lvars agent;
    lvars i, cell, x, y;

    explode(gl_loc(agent)) -> (x, y);
    for i cell in gl_surface(agent), gl_physical(agent) do
        cell -> GlGrid(x+i(1), y+i(2));
    endfor;
enddefine;


/***************************************************************************
NAME
    GlAddToDisplay

SYNOPSIS
    GlAddToDisplay(agent);

FUNCTION
    Add an agent to the display.

RETURNS
    None
***************************************************************************/
define :method vars GlAddToDisplay(agent:gl_attrib);
    lvars agent;
    lvars x, y;

    explode(gl_loc(agent)) -> (x, y);
    if gl_display(gl_window) and GlValidLoc(x, y) and not(lmember(agent,
                    rc_window_contents(gl_gridland_widget(gl_window)))) then
        GlGridXToRc(x) -> rc_picx(agent);
        GlGridYToRc(y) -> rc_picy(agent);
        rc_draw_linepic(agent);
        rc_add_pic_to_window(agent, gl_gridland_widget(gl_window), true);
    endif;
enddefine;


/***************************************************************************
NAME
    GlRemoveFromGrid

SYNOPSIS
    GlRemoveFromGrid(agent);

FUNCTION
    Remove an agent from the physical grid.

RETURNS
    None.
***************************************************************************/
define :method vars GlRemoveFromGrid(agent:gl_attrib);
    lvars agent;
    lvars i, x, y;

    explode(gl_loc(agent)) -> (x, y);
    for i in gl_surface(agent) do
        empty_loc -> GlGrid(x+i(1), y+i(2));
    endfor;
enddefine;


/***************************************************************************
NAME
    GlRemoveFromDisplay

SYNOPSIS
    GlRemoveFromDisplay(agent);

FUNCTION
    Remove an agent from the display.

RETURNS
    None.
***************************************************************************/
define :method vars GlRemoveFromDisplay(agent:gl_attrib);
    lvars agent;

    if gl_display(gl_window) and GlValidLoc(explode(gl_loc(agent))) and
            lmember(agent,
                rc_window_contents(gl_gridland_widget(gl_window))) then
        rc_draw_linepic(agent);
        rc_remove_pic_from_window(agent, gl_gridland_widget(gl_window));
    endif;
enddefine;


/***************************************************************************
NAME
    GlDisplayAgents

SYNOPSIS
    GlDisplayAgents() -> display;
    display -> GlDispalyAgents();

FUNCTION
    In update mode this displays or hides the agents, otherwise it returns
    the current status of the display.

RETURNS
    <true> if agents dispalyed, else <false>.
***************************************************************************/
define updaterof vars procedure GlDisplayAgents(display);
    lvars display;
    lvars agent;

    true -> gl_display(gl_window);
    for agent in gl_agents(gl_window) do
        if display then
            GlAddToDisplay(agent);
        else
            GlRemoveFromDisplay(agent);
        endif;
    endfor;
    display -> gl_display(gl_window);
enddefine;

define vars procedure GlDisplayAgents() /* -> display */;
    return(gl_display(gl_window));
enddefine;


/***************************************************************************
NAME
    GlAddAgent

SYNOPSIS
    GlAddAgent(agent);

FUNCTION
    Adds the agent "agent" to the Gridland world. The agent attribs are
    inserted into the gridland array and the agent is drawn on the screen.

    If the cell is occupied (or off the edge of the grid) then the
    agent's location is set to 0, 0.

RETURNS
    None.
***************************************************************************/
define :method vars GlAddAgent(agent:gl_attrib);
    lvars agent;
    lvars i, x, y;

    explode(gl_loc(agent)) -> (x, y);

    if GlValidLoc(x, y) and GlCellUnoccupied(agent, x, y) then
        GlAddToGrid(agent);
        GlAddToDisplay(agent);
    else
        0 -> gl_loc(agent)(1);
        0 -> gl_loc(agent)(2);
    endif;
enddefine;


/***************************************************************************
NAME
    GlRemoveAgent

SYNOPSIS
    GlRemoveAgent(agent);

FUNCTION
    Remove the agent "agent" from the Gridland world. The agent attribs are
    reset to reflect a (0, 0) Grid location, the gridland array is marked
    as empty, and the agent is removed on the screen.

RETURNS
    None.
***************************************************************************/
define :method vars GlRemoveAgent(agent:gl_attrib);
    lvars agent;

    if GlValidLoc(explode(gl_loc(agent))) then
        GlRemoveFromGrid(agent);
        GlRemoveFromDisplay(agent);
        0 -> gl_loc(agent)(1);
        0 -> gl_loc(agent)(2);
    endif;
enddefine;


/***************************************************************************
NAME
    GlMoveAgent

SYNOPSIS
    GlMoveAgent(obj, x, y);

FUNCTION
    Moves the agent "obj" to a new location (x, y). The agent is first
    removed from Gridland and then added at the new location. Both the
    agent presence in the gridland array and on the sceeen are updated.

RETURNS
    None.
***************************************************************************/
define :method vars GlMoveAgent(obj:gl_attrib, x, y);
    lvars obj, x, y;

    if GlValidLoc(x, y) then
        GlRemoveAgent(obj);
        x -> gl_loc(obj)(1);
        y -> gl_loc(obj)(2);
        GlAddAgent(obj);
    endif;
enddefine;


/***************************************************************************
NAME
    GlRefreshAgent

SYNOPSIS
    GlRefreshAgent(obj, x, y);

FUNCTION
    Refreshes the agent attributes by re-adding it to the grid.

RETURNS
    None.
***************************************************************************/
define :method vars GlRefreshAgent(agent:gl_attrib);
    lvars agent;

    if GlValidLoc(explode(gl_loc(agent))) then
        GlAddToGrid(agent);
    endif;
enddefine;


/***************************************************************************
NAME
    GlFindFreeLoc

SYNOPSIS
    GlFindFreeLoc(agent) -> (x, y);

FUNCTION
    Finds a free location on the grid big enough to tage the agent. The
    routine makes a number of attempts (count) to find a big enough
    space before giving up and returning 0, 0.

RETURNS
    Free grid location, or (0, 0) if none found.
***************************************************************************/
define :method vars GlFindFreeLoc(agent:gl_attrib) /* -> (x, y) */;
    lvars agent;

    lvars count = 100;                  ;;; number of attempts allowed
    lvars newx, newy;
    lvars i;
    lvars occupied = true;

    while occupied and count > 0 do

        random(gridxsize) -> newx;
        random(gridysize) -> newy;

        false -> occupied;
        for i in gl_surface(agent) do
            if gl_occupancy(GlGrid(newx+i(1), newy+i(2))) /== 0 then
                true -> occupied;
                quitloop;
            endif;
        endfor;

        count - 1 -> count;
    endwhile;

    if occupied then
        return(0, 0);
    endif;
    return(newx, newy);
enddefine;


/***************************************************************************
NAME
    GlGridXToRc

SYNOPSIS
    GlGridXToRc(x) -> rc;

FUNCTION
    Converts a Gridland x coord into a rc_graphic coord.

RETURNS
    rc_graphic coord.
***************************************************************************/
define vars procedure GlGridXToRc(x) /* -> rc */;
    lvars x;

    if x < 1 then
        return(0);
    elseif x > gridxsize then
        return((gridxsize-1) * cellsize);
    endif;

    return((x-1) * cellsize);
enddefine;

/***************************************************************************
NAME
    GlGridYToRc

SYNOPSIS
    GlGridYToRc(y) -> rc;

FUNCTION
    Converts a Gridland y coord into a rc_graphic coord.

RETURNS
    rc_graphic coord.
***************************************************************************/
define vars procedure GlGridYToRc(y) /* -> rc */;
    lvars y;

    if y < 1 then
        return(0);
    elseif y > gridysize then
        return((gridysize-1) * cellsize);
    endif;

    return((y-1) * cellsize);
enddefine;


/***************************************************************************
NAME
    GlGridRcToX

SYNOPSIS
    GlGridRcToX(rc) -> x;

FUNCTION
    Converts a rc_graphic coord into a Gridland x coord. Values outside
    the grid are clipped to the edge.

RETURNS
    Gridland x coord.
***************************************************************************/
define vars procedure GlRcToGridX(rc) /* -> x */;
    lvars rc;

    if rc < 0 then
        return(1);
    elseif rc > (gridxsize-1) * cellsize then
        return(gridxsize);
    endif;

    return((rc div cellsize)+1);
enddefine;


/***************************************************************************
NAME
    GlGridRcToY

SYNOPSIS
    GlGridRcToY(rc) -> y;

FUNCTION
    Converts a rc_graphic coord into a Gridland y coord. Values outside the
    grid are clipped to the edge.

RETURNS
    Gridland y coord.
***************************************************************************/
define vars procedure GlRcToGridY(rc);
    lvars rc;

    if rc < 0 then
        return(1);
    elseif rc > (gridysize-1)*cellsize then
        return(gridysize);
    endif;

    return((rc div cellsize)+1);
enddefine;


/* ====================================================================== */

/*
    Customise the print method
    ==========================

    print_instance(item);               - for displaying agent attribs
    GlUpdateStatusBanner();             - set the status print banner
    GlPrintStatus(agent, clear);        - print status info
*/

/***************************************************************************
NAME
    print_instance

SYNOPSIS
    print_instance(item);

FUNCTION
    print_instance method for gl_agents.

RETURNS
    None.
***************************************************************************/
define :method vars print_instance(item:gl_agent);
    lvars item;
    dlocal pop_pr_places = 0;

    printf('<agent %p at (%p %p)>',
            [% sim_name(item), explode(gl_loc(item)) %]);
enddefine;


/***************************************************************************
NAME
    GlPrintStatus

SYNOPSIS
    GlPrintStatus(item, clear);

FUNCTION
    Prints the status info in the status window. If "clear" is set then the
    window is first cleared and the text position is reset to the top
    of the window.

RETURNS
    None.
***************************************************************************/
define :method vars GlPrintStatus(item:gl_agent, clear);
    lvars item, clear;
    dlocal pop_pr_places = 3;
    dlocal pop_pr_ratios = false;
    lvars i, j, data, slots;

    /* clear windows */

    if clear then
        GlClrWin(agent_win);
    endif;

    /* sim agent slots */

    if issim_agent(item) then
        class_slots(sim_agent_key) -> slots;
    elseif issim_object(item) then
        class_slots(sim_object_key) -> slots;
    else
        [] -> slots;
    endif;
    unless slots == [] then
        GlPrWinStatusBanner(sim_agent_out);
        for i in slots do
            if i == sim_data then
                GlPrWinStatusBanner(sim_data_out);
                GlPrWin(sim_data_out, sprintf('sim_name = %p',
                                                    [^(sim_name(item))]));
                if (GlDbtable(sim_data(item)) ->> data) == [] then
                    GlPrWin(sim_data_out, 'sim_data = []');
                else
                    GlPrWin(sim_data_out, 'sim_data = [');
                    for j in data do
                        GlPrWin(sim_data_out, '  ' >< j);
                    endfor;
                    GlPrWin(sim_data_out, '  ]');
                endif;
                if clear then GlTopWin(sim_data_out) endif;
            else
                GlPrWin(sim_agent_out, sprintf('%p = %p',
                                              [% pdprops(i),  i(item) %]));
            endif;
        endfor;
        if clear then GlTopWin(sim_agent_out) endif;
    endunless;

    /* gl_agent slots */

    if isgl_agent(item) then
        class_slots(gl_agent_key) -> slots;
        GlPrWinStatusBanner(gl_agent_out);
        for i in slots do
            GlPrWin(gl_agent_out, sprintf('%p = %p',
                                              [% pdprops(i),  i(item) %]));
        endfor;
        if clear then GlTopWin(gl_agent_out) endif;
    endif;

    /* gl_attrib slots */

    if isgl_attrib(item) then
        class_slots(gl_attrib_key) -> slots;
        GlPrWinStatusBanner(gl_attrib_out);
        for i in slots do
            GlPrWin(gl_attrib_out, sprintf('%p = %p',
                                              [% pdprops(i),  i(item) %]));
        endfor;
        if clear then GlTopWin(gl_attrib_out) endif;
    endif;
enddefine;


/***************************************************************************
NAME
    GlUpdateStatusBanner

SYNOPSIS
    GlUpdateStatusBanner();

FUNCTION
    Updates the status banner string to reflect the current sim_agent cycle.

RETURNS
    None.
***************************************************************************/
define vars procedure GlUpdateStatusBanner();
    sprintf('=== cycle %p ===', [^sim_cycle_number]) -> status_banner;
enddefine;

/* ====================================================================== */

/*
    Status Window Printing
    ======================

    GlTextDisableRedisplay(win);    - disable text redisplay in window
    GlTextEnableRedisplay(win);     - enable text redisplay in window
    GlClrWin(win);                  - clear the status window
    GlPrWinStatusBanner(win);       - print the status_banner in the window
    GlPrWin(win, data);             - print "data" in the status window
    GlTopWin(win);                  - set text position to top of window
    GlDbtable(table);               - returns list of items in table
*/


/***************************************************************************
NAME
    GlTextDisableRedisplay

SYNOPSIS
    GlClrWin(win);

FUNCTION
    Clears the status window "win", reseting the window pointers.

RETURNS
    None.
***************************************************************************/
define :method GlTextDisableRedisplay(win:gl_text_win);
    lvars win;
    XmTextDisableRedisplay(gl_text_widget(win));
enddefine;

define :method GlTextDisableRedisplay(win:gl_status_win);
    lvars win;
    lvars i;
    for i from 1 to gl_num_windows(win) do
        XmTextDisableRedisplay(gl_text_widgets(win)(i));
    endfor;
enddefine;



define :method GlTextEnableRedisplay(win:gl_status_win);
    lvars win;
    lvars i;
    for i from 1 to gl_num_windows(win) do
        XmTextEnableRedisplay(gl_text_widgets(win)(i));
    endfor;
enddefine;

define :method GlTextEnableRedisplay(win:gl_text_win);
    lvars win;
    XmTextEnableRedisplay(gl_text_widget(win));
enddefine;

/***************************************************************************
NAME
    GlClrWin

SYNOPSIS
    GlClrWin(win);

FUNCTION
    Clears the status window "win", reseting the window pointers.

RETURNS
    None.
***************************************************************************/
define :method vars GlClrWin(win:gl_text_win);
    lvars win;

    if gl_pos(win) /== 0 then
        XmTextSetString(gl_text_widget(win), nullstring);
        0 -> gl_pos(win);
        0 -> gl_top(win);
        0 -> gl_old_pos(win);
        1 -> gl_count(win);
        fill(dupnum(0,gl_size(win)), gl_delete_pts(win)) ->;
    endif;
enddefine;

define :method vars GlClrWin(win:gl_status_win);
    lvars win;
    lvars i;
    for i from 1 to gl_num_windows(win) do
        GlClrWin(gl_text_wins(win)(i));
    endfor;
enddefine;

/***************************************************************************
NAME
    GlPrWinStatusBanner

SYNOPSIS
    GlPrWinStatusBanner(win);

FUNCTION
    Print the status_banner (containing the current cycle number) in the
    window "win".

RETURNS
    None.
***************************************************************************/
define :method vars GlPrWinStatusBanner(win:gl_text_win);
    max(0, gl_pos(win)) -> gl_top(win);
    XmTextShowPosition(gl_text_widget(win), gl_top(win));
    GlPrWin(win, status_banner);
enddefine;

define :method vars GlPrWinStatusBanner(win:gl_status_win);
    lvars win;
    lvars i;
    for i from 1 to gl_num_windows(win) do
        GlPrWinStatusBanner(gl_text_wins(win)(i));
    endfor;
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

    /* add new text */

    XmTextInsert(gl_text_widget(win), gl_pos(win), str);
    gl_pos(win) + len -> gl_pos(win);
    unless gl_top(win) then
        XmTextShowPosition(gl_text_widget(win), gl_pos(win));
    endunless;
enddefine;

define :method vars GlMkWin(win:gl_status_win);
    lvars win;
    lvars i;
    for i from 1 to gl_num_windows(win) do
        GlMkWin(gl_text_wins(win)(i));
    endfor;
enddefine;

define :method vars GlMkWin(win:gl_text_win);
    lvars win;
    lvars delete_pt;

    gl_count(win) mod gl_size(win) + 1 -> gl_count(win);
    gl_delete_pts(win)(gl_count(win)) -> delete_pt;
    gl_pos(win) - gl_old_pos(win) -> gl_delete_pts(win)(gl_count(win));
    gl_pos(win) -> gl_old_pos(win);

    if delete_pt > 0 then
        ;;;XmTextDisableRedisplay(gl_text_widget(win));
        XmTextSetEditable(gl_text_widget(win), true);
/*
        removing a section caused problems

        XmTextSetSelection(gl_text_widget(win), 0, delete_pt,
                XtLastTimestampProcessed(XtDisplay(gl_text_widget(win))));

        XmTextRemove(gl_text_widget(win)) ->;
*/
		/* removing a selection causes problems so now use replace */
        XmTextReplace(gl_text_widget(win), 0, delete_pt, '');

        XmTextSetEditable(gl_text_widget(win), false);
        max(0, gl_old_pos(win) - delete_pt) -> gl_old_pos(win);
        max(0, gl_pos(win) - delete_pt) -> gl_pos(win);

        if gl_top(win) then
            max(0, gl_top(win) - delete_pt) -> gl_top(win);
        else
            XmTextShowPosition(gl_text_widget(win), gl_pos(win));
        endif;

        ;;;XmTextEnableRedisplay(gl_text_widget(win));
    endif;

enddefine;

/***************************************************************************
NAME
    GlTopWin

SYNOPSIS
    GlTopWin(win);

FUNCTION
    Sets the text show position to the top of the window "win".

RETURNS
    None.
***************************************************************************/
define vars procedure GlTopWin(win);
    lvars win;
    ;;;XmTextShowPosition(gl_text_widget(win), gl_top(win));
    if gl_top(win) then
        gl_top(win) ->
                    XptVal[fast] (gl_text_widget(win)) (XmN topCharacter);
    endif;
enddefine;


/***************************************************************************
NAME
    GlDbtable

SYNOPSIS
    GlDbtable(table) -> items;

FUNCTION
    Returns a list of the contents of the prb_database "table"

RETURNS
    None.
***************************************************************************/
define vars procedure GlDbtable(dbtable) /* -> items */;
    lvars dbtable;
    dlocal pop_pr_ratios = false;
    lvars key;
    lvars keys = sort(prb_database_keys(dbtable));

    return([% fast_for key in keys do explode(dbtable(key)) endfor %]);
enddefine;

/* ====================================================================== */

/*
    Tracing
    =======

    sim_scheduler_pausing_trace(objects, cycle);
    sim_scheduler_finshed(object, cycle);
    sim_agent_message_out_trace(agent);
    sim_agent_message_in_trace(agent);
    sim_agent_actions_out_trace(agent);
    sim_agent_rulefamily_trace(object, rulefamily);
    sim_agent_endrun_trace(agent);
    sim_agent_terminated_trace(object);
*/

define vars procedure sim_scheduler_pausing_trace(objects, cycle);
    ;;; user definable
    lvars objects, cycle;
    if gl_trace(gl_window) then
        GlPrWin(debug_out, '=== end of cycle ' >< cycle >< ' ===');
    endif;
enddefine;

define vars procedure sim_scheduler_finished(objects, cycle);
    ;;; user definable
    lvars objects, cycle;
    if gl_trace(gl_window) then
        GlPrWin(debug_out, '=== Finished. Cycle ' >< cycle >< ' ===');
    endif;
enddefine;

define :method vars sim_agent_messages_out_trace(agent:gl_agent);
    lvars agent;
    dlocal pop_pr_ratios = false;

    if gl_debug_level(agent) > 0 and gl_trace(gl_window) then
        lvars messages = sim_out_messages(agent);
        GlPrWin(debug_out, sprintf('New messages out %p %p',
                                        [^(sim_name(agent)) ^messages]));
    endif;
enddefine;

define :method vars sim_agent_messages_in_trace(agent:gl_agent);
    lvars agent;
    dlocal pop_pr_ratios = false;

    if gl_debug_level(agent) > 0  and gl_trace(gl_window) then
        lvars messages = sim_in_messages(agent);
        GlPrWin(debug_out, sprintf('New messages in %p %p',
                                        [^(sim_name(agent)) ^messages]));
    endif;
enddefine;

define :method vars sim_agent_actions_out_trace(agent:gl_agent);
    lvars agent;
    dlocal pop_pr_ratios = false;

    if gl_debug_level(agent) > 0 and gl_trace(gl_window) then
        lvars actions = sim_actions(agent);
        GlPrWin(debug_out, sprintf('New actions %p %p',
                                            [^(sim_name(agent)) ^actions]));
    endif;
enddefine;

define :method vars sim_agent_rulefamily_trace(object:gl_agent, rulefamily);
    lvars object, rulefamily;
    dlocal pop_pr_ratios = false;
    lvars j, data;

    if gl_debug_level(object) > 0 and gl_trace(gl_window) then
        GlPrWin(debug_out, sprintf('Try rulefamily %p with %p',
                                    [^rulefamily ^(sim_name(object))]));

        if (GlDbtable(sim_data(object)) ->> data) == [] then
            GlPrWin(debug_out, '  with data: []');
        else
            GlPrWin(debug_out, '  with data: [');
            for j in data do
                GlPrWin(debug_out, '  ' >< j);
            endfor;
            GlPrWin(debug_out, '  ]');
        endif;
    endif;
enddefine;

define :method vars sim_agent_endrun_trace(agent:gl_agent);
    lvars agent;
    dlocal pop_pr_ratios = false;
    lvars j, data;

    if gl_debug_level(agent) > 0 and gl_trace(gl_window) then
        if (GlDbtable(sim_data(agent)) ->> data) == [] then
            GlPrWin(debug_out, sprintf('Data in %p: []',
                                            [^(sim_name(agent))]));
        else
            GlPrWin(debug_out, sprintf('Data in %p: [',
                                            [^(sim_name(agent))]));
            for j in data do
                GlPrWin(debug_out, '  ' >< j);
            endfor;
            GlPrWin(debug_out, '  ]');
        endif;
    endif;
enddefine;

define :method sim_agent_terminated_trace(agent:sim_object, number_run, runs, max_cycles);
    ;;; After each rulesystem is run, this procedure is given the object, the
    ;;; number of actions run other than STOP and STOPIF actions, the number of times
    ;;; the rulesystem has been run, the maximum possible number (sim_speed).
    if number_run == 0 then
        true -> sim_stop_this_agent;
    endif;
enddefine;


/* ====================================================================== */

global vars gl_agent = true;            ;;; for uses

endsection;

nil -> proglist;


/* ====================================================================== */


/* --- Revision History ---------------------------------------------------

--- Steve Allen, Jul 23 2000
    Fixed problem with popup memu - hadn't assigned new x,y coords
    Now using MetroLink OpenMotif - no more Motif problems :-)

--- Steve Allen, May 21 2000
	Added changes for old simkit
    Added patches for LessTif

--- Steve Allen, Nov 23 1998
    Added a title to GlAddAgentList().
    Swapped order of Gl_Brightness and Gl_Hardness in Gl_attrib to mirror
    the order in cells.

--- Steve Allen, Nov 21 1998
    Added more trace support features and standardised the header.

--- Steve Allen, Jun 9 1998
    Added ability to set status window width in GlSetup()

--- Steve Allen, Jun 6 1998
    First written
*/
