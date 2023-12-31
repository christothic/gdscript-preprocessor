@tool
extends EditorPlugin

var all_defines: Dictionary = {}
var all_errors: Array = []
var all_files: Dictionary = {}

const define_string = "##define "
const if_defined_string = "##if defined "
const if_string = "##if "
const elif_string = "##elseif "
const else_string = "##else"
const endif_string = "##endif"
const not_defined_string = "#--"

enum ParseStatus {NORMAL, COMMENTING, UNCOMMENTING}

func get_all_gdscript_files(path, files, threads):
    var dir = DirAccess.open(path)
    dir.list_dir_begin()
    var filename = dir.get_next()
    while(filename != ""):
        var cur_dir = dir.get_current_dir()
        if dir.current_is_dir():
            var thread = Thread.new()
            threads.append(thread)
            thread.start(func():
                get_all_gdscript_files(cur_dir + "/" + filename, files, threads))
        elif filename.ends_with(".gd") and not cur_dir.contains("res://addons/"):
            files.append(cur_dir + ("/" if cur_dir != "res://" else "") + filename)
        filename = dir.get_next()
    dir.list_dir_end()

func parse_string_value(string_value: String):
    var check_float = float(string_value)
    if check_float == 0:
        if string_value == "true":
            return true
        if string_value == "false":
            return false
        return string_value.trim_prefix("\"").trim_suffix("\"")
    if is_equal_approx(check_float, roundf(check_float)):
        return int(check_float)
    return check_float
    
func apply_defines_on_dictionary_from_file(file_str):
    var file = FileAccess.open(file_str, FileAccess.READ)
    var file_array = []
    var file_defines = {}
    var nest_status_stack = [ParseStatus.NORMAL]
    while file.get_position() < file.get_length():
        var line = file.get_line()
        if line.find(define_string) == 0:
            var define = line.trim_prefix(define_string)
            define = define.split(" ", true, 2)
            if define.size() == 1:
                file_defines[define[0]] = true
            if define.size() == 2:
                file_defines[define[0]] = parse_string_value(define[1])
        if line.find(if_defined_string) == 0:
            nest_status_stack.append(parse_if_def_line(line, nest_status_stack.back(), file_defines))
            file_array.append(line)
            continue
        if line.find(if_string) == 0:
            nest_status_stack.append(parse_if_line(line, nest_status_stack.back(), file_defines))
            file_array.append(line)
            continue
        if line.find(else_string) == 0:
            if nest_status_stack.size() > 1 and nest_status_stack[-2] != ParseStatus.COMMENTING:
                nest_status_stack[-1] = ParseStatus.COMMENTING if nest_status_stack[-1] == ParseStatus.UNCOMMENTING else ParseStatus.UNCOMMENTING
            file_array.append(line)
            continue
        if line.find(endif_string) == 0:
            nest_status_stack.pop_back()
            file_array.append(line)
            continue
        var new_line = parse_code_line(line, nest_status_stack.back())
        file_array.append(new_line)
    file.close()
    if nest_status_stack.size() != 1 and nest_status_stack.back() != ParseStatus.NORMAL:
        all_errors.append("UNEVEN NESTING, You may be missing or have an extra \"" 
            + if_string + "\" or \"" + endif_string + "\"")
        return
    all_files[file_str] = file_array
    all_defines.merge(file_defines)
    
func parse_code_line(line, parsing_status):
    match parsing_status:
        ParseStatus.UNCOMMENTING:
            line = line.trim_prefix(not_defined_string)
        ParseStatus.COMMENTING:
            if line.find(not_defined_string) != 0:
                line = line.indent(not_defined_string)
    return line
    
func parse_if_def_line(line, parsing_status, defines):
    if parsing_status == ParseStatus.NORMAL or parsing_status == ParseStatus.UNCOMMENTING:
        var if_def = line.trim_prefix(if_defined_string)
        if_def = if_def.split(" ", true)
        if not if_def.is_empty():
            parsing_status = ParseStatus.UNCOMMENTING if defines.has(if_def[0]) else ParseStatus.COMMENTING
    return parsing_status
    
func parse_if_line(line, parsing_status, defines):
    if parsing_status == ParseStatus.NORMAL or parsing_status == ParseStatus.UNCOMMENTING:
        var if_exp = line.trim_prefix(if_string)
        for define in defines:
            if if_exp.contains(define):
                if_exp = if_exp.replace(define, str(defines[define]))
        var expression = Expression.new()
        expression.parse(if_exp)
        var result = expression.execute()
        parsing_status = ParseStatus.UNCOMMENTING if result else ParseStatus.COMMENTING
    return parsing_status
    
func write_all_defines_on_file(file_str):
    print("Parsing file: " + file_str)
    var parsed_file_array = []
    var nest_status_stack = [ParseStatus.NORMAL]
    var file_array = all_files[file_str]
    for line in file_array:
        if line.find(if_defined_string) == 0:
            nest_status_stack.append(parse_if_def_line(line, nest_status_stack.back(), all_defines))
            parsed_file_array.append(line)
            continue
        if line.find(if_string) == 0:
            nest_status_stack.append(parse_if_line(line, nest_status_stack.back(), all_defines))
            parsed_file_array.append(line)
            continue
        if line.find(else_string) == 0:
            if nest_status_stack.size() > 1 and nest_status_stack[-2] != ParseStatus.COMMENTING:
                nest_status_stack[-1] = ParseStatus.COMMENTING if nest_status_stack[-1] == ParseStatus.UNCOMMENTING else ParseStatus.UNCOMMENTING
            parsed_file_array.append(line)
            continue
        if line.find(endif_string) == 0:
            nest_status_stack.pop_back()
            parsed_file_array.append(line)
            continue
        var new_line = parse_code_line(line, nest_status_stack.back())
        parsed_file_array.append(new_line)
    if nest_status_stack.size() != 1 and nest_status_stack.back() != ParseStatus.NORMAL:
        all_errors.append("UNEVEN NESTING, You may be missing or have an extra \"" 
            + if_string + "\" or \"" + endif_string + "\"")
        return
    var file = FileAccess.open(file_str, FileAccess.READ)
    var file_changed = false
    var index = 0
    while file.get_position() < file.get_length():
        if index >= parsed_file_array.size():
            all_errors.append("LINE ERROR: Different line count after parsing")
            return
        if file.get_line() != parsed_file_array[index]:
            file_changed = true
            break
        index += 1
    file.close()
    if not file_changed:
        return
    file = FileAccess.open(file_str, FileAccess.WRITE)
    for line in parsed_file_array:
        file.store_line(line)
    file.close()

func write_all_defines_on_files(files):
    var threads = []
    for file_str in files:
        var thread = Thread.new()
        threads.append(thread)
        thread.start(func():
            write_all_defines_on_file(file_str))
    for t in threads:
        t.wait_to_finish()
        
func apply_defines_on_dictionary_from_files(files):
    var threads = []
    for file_str in files:
        var thread = Thread.new()
        threads.append(thread)
        thread.start(func():
            apply_defines_on_dictionary_from_file(file_str))
    for t in threads:
        t.wait_to_finish()

func check_for_errors():
    if not all_errors.is_empty():
        print("ERRORS:")
        for error in all_errors:
            print(error.indent("    "))
        all_defines.clear()
        all_files.clear()
        all_errors.clear()
        return true
    return false

func clear_dictionaries() -> void:
    all_files.clear()
    all_defines.clear()

func _build() -> bool:
    print("STARTING PREPROCESS:")
    clear_dictionaries()
    var all_gdscript_files = []
    var threads = []
    get_all_gdscript_files("res://", all_gdscript_files, threads)
    for t in threads:
        t.wait_to_finish()
    threads.clear()
    apply_defines_on_dictionary_from_files(all_gdscript_files)
    if check_for_errors():
        return false
    print("Defines:")
    for define in all_defines:
        print(define.indent("    ") + " = " + str(all_defines[define]))
    write_all_defines_on_files(all_gdscript_files)
    clear_dictionaries()
    if check_for_errors():
        return false
    print("PREPROCESS ENDED SUCCESSFULLY")
    return true
