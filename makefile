test:
	nvim \
		--headless \
		-u tests/init.lua \
		-c "PlenaryBustedDirectory tests/ { init = 'tests/init.lua' }"

test-watch:
	find tests -name '*.lua' | entr -c nvim \
		--headless \
		-u tests/init.lua \
		-c "PlenaryBustedDirectory tests/ { init = 'tests/init.lua' }"
