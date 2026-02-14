	# Makefile

.PHONY: init format analyze build clean env pubget test build-function deploy-function-dev deploy-function-prod

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

create_feature:
	@bash scripts/create_feature.sh $(name)

generate_dev_apk:
	flutter build apk --debug --flavor dev -t lib/main_dev.dart

generate_prod_appbundle:
	flutter build appbundle --release --flavor prod -t lib/main.dart

generate_launcher_icon:
	flutter pub run flutter_launcher_icons

build-function:
	cd functions && npm run build

# dev 環境に Functions を deploy
deploy-function-dev: build-function
	firebase deploy --only functions --project dev

# prod 環境に Functions を deploy（※注意）
deploy-function-prod: build-function
	firebase deploy --only functions --project prod
