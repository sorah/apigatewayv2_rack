build:
	jsonnet template.jsonnet > template.json
	sam build

setup: build
	sam deploy --guided

deploy: build
	sam deploy
