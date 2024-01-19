test:
	nvim \
		--headless \
		-u tests/init.lua \
		-c "PlenaryBustedDirectory tests/ { minimal_init = 'tests/init.lua' }"

test-watch:
	find tests -name '*.lua' | entr nvim \
		--headless \
		-u tests/init.lua \
		-c "PlenaryBustedDirectory tests/ { minimal_init = 'tests/init.lua' }"
