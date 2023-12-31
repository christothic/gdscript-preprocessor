# GDScript Preprocessor Plugin

## Overview
The GDScript Preprocessor Plugin extends the capabilities of GDScript, Godot's native scripting language, by introducing preprocessing features akin to those in C/C++. This plugin allows developers to use custom directives for conditional compilation and defining constants, significantly enhancing the scripting workflow in Godot.

## Features
- **Define Directives**: Define constants using the `##define` directive.
- **Conditional Compilation**: Use `##if`, `##else`, and `##endif` for conditional compilation of code segments.
- **Multi-Threaded File Processing**: Speeds up file operations and parsing with multi-threading.
- **Error Checking**: Robust error handling for directive nesting and syntax.
- **Compatibility**: Designed to integrate seamlessly with the Godot Editor.

## Installation
1. Download latest release.
2. Unzip the `addons/` directory into your Godot project folder.
3. In Godot, go to `Project` > `Project Settings` > `Plugins`.
4. Find the GDScript Preprocessor Plugin and make sure to `Enable` it by clicking the checkbox under the Status column.
5. Sample project is included in the repository if you want to try it on a safe environment.

## Usage
### Basic Directives
- `##define NAME VALUE`: Define a constant, if no value is provided it defaults to `true` for now.
- `##if CONDITION`: Compile the following code block if CONDITION is true.
- `##else`: Compile the following code block if none of the preceding conditions were true.
- `##endif`: End of a conditional block.
- ~~`##elseif CONDITION`~~: To be implemented, use nested `##if` after the `##else` for now.

### Examples:
```gdscript
##define DEBUG_MODE
func _ready():
##if defined DEBUG_MODE
    print("Debug mode is active.")
##else
    print("Running in production mode.")
##endif
```
#### Would get converted into:
```gdscript
##define DEBUG_MODE
func _ready():
##if defined DEBUG_MODE
    print("Debug mode is active.")
##else
#--    print("Running in production mode.")
##endif
```
#### And
```gdscript
##define VALUE 10
func _ready():
##if VALUE > 5
    print("VALUE > 5")
##else
    print("VALUE <= 5")
##endif
```
#### Would get converted into:
```gdscript
##define VALUE 10
func _ready():
##if VALUE > 5
    print("VALUE > 5")
##else
#--    print("VALUE <= 5")
##endif
```

## Advanced Usage
- Utilize multi-threading for handling large projects. `Please send feedback on this!` I'm still a godot noob and a godot threads noob by extension, so this only has been tested on small projects on a fast computer.
- Implement nested conditional directives for complex scenarios.
- Combine multiple `##define` directives to manage various build configurations.
- If your project needs different strings for the directives, or if you like to customize them to your style, all of them are defined near the top in `addons/preprocessor/preprocessor.gd` for you to change:
```gdscript
const define_string = "##define "
const if_defined_string = "##if defined "
const if_string = "##if "
const elif_string = "##elseif "
const else_string = "##else"
const endif_string = "##endif"
const not_defined_string = "#--"
```

## Future releases:
- Probably next will be implementing `##elseif`.
- Another thing I need to work is properly concatenating `defined(DEFINE)` directive to use in for example `##if defined(DEFINE1) or defined(DEFINE2)`, etc.
- Maybe in the later future also implement proper C-like defines with macros and multiple lines with `\` or some other character, but for now is not something urgent that can't be acomplished with some functions.

## Contributing
Contributions to the GDScript Preprocessor Plugin are welcome! Just fork and send your pull request, I will test it as soon as I can.

## License
MIT, do whatever with this, I'm happy knowing it helped somewhat.

## Acknowledgments
Thanks to the Godot community for the continuous support.

