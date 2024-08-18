/* -------------------------------------------------------------------------
   ---       Concern Processing in Autonomous Agents - PhD Thesis        ---
   ---                                                                   ---
   ---       Copyright (c) Steve Allen, 1998. All rights reserved.       ---
   -------------------------------------------------------------------------

   File:            gl_agentLite.p
   Author           Steve Allen, 28 Dec 2000 - (see revisions at EOF)
   Purpose:         This file contains the general class definitions
                    and methods for the Gridland world.

   Libraries:       LIB sim_agent, poprulebase, objectclass
*/

/* --- Introduction --------------------------------------------------------

This library forms the core of the Gridland Sim Agent library, providing
the basic object class definitions. The libary was produced as part of
an investigation into "Concern Processing in Autonomous Agents".

--------------------------------------------------------------------------*/

section;

/* system includes */

uses sim_agent;
uses rulefamily;

/***************************************************************************
Public functions writen in this module.

    define vars procedure GlSetup(xsize, ysize, csize, type, user_wins);

    define vars procedure GlSetupGrid();
    define vars procedure GlCellSize();
    define vars procedure GlGridXSize();
    define vars procedure GlGridYSize();
    define vars procedure GlGridType();

    define vars procedure GlValidLoc(x, y) -> valid;
    define vars procedure GlGrid(x, y);
    define updaterof vars procedure GlGrid(cell, x, y);
    define :method vars   GlCellUnoccupied(agent:gl_attrib, x, y);
    define :method vars   GlAddToGrid(agent:gl_attrib);
    define :method vars   GlRemoveFromGrid(agent:gl_attrib);
    define :method vars   GlAddAgent(agent:gl_attrib);
    define :method vars   GlRemoveAgent(agent:gl_attrib);
    define :method vars   GlMoveAgent(obj:gl_attrib, x, y);
    define :method vars   GlRefreshAgent(agent:gl_attrib);
    define :method vars   GlFindFreeLoc(agent:gl_attrib) -> (x, y);

***************************************************************************/

/* -- Gridland Setup -- */
vars procedure GlSetup;

/* -- Grid Display and Resize -- */
vars procedure GlSetupGrid;
vars procedure GlCellSize;
vars procedure GlGridXSize;
vars procedure GlGridYSize;
vars procedure GlGridType;

/* -- Gridland Access Mechanisms -- */
vars procedure GlValidLoc;
vars procedure GlGrid;
vars procedure GlCellUnoccupied;
vars procedure GlAddToGrid;
vars procedure GlRemoveFromGrid;
vars procedure GlAddAgent;
vars procedure GlRemoveAgent;
vars procedure GlMoveAgent;
vars procedure GlRefreshAgent;
vars procedure GlFindFreeLoc;

/* -- Print Methods -- */
vars procedure print_instance;

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

/* -- Some local constants -- */

lconstant invalid_loc = conscell(FULL, 0, 1, 0, false);
lconstant empty_loc = conscell(EMPTY, 0, 0, 0, false);

/***************************************************************************
Global data declared in this module.
Extern definitions for any external global data used by this module.
File wide static data.
***************************************************************************/

vars gl_window;                     /* Gridland window          */

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

define :mixin gl_sel;
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

    newgl_window() -> gl_window;

    xsize ->> gl_gridxsize(gl_window) -> gridxsize;
    ysize ->> gl_gridysize(gl_window) -> gridysize;
    csize ->> gl_cellsize(gl_window) -> cellsize;

    type -> gl_gridtype(gl_window);
    GlSetupGrid();

enddefine;

/* ====================================================================== */

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

    x ->> gl_gridxsize(gl_window) -> gridxsize;
    y ->> gl_gridysize(gl_window) -> gridysize;
    c ->> gl_cellsize(gl_window) -> cellsize;
    type -> gl_gridtype(gl_window);

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
    Gridland Access Mechanisms
    ==========================

    GlValidLoc(x, y) -> valid;          - checks validity of x,y

    GlGrid(x, y ) -> cell;              - returns cell at loc (x,y)
    cell -> GlGrid(x, y);               - writes cell to loc (x,y)

    GlCellUnoccupied(agent, x, y)       - tests for unoccupied cells
                            -> boole;

    GlAddToGrid(agent);                 - add agent to grid
    GlRemoveFromGrid(agent);            - remove agent from grid

    GlAddAgent(agent);                  - add agent to gridland
    GlRemoveAgent(agent);               - remove agent from gridland
    GlMoveAgent(agent, x, y);           - move agent to loc (x,y)

    GlRefreshAgent(agent);              - update agent attribs in grid
    GlFindFreeLoc(agent) -> (x, y);     - returns a free location big enough
                                            for the agent.

*/

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


/* ====================================================================== */

/*
    Customise the print method
    ==========================

    print_instance(item);               - for displaying agent attribs
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


global vars gl_agent = true;            ;;; for uses (pretend to be gl_agent)
global vars gl_agentLite = true;        ;;; for uses

endsection;

nil -> proglist;


/* ====================================================================== */


/* --- Revision History ---------------------------------------------------

--- Steve Allen, Dec 28, 1998
    First written
*/
