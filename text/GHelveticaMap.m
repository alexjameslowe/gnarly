//
//  GHelveticaMap.m
//  BraveRocket
//
//  Created by Alexander Lowe on 7/9/16.
//  Copyright © 2016 Alexander Lowe. See Licence.
//

#import "GHelveticaMap.h"

@implementation GHelveticaMap

- (id) init {
    
    self = [super init];
    
    //correction-y were tested with the font at 22.
    
    
    //http://unicode-table.com/en/#control-character
    //Array Position:            0     1     2     3     4     5    6    7    8    9    10   11   12   13   14   15   16   17   18   19   20   21   22   23   24   25   26   27   28    29    30    31   32   33   34   35   36   37   38   39   40   41   42   43   44   45   46   47   48   49   50  51   52    53    54    55    56    57    58    59   60   61    62  63   64  65   66   67   68   69    70    71    72  73  74   75   76   77   78   79    80    81    82    83    84    85    86    87    88    89    90    91   92    93   94
    //
    //Character:                       !     "     #     $     %    &    '    (    )    *    +    ,    -    .    /    0    1    2    3    4    5    6    7    8    9    :    ;    <     =     >     ?    @    A    B    C    D    E    F    G    H    I    J    K    L    M    N    O    P    Q    R   S    T     U     V     W     X     Y     Z     [    \    ]         _        a    b    c    d    e     f     g     h   i   j    k    l    m    n    o     p     q     r     s     t     u     v     w     x     y     z     {    |     }    °
    //Unicode:                   32    33    34    35    36    37   38   39   40   41   42   43   44   45   46   47   48   49   50   51   52   53   54   55   56   57   58   59   60    61    62    63   64   65   66   67   68   69   70   71   72   73   74   75   76   77   78   79   80   81   82  83   84    85    86    87    88    89    90    91   92   93    94  95   96  97   98   99   100  101   102   103   104 105 106  107  108  109  110  111   112   113   114   115   116   117   118   119   120   121   122   123  124   125  176
    //texture coords
    float    _xCoords[]       = {380,  441,  98,   424,  471,  1,   193, 323, 243, 265, 396, 195, 398, 295, 423, 363, 39,  78,  109, 149, 189, 230, 270, 308, 345, 386, 342, 34,  235,  155,  281,  461, 130, 3,   87,  166, 245, 326, 406, 466, 42,  122, 158, 213, 298, 358, 470, 39,  126, 202, 290,360, 441,  3,    86,   178,  297,  386,  471,  54,  3,   75,   0,  67,  0,  50,  131, 210, 287, 367,  441,  3,    86, 142,194, 262, 337, 413, 3,   86,   166,  251,  334,  404,  485,  46,   135,  243,  345,  431,  3,    98,  369,  123, 65  };
    float    _yCoords[]       = {442,  301,  371,  375,  374,  376, 373, 390, 372, 372, 371, 455, 400, 398, 342, 371, 301, 301, 301, 301, 301, 301, 301, 301, 301, 301, 378, 444, 454,  459,  454,  300, 374, 10,  10,  10,  10,  10,  10,  10,  75,  75,  75,  75,  75,  75,  75,  155, 155, 155, 155,155, 155,  228,  228,  228,  228,  228,  228,  442, 442, 442,  0,  406, 0,  10,  10,  10,  10,  10,   10,   75,   75, 75, 75,  75,  75,  75,  155, 155,  155,  155,  155,  155,  155,  228,  228,  228,  228,  228,  301,  443, 442,  443, 370 };
    
    //dimensions of the character
    float    _widths[]        = {12,   12.2, 25.8, 39,   30,   54.4,45.8,12.2,21.4,21.4,23.5,34.2,14.2,19.2,12.2,27.8,30.7,20,  31.4,31.7,32.1,31.7,31.7,32.5,31.9,31.9,12.2,14.2,36.9, 34.2, 36.9, 34.8,52.2,43.1,38.2,39.5,39.4,35.3,32.2,41.9,37.5,9.7, 29.2,40.8,33,  45.1,37.8,43.5,35.1,43.4,38, 38.6,37.7, 37.4, 40.8, 58,   39.7, 39.6, 35.5, 19.1,25.5,19.1, 0,  41.1,0,  31.5,32,  31.8,33.6,34.2, 19.9, 33.2, 31, 9.1,13.3,31.9,9,   49.4,31.1,35.2, 31.6, 33.4, 20,   32,   19.3, 31,   34.3, 46.7, 34.1, 34.3, 29,   24.2,8,    24.2,25  };
    float    _heights[]       = {54,   52.8, 22.2, 49,   52,   52,  52,  22.2,62.4,62.4,23.3,37.2,20.4,9.3, 12.2,53,  52,  52,  52,  52,  52,  52,  52,  52,  52,  52,  36.4,44.9,39.6, 25.1, 39.6, 52.5,49,  52,  52,  53,  52,  52,  53,  52,  52,  52,  52,  52,  52,  52,  52,  53,  52,  55,  52, 53,  52,   53,   52,   52,   52,   52,   52,   62.5,53,  62.5, 0,  7.7, 0,  39.5,52,  40,  52,  40.5, 52,   53.7, 52, 52, 67,  52,  52,  38.3,38.3,40.5, 53,   53.3, 38.3, 40.5, 48.1, 38.3, 37.5, 37.5, 37.4, 52.6, 37.5, 62.5,62.5, 62.5,25  };
    
    //0 mean flush to top, 1 means centered vertically, 2 means flush to bottom
    int  _defaultY[]          = {0,    0,    0,    0,    0,    0,   0,   0,   1,   1,   1,   1,   2,   1,   2,   1,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   2,   2,   1,    1,    1,    0,   0,   2,   2,   2,   2,   2,   2,   2,   2,   2,   2,   2,   2,   2,   2,   2,   2,   2,   2,  2,   2,    2,    2,    2,    2,    2,    2,    1,   1,   1,    0,  2,   0,  2,   2,   2,   2,   2,    2,    2,    2,  2,  2,   2,   2,   2,   2,   2,    2,    2,    2,    2,    2,    2,    2,    2,    2,    2,    2,    1,   1,    1,   0   };
   
    //corrections in y coords. will add onto the default y-value.
    float  _correctionY[]     = {0,    0,    0,    0,    0,    0,   0,   0,   0,   0,   0,   0,   12,  0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   12,  0,    0,    0,    0,   0,   0,   0,   0,   0,   0,   0,   1,   0,   0,   0,   0,   0,   0,   0,   0,   0,   2.5, 0,  0,   0,    0,    0,    0,    0,    0,    0,    0,   0,   0,    0,  0,   0,  1,   1,   2,   1,   2,    0,    13,   0,  0,  13,  0,   0,   0,   0,   2,    13,   13,   0,    2,    0,    0,    0,    0,    0,    13,   0,    0,   0,    0,   -3  };

    
    [self setWidth:_widths height:_heights
                 x:_xCoords y:_yCoords
       yCorrection:_correctionY defaultYPosition:_defaultY
           kerning:6 lineHeight:52 length:95];
    

    

    return self;
    
}



//previoustCharacterBuffer is A DELTA.
- (float) calculateBufferForCurrentCharacter:(int)currentUnicode andPreviousCharacter:(int)prevUnicode {
    int u = currentUnicode;
    
    float previousCharacterBuffer = 0;
    
    //we have some annoying things in here: certain combinations
    //of characters look just horrible. the spacing is wrong we have another
    //corrective buffer to retroactively adjust the stackX of the GTextField so
    //that this letter has nice-looking spacing.
    
    // li ii il ll look a little too close together.
    //      l           i
    if(u == 108 || u == 105) {
    
        if(prevUnicode > 0) {
        
        previousCharacterBuffer = 0.5;//1;
            
        }
        
    }
    
    //else if the | character,
    else
    if(u == 124 || prevUnicode == 124) {
        
    previousCharacterBuffer = 5;
            
    }
    
    //this has been tested with textField.text = @"LV, LT, LY, LW, Lt";
    //if the previous is L, then we have LV, LT, LY, LW, Lt
    if(prevUnicode == 76) {
        
        //      Y          T          V          W
        if(u == 89 || u == 84 || u == 86 || u == 87) {
        previousCharacterBuffer = -10;//-5;
        }
        
    }
    
    //if r then we want to hug some of these same lowercase characters closer.
    if(prevUnicode == 114) {
        
        if(u >= 97 && u <= 122) {
            
            //a   c  d    e    g    j    m    n    o   p    q   r   s   u   v   w    x   y    z
            //97  99 100  101  103  106  109  110  111 112  113 114 115 117 118 119  120 121  122
            if( !(u == 98 || u == 102 || u == 104 || u == 105 || u == 107 || u == 108 || u == 116)) {
            previousCharacterBuffer = -1.5;//-3;
            }
            
        }
        
    }
    
    
    //Both of these cases test with textField.text = @"vA wA PA YA TA VA WA \n Av Aw AP AY AT AV AW";
    //A is tricky. If the previous character was A:
    if(prevUnicode == 65) {
        
        //      Av          Aw          AY         AT         AV         AW
        if(u == 118 || u == 119 || u == 89 || u == 84 || u == 86 || u == 87) {
        previousCharacterBuffer = -5;
        }
        
        
    }
    
    //if the current character is A:
    else
    if(u == 65) {
    int p = prevUnicode;
        
        //      vA          wA          PA         YA         TA         VA         WA
        if(p == 118 || p == 119 || p == 80 || p == 89 || p == 84 || p == 86 || p == 87) {
        previousCharacterBuffer = -5;
        }
    
    }
    

    
    //Both of these cases were testes with: textField.text = @"Wa To Yd Va Vd \n aV oY bT rW bV";
    //For cases like Wa Vo Wm Td To where we have
    //                W                    V                    T                    Y
    if(prevUnicode == 87 || prevUnicode == 86 || prevUnicode == 84 || prevUnicode == 89) {
    
        
        //if it's one of these, then we can bring it closer to the previous W,V,T,Y.
        //For cases like: Wa To Yd Va Vd
        //a   c  d    e    g    j    m    n    o   p    q   r   s   u   v   w    x   y    z
        //97  99 100  101  103  106  109  110  111 112  113 114 115 117 118 119  120 121  122
        if(u >= 97 && u <= 122) {
            if( !(u == 98 || u == 102 || u == 104 || u == 105 || u == 107 || u == 108 || u == 116)) {
            previousCharacterBuffer = -5;
            }
        }
        
        //for cases like W. V, T_
        //      ,          .          _
        else
        if(u == 44 || u == 46 || u == 95) {
        previousCharacterBuffer = -7;
        }
        
    }
    
    //For cases like: aW bV rT uY
    //      W          V          T          Y
    else
    if(u == 87 || u == 86 || u == 84 || u == 89) {
    int p = prevUnicode;
        
        //a  b   c    e    g    j     m    n    o   p   q   r   s   u   v   w    x   y    z
        //97 98  99   101  103  106  109  110  111 112  113 114 115 117 118 119  120 121  122
        if(p >= 97 && p <= 122) {
            if (!(p == 100 || p == 102 || p == 104 || p == 105 || p == 107 || p == 108 || p == 116)) {
            previousCharacterBuffer = -5;//-5;
            }
        }
    }
    
    else
    if(u == 45) {
    previousCharacterBuffer = 3;
    } else
    if(prevUnicode == 45) {
    previousCharacterBuffer = 3;
    }
    
return previousCharacterBuffer;
}


@end
