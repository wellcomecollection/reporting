test:
	echo "Tests needed"
	exit 1
	
install:
	docker run -v $(shell pwd)/$(name):/src -w /src wellcome/python3 pip install -r requirements.txt --no-deps -t python

zip:
	pushd $(name) && zip -r $(name).zip ./*.py ./python && popd

deploy:
	aws s3 --profile reporting-dev cp ./$(name)/$(name).zip s3://wellcomecollection-reporting-lambdas/
