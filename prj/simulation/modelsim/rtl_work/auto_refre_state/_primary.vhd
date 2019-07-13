library verilog;
use verilog.vl_types.all;
entity auto_refre_state is
    generic(
        C_NOP           : vl_logic_vector(0 to 3) := (Hi0, Hi1, Hi1, Hi1);
        C_PRE           : vl_logic_vector(0 to 3) := (Hi0, Hi0, Hi1, Hi0);
        C_AREF          : vl_logic_vector(0 to 3) := (Hi0, Hi0, Hi0, Hi1);
        C_MSET          : vl_logic_vector(0 to 3) := (Hi0, Hi0, Hi0, Hi0);
        C_ACT           : vl_logic_vector(0 to 3) := (Hi0, Hi0, Hi1, Hi1);
        C_RD            : vl_logic_vector(0 to 3) := (Hi0, Hi1, Hi0, Hi1);
        C_WR            : vl_logic_vector(0 to 3) := (Hi0, Hi1, Hi0, Hi0);
        INIT_PRE        : integer := 20000;
        REF_PRE         : integer := 3;
        REF_REF         : integer := 10;
        AUTO_REF        : integer := 1560;
        LMR_ACT         : integer := 2;
        WR_PRE          : integer := 2;
        SC_RCD          : integer := 3;
        SC_CL           : integer := 3;
        SC_BL           : integer := 8;
        OP_CODE         : vl_logic := Hi0;
        SDR_BL          : vl_notype;
        SDR_BT          : vl_logic := Hi0;
        SDR_CL          : vl_notype
    );
    port(
        Clk             : in     vl_logic;
        Rst_n           : in     vl_logic;
        Cs_n            : out    vl_logic;
        Ras_n           : out    vl_logic;
        Cas_n           : out    vl_logic;
        We_n            : out    vl_logic;
        Sa              : out    vl_logic_vector(12 downto 0);
        auto_refre_en   : in     vl_logic;
        ref_opt_done    : out    vl_logic
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of C_NOP : constant is 1;
    attribute mti_svvh_generic_type of C_PRE : constant is 1;
    attribute mti_svvh_generic_type of C_AREF : constant is 1;
    attribute mti_svvh_generic_type of C_MSET : constant is 1;
    attribute mti_svvh_generic_type of C_ACT : constant is 1;
    attribute mti_svvh_generic_type of C_RD : constant is 1;
    attribute mti_svvh_generic_type of C_WR : constant is 1;
    attribute mti_svvh_generic_type of INIT_PRE : constant is 1;
    attribute mti_svvh_generic_type of REF_PRE : constant is 1;
    attribute mti_svvh_generic_type of REF_REF : constant is 1;
    attribute mti_svvh_generic_type of AUTO_REF : constant is 1;
    attribute mti_svvh_generic_type of LMR_ACT : constant is 1;
    attribute mti_svvh_generic_type of WR_PRE : constant is 1;
    attribute mti_svvh_generic_type of SC_RCD : constant is 1;
    attribute mti_svvh_generic_type of SC_CL : constant is 1;
    attribute mti_svvh_generic_type of SC_BL : constant is 1;
    attribute mti_svvh_generic_type of OP_CODE : constant is 1;
    attribute mti_svvh_generic_type of SDR_BL : constant is 3;
    attribute mti_svvh_generic_type of SDR_BT : constant is 1;
    attribute mti_svvh_generic_type of SDR_CL : constant is 3;
end auto_refre_state;
