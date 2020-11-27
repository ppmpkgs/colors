unit ConsoleColors;

{$mode objfpc}
{$h+}

interface

  type
    TColorModifier = (
      cmReset = 0,
      cmBold = 1,
      cmFaint = 2,
      cmItalic = 3,
      cmUnderline = 4,
      cmReverse = 7,
      cmStrike = 9
    );

    TColorModifiers = Set of TColorModifier;

  var
    COLORS_ENABLED: Boolean = true;

  type
    { The abstract color class from which all variants derive. }
    TColor = class abstract
    private
      mods: TColorModifiers;

      function GetBold: Boolean;
      procedure SetBold(v: Boolean);
      function GetFaint: Boolean;
      procedure SetFaint(v: Boolean);
      function GetItalic: Boolean;
      procedure SetItalic(v: Boolean);
      function GetUnderline: Boolean;
      procedure SetUnderline(v: Boolean);
      function GetReverse: Boolean;
      procedure SetReverse(v: Boolean);
      function GetStrike: Boolean;
      procedure SetStrike(v: Boolean);

      function GetMods: String;
    public
      property Bold: Boolean read GetBold write SetBold;
      property Faint: Boolean read GetFaint write SetFaint;
      property Italic: Boolean read GetItalic write SetItalic;
      property Underline: Boolean read GetUnderline write SetUnderline;
      property Reverse: Boolean read GetReverse write SetReverse;
      property Strike: Boolean read GetStrike write SetStrike;

      function Copy: TColor; virtual abstract;
      function ToString: String; reintroduce virtual abstract;
      function S: String;
    end;

    {
      Simple foreground/background colors.

      See <https://en.wikipedia.org/wiki/ANSI_escape_code#3-bit_and_4-bit>.
    }
    T4BitColor = class(TColor)
      code: Byte;

      constructor Create(ACode: Byte; AMods: TColorModifiers = []);
      function Copy: TColor; override;
      function ToString: String; override;
    end;

    {
      More complex colors.

      Codes 16--231 function as RGB codes, where:

        code = 16 + 36 * r + 6 * g + b

      `r`, `g` and `b` are all more than 0 and less than six.

      See <https://en.wikipedia.org/wiki/ANSI_escape_code#8-bit>.
    }
    T8BitColor = class(TColor)
      code: Byte;
      background: Boolean;

      constructor Create(ACode: Byte; ABackground: Boolean = false; AMods: TColorModifiers = []);
      constructor Create(red, green, blue: Byte; ABackground: Boolean = false; AMods: TColorModifiers = []);
      function Copy: TColor; override;
      function ToString: String; override;
    end;

    {
      Full RGB colors.

      See <https://en.wikipedia.org/wiki/ANSI_escape_code#16-bit>.
    }
    T24BitColor = class(TColor)
      red, green, blue: Byte;
      background: Boolean;

      constructor Create(ARed, AGreen, ABlue: Byte; ABackground: Boolean = false; AMods: TColorModifiers = []);
      constructor Create(hex: LongWord; ABackground: Boolean = false; AMods: TColorModifiers = []);

      function Copy: TColor; override;
      function ToString: String; override;
    end;

  { Common aliases. }
  type
    TBasicColor = T4BitColor;
    TAdvancedColor = T8BitColor;
    TRGBColor = T24BitColor;

  const
    CODE_BLACK = 30;
    CODE_RED = 31;
    CODE_GREEN = 32;
    CODE_YELLOW = 33;
    CODE_BLUE = 34;
    CODE_MAGENTA = 35;
    CODE_CYAN = 36;
    CODE_WHITE = 37;

    CODE_BG_BLACK = 40;
    CODE_BG_RED = 41;
    CODE_BG_GREEN = 42;
    CODE_BG_YELLOW = 43;
    CODE_BG_BLUE = 44;
    CODE_BG_MAGENTA = 45;
    CODE_BG_CYAN = 46;
    CODE_BG_WHITE = 47;

  var
    COLOR_RESET, COLOR_BOLD, COLOR_FAINT, COLOR_ITALIC, COLOR_UNDERLINE, COLOR_REVERSE, COLOR_STRIKE,
    { Foreground colors. }
    COLOR_BLACK, COLOR_RED, COLOR_GREEN, COLOR_YELLOW, COLOR_BLUE, COLOR_MAGENTA, COLOR_CYAN, COLOR_WHITE,
    { Background colors. }
    COLOR_BG_BLACK, COLOR_BG_RED, COLOR_BG_GREEN, COLOR_BG_YELLOW, COLOR_BG_BLUE, COLOR_BG_MAGENTA, COLOR_BG_CYAN, COLOR_BG_WHITE:
      TBasicColor;

implementation

  uses
    SysUtils;

  const
    ESCAPE_CHAR = #27;

  function TColor.GetMods: String;
  var
    m: TColorModifier;
  begin
    GetMods := '';

    for m in mods do
      GetMods += IntToStr(Byte(m)) + ';';

    if (Length(GetMods) <> 0) and (GetMods[Length(GetMods) - 1] = ';') then
      GetMods[Length(GetMods) - 1] := #0
  end;

  function TColor.GetBold: Boolean;
  begin
    GetBold := cmBold in mods
  end;

  procedure TColor.SetBold(v: Boolean);
  begin
    if v then Include(mods, cmBold)
    else Exclude(mods, cmBold)
  end;

  function TColor.GetFaint: Boolean;
  begin
    GetFaint := cmFaint in mods
  end;

  procedure TColor.SetFaint(v: Boolean);
  begin
    if v then Include(mods, cmFaint)
    else Exclude(mods, cmFaint)
  end;

  function TColor.GetItalic: Boolean;
  begin
    GetItalic := cmItalic in mods
  end;

  procedure TColor.SetItalic(v: Boolean);
  begin
    if v then Include(mods, cmItalic)
    else Exclude(mods, cmItalic)
  end;

  function TColor.GetUnderline: Boolean;
  begin
    GetUnderline := cmUnderline in mods
  end;

  procedure TColor.SetUnderline(v: Boolean);
  begin
    if v then Include(mods, cmUnderline)
    else Exclude(mods, cmUnderline)
  end;

  function TColor.GetReverse: Boolean;
  begin
    GetReverse := cmReverse in mods
  end;

  procedure TColor.SetReverse(v: Boolean);
  begin
    if v then Include(mods, cmReverse)
    else Exclude(mods, cmReverse)
  end;

  function TColor.GetStrike: Boolean;
  begin
    GetStrike := cmStrike in mods
  end;

  procedure TColor.SetStrike(v: Boolean);
  begin
    if v then Include(mods, cmStrike)
    else Exclude(mods, cmStrike)
  end;

  function TColor.S: String;
  begin
    S := ToString
  end;

  constructor T4BitColor.Create(ACode: Byte; AMods: TColorModifiers = []);
  begin
    code := ACode;
    mods := AMods
  end;

  function T4BitColor.Copy: TColor;
  begin
    Copy := T4BitColor.Create(code, mods)
  end;

  function T4BitColor.ToString: String;
  begin
    if not COLORS_ENABLED then Exit('');

    ToString := ESCAPE_CHAR + '[' + GetMods + IntToStr(code) + 'm'
  end;

  constructor T8BitColor.Create(ACode: Byte; ABackground: Boolean = false; AMods: TColorModifiers = []);
  begin
    code := ACode;
    background := ABackground;
    mods := AMods
  end;

  constructor T8BitColor.Create(red, green, blue: Byte; ABackground: Boolean = false; AMods: TColorModifiers = []);
  begin
    code := 16 + 36 * red + 6 * green + blue;
    background := ABackground;
    mods := AMods
  end;

  function T8BitColor.Copy: TColor;
  begin
    Copy := T8BitColor.Create(code, background, mods)
  end;

  function T8BitColor.ToString: String;
  begin
    if not COLORS_ENABLED then Exit('');

    ToString := ESCAPE_CHAR + '[' + GetMods +
      BoolToStr(background, '48', '38') + ';5;' + IntToStr(code) + 'm'
  end;

  constructor T24BitColor.Create(ARed, AGreen, ABlue: Byte; ABackground: Boolean = false; AMods: TColorModifiers = []);
  begin
    red := ARed;
    green := AGreen;
    blue := ABlue;
    background := ABackground;
    mods := AMods
  end;

  constructor T24BitColor.Create(hex: LongWord; ABackground: Boolean = false; AMods: TColorModifiers = []);
  begin
    red := hex shr 16;
    green := (hex and $00FF00) shr 8;
    blue := hex and $0000FF;
    background := ABackground;
    mods := AMods
  end;

  function T24BitColor.Copy: TColor;
  begin
    Copy := T24BitColor.Create(red, green, blue, background, mods)
  end;

  function T24BitColor.ToString: String;
  begin
    if not COLORS_ENABLED then Exit('');

    ToString := ESCAPE_CHAR + '[' + GetMods +
      BoolToStr(background, '48', '38') + ';2;' +
      IntToStr(red) + ';' + IntToStr(green) + ';' + IntToStr(blue) + 'm'
  end;

initialization

  COLOR_RESET := TBasicColor.Create(Byte(cmReset));
  COLOR_BOLD := TBasicColor.Create(Byte(cmBold));
  COLOR_FAINT := TBasicColor.Create(Byte(cmFaint));
  COLOR_ITALIC := TBasicColor.Create(Byte(cmItalic));
  COLOR_UNDERLINE := TBasicColor.Create(Byte(cmUnderline));
  COLOR_REVERSE := TBasicColor.Create(Byte(cmReverse));
  COLOR_STRIKE := TBasicColor.Create(Byte(cmStrike));

  COLOR_BLACK := TBasicColor.Create(CODE_BLACK);
  COLOR_RED := TBasicColor.Create(CODE_RED);
  COLOR_GREEN := TBasicColor.Create(CODE_GREEN);
  COLOR_YELLOW := TBasicColor.Create(CODE_YELLOW);
  COLOR_BLUE := TBasicColor.Create(CODE_BLUE);
  COLOR_MAGENTA := TBasicColor.Create(CODE_MAGENTA);
  COLOR_CYAN := TBasicColor.Create(CODE_CYAN);
  COLOR_WHITE := TBasicColor.Create(CODE_BLACK);

  COLOR_BG_BLACK := TBasicColor.Create(CODE_BG_BLACK);
  COLOR_BG_RED := TBasicColor.Create(CODE_BG_RED);
  COLOR_BG_GREEN := TBasicColor.Create(CODE_BG_GREEN);
  COLOR_BG_YELLOW := TBasicColor.Create(CODE_BG_YELLOW);
  COLOR_BG_BLUE := TBasicColor.Create(CODE_BG_BLUE);
  COLOR_BG_MAGENTA := TBasicColor.Create(CODE_BG_MAGENTA);
  COLOR_BG_CYAN := TBasicColor.Create(CODE_BG_CYAN);
  COLOR_BG_WHITE := TBasicColor.Create(CODE_BG_BLACK);

end.
