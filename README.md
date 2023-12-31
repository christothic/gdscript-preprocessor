# GDScript Preprocessor Plugin

## Overview
The GDScript Preprocessor Plugin extends the capabilities of GDScript, Godot's native scripting language, by introducing preprocessing features akin to those in C/C++. This plugin allows developers to use custom directives for conditional compilation and defining constants, significantly enhancing the scripting workflow in Godot.

## Features
- **Define Directives**: Define constants using the `##define` directive.
- **Conditional Compilation**: Use `##if`, `##elseif`, `##else`, and `##endif` for conditional compilation of code segments.
- **Multi-Threaded File Processing**: Speeds up file operations and parsing with multi-threading.
- **Error Checking**: Robust error handling for directive nesting and syntax.
- **Compatibility**: Designed to integrate seamlessly with the Godot Editor.

## Installation
1. Download latest release.
2. Unzip the `addons/` directory into your Godot project folder.
3. In Godot, go to `Project` > `Project Settings` > `Plugins`.
4. Find the GDScript Preprocessor Plugin and make sure is `Activated`.
5. Sample project is included in the repository.

## Usage
### Basic Directives
- `##define NAME VALUE`: Define a constant.
- `##if CONDITION`: Compile the following code block if CONDITION is true.
- `##elseif CONDITION`: To be implemented, use nested `##if` after the `##else` for now.
- `##else`: Compile the following code block if none of the preceding conditions were true.
- `##endif`: End of a conditional block.

### Example
```gdscript
##define DEBUG_MODE
func _ready():
    ##if DEBUG_MODE
        print("Debug mode is active.")
    ##else
        print("Running in production mode.")
    ##endif
```

## Advanced Usage
- Utilize multi-threading for handling large projects. `Please send feedback on this!` I'm still a godot noob and a godot threads noob by extension, so this only has been tested on small projects on a fast computer.
- Implement nested conditional directives for complex scenarios.
- Combine multiple `##define` directives to manage various build configurations.

## Contributing
Contributions to the GDScript Preprocessor Plugin are welcome! Just fork and send your pull request, I will test it as soon as I can.

## License
MIT, do whatever with this, I'm happy knowing it helped somewhat.

## Acknowledgments
Thanks to the Godot community for the continuous support.
