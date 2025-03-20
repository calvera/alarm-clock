package segment7_pkg;
    // User-defined types
    typedef logic [3:0] digit_t;
    typedef logic [7:0] segment_output_t;
    
    // Enumerated type for segment states
    typedef enum logic {
        ACTIVE_HIGH = '0,
        ACTIVE_LOW = '1
    } polarity_t;
endpackage
