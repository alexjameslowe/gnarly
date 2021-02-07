//
//  GHelveticaBoldRobRocketMap.m
//  BraveRocket
//
//  Created by Alexander Lowe on 8/3/16.
//  Copyright © 2016 Alexander Lowe. See Licence.
//



#import "GRobRocketMap.h"

@implementation GRobRocketMap

//a mutant helvetica map.

- (id) init {
    
    self = [super init];
    
    //http://unicode-table.com/en/#control-character
    
    //Array Position:            0     1    2     3     4     5    6    7    8    9    10   11   12   13   14   15   16   17   18   19   20   21   22   23   24   25   26   27   28    29    30    31   32   33   34   35   36   37   38   39   40   41   42   43   44   45   46   47   48   49  50   51   52    53    54    55    56    57    58    59   60   61    62  63    64  65    66   67   68   69    70    71    72   73   74   75   76   77   78   79    80    81    82    83    84    85    86    87    88    89    90    91   92    93    94
    //
    //Character:                       !    "     #     $     %    &    '    (    )    *    +    ,    -    .    /    0    1    2    3    4    5    6    7    8    9    :    ;    <     =     >     ?    @    A    B    C    D    E    F    G    H    I    J    K    L    M    N    O    P    Q   R    S    T     U     V     W     X     Y     Z     [    \    ]         _         a     b    c    d    e     f     g     h    i    j    k    l    m    n    o     p     q     r     s     t     u     v     w     x     y     z     {    |     }     °
    //Unicode:                   32    33   34    35    36    37   38   39   40   41   42   43   44   45   46   47   48   49   50   51   52   53   54   55   56   57   58   59   60    61    62    63   64   65   66   67   68   69   70   71   72   73   74   75   76   77   78   79   80   81  82   83   84    85    86    87    88    89    90    91   92   93    94  95    96  97    98   99   100  101   102   103   104  105  106  107  108  109  110  111   112   113   114   115   116   117   118   119   120   121   122   123  124   125   176
    //texture coords
    float    _xCoords[]       = {470,  3,   92,   253,  212,  310, 158, 491, 371, 401, 2,   207, 132, 393, 68,  111, 288, 329, 360, 401, 442, 2,   43,  83,  124, 165, 68,  132, 300,  36,   347,  26,  251, 2,   100, 188, 279, 370, 456, 32,  126, 213, 254, 293, 393, 458, 60,  146, 242, 329,428, 2,   89,   165,  250,  349,  2,    107,  206,  187, 148, 213,  0,  392,  0,  58,   146, 238, 327, 413,  2,    84,   173, 234, 486, 347, 436, 3,   106, 198,  286,  385,  477,  49,   135,  211,  302,  418,  57,   161,  250,  432, 493,  461,  78   };
    float    _yCoords[]       = {457,  347, 347,  347,  335,  290, 347, 359, 290, 290, 409, 290, 371, 376, 347, 404, 233, 233, 233, 233, 233, 290, 290, 290, 290, 290, 347, 347, 357,  409,  357,  347, 290, 1,   1,   1,   1,   1,   1,   57,  57,  57,  57,  57,  57,  57,  115, 115, 115, 115,115, 176, 176,  176,  176,  176,  233,  233,  233,  403, 404, 403,  0,  358,  0,  1,    1,   1,   1,   1,    57,   57,   57,  57,  178, 57,  57,  115, 115, 115,  115,  115,  115,  176,  176,  176,  176,  176,  233,  233,  233,  290, 247,  290,  407  };
    
    //dimensions of the character
    float    _widths[]        = {17,   20,  35.2, 43.3, 37.4, 58,  51.2,18.2,27,  27,  29.7,39.4,20.2,24,  20,  34.8,37.2,26.4,37.1,37.5,37.7,37.6,37.3,38.1,37.5,37.5,20,  22,  42,   39.4, 42,   37.6,54.9,52.2,43.4,46.6,44.6,40.7,38.8,48.5,42.7,16.7,35,  50.7,38.5,49.8,43,  49.5,40.6,51.3,43.2,43.8,43,  42.7, 48.9, 65.5, 52.6, 51.7, 41.3, 22.8,34.8,22.8, 0,  41.2, 0,  38,   39.1,37.8,39.1,39.7, 26.3, 38.8, 36.7,16.2,20.2,42.3,16.1,53.9,36.8,40.6, 39,   39,   26.4, 37.2, 25.8, 36.7, 43,   56.2, 46.3, 42.9, 34.9, 26.4,15.4, 26.4, 31   };
    float    _heights[]       = {53,   52.9,28.2, 49.7, 61.2, 51.3,51.9,28.2,63.7,63.7,29,  39.4,26.4,15.6,20,  52.2,52.5,50.7,50.8,51.8,50.3,51.1,52.1,50,  51.9,52.1,43.3,50.4,45,   29.1, 45,   53.7,53.5,51.3,51.3,53.5,51.3,51.3,51.2,53.5,51.3,51.3,52.3,51.3,51.3,51.3,51.3,53.8,51.3,57.3,51.3,53.8,51.3,52.6, 51.3, 51.3, 51.3, 51.3, 51.3, 64.1,52.2,64.1, 0,  13.6, 0,  41.7, 52.1,43.8,52.2,43.9, 51.7, 55.9, 51.1,51.5,64.5,51.1,51.3,40.6,40.7,42,   53.3, 53.5, 40.7, 41.9, 49.1, 40.6, 39.9, 39.9, 39.9, 52.9, 39.9, 63.9,60.3, 63.9, 31   };

    //0 mean flush to top, 1 means centered vertically, 2 means flush to bottom
    int  _defaultY[]          = {0,    0,   0,    0,    0,    0,   0,   0,   1,   1,   1,   1,   2,   1,   2,   1,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   2,   2,   1,    1,    1,    0,   0,   2,   2,   2,   2,   2,   2,   2,   2,   2,   2,   2,   2,   2,   2,   2,   2,   2,   2,   2,   2,   2,    2,    2,    2,    2,    2,    1,   1,   1,    0,  2,    0,  2,    2,   2,   2,   2,    2,    2,    2,   2,   2,   2,   2,   2,   2,   2,    2,    2,    2,    2,    2,    2,    2,    2,    2,    2,    2,    1,   1,    1,    0    };
    
    //corrections in y coords. will add onto the default y-value.
    float  _correctionY[]     = {0,    0,   0,    0,    0,    0,   0,   0,   0,   0,   0,   0,   12,  0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   12,  0,    0,    0,    0,   0,   0,   0,   1,   0,   0,   0,   1,   0,   0,   1,   0,   0,   0,   0,   1,   0,   4,   0,   2,   0,   1.5,  0,    0,    0,    0,    0,    0,   0,   0,    0,  0,   0,   0.5,  0.5, 3,   0.5, 3,    0,    15,   0,   0,   13,  0,   0,   0,   0,   2,    13,   13,   0,    2,    0,    1,    0,    0,    0,    13,   0,    0,   0,    0,   -3    };

    
    [self setWidth:_widths height:_heights
                 x:_xCoords y:_yCoords
                yCorrection:_correctionY defaultYPosition:_defaultY
     kerning:1 lineHeight:52 length:95];
           //kerning:2 lineHeight:52 length:95];
     
    
    return self;
    
}



//previoustCharacterBuffer is A DELTA.
//22 was the font-size used to test all of the adjustments
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
            previousCharacterBuffer = -9;//-5;
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
        
        //      Av          Aw          AY         AT         AV         AW         AC         AS
        if(u == 118 || u == 119 || u == 89 || u == 84 || u == 86 || u == 87 || u == 67 || u == 83) {
            
            if(u == 67 || u == 83) {
            previousCharacterBuffer = -5;
            } else
            if(u == 89) {
            previousCharacterBuffer = -11;
            } else {
            previousCharacterBuffer = -9;
            }
            
        }
        
    }
    
    //if the current character is A:
    else
        if(u == 65) {
            int p = prevUnicode;
        
            //      vA          wA          PA         YA         TA         VA         WA         FA         CA         SA
            if(p == 118 || p == 119 || p == 80 || p == 89 || p == 84 || p == 86 || p == 87 || p == 70 || p == 67 || p == 83) {
                
                if(p == 67 || p == 83) {
                previousCharacterBuffer = -5;
                } else
                if(p == 89) {
                previousCharacterBuffer = -11;
                } else {
                previousCharacterBuffer = -9;
                }
                
            }
            
        }
    
    
    
    //Both of these cases were tested with: textField.text = @"Wa To Yd Va Vd \n aV oY bT rW bV";
    //For cases like Wa Vo Wm Td To where we have
    //                W                    V                    T                    Y
    if(prevUnicode == 87 || prevUnicode == 86 || prevUnicode == 84 || prevUnicode == 89) {
        
        
        //if it's one of these, then we can bring it closer to the previous W,V,T,Y.
        //For cases like: Wa To Yd Va Vd
        //a   c  d    e    g    j    m    n    o   p    q   r   s   u   v   w    x   y    z
        //97  99 100  101  103  106  109  110  111 112  113 114 115 117 118 119  120 121  122
        if(u >= 97 && u <= 122) {
            if( !(u == 98 || u == 102 || u == 104 || u == 105 || u == 107 || u == 108 || u == 116)) {
                previousCharacterBuffer = -9;//-5;
            }
        }
        
        //for cases like W. V, T_
        //      ,          .          _
        else
        if(u == 44 || u == 46 || u == 95) {
        previousCharacterBuffer = -3.5;//-7;
        }
        
        //else if YS
        else
        if(u == 83) {
        previousCharacterBuffer = -5;
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
                previousCharacterBuffer = -9;//-5;
            }
        }
        
        //else if SY
        else
        if(p == 83) {
        previousCharacterBuffer = -5;
        }
        
    } else
        
    if(u == 45) {
    previousCharacterBuffer = 7;
    } else
    if(prevUnicode == 45) {
    previousCharacterBuffer = 7;
    }
    
    return previousCharacterBuffer;
}

@end
