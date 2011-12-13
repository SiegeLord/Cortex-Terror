DC               := dmd
INSTALL_PREFIX   := /usr/local
XFBUILD          := $(shell which xfbuild)
GAME_NAME        := game
GAME_FILES       := main.d
ALLEGRO_LD_FLAGS := -L-ldallegro5 -L-lallegro -L-lallegro_image
TANGO_LD_FLAGS   := -L-ltango -L-ldl
ENGINE_FILES     := $(wildcard engine/*.d)
ALL_FILES        := $(GAME_FILES) $(ENGINE_FILES)

LD_FLAGS         := $(ALLEGRO_LD_FLAGS) $(TANGO_LD_FLAGS)
D_FLAGS          := -g -unittest -L-L.

# Compiles a D program
# $1 - program name
# $2 - program files
ifeq ($(XFBUILD),)
    define d_build
        $(DC) -of$1 -od".objs_$1" $(D_FLAGS) $(LD_FLAGS) $2
    endef
else
    define d_build
        $(XFBUILD) +D=".deps_$1" +O=".objs_$1" +threads=6 +o$1 +c$(DC) +x$(DC) +xtango +xstd +xcore $2 $(D_FLAGS) $(LD_FLAGS)
        rm -f *.rsp
    endef
endif

.PHONY : all
all : $(GAME_NAME)

$(GAME_NAME) : $(ALL_FILES)
	$(call d_build,$(GAME_NAME),$(ALL_FILES))

.PHONY : clean
clean :
	rm -f $(GAME_NAME) .deps*
	rm -f *.moduleDeps
	rm -rf .objs*
	rm -f *.rsp
