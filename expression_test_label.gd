extends Label

##define BOOL_DEFINE
##define INT_DEFINE 2
##define STR_DEFINE "STR"

func _ready() -> void:
    text = "Original text"
##if INT_DEFINE > 3
#--    text = "INT_DEFINE > 3"
##if BOOL_DEFINE == false
#--    text = "BOOL_DEFINE == false"
##else
#--    text = "BOOL_DEFINE == true"
##endif
##else
    text = "INT_DEFINE < 4"
##endif
