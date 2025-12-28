	# Makefile

.PHONY: init format analyze build clean env pubget test

init: env pubget build

pubget:
	bash scripts/pubget.sh

format:
	bash scripts/format.sh

analyze:
	bash scripts/analyze.sh

build:
	bash scripts/build_runner.sh

test:
	bash scripts/flutter_test.sh

clean:
	bash scripts/clean.sh

env:
	bash scripts/prepare_env.sh

create-feature:
	@bash scripts/create_feature.sh $(name)
