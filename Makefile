start:
	rm -rf tmp/pids/server.pid
	bin/rails s -b 0.0.0.0

setup: install

install:
	npm install
	npm init @eslint/config
	yarn build
	yarn build:css
	bin/setup
	bin/rails db:migrate
	rake assets:precompile

db-prepare:
	bin/rails db:drop
	bin/rails db:migrate

check: test lint

test:
	RAILS_ENV=test bin/rails test

lint:
	bundle exec rubocop
	bundle exec slim-lint app/views/

lint-fix:
	bundle exec rubocop -A

.PHONY: test
