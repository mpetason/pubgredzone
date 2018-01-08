SHELL := /bin/bash
REV_FILE=.make-rev-check

set-rev:
	git rev-parse --short HEAD > $(REV_FILE)

images: set-rev
	./make-image.sh app.Dockerfile "rotisserie-app:$$(cat $(REV_FILE))"
	./make-image.sh ocr.Dockerfile "rotisserie-ocr:$$(cat $(REV_FILE))"
	./make-image.sh static-server.Dockerfile "rotisserie-static:$$(cat $(REV_FILE))"

tag-images: set-rev
	sudo docker tag "rotisserie-app:$$(cat $(REV_FILE))" "$$docker_username/rotisserie-app:$$(cat $(REV_FILE))"
	sudo docker tag "rotisserie-ocr:$$(cat $(REV_FILE))" "$$docker_username/rotisserie-ocr:$$(cat $(REV_FILE))"
	sudo docker tag "rotisserie-static:$$(cat $(REV_FILE))" "$$docker_username/rotisserie-static:$$(cat $(REV_FILE))"

upload-images: set-rev
	sudo docker push "$$docker_username/rotisserie-app:$$(cat $(REV_FILE))"
	sudo docker push "$$docker_username/rotisserie-ocr:$$(cat $(REV_FILE))"
	sudo docker push "$$docker_username/rotisserie-static:$$(cat $(REV_FILE))"

.PHONY: deploy
deploy: set-rev
	IMAGE_TAG=$$(cat $(REV_FILE)) envsubst < deploy/rotisserie.yaml | kubectl apply -f -

delete-deployments:
	kubectl delete deployment rotisserie-app
	kubectl delete deployment rotisserie-ocr

redeploy: delete-deployments deploy

roll: set-rev images tag-images upload-images deploy
