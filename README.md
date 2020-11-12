# Colors!

This is a package that simplifies the use of colors in the terminal. To better understand this package, at least a rudimentary knowledge of [Select Graphics Rendition (SGR) ANSI escape sequences](https://en.wikipedia.org/wiki/ANSI_escape_code#SGR) is recommended.

## Usage

### Basic colors

If you want to use a simple color, just do this:

~~~ pascal
WriteLn(COLOR_RED.S, 'error', COLOR_RESET.S, ': something went wrong');
~~~

Please note that all colors in this package are class instances. Just typing:

~~~ pascal
WriteLn(COLOR_RED)
~~~

will throw an error:

~~~
Error: Can't read or write variables of this type
~~~

For this reason, use the `ToString` function (also aliased as just `S`) to get the actual ANSI escape sequence.

In addition to `COLOR_RESET`, you can use the following simple colors:

<span id="color-constants-list"></span>

   1. `COLOR_BOLD` (**bolder and often brighter text**)
   2. `COLOR_FAINT` (fainter colors)
   3. `COLOR_ITALIC` (*italic*)
   4. `COLOR_UNDERLINE` (underline)
   5. `COLOR_REVERSE` (reverse foreground & background colors)
   6. `COLOR_STRIKE` (~~strikethrough~~)
   7. `COLOR_BLACK` / `COLOR_BG_BLACK`
   8. `COLOR_RED` / `COLOR_BG_RED`
   9. `COLOR_GREEN` / `COLOR_BG_GREEN`
  10. `COLOR_YELLOW` / `COLOR_BG_YELLOW`
  11. `COLOR_BLUE` / `COLOR_BG_BLUE`
  12. `COLOR_MAGENTA` / `COLOR_BG_MAGENTA`
  13. `COLOR_CYAN` / `COLOR_BG_CYAN`
  14. `COLOR_WHITE` / `COLOR_BG_WHITE`

Again, don't forget to call `ToString`.

### Colors as objects

In this package, all colors are objects. (That's why you need to call `ToString`). The main building block is the abstract class `TColor`. It has three children:

  1. `T4BitColor`, also aliased as `TBasicColor` ([more info](https://en.wikipedia.org/wiki/ANSI_escape_code#3-bit_and_4-bit))
  2. `T8BitColor`, also aliased as `TAdvancedColor` ([more info](https://en.wikipedia.org/wiki/ANSI_escape_code#8-bit))
  3. `T24BitColor`, also aliased as `TRGBColor` ([more info](https://en.wikipedia.org/wiki/ANSI_escape_code#24-bit))

All of the `COLOR_*` constants are just preprepared instances of `TBasicColor`.

### Modifying colors

All `TColor`s have the following properties:

~~~ pascal
property Bold: Boolean read ... write ...;
property Faint: Boolean read ... write ...;
property Italic: Boolean read ... write ...;
property Underline: Boolean read ... write ...;
property Reverse: Boolean read ... write ...;
property Strike: Boolean read ... write ...;
~~~

For example, use this code to change red color to be underlined by default:

~~~ pascal
COLOR_RED.Underline := true;
~~~

Please note that this changes the `COLOR_RED` object itself. If you want to create a new color, see the next two sections.

### Copying existing colors

All descendants of the `TColor` class implement a `Copy` method, which returns a new `TColor` object with the same attributes. Example:

~~~ pascal
uses
  Colors;
var
  newColor: TBasicColor;
begin
  newColor := COLOR_RED.Copy as TBasicColor;
  newColor.Underline := true;
  WriteLn(COLOR_RED.S, 'hello', COLOR_RESET.S);  // this will be red
  WriteLn(newColor.S, 'hello', COLOR_RESET.S);  // this will be red & underlined
end.
~~~

**IMPORTANT**: Remember that `Copy` returns a `TColor` object, and so if you want to use it as a specific color, you need to cast it.

### Creating new colors

#### Modifiers

The last parameter of all color constructors is called `AMods` and has the type `TColorModifiers`, which is a set of `TColorModifier`, which is defined like this:

~~~ pascal
type TColorModifier = (
  cmReset = 0,
  cmBold = 1,
  cmFaint = 2,
  cmItalic = 3,
  cmUnderline = 4,
  cmReverse = 7,
  cmStrike = 9
);
~~~

#### Creating basic (4-bit) colors

~~~ pascal
constructor TBasicColor.Create(ACode: Byte; AMods: TColorModifiers = []);
~~~

`ACode` is one of the SGR codes from [this table](https://en.wikipedia.org/wiki/ANSI_escape_code#SGR). Luckily, constants for all of the colors on [this list](#color-constants-list) exist; just replace `COLOR_` with `CODE_`; so if you want to create your own green color, you would do this:

~~~ pascal
greenColor := TBasicColor.Create(CODE_GREEN);
~~~

For modifiers, `CODE_*` constants **do not** exist; to create your own bold color, do this:

~~~ pascal
boldColor := TBasicColor.Create(Byte(cmBold));
~~~

#### Creating advanced (8-bit) colors

~~~ pascal
constructor TAdvancedColor.Create(ACode: Byte; ABackground: Boolean = false; AMods: TColorModifiers = []);
constructor TAdvancedColor.Create(red, green, blue: Byte; ABackground: Boolean = false; AMods: TColorModifiers = []);
~~~

`ACode` is one of the codes from [here](https://en.wikipedia.org/wiki/ANSI_escape_code#8-bit).

Alternatively, you can supply the `red`, `green` and `blue` values instead. They should be between 0 and 5 (inclusive), although this isn't checked. The code is then calculated from them using the following formula:

    16 + 36 * red + 6 * green + blue

(Please note that only codes from 16 to 231 (inclusive) are actual RGB colors.)

If you set `ABackground` to `true`, the background color will be set instead of the foreground color.

#### Creating RGB (24-bit) colors

~~~ pascal
constructor TRGBColor.Create(ARed, AGreen, ABlue: Byte; ABackground: Boolean = false; AMods: TColorModifiers = []);
constructor TRGBColor.Create(hex: LongWord; ABackground: Boolean = false; AMods: TColorModifiers = []);
~~~

The first constructor overload works how you would expect; you provide a red, green and blue component (between 0 and 255 (inclusive), obviously) and a color is created.

If you like hex codes, you can use the second overload like this:

~~~ pascal
TRGBColor.Create($00a300);  // green
TRGBColor.Create($a300);  // this works too
TRGBColor.Create($e34fe3);  // pink
~~~

`ABackground` works the same way as in the `TAdvancedColors` constructor.
