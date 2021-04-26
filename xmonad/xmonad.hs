--  __    _
-- |  \  | | Dem Nikos seine config
-- |   \ | | xmonad
-- | |\ \| | Based on standard config from Haskell Wiki
-- |_| \___| Communism will win

import XMonad
import XMonad.Layout.Fullscreen
    ( fullscreenEventHook, fullscreenManageHook, fullscreenSupport, fullscreenFull )
import Data.Monoid ()
import System.Exit ()
import XMonad.Util.SpawnOnce ( spawnOnce )
import Graphics.X11.ExtraTypes.XF86 (xF86XK_AudioLowerVolume, xF86XK_AudioRaiseVolume, xF86XK_AudioMute, xF86XK_MonBrightnessDown, xF86XK_MonBrightnessUp, xF86XK_AudioPlay, xF86XK_AudioPrev, xF86XK_AudioNext)
import XMonad.Hooks.EwmhDesktops ( ewmh )
import Control.Monad ( join, when )
import XMonad.Layout.NoBorders
import XMonad.Hooks.ManageDocks
    ( avoidStruts, docks, manageDocks, Direction2D(D, L, R, U) )
import XMonad.Hooks.ManageHelpers ( doFullFloat, isFullscreen )
import XMonad.Layout.Spacing ( spacingRaw, Border(Border) )
import XMonad.Layout.Gaps
    ( Direction2D(D, L, R, U),
      gaps,
      setGaps,
      GapMessage(DecGap, ToggleGaps, IncGap) )

import qualified XMonad.StackSet as W
import qualified Data.Map        as M
import Data.Maybe (maybeToList)
import XMonad.Layout.MultiColumns
import XMonad.Config.Desktop
import XMonad.Actions.CycleWS

-- Default Applications
myBrowser :: String
myBrowser = "brave"

myTerminal :: String
myTerminal = "termite"

myFileManager :: String
myFileManager = "spacefm"

-- Whether focus follows the mouse pointer.
myFocusFollowsMouse :: Bool
myFocusFollowsMouse = False

-- Whether clicking on a window to focus also passes the click to the window
myClickJustFocuses :: Bool
myClickJustFocuses = True

-- Width of the window border in pixels.

myBorderWidth   = 1


--Set modmask to Super key

myModMask       = mod4Mask

-- Make Alt-key usable

altMask :: KeyMask
altMask = mod1Mask 

--Setting up workspaces

myWorkspaces    = ["www", "mail", "file", "chat", "doc", "med", "vbox", "dev", "misc"]


-- Load BaseConfig

myBaseConfig = desktopConfig

-- Border colors for unfocused and focused windows, respectively.

myNormalBorderColor  = "#dddddd"
myFocusedBorderColor = "#ff0000"

addNETSupported :: Atom -> X ()
addNETSupported x   = withDisplay $ \dpy -> do
    r               <- asks theRoot
    a_NET_SUPPORTED <- getAtom "_NET_SUPPORTED"
    a               <- getAtom "ATOM"
    liftIO $ do
       sup <- (join . maybeToList) <$> getWindowProperty32 dpy a_NET_SUPPORTED r
       when (fromIntegral x `notElem` sup) $
         changeProperty32 dpy r a_NET_SUPPORTED a propModeAppend [fromIntegral x]

addEWMHFullscreen :: X ()
addEWMHFullscreen   = do
    wms <- getAtom "_NET_WM_STATE"
    wfs <- getAtom "_NET_WM_STATE_FULLSCREEN"
    mapM_ addNETSupported [wms, wfs]

------------------------------------------------------------------------
-- Key bindings. Add, modify or remove key bindings here.

myKeys conf@(XConfig {XMonad.modMask = modm}) = M.fromList $

    -- ###BASICS
    -- ##basic functionality
    [ ((modm, xK_t), spawn $ (myTerminal ++ " -e fish"))
    , ((modm,               xK_r     ), spawn "dmenu_run -i -nb '#191919' -nf '#fea63c' -sb '#fea63c' -sf '#191919' -fn 'NotoMonoRegular:bold:pixelsize=14'")
    , ((modm .|. shiftMask, xK_q     ), spawn "arcolinux-logout")
    , ((modm .|. controlMask, xK_q     ), spawn "xmonad --recompile; xmonad --restart")
    , ((modm, xK_q     ), kill)
    , ((modm,                 xK_space ), spawn "albert toggle")
    
    -- ##Function Keys
    --audiokeys
    , ((0, xF86XK_AudioRaiseVolume), spawn "pactl set-sink-volume 0 +5%")
    , ((0, xF86XK_AudioLowerVolume), spawn "pactl set-sink-volume 0 -5%")
    , ((0, xF86XK_AudioMute), spawn "pactl set-sink-mute 0 toggle")    
    , ((0, xF86XK_AudioPlay), spawn "playerctl play-pause")
    , ((0, xF86XK_AudioNext), spawn "playerctl next")
    , ((0, xF86XK_AudioPrev), spawn "playerctl previous")
    -- Brightness keys
    , ((0,                    xF86XK_MonBrightnessUp), spawn "brightnessctl s +10%")
    , ((0,                    xF86XK_MonBrightnessDown), spawn "brightnessctl s 10-%")

    -- Navigation
    -- Move focus to the next window
    , ((modm,               xK_l     ), windows W.focusDown)
    -- Move focus to the previous window
    , ((modm,               xK_h     ), windows W.focusUp  )
    -- Cycle Workspaces
    , ((modm,               xK_k),  nextWS)
    , ((modm,               xK_j),    prevWS)
    
    -- Swap the focused window with the next window
    , ((modm .|. shiftMask, xK_l     ), windows W.swapDown  )
    -- Swap the focused window with the previous window
    , ((modm .|. shiftMask, xK_h     ), windows W.swapUp    )
    -- Shift Windows through workspaces
    , ((modm .|. shiftMask, xK_k),  shiftToNext >> nextWS)
    , ((modm .|. shiftMask, xK_j),    shiftToPrev >> prevWS)
    
    -- Rotate through the available layout algorithms
    , ((modm .|. controlMask,              xK_space ), sendMessage NextLayout)
    -- Resize viewed windows to the correct size
    , ((modm,               xK_n     ), refresh)

    -- Shrink the master area
    , ((modm .|. controlMask,               xK_h     ), sendMessage Shrink)
    -- Expand the master area
    , ((modm .|. controlMask,               xK_l     ), sendMessage Expand)

    -- ###LAUNCH Applications
    -- launch browser
    , ((modm,                 xK_g     ), spawn myBrowser)
    
    -- launch thunderbird
    , ((modm,                 xK_u     ), spawn "thunderbird")
    
    -- launch files within gui
    , ((modm,                 xK_f     ), spawn myFileManager)

    -- launch files within cli
    , ((modm .|. controlMask, xK_f     ), spawn (myTerminal ++ " -e vifm"))
    
    -- launch spotify
    , ((modm,                 xK_m     ), spawn "spotify")
    
    -- launch keepass
    , ((modm,                 xK_x     ), spawn "keepassxc")
    
     -- launch pamac
    , ((modm .|. controlMask, xK_u     ), spawn "pamac-manager")

     -- launch obsidian
    , ((modm                , xK_b     ), spawn "md.obsidian.Obsidian")
    
    -- launch notepadqq
    , ((modm .|. altMask, xK_a     ), spawn "notepadqq")

    -- launch CCCPmacs
    , ((modm                , xK_a     ), spawn "emacs")

    -- launch vim
    , ((modm .|. controlMask, xK_a     ), spawn (myTerminal ++ " -e vim"))

    -- launch telegram
    , ((modm,                 xK_e     ), spawn "telegram-desktop")
    
    -- launch taskmanager
    , ((modm .|. controlMask, xK_t     ), spawn "xfce4-taskmanager")

    -- launch WhatsApp
    , ((modm                , xK_w     ), spawn (myBrowser ++ " --profile-directory=Default --app-id=hnpfjngllnobngcgfapefoaidbinmjnm"))

    -- launch LibreOffice
    , ((modm                , xK_o     ), spawn "libreoffice")

    -- launch LibreOffice Writer
    , ((modm                , xK_s     ), spawn "lowriter")

    -- launch Discord
    , ((modm                , xK_i    ), spawn "discord")
    
    -- launch signal
    , ((modm                , xK_n    ), spawn "signal-desktop")

    -- launch zoom
    , ((modm                , xK_z    ), spawn "zoom")

    -- launch SimpleScan
    , ((modm                , xK_d    ), spawn "simple-scan")

    -- launch GenkiArcade
    , ((modm .|. controlMask, xK_e    ), spawn (myBrowser ++ " --profile-directory=Default --app-id=apmgkabhjdajndnmdcbiiaadmfmomlki"))

    -- launch Pocket
    , ((modm                , xK_p    ), spawn (myBrowser ++ " --profile-directory=Default --app-id=kfpojikjhmgaokldhmplmgmcoomikeek"))

    -- launch Calculator
    , ((modm                , xK_c    ), spawn "galculator")
    
    -- launch PulseAudioControl
    , ((modm .|. controlMask, xK_m     ), spawn "pavucontrol")
    
    -- launch wifimanager
    , ((modm .|. controlMask, xK_w     ), spawn (myTerminal ++ "-e network-manager.nmtui-connect"))
    
    -- launch blueberry
    , ((modm .|. controlMask, xK_b     ), spawn "blueberry")

    -- launch ToDo
    , ((modm .|. controlMask, xK_d     ), spawn (myBrowser ++ " --profile-directory=Default --app-id=jlhoajbaojeilbdnlldgecmilgppanbh"))

    -- launch vlc
    , ((modm,                 xK_v     ), spawn "vlc")

    -- make a screenshot
    , ((0,                  xK_Print), spawn "flameshot gui")
    , ((shiftMask,          xK_Print), spawn "flameshot full -c -p ~/Bilder/Screenshots")
    
    -- ###JOIN Online Meetings

    -- ###Travel:
    -- Wifi on ICE
    , ((modm .|. altMask, xK_i    ), spawn "brave http://wifionice.de/de/")
    ]
    ++


    -- mod-[1..9], Switch to workspace N
    -- mod-shift-[1..9], Move client to workspace N

    [((m .|. modm, k), windows $ f i)
        | (i, k) <- zip (XMonad.workspaces conf) [xK_1 .. xK_9]
        , (f, m) <- [(W.greedyView, 0), (W.shift, shiftMask)]]


------------------------------------------------------------------------
-- Mouse bindings: default actions bound to mouse events
--
myMouseBindings (XConfig {XMonad.modMask = modm}) = M.fromList $

    -- mod-button1, Set the window to floating mode and move by dragging
    [ ((modm, button1), (\w -> focus w >> mouseMoveWindow w
                                       >> windows W.shiftMaster))

    -- mod-button2, Raise the window to the top of the stack
    , ((modm, button2), (\w -> focus w >> windows W.shiftMaster))

    -- mod-button3, Set the window to floating mode and resize by dragging
    , ((modm, button3), (\w -> focus w >> mouseResizeWindow w
                                       >> windows W.shiftMaster))

    -- you may also bind events to the mouse scroll wheel (button4 and button5)
    ]

------------------------------------------------------------------------
-- Layouts:

myLayout = mc ||| tiled ||| Full
  where
     -- default tiling algorithm
     mc = multiCol [1] 1 0.01 (-0.5)
     
     --Definition of tiled     
     tiled   = Tall nmaster delta ratio

     -- The default number of windows in the master pane
     nmaster = 1

     -- Default proportion of screen occupied by master pane
     ratio   = 1/2

     -- Percent of screen to increment by when resizing panes
     delta   = 3/100

------------------------------------------------------------------------
-- Window rules:

--
myManageHook = fullscreenManageHook <+> manageDocks <+> composeAll
    [ className =? "MPlayer"        --> doFloat
    , className =? "Gimp"           --> doFloat
    , className =? "galculator"     --> doFloat
    , resource  =? "desktop_window" --> doIgnore
    , resource  =? "kdesktop"       --> doIgnore
    , isFullscreen --> doFullFloat
                                 ]

------------------------------------------------------------------------
-- Event handling
--
myEventHook = mempty


------------------------------------------------------------------------
-- Status bars and logging

myLogHook = return ()

------------------------------------------------------------------------
-- Startup hook

myStartupHook = do
  spawnOnce "xlayoutdisplay -d 108"
  spawnOnce "polybar mainbar-xmonad" 
  spawn "xsetroot -cursor_name left_ptr"
  spawn "exec ~/bin/lock.sh"
  spawnOnce "nitrogen --restore"
  spawnOnce "picom -f"
  spawnOnce "dunst"
  spawnOnce "albert"
  spawnOnce "nextcloud"
  spawnOnce "dropbox"
  spawnOnce "exec /usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1"
  spawnOnce "copyq"
  spawnOnce "exec ~/.xmonad/scripts/disable_screenoff.sh"
  spawnOnce "flameshot"

------------------------------------------------------------------------
-- Now run xmonad with all the defaults we set up.

-- Run xmonad with the settings you specify. No need to modify this.

main = xmonad $ fullscreenSupport $ docks $ ewmh defaults

defaults = def {
      -- simple stuff
        terminal           = myTerminal,
        focusFollowsMouse  = myFocusFollowsMouse,
        clickJustFocuses   = myClickJustFocuses,
        borderWidth        = myBorderWidth,
        modMask            = myModMask,
        workspaces         = myWorkspaces,
        normalBorderColor  = myNormalBorderColor,
        focusedBorderColor = myFocusedBorderColor,

      -- key bindings
        keys               = myKeys,
        mouseBindings      = myMouseBindings,

      -- hooks, layouts
        manageHook = myManageHook, 
        layoutHook = gaps [(U,35), (D,5), (R,5), (L,5)] $ myLayout ||| layoutHook myBaseConfig,
        handleEventHook    = myEventHook,
        logHook            = myLogHook,
        startupHook        = myStartupHook >> addEWMHFullscreen
    }

-- | Finally, a copy of the default bindings in simple textual tabular format.
help :: String
help = unlines ["The default modifier key is 'super'. Default keybindings:",
    "",
    "-- launching and killing programs",
    "mod-Shift-Enter  Launch xterminal",
    "mod-p            Launch dmenu",
    "mod-Shift-p      Launch gmrun",
    "mod-Shift-c      Close/kill the focused window",
    "mod-Space        Rotate through the available layout algorithms",
    "mod-Shift-Space  Reset the layouts on the current workSpace to default",
    "mod-n            Resize/refresh viewed windows to the correct size",
    "",
    "-- move focus up or down the window stack",
    "mod-Tab        Move focus to the next window",
    "mod-Shift-Tab  Move focus to the previous window",
    "mod-j          Move focus to the next window",
    "mod-k          Move focus to the previous window",
    "mod-m          Move focus to the master window",
    "",
    "-- modifying the window order",
    "mod-Return   Swap the focused window and the master window",
    "mod-Shift-j  Swap the focused window with the next window",
    "mod-Shift-k  Swap the focused window with the previous window",
    "",
    "-- resizing the master/slave ratio",
    "mod-h  Shrink the master area",
    "mod-l  Expand the master area",
    "",
    "-- floating layer support",
    "mod-t  Push window back into tiling; unfloat and re-tile it",
    "",
    "-- increase or decrease number of windows in the master area",
    "mod-comma  (mod-,)   Increment the number of windows in the master area",
    "mod-period (mod-.)   Deincrement the number of windows in the master area",
    "",
    "-- quit, or restart",
    "mod-Shift-q  Quit xmonad",
    "mod-q        Restart xmonad",
    "mod-[1..9]   Switch to workSpace N",
    "",
    "-- Workspaces & screens",
    "mod-Shift-[1..9]   Move client to workspace N",
    "mod-{w,e,r}        Switch to physical/Xinerama screens 1, 2, or 3",
    "mod-Shift-{w,e,r}  Move client to screen 1, 2, or 3",
    "",
    "-- Mouse bindings: default actions bound to mouse events",
    "mod-button1  Set the window to floating mode and move by dragging",
    "mod-button2  Raise the window to the top of the stack",
    "mod-button3  Set the window to floating mode and resize by dragging"]
