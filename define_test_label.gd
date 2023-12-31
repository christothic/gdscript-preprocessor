extends Label

##define TEST_DEFINE
##define NESTED_TEST_DEFINE

func _ready() -> void:
    text = "Original text"
##if defined TEST_DEFINE
    text = "defined TEST_DEFINE"
##if defined NESTED_TEST_DEFINE
    text = "defined TEST_DEFINE and NESTED_TEST_DEFINE"
##else
#--    text = "not defined NESTED_TEST_DEFINE"
##endif
##else
#--    text = "not defined TEST_DEFINE"
##endif
