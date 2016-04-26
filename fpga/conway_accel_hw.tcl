# TCL File Generated by Component Editor 13.1.1
# Tue Apr 26 13:58:26 EDT 2016
# DO NOT MODIFY


# 
# conway_accel "conway_accel" v1.1
#  2016.04.26.13:58:26
# 
# 

# 
# request TCL package from ACDS 13.1
# 
package require -exact qsys 13.1


# 
# module conway_accel
# 
set_module_property DESCRIPTION ""
set_module_property NAME conway_accel
set_module_property VERSION 1.1
set_module_property INTERNAL false
set_module_property OPAQUE_ADDRESS_MAP true
set_module_property AUTHOR ""
set_module_property DISPLAY_NAME conway_accel
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE true
set_module_property ANALYZE_HDL AUTO
set_module_property REPORT_TO_TALKBACK false
set_module_property ALLOW_GREYBOX_GENERATION false


# 
# file sets
# 
add_fileset QUARTUS_SYNTH QUARTUS_SYNTH "" ""
set_fileset_property QUARTUS_SYNTH TOP_LEVEL Conway_Accel
set_fileset_property QUARTUS_SYNTH ENABLE_RELATIVE_INCLUDE_PATHS false
add_fileset_file conway_accel.sv SYSTEM_VERILOG PATH conway_accel.sv TOP_LEVEL_FILE


# 
# parameters
# 
add_parameter TOP STD_LOGIC_VECTOR 1
set_parameter_property TOP DEFAULT_VALUE 1
set_parameter_property TOP DISPLAY_NAME TOP
set_parameter_property TOP TYPE STD_LOGIC_VECTOR
set_parameter_property TOP UNITS None
set_parameter_property TOP ALLOWED_RANGES 0:15
set_parameter_property TOP HDL_PARAMETER true
add_parameter MID STD_LOGIC_VECTOR 2
set_parameter_property MID DEFAULT_VALUE 2
set_parameter_property MID DISPLAY_NAME MID
set_parameter_property MID TYPE STD_LOGIC_VECTOR
set_parameter_property MID UNITS None
set_parameter_property MID ALLOWED_RANGES 0:15
set_parameter_property MID HDL_PARAMETER true
add_parameter BOT STD_LOGIC_VECTOR 3
set_parameter_property BOT DEFAULT_VALUE 3
set_parameter_property BOT DISPLAY_NAME BOT
set_parameter_property BOT TYPE STD_LOGIC_VECTOR
set_parameter_property BOT UNITS None
set_parameter_property BOT ALLOWED_RANGES 0:15
set_parameter_property BOT HDL_PARAMETER true
add_parameter EOR STD_LOGIC_VECTOR 4
set_parameter_property EOR DEFAULT_VALUE 4
set_parameter_property EOR DISPLAY_NAME EOR
set_parameter_property EOR TYPE STD_LOGIC_VECTOR
set_parameter_property EOR UNITS None
set_parameter_property EOR ALLOWED_RANGES 0:15
set_parameter_property EOR HDL_PARAMETER true


# 
# display items
# 


# 
# connection point clock
# 
add_interface clock clock end
set_interface_property clock clockRate 0
set_interface_property clock ENABLED true
set_interface_property clock EXPORT_OF ""
set_interface_property clock PORT_NAME_MAP ""
set_interface_property clock CMSIS_SVD_VARIABLES ""
set_interface_property clock SVD_ADDRESS_GROUP ""

add_interface_port clock clk clk Input 1


# 
# connection point reset
# 
add_interface reset reset end
set_interface_property reset associatedClock clock
set_interface_property reset synchronousEdges DEASSERT
set_interface_property reset ENABLED true
set_interface_property reset EXPORT_OF ""
set_interface_property reset PORT_NAME_MAP ""
set_interface_property reset CMSIS_SVD_VARIABLES ""
set_interface_property reset SVD_ADDRESS_GROUP ""

add_interface_port reset reset reset Input 1


# 
# connection point avalon_slave
# 
add_interface avalon_slave avalon end
set_interface_property avalon_slave addressUnits WORDS
set_interface_property avalon_slave associatedClock clock
set_interface_property avalon_slave associatedReset reset
set_interface_property avalon_slave bitsPerSymbol 20
set_interface_property avalon_slave burstOnBurstBoundariesOnly false
set_interface_property avalon_slave burstcountUnits WORDS
set_interface_property avalon_slave explicitAddressSpan 0
set_interface_property avalon_slave holdTime 0
set_interface_property avalon_slave linewrapBursts false
set_interface_property avalon_slave maximumPendingReadTransactions 0
set_interface_property avalon_slave readLatency 0
set_interface_property avalon_slave readWaitTime 1
set_interface_property avalon_slave setupTime 0
set_interface_property avalon_slave timingUnits Cycles
set_interface_property avalon_slave writeWaitTime 0
set_interface_property avalon_slave ENABLED true
set_interface_property avalon_slave EXPORT_OF ""
set_interface_property avalon_slave PORT_NAME_MAP ""
set_interface_property avalon_slave CMSIS_SVD_VARIABLES ""
set_interface_property avalon_slave SVD_ADDRESS_GROUP ""

add_interface_port avalon_slave address_b_1 address Input 16
add_interface_port avalon_slave q_b_1 readdata Output 20
add_interface_port avalon_slave wait_request waitrequest Output 1
set_interface_assignment avalon_slave embeddedsw.configuration.isFlash 0
set_interface_assignment avalon_slave embeddedsw.configuration.isMemoryDevice 0
set_interface_assignment avalon_slave embeddedsw.configuration.isNonVolatileStorage 0
set_interface_assignment avalon_slave embeddedsw.configuration.isPrintableDevice 0
