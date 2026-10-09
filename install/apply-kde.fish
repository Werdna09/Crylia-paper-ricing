#!/usr/bin/env fish

# Crylia Paper — KDE / KWin / Klassy setup
# Target: Plasma / KWin 6.7.x + Klassy 6.7.x
#
# This script:
#   1. backs up the relevant KDE/Klassy config files,
#   2. creates/updates a custom "Crylia" Klassy window-decoration preset,
#   3. loads that preset,
#   4. enforces the KWin decoration/button layout,
#   5. enables the useful KWin effects,
#   6. regenerates Klassy system icons and reloads KWin.

set -g ROOT "$HOME/Rice/crylia-paper"
set -g BACKUP_DIR "$ROOT/backups/kde"

set -g KLASSY_DIR "$HOME/.config/klassy"
set -g KLASSY_CONFIG "$KLASSY_DIR/klassyrc"
set -g KLASSY_PRESETS "$KLASSY_DIR/windecopresetsrc"

set -g PRESET_GROUP "Windeco Preset Crylia"
set -g TIMESTAMP (date "+%Y%m%d-%H%M%S")


function die
    echo "ERROR: $argv" >&2
    exit 1
end


function need
    command -q "$argv[1]"; or die "Missing command: $argv[1]"
end


function preset_set
    set -l key "$argv[1]"
    set -l value "$argv[2]"

    kwriteconfig6 \
        --file "$KLASSY_PRESETS" \
        --group "$PRESET_GROUP" \
        --key "$key" \
        "$value"; or die "Failed to write Klassy preset key: $key"
end


echo "== Crylia KDE setup =="

need kwriteconfig6
need kreadconfig6
need qdbus6
need klassy-settings

mkdir -p "$BACKUP_DIR"
mkdir -p "$KLASSY_DIR"


# ------------------------------------------------------------
# BACKUP
# ------------------------------------------------------------

echo "Backing up current KDE/Klassy configuration..."

if test -f "$HOME/.config/kwinrc"
    cp \
        "$HOME/.config/kwinrc" \
        "$BACKUP_DIR/kwinrc.$TIMESTAMP"
end

if test -f "$HOME/.config/kdeglobals"
    cp \
        "$HOME/.config/kdeglobals" \
        "$BACKUP_DIR/kdeglobals.$TIMESTAMP"
end

if test -f "$KLASSY_CONFIG"
    cp \
        "$KLASSY_CONFIG" \
        "$BACKUP_DIR/klassyrc.$TIMESTAMP"
end

if test -f "$KLASSY_PRESETS"
    cp \
        "$KLASSY_PRESETS" \
        "$BACKUP_DIR/windecopresetsrc.$TIMESTAMP"
end


# ------------------------------------------------------------
# CRYLIA KLASSY PRESET
# ------------------------------------------------------------

echo "Writing Klassy preset: Crylia..."

# General
preset_set BundledPreset false
preset_set AnimationsEnabled true
preset_set AnimationsSpeedRelativeSystem 0

# Titlebar
preset_set BoldTitle false
preset_set TitleAlignment AlignCenterFullWidth

preset_set TitleBarTopMargin 3
preset_set TitleBarBottomMargin 3
preset_set TitleBarLeftMargin 4
preset_set TitleBarRightMargin 4
preset_set TitleSidePadding 6

preset_set OverrideTitleBarOpacityActive false
preset_set OverrideTitleBarOpacityInactive false
preset_set TitleBarOpacityActive 100
preset_set TitleBarOpacityInactive 100
preset_set OpaqueMaximizedTitleBars true

preset_set DrawBackgroundGradient false
preset_set DrawTitleBarSeparator false
preset_set MatchTitleBarToApplicationColor false
preset_set UseTitleBarColorForAllBorders true

# Window geometry
preset_set KwinBorderSize None
preset_set WindowCornerRadius 8
preset_set RoundAllCornersWhenNoBorders true
preset_set DrawBorderOnMaximizedWindows false

# Shadow
preset_set ShadowColorActive "0,0,0"
preset_set ShadowColorInactive "0,0,0"
preset_set ShadowSizeActive ShadowLarge
preset_set ShadowSizeInactive ShadowLarge
preset_set ShadowStrengthActive 220
preset_set ShadowStrengthInactive 110

# Window outline
preset_set WindowOutlineThickness 1
preset_set WindowOutlineStyleActive WindowOutlineAccentColor
preset_set WindowOutlineStyleInactive WindowOutlineAccentWithContrast

preset_set WindowOutlineAccentColorOpacityActive 67
preset_set WindowOutlineAccentColorOpacityInactive 25
preset_set WindowOutlineAccentWithContrastOpacityActive 50
preset_set WindowOutlineAccentWithContrastOpacityInactive 20

preset_set WindowOutlineContrastFromColorSchemeActive true
preset_set WindowOutlineContrastFromColorSchemeInactive true
preset_set WindowOutlineContrastOpacityActive 20
preset_set WindowOutlineContrastOpacityInactive 20

preset_set ColorizeWindowOutlineWithButton false

# Buttons — Material Dynamic, compact, rounded
preset_set ButtonIconStyle StyleMaterialDynamic
preset_set IconSize IconLargeMedium
preset_set SystemIconSize SystemIcon16
preset_set BoldButtonIcons BoldIconsActiveHiDpi

preset_set ButtonShape ShapeIntegratedRoundedRectangle
preset_set ButtonCornerRadius SameAsWindow
preset_set ButtonCustomCornerRadius 1
preset_set IntegratedRoundedRectangleBottomPadding 2

preset_set ButtonSpacingLeft 4
preset_set ButtonSpacingRight 4

preset_set FullHeightButtonSpacingLeft 2
preset_set FullHeightButtonSpacingRight 2
preset_set FullHeightButtonWidthMarginLeft 8
preset_set FullHeightButtonWidthMarginRight 18
preset_set CloseFullHeightButtonWidthMarginRelative 100

preset_set ButtonIconColorsActive TitleBarText
preset_set ButtonIconColorsInactive TitleBarText
preset_set ButtonIconOpacityActive 100
preset_set ButtonIconOpacityInactive 85

preset_set ButtonBackgroundColorsActive AccentNegativeClose
preset_set ButtonBackgroundColorsInactive AccentNegativeClose
preset_set ButtonBackgroundOpacityActive 60
preset_set ButtonBackgroundOpacityInactive 45

preset_set ShowBackgroundNormallyActive false
preset_set ShowBackgroundNormallyInactive false
preset_set ShowBackgroundOnHoverActive true
preset_set ShowBackgroundOnHoverInactive true
preset_set ShowBackgroundOnPressActive true
preset_set ShowBackgroundOnPressInactive true

preset_set ShowOutlineNormallyActive false
preset_set ShowOutlineNormallyInactive false
preset_set ShowOutlineOnHoverActive false
preset_set ShowOutlineOnHoverInactive false
preset_set ShowOutlineOnPressActive false
preset_set ShowOutlineOnPressInactive false

preset_set ShowIconNormallyActive true
preset_set ShowIconNormallyInactive true
preset_set ShowIconOnHoverActive true
preset_set ShowIconOnHoverInactive true
preset_set ShowIconOnPressActive true
preset_set ShowIconOnPressInactive true

# Close button
preset_set NegativeCloseBackgroundHoverPressActive true
preset_set NegativeCloseBackgroundHoverPressInactive true
preset_set CloseButtonIconColorActive WhiteWhenHoverPress
preset_set CloseButtonIconColorInactive WhiteWhenHoverPress

preset_set ShowCloseBackgroundNormallyActive false
preset_set ShowCloseBackgroundNormallyInactive false
preset_set ShowCloseBackgroundOnHoverActive true
preset_set ShowCloseBackgroundOnHoverInactive true
preset_set ShowCloseBackgroundOnPressActive true
preset_set ShowCloseBackgroundOnPressInactive true

preset_set ShowCloseOutlineNormallyActive false
preset_set ShowCloseOutlineNormallyInactive false
preset_set ShowCloseOutlineOnHoverActive false
preset_set ShowCloseOutlineOnHoverInactive false
preset_set ShowCloseOutlineOnPressActive false
preset_set ShowCloseOutlineOnPressInactive false

preset_set ShowCloseIconNormallyActive true
preset_set ShowCloseIconNormallyInactive true
preset_set ShowCloseIconOnHoverActive true
preset_set ShowCloseIconOnHoverInactive true
preset_set ShowCloseIconOnPressActive true
preset_set ShowCloseIconOnPressInactive true

# Keep active/inactive behaviour aligned
preset_set LockButtonBehaviourActiveInactive true
preset_set LockButtonColorsActiveInactive true
preset_set LockButtonSpacingLeftRight true
preset_set LockCloseButtonBehaviourActive true
preset_set LockCloseButtonBehaviourInactive true
preset_set LockTitleBarLeftRightMargins true
preset_set LockTitleBarTopBottomMargins true

# Misc
preset_set ApplyOpacityToHeader true
preset_set BlurTransparentTitleBars true
preset_set ForceColorizeSystemIcons true
preset_set KlassyIconThemeInherits breeze
preset_set KlassyDarkIconThemeInherits breeze-dark

preset_set PoorBackgroundContrastThresholdActive 1.1
preset_set PoorBackgroundContrastThresholdInactive 1.1
preset_set PoorIconContrastThresholdActive 1.5
preset_set PoorIconContrastThresholdInactive 1.5
preset_set OnPoorIconContrastActive TitleBarBackground
preset_set OnPoorIconContrastInactive TitleBarBackground

# Window controls:
# I = minimize, A = maximize, X = close
preset_set KwinButtonsOnLeft ""
preset_set KwinButtonsOnRight IAX


# ------------------------------------------------------------
# VALIDATE PRESET
# ------------------------------------------------------------

echo "Validating Klassy preset..."

set -l written_radius (
    kreadconfig6 \
        --file "$KLASSY_PRESETS" \
        --group "$PRESET_GROUP" \
        --key WindowCornerRadius
)

if test "$written_radius" != "8"
    die "Crylia preset was not written correctly (WindowCornerRadius=$written_radius)"
end

echo "Preset written successfully."


# ------------------------------------------------------------
# LOAD PRESET
# ------------------------------------------------------------

echo "Loading Klassy preset..."

klassy-settings \
    --load-windeco-preset Crylia; or die "Klassy could not load the Crylia preset"


# ------------------------------------------------------------
# KWIN DECORATION
# ------------------------------------------------------------

echo "Configuring KWin decoration..."

kwriteconfig6 \
    --file kwinrc \
    --group org.kde.kdecoration2 \
    --key library \
    org.kde.klassy

kwriteconfig6 \
    --file kwinrc \
    --group org.kde.kdecoration2 \
    --key BorderSize \
    Tiny

kwriteconfig6 \
    --file kwinrc \
    --group org.kde.kdecoration2 \
    --key BorderSizeAuto \
    false

kwriteconfig6 \
    --file kwinrc \
    --group org.kde.kdecoration2 \
    --key ButtonsOnLeft \
    ""

kwriteconfig6 \
    --file kwinrc \
    --group org.kde.kdecoration2 \
    --key ButtonsOnRight \
    IAX

kwriteconfig6 \
    --file kwinrc \
    --group org.kde.kdecoration2 \
    --key ShowToolTips \
    true


# ------------------------------------------------------------
# KWIN EFFECTS
# ------------------------------------------------------------

echo "Configuring KWin effects..."

kwriteconfig6 \
    --file kwinrc \
    --group Plugins \
    --key blurEnabled \
    true

kwriteconfig6 \
    --file kwinrc \
    --group Plugins \
    --key contrastEnabled \
    true

kwriteconfig6 \
    --file kwinrc \
    --group Plugins \
    --key wobblywindowsEnabled \
    false

kwriteconfig6 \
    --file kwinrc \
    --group Plugins \
    --key magiclampEnabled \
    false


# ------------------------------------------------------------
# SYSTEM ICONS
# ------------------------------------------------------------

echo "Regenerating Klassy system icons..."

klassy-settings \
    --generate-system-icons; or die "Klassy system icon generation failed"


# ------------------------------------------------------------
# RELOAD
# ------------------------------------------------------------

echo "Reloading KWin..."

qdbus6 \
    org.kde.KWin \
    /KWin \
    reconfigure; or die "KWin reconfigure failed"

echo
echo "Crylia KDE settings applied."
echo "Preset: Crylia"
echo "KWin decoration: "(kreadconfig6 --file kwinrc --group org.kde.kdecoration2 --key library)
echo "Window radius: "(kreadconfig6 --file "$KLASSY_PRESETS" --group "$PRESET_GROUP" --key WindowCornerRadius)
echo "Backups: $BACKUP_DIR"
