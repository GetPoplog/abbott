/* -------------------------------------------------------------------------
   ---       Concern Processing in Autonomous Agents - PhD Thesis        ---
   ---                                                                   ---
   ---       Copyright (c) Steve Allen, 2000. All rights reserved.       ---
   -------------------------------------------------------------------------

   File:            file.p
   Author           Steve Allen, 12 Aug 2000 - (see revisions at EOF)
   Purpose:         Read and write experiment data to the disk.

   Libraries:       LIB sim_agent, poprulebase, objectclass
                    LIB (*local) gl_agent gl_abbott

   Related Files:   control.p
*/

/* --- Introduction --------------------------------------------------------

This file contains routines used to read and write experiments to a file.
The file generated is in ASCII, and uses special tokens to identify the
different types of identifer.

--------------------------------------------------------------------------*/

lvars filepath = sys_fname_path(popfilename);

extend_searchlist(filepath, popincludelist) -> popincludelist;
extend_searchlist(filepath, popuseslist) -> popuseslist;

include gridland;
loadinclude XmConstants;

/***************************************************************************
Public functions writen in this module.

    define vars procedure WriteExperiment(expt);
    define vars procedure ReadExperiment(expt) -> ok;

***************************************************************************/

vars procedure WriteExperiment;         /* write an experiment  */
vars procedure ReadExperiment;          /* read an experiment   */

/***************************************************************************
External functions accessed by this module.
Specify through module public interface include files or define explicitly.

***************************************************************************/

uses poprulebase;
uses sim_agent;
uses gl_agent;

/* -- poprulebase.p -- */

vars procedure prb_newdatabase;

/* -- sim_agent.p -- */

vars procedure sim_add_list_to_db;

/* -- control.p -- */

vars procedure NewExperiment;           /* setup a new experiment       */

/***************************************************************************
Private functions in this module.
Define as lexical.

    define lvars procedure WriteVar(expt, item);
    define lvars procedure WriteObject(expt, obj);
    define lvars procedure WriteToken(expt, token);
    define lvars procedure WriteItem(expt, item);

    define lvars procedure ReadObject(expt, identifier) -> ok;
    define lvars procedure ReadSlots(expt, obj) -> ok;
    define lvars procedure ReadToken(expt) -> token;
    define lvars procedure ReadItem(expt) -> item;

    define :method lvars OpenFile(expt:gl_experiment, type) -> file_ptr;
    define :method lvars  CloseFile(expt:gl_experiment);
***************************************************************************/

lvars procedure WriteVar;               /* write a variable to a file   */
lvars procedure WriteObject;            /* write an object to a file    */
lvars procedure WriteToken;             /* write a token to a file      */
lvars procedure WriteItem;              /* write an item to a file      */

lvars procedure ReadObject;             /* read an object from a file   */
lvars procedure ReadSlots;              /* read slots from a file       */
lvars procedure BuildDbase;             /* build a "sim_data" database  */
lvars procedure ReadToken;              /* read a token from a file     */
lvars procedure ReadItem;               /* read an item from a file     */

lvars procedure OpenFile;               /* open a file for read/write   */
lvars procedure CloseFile;              /* close a file                 */

/***************************************************************************
Private macros and constants.
***************************************************************************/


/***************************************************************************
Global data declared in this module.
Extern definitions for any external global data used by this module.
File wide static dtata.
***************************************************************************/

/* -- sim_agent.p -- */

vars sim_dbsize;

/**************************************************************************
Functions
***************************************************************************/


/* ====================================================================== */

/*
    Write Routines
    ==============

    WriteExperiment(expt)           - write an experiment to a file
    WriteVar(expt, var)             - write a variable to a file
    WriteObject(expt, obj)          - write an object to a file
    WriteToken(expt, token)         - write a token to a file
    WriteItem(expt, item)           - write an item to a file

*/


/***************************************************************************
NAME
    WriteExperiment

SYNOPSIS
    WriteExperiment(expt);

FUNCTION
    Write an experiment to a file. The file pointer is contained within the
    "expt" object structure. If the file cannot be created then <false> is
    written into the gl_created slot.

RETURNS
    None.
***************************************************************************/
define vars procedure WriteExperiment(expt);
    lvars file_name;
    lvars item, i;

    sysgarbage();

    if OpenFile(expt, "write") then
        WriteItem(expt, sprintf('# %p #\n\n', [^(gl_created(expt))]));
        WriteVar(expt, gl_name(expt));

        for item in gl_all_agents(expt) do
            WriteVar(expt, sim_name(item));
            if isgl_parent(item) then
                for i in gl_children(item) do
                    WriteVar(expt, sim_name(i));
                endfor;
            endif;
        endfor;

        CloseFile(expt);
    else
        false -> gl_created(expt);
    endif;

enddefine;


/***************************************************************************
NAME
    WriteVar

SYNOPSIS
    WriteVar(expt, var);

FUNCTION
    Write a variable to a file. The file pointer is contained within the
    "expt" object structure. The variable name can be either a "string"
    or a "word" identifier.

RETURNS
    None.
***************************************************************************/
define lvars procedure WriteVar(expt, var);
    lvars expt, var;

    if isstring(var) then consword(var) -> var endif;

    if isword(var) then
        WriteItem(expt, sprintf('%p = ', [^var]));

        valof(var) -> var;

        if isinstance(var) then
            WriteObject(expt, var);
        else
            WriteToken(expt, var);
        endif;

        WriteItem(expt, '\n\n');
    endif;

    sysflush(gl_iodev(expt));
enddefine;


/***************************************************************************
NAME
    WriteObject

SYNOPSIS
    WriteObject(expt, obj);

FUNCTION
    Write an object to a file. The file pointer is contained within the
    "expt" object structure.

    Slots "gl_io", "gl_iodev" and "gl_eof" are not written as they refer
    to the current experiment and will cause problems when assigned in
    ReadSlots() as the experiment is read back.

    Objects are enclosed in a "obj(...)" token. The first word of the
    written object is the object class.

RETURNS
    None.
***************************************************************************/
define lvars procedure WriteObject(expt, obj);
    lvars expt, obj;

    lvars item;
    lvars key = datakey(obj);

    WriteItem(expt, sprintf('__obj( %p ', [^(class_dataword(key))]));

    for item in class_slots(key) do
        switchon item
            case == gl_io then
            case == gl_eof then
            case == gl_iodev then
            else
                WriteItem(expt, sprintf('%p = ', [^(pdprops(item))]));

                if isgl_child(obj) and isproperty(item(obj)) and
                        item(obj) == sim_data(gl_parent(obj)) then
                    WriteItem(expt, '__parent_data ');
                elseif isgl_child(obj) and isproperty(item(obj)) and
                        item(obj) == sim_shared_data(gl_parent(obj)) then
                    WriteItem(expt, '__parent_shared_data ');
                else
                    WriteToken(expt, item(obj));
                endif;
        endswitchon;
    endfor;

    WriteItem(expt, ')');
enddefine;


/***************************************************************************
NAME
    WriteToken

SYNOPSIS
    WriteToken(expt, token);

FUNCTION
    Write a token to a file. The file pointer is contained within the
    "expt" object structure.

    If the token is of type "gl_agent" then write "__valof(...)" the agent
    name given by sim_name(agent).

    Lists, Vectors and Strings are enclosed in the appropriate markers.

    Properties are expanded and identified by "prop [...]". Procedures
    are identified by "proc(...)".

RETURNS
    None.
***************************************************************************/
define lvars procedure WriteToken(expt, token);
    lvars expt, token;
    lvars x;

    if isgl_agent(token) then
        WriteItem(expt, sprintf('__valof(%p) ', [^(sim_name(token))]));
    elseif islist(token) then
        WriteItem(expt, '[ ');
        for x in token do
            WriteToken(expt, x);
        endfor;
        WriteItem(expt, '] ');
    elseif isvector(token) then
        WriteItem(expt, '{ ');
        for x in token using_subscriptor subscrv do
            WriteToken(expt, x);
        endfor;
        WriteItem(expt, '} ');
    elseif isstring(token) then
        WriteItem(expt, sprintf('\'%p\' ', [^token]));
    elseif isproperty(token) then
        WriteItem(expt, '__prop(');
        WriteToken(expt, [%explode(token)%]);
        WriteItem(expt, sprintf('%p %p ) ',
            [%property_size(token), property_default(token)%]));
    elseif isarray(token) then
        WriteItem(expt, sprintf('__array(%p %p) ',
                            [^(boundslist(token)) ^(arrayvector(token))]));
    elseif isprocedure(token) then
        WriteItem(expt, sprintf('__proc(%p) ', [^(pdprops(token))]));
    elseif datakey(token) == ref_key then
        WriteItem(expt, '__ref(');
        WriteToken(expt, cont(token));
        WriteItem(expt, ')');
    elseif datakey(token) == prb_rulefamily_key then
        WriteItem(expt, '__rulefam(');
        WriteToken(expt, prb_rulefamily_name(token));
        WriteToken(expt, prb_next_ruleset(token));
        WriteToken(expt, prb_family_stack(token));
        WriteToken(expt, prb_family_limit(token));
        WriteToken(expt, prb_family_section(token));

        ;;;WriteToken(expt, prb_family_matchvars(token));
        ;;;WriteToken(expt, prb_family_dlocal(token));
        WriteItem(expt, ')');
    elseif isvectorclass(token) then
        WriteItem(expt, sprintf('__class(%p %p) ', [^(dataword(token))
                            {^(valof("dest"<>dataword(token))(token))}]));
    elseif isrecordclass(token) then
        WriteItem(expt, sprintf('__class(%p %p) ', [^(dataword(token))
                            {^(valof("dest"<>dataword(token))(token))}]));
    else
        WriteItem(expt, sprintf('%p ', [^token]));
    endif;
enddefine;

/***************************************************************************
NAME
    WriteItem

SYNOPSIS
    WriteItem(expt, item);

FUNCTION
    Write an item to a file. This is the low-level file access routine
    which uses the item_repeater in "gl_io(expt)". Items consist of
    words, strings, integers, ratios, floating-point and complex number
    types.

    The eof field of the "expt" structure is tested before any items are
    written.

RETURNS
    None.
***************************************************************************/
define lvars procedure WriteItem(expt, item);
    lvars expt, item;

    unless gl_eof(expt) then
        gl_io(expt)(item);
    endunless;
enddefine;


/* ====================================================================== */

/*
    Read Routines
    =============

    ReadExperiment(expt)            - read an experiment from a file
    ReadObject(expt, identifier)    - read an object from a file
    ReadSlots(expt, obj)            - read object slots from a file
    BuildDbase(lst, dbase)          - build a property list (dbase)
    ReadToken(expt, token)          - read a token from a file
    ReadItem(expt, char)            - read an item from a file

*/


/***************************************************************************
NAME
    ReadExperiment

SYNOPSIS
    ReadExperiment(expt);

FUNCTION
    Read an experiment from a file. The file pointer is contained within the
    "expt" object structure. If the file cannot be opened then <false> is
    returned.

RETURNS
    true if read operation successful, else false.
***************************************************************************/
define vars procedure ReadExperiment(expt) /* -> ok */;
    lvars expt;

    lvars ok, identifier, equates, value;
    lvars error;

    sysgarbage();

    if OpenFile(expt, "read") then
        false -> identifier;
        true -> ok;
        until identifier == termin or ok == false do
            ReadToken(expt) -> identifier;
            ReadToken(expt) -> equates;
            if equates == "=" then

                if identprops(identifier) == "undef" then
                    sysSYNTAX(identifier, 0, false);
                endif;

                ReadToken(expt) -> value;

                if value == "__obj" then
                    ReadObject(expt, identifier) -> ok;
                else
                    value -> valof(identifier);
                endif;
            endif;
        enduntil;
        CloseFile(expt);
    else
        false -> ok;
    endif;
    return(ok);
enddefine;


/***************************************************************************
NAME
    ReadObject

SYNOPSIS
    ReadObject(expt, identifier);

FUNCTION
    Read an object from a file. The file pointer is contained within the
    "expt" object structure. If the object does not already exist, it is
    first created before being updated with the new values. if the object
    class is "sim_object" then a prb_newdatabase() is created.

RETURNS
    true if read operation successful, else false.
***************************************************************************/
define lvars procedure ReadObject(expt, identifier) /* -> ok */;
    lvars expt, identifier;

    lvars obj, ok;
    lvars token = ReadToken(expt);

    if token /== "(" then
        return(false);
    endif;

    lvars classtype = ReadToken(expt);
    lvars test_classtype = valof("is" <> classtype);
    lvars new_classtype = valof("new" <> classtype);

    if test_classtype(valof(identifier)) == false then
        /* new objectclass */
        new_classtype() -> obj;

        ReadSlots(expt, obj) -> ok;
        obj -> valof(identifier);
    else
        /* update objectclass */
        ReadSlots(expt, valof(identifier)) -> ok;
    endif;
    return(ok);
enddefine;


/***************************************************************************
NAME
    ReadSlots

SYNOPSIS
    ReadSlots(expt, obj);

FUNCTION
    Read object slots from a file. The file pointer is contained within the
    "expt" object structure. If the value is "__parent_data" or
    "__parent_shared_data" then link to the parent new database.

RETURNS
    true if read operation successful, else false.
***************************************************************************/
define lvars procedure ReadSlots(expt, obj) /* -> ok*/;
    lvars expt, obj;

    lvars token = ReadToken(expt);
    lvars value, dbase;

    until token == ")" or token == termin do

        if ReadToken(expt) /== "=" then
            return(false);
        endif;

        ReadToken(expt) -> value;

        switchon value
            case == "__parent_data" then
                sim_data(gl_parent(obj)) -> value;

            case == "__parent_shared_data" then
                sim_shared_data(gl_parent(obj)) -> value;
        endswitchon;

        unless value == "undef" or value == termin then
            value -> valof(token)(obj);
        endunless;

        ReadToken(expt) -> token;           /* read the next token */
    enduntil;

    if token == termin then
        return(false);
    endif;
    return(true);
enddefine;


/***************************************************************************
NAME
    ReadToken

SYNOPSIS
    ReadToken(expt);

FUNCTION
    Read a token from a file. The file pointer is contained within the
    "expt" object structure. Comments are surrounded by "#" characters,
    "proc" is used to identify procedures, "valof" to identify vars, "{}"
    for vectors, and "[]" for lists.

RETURNS
    token read.
***************************************************************************/
define lvars procedure ReadToken(expt) /* -> token */;
    lvars expt;

    lvars token, c, type;

    ReadItem(expt) -> c;

    switchon c
        case == "#" then                /* comment character */
            ReadItem(expt) -> c;
            until c == "#" or c == termin do
                ReadItem(expt) -> c;
            enduntil;
            ReadToken(expt) -> token;
        case == "__valof" then
            if ReadToken(expt) /== "(" then return(termin) endif;
            ReadToken(expt) -> token;
            if ReadToken(expt) /== ")" then return(termin) endif;
            valof(token) -> token;
        case == "__proc" then             /* procedure */
            if ReadToken(expt) /== "(" then return(termin) endif;
            ReadToken(expt) -> token;
            if ReadToken(expt) /== ")" then return(termin) endif;
            valof(token) -> token;
        case == "__ref" then             /* ref */
            if ReadToken(expt) /== "(" then return(termin) endif;
            ReadToken(expt) -> token;
            if ReadToken(expt) /== ")" then return(termin) endif;
            consref(token) -> token;
        case == "__class" then            /* class */
            if ReadToken(expt) /== "(" then return(termin) endif;
            ReadToken(expt) -> type;
            ReadToken(expt) -> token;
            if ReadToken(expt) /== ")" then return(termin) endif;
            valof("cons"<>type)(explode(token)) -> token;
        case == "__array" then             /* procedure */
            if ReadToken(expt) /== "(" then return(termin) endif;
            ReadToken(expt);
            ReadToken(expt);
            if ReadToken(expt) /== ")" then
                erasenum(2);
                return(termin);
            endif;
            newanyarray() -> token;
        case == "__prop" then               /* procedure */
            if ReadToken(expt) /== "(" then return(termin) endif;
            ReadToken(expt);
            ReadToken(expt);
            ReadToken(expt);
            if ReadToken(expt) /== ")" then
                erasenum(3);
                return(termin);
            endif;
            newproperty("perm") -> token;
        case == "__rulefam" then
            if ReadToken(expt) /== "(" then return(termin) endif;
            ReadToken(expt) -> token;
            if isword(token) and isprb_rulefamily(valof(token)) then
                copydata(valof(token)) -> token;
                ReadToken(expt) -> prb_next_ruleset(token);
                ReadToken(expt) -> prb_family_stack(token);
                ReadToken(expt) -> prb_family_limit(token);
                ReadToken(expt) -> prb_family_section(token);
                ;;;ReadToken(expt) -> prb_family_matchvars(token);
                ;;;ReadToken(expt) -> prb_family_dlocal(token);
            else
                return(termin);
            endif;
            if ReadToken(expt) /== ")" then return(termin) endif;
        case == "{" then                /* vector */
            {%
            until c == "}" or c == termin do
                ReadToken(expt) ->> c;
            enduntil;
            -> c;
            %} -> token;
            if c == termin then c -> token endif;
        case == "[" then                /* list */
            [%
            until c == "]" or c == termin do
                ReadToken(expt) ->> c;
            enduntil;
            -> c;
            %] -> token;
            if c == termin then c -> token endif;
        case == "<" then
            ReadToken(expt) -> token;
            if ReadToken(expt) /== ">" then
                ReadToken(expt) -> c;
                until c == ">" or c == termin do
                    ReadToken(expt) -> c;
                enduntil;
                return("undef");
            endif;
            valof(token) -> token;
        else
            c -> token;
    endswitchon;

    return(token);
enddefine;


/***************************************************************************
NAME
    ReadItem

SYNOPSIS
    ReadItem(expt);

FUNCTION
    Read an item from a file. This is the low-level read file routine. Items
    are read from the item_repeater held in "gl_io(expt)". If the end of
    file is reached then the routine returns "termin".

RETURNS
    item or termin if at end of file.
***************************************************************************/
define lvars procedure ReadItem(expt) /* -> item */;
    lvars expt;
    lvars item;

    if gl_eof(expt) then return(termin) endif;

    gl_io(expt)() -> item;

    if item == termin then true -> gl_eof(expt) endif;

    return(item);
enddefine;


/* ====================================================================== */

/*
    File Access
    ===========

    OpenFile(expt, type)                - open a file for reading/writing
    CloseFile(expt)                     - close a file
*/


/***************************************************************************
NAME
    OpenFile

SYNOPSIS
    OpenFile(expt, type);

FUNCTION
    Opens a file for "read" or "write", depending on the setting
    of the "type" argument.

RETURNS
    The file pointer, or false if unable to access the file.
***************************************************************************/
define :method lvars OpenFile(expt:gl_experiment, type) /* -> file_ptr */;
    lvars expt, type;
    lvars iodev;

    false -> gl_eof(expt);
    switchon type
        case == "read" then
            incharitem(discin(gl_filename(expt))->>iodev) -> gl_io(expt);
            discin_device(iodev) -> gl_iodev(expt);
        case == "write" then
            outcharitem(discout(gl_filename(expt))->>iodev) -> gl_io(expt);
            discout_device(iodev) -> gl_iodev(expt);
        else
            false -> gl_io(expt);
            true -> gl_eof(expt);
    endswitchon;

    return(gl_io(expt));
enddefine;


/***************************************************************************
NAME
    CloseFile

SYNOPSIS
    CloseFile(expt);

FUNCTION
    Closes the file associated with "expt", which had been opened for
    "read", "write".

RETURNS
    None.
***************************************************************************/
define :method lvars  CloseFile(expt:gl_experiment);
    lvars expt;

    if isincharitem(gl_io(expt)) == false then
        WriteItem(expt, termin);
    endif;
    true -> gl_eof(expt);
enddefine;



/* ====================================================================== */

/* --- Revision History ---------------------------------------------------

--- Steve Allen, Aug 12 2000
    Added support for new SIM_AGENT toolkit.

--- Steve Allen, Nov 19 1998
    Standardised the header.

--- Steve Allen, Jun 22 1998
    Tidied up and added comments.

--- Steve Allen, May 26 1998
    First written.
*/
