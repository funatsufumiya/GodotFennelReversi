FNLS := $(wildcard src/*.fnl)
LUA := $(FNLS:.fnl=.lua)

.PHONY: all
all: $(LUA)

src/%.lua: src/%.fnl
	fennel --compile $< > $@