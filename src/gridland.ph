iconstant
    macro (
        NONE       = 0,
        FILE_MASK  = '*.def'
    );

iconstant
    macro (
        ENERGY_UNIT = 20,
        WATER_UNIT  = 20,
        FOOD_UNIT   = 20
    );

iconstant
    macro (
        EMPTY       = 0,
        FULL        = 1,
        PARTIAL     = 2
    );

/*

    The two lists (cell_to_x & cell_to_y) point to the relative positions
    of the cells in the sensor list - i.e. the top-left cell is the first
    element, then the top-middle etc.

        CELLs           SENSOR VECTOR
     -----------
    | 1 | 2 | 3 |
     -----------
    | 8 | * | 4 |  ==> {1 2 3 4 5 6 7 8}
     -----------
    | 7 | 6 | 5 |
     -----------

*/

iconstant cell_to_x = {-1 0 1 1 1 0 -1 -1};
iconstant cell_to_y = {1 1 1 0 -1 -1 -1 0};

/*

        CELLs            HEADING VECTOR
     -----------
    |   | 1 |   |
     -----------
    | 4 | * | 2 |    ==>   {1 2 3 4}
     -----------
    |   | 3 |   |
     -----------
*/

iconstant heading_to_x = {0 1 0 -1};
iconstant heading_to_y = {1 0 -1 0};
