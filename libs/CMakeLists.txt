cmake_minimum_required(VERSION 3.10)
project(api LANGUAGES CXX C)

set (CMAKE_CXX_STANDARD 11)
add_definitions(-fPIC)
add_definitions(-DHAVE_CONFIG_H=1)
add_definitions(-DPDCURSES=1)

add_library(rogue
  SHARED
  ./PDCurses-3.4/pdcurses/addch.c
  ./PDCurses-3.4/pdcurses/addchstr.c
  ./PDCurses-3.4/pdcurses/addstr.c
  ./PDCurses-3.4/pdcurses/attr.c
  ./PDCurses-3.4/pdcurses/beep.c
  ./PDCurses-3.4/pdcurses/bkgd.c
  ./PDCurses-3.4/pdcurses/border.c
  ./PDCurses-3.4/pdcurses/clear.c
  ./PDCurses-3.4/pdcurses/color.c
  ./PDCurses-3.4/pdcurses/debug.c
  ./PDCurses-3.4/pdcurses/delch.c
  ./PDCurses-3.4/pdcurses/deleteln.c
  ./PDCurses-3.4/pdcurses/deprec.c
  ./PDCurses-3.4/pdcurses/getch.c
  ./PDCurses-3.4/pdcurses/getstr.c
  ./PDCurses-3.4/pdcurses/getyx.c
  ./PDCurses-3.4/pdcurses/inch.c
  ./PDCurses-3.4/pdcurses/inchstr.c
  ./PDCurses-3.4/pdcurses/initscr.c
  ./PDCurses-3.4/pdcurses/inopts.c
  ./PDCurses-3.4/pdcurses/insch.c
  ./PDCurses-3.4/pdcurses/insstr.c
  ./PDCurses-3.4/pdcurses/instr.c
  ./PDCurses-3.4/pdcurses/kernel.c
  ./PDCurses-3.4/pdcurses/keyname.c
  ./PDCurses-3.4/pdcurses/mouse.c
  ./PDCurses-3.4/pdcurses/move.c
  ./PDCurses-3.4/pdcurses/outopts.c
  ./PDCurses-3.4/pdcurses/overlay.c
  ./PDCurses-3.4/pdcurses/pad.c
  ./PDCurses-3.4/pdcurses/panel.c
  ./PDCurses-3.4/pdcurses/printw.c
  ./PDCurses-3.4/pdcurses/refresh.c
  ./PDCurses-3.4/pdcurses/scanw.c
  ./PDCurses-3.4/pdcurses/scr_dump.c
  ./PDCurses-3.4/pdcurses/scroll.c
  ./PDCurses-3.4/pdcurses/slk.c
  ./PDCurses-3.4/pdcurses/termattr.c
  ./PDCurses-3.4/pdcurses/terminfo.c
  ./PDCurses-3.4/pdcurses/touch.c
  ./PDCurses-3.4/pdcurses/util.c
  ./PDCurses-3.4/pdcurses/window.c
  ./PDCurses-3.4/impl/pdc_impl.c
  ./rogue-5.4/armor.c
  ./rogue-5.4/chase.c
  ./rogue-5.4/command.c
  ./rogue-5.4/config.h
  ./rogue-5.4/daemon.c
  ./rogue-5.4/daemons.c
  ./rogue-5.4/extern.c
  ./rogue-5.4/extern.h
  ./rogue-5.4/fight.c
  #./rogue-5.4/findpw.c
  ./rogue-5.4/init.c
  ./rogue-5.4/io.c
  ./rogue-5.4/LICENSE.TXT
  ./rogue-5.4/list.c
  ./rogue-5.4/mach_dep.c
  ./rogue-5.4/mdport.c
  ./rogue-5.4/misc.c
  ./rogue-5.4/monsters.c
  ./rogue-5.4/new_level.c
  ./rogue-5.4/options.c
  ./rogue-5.4/pack.c
  ./rogue-5.4/passages.c
  ./rogue-5.4/potions.c
  ./rogue-5.4/rings.c
  ./rogue-5.4/rip.c
  ./rogue-5.4/rogue.h
  ./rogue-5.4/rogue_main.c
  ./rogue-5.4/rogue_move.c
  ./rogue-5.4/rooms.c
  ./rogue-5.4/save.c
  #./rogue-5.4/scedit.c
  #./rogue-5.4/scmisc.c
  ./rogue-5.4/score.h
  ./rogue-5.4/scrolls.c
  ./rogue-5.4/state.c
  ./rogue-5.4/sticks.c
  ./rogue-5.4/things.c
  ./rogue-5.4/vers.c
  ./rogue-5.4/weapons.c
  ./rogue-5.4/wizard.c
  ./rogue-5.4/xcrypt.c
)

target_include_directories(rogue 
    PRIVATE
    ./PDCurses-3.4/impl
    ./PDCurses-3.4/
    ./rogue-5.4/
)


add_library(api
  SHARED
  ./api.cpp
  exports.def
)

target_include_directories(api 
    PRIVATE
    ./PDCurses-3.4/
    ./PDCurses-3.4/impl
    ./rogue-5.4/
)

target_link_libraries(api PRIVATE rogue)
