BUCKET_NAME = robsstaticsite-test
FILE_NAME = index.html
REGION = ap-southeast-2
BUCKET_POLICY=\
'{\
    "Version": "2012-10-17",\
    "Statement": [\
      {\
        "Sid": "PublicReadGetObject",\
        "Effect": "Allow",\
        "Principal": "*",\
        "Action": "s3:GetObject",\
        "Resource": "arn:aws:s3:::$(BUCKET_NAME)/$(FILE_NAME)"\
      }\
    ]\
  }'\

create-bucket:
	aws s3 mb s3://$(BUCKET_NAME)

upload-file:
	aws s3 cp $(FILE_NAME) s3://$(BUCKET_NAME)/

set-static-website:
	aws s3 website s3://$(BUCKET_NAME)/ --index-document $(FILE_NAME)

grant-public-read-access:
	aws s3api delete-public-access-block --bucket $(BUCKET_NAME)
	aws s3api put-bucket-policy --bucket $(BUCKET_NAME) --policy $(BUCKET_POLICY)

host-site: create-bucket upload-file set-static-website grant-public-read-access

delete-site:
	aws s3 rm s3://$(BUCKET_NAME)/ --recursive
	aws s3api delete-bucket --bucket $(BUCKET_NAME)

update-site:
	aws s3 cp $(FILE_NAME) s3://$(BUCKET_NAME)/

test-site:
	curl http://$(BUCKET_NAME).s3-website-$(REGION).amazonaws.com
