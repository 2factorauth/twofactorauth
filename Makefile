.PHONY : help
help: # Display help
	@awk -F ':|##' \
		'/^[^\t].+?:.*?##/ {\
			printf "\033[36m%-30s\033[0m %s\n", $$1, $$NF \
		}' $(MAKEFILE_LIST)

.PHONY : all
all : stop run ## all the things

.PHONY : run
run : ## run containers
	@docker-compose up -d

.PHONY : stop
stop : ## stop containers
	@docker-compose down
