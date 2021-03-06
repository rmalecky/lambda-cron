cfn_stack   = LambdaCron
template    = template.cfn.yml
code_bucket = lambda-cron-rmalecky
cur-dir     = $(shell pwd)
timestamp   = $(shell date +%s)


update-stack:
	aws cloudformation update-stack --stack-name $(cfn_stack) \
				--template-body file://$(template) \
				--parameters ParameterKey=CodeS3Key,UsePreviousValue=true \
				--capabilities CAPABILITY_IAM

list:
	aws cloudformation list-stack-resources --stack-name $(cfn_stack)

events:
	aws cloudformation describe-stack-events --stack-name $(cfn_stack)

delete-stack:
	aws cloudformation delete-stack --stack-name $(cfn_stack)

validate:
	aws cloudformation validate-template --template-body file://$(template)

summary:
	aws cloudformation get-template-summary --stack-name $(cfn_stack)

update-code:
	rm -f code.zip
	cd $(VIRTUAL_ENV)/lib/python2.7/site-packages; \
	zip -r $(cur-dir)/code.zip .
	zip code.zip main.py
	aws s3 cp code.zip s3://$(code_bucket)/code$(timestamp).zip
	aws cloudformation update-stack --stack-name $(cfn_stack) \
				--template-body file://$(template) \
				--parameters ParameterKey=CodeS3Key,ParameterValue=code$(timestamp).zip \
				--capabilities CAPABILITY_IAM
