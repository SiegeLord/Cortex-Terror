DC               := ldc2
INSTALL_PREFIX   := /usr/local
XFBUILD          := $(shell which xfbuild)
GAME_NAME        := main
GAME_FILES       := $(wildcard game/*.d) $(wildcard game/components/*.d)
ALLEGRO_LD_FLAGS := -L-ldallegro5 -L-lallegro -L-lallegro_image -L-lallegro_primitives
TANGO_LD_FLAGS   := -L-ltango -L-ldl
ENGINE_FILES     := $(wildcard engine/*.d)
ALL_FILES        := $(GAME_FILES) $(ENGINE_FILES)

LD_FLAGS         := $(ALLEGRO_LD_FLAGS) $(TANGO_LD_FLAGS)

ifeq ($(DC),ldc2)
    D_FLAGS          := -g -unittest -L-L. -d-version=DebugDisposable
else
    D_FLAGS          := -g -unittest -L-L. -version=DebugDisposable
endif

# Compiles a D program
# $1 - program name
# $2 - program files
ifeq ($(XFBUILD),)
    define d_build
        @$(DC) -of$1 -od".objs_$1" $(D_FLAGS) $(LD_FLAGS) $2
    endef
else
    define d_build
        @$(XFBUILD) +D=".deps_$1" +O=".objs_$1" +threads=6 +o$1 +c$(DC) +x$(DC) +xldc +xtango +xstd +xcore +xallegro5 $2 $(D_FLAGS) $(LD_FLAGS)
        @rm -f *.rsp
    endef
endif

.PHONY : all
all : $(GAME_NAME)

$(GAME_NAME) : $(ALL_FILES)
	$(call d_build,$(GAME_NAME),$(ALL_FILES))

.PHONY : clean
clean :
	@rm -f $(GAME_NAME) .deps*
	@rm -f *.moduleDeps
	@rm -rf .objs*
	@rm -f *.rsp
