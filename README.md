# static-website 

This repo will create a static website using the contents of [index.html](index.html) by hosting it in a publicly accessible S3 bucket within AWS. These resources are deployed, updated, tested and delete through the use of [make](https://www.gnu.org/software/make/) 

# Prerequisites 

* [awscli](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html) 
* [make](https://www.gnu.org/software/make/) 
* An IAM User or Role with permissions to; 
    * Create S3 Buckets 
    * Create S3 Bucket Policies 
    * Write to S3 Buckets 

Ensure that your environment has been configured so that you can [use this IAM user or role with awscli](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-configure.html). 

# Implementation 

## Initial Deployment 

To deploy the static website, ensure the pre-requisites have been met and run `make host-site` 

## Updating the contents of the hosted website 

Once the website has been deployed, changes can be made to index.html and deployed with `make update-site`  

## Testing 

Run `make test-site` to print the index.html that is hosted on the bucket to the console. If successful, you should see the contents of index.html. 

## Cleaning up resources 

Run `make delete-site`  to delete the bucket and hosted index.html file 

# Improvements 

While hosting a static site with S3 is a very quick way to set up an internet-accesible webpage, it is by no means the ideal solution. There are many improvements that will need to be made if the site is to be used for anything other than testing purposes.  

## HTTPS 

Currently, this solution does not use SSL/TLS to encrypt the traffic going to and from the website. Unfortunately, [AWS does not offer this feature with S3](https://docs.aws.amazon.com/AmazonS3/latest/userguide/HostingWebsiteOnS3Setup.html#step7-test-web-site) and you have to host the static site with CloudFront if you want HTTPS on the endpoint and are determined to go with AWS.  

## CI/CD 

I set up a Makefile for this as I thought it was a nice middle ground between a singular bash script that would be hard to change and a deployment process using GitHub Actions that would be too complex for the task at hand (this repository is currently hosted using Github so Actions seems like a natural choice but any build tool could be used here.). Of course, if frequent changes were going to be made to the site, the next step would be to set up a build pipeline with associated service accounts to;

* Validate that the html is valid upon raising a PR
* Deploy the changed html to the bucket upon merging

This would make the application more robust, maintainable and easier to work with.

## IaC 
This solution uses cli commands to build the infrastructure. While more amintainable than manually clicking on the console, Infrastructure-as-Code should be used to formalize and track what is actually being deployed. For mine, Terraform would be the preferred option as the [testing](https://developer.hashicorp.com/terraform/tutorials/configuration-language/test) and [custom condition](https://developer.hashicorp.com/terraform/tutorials/configuration-language/custom-conditions) features allow for your build pipelines to validate your changes before they are deployed. CloudFormation would also make a acceptable choice if you wanted to stick to AWS-native products. Finally, if you had a larger codebase you wanted to sync with, you could use [Pulumi](https://github.com/pulumi/pulumi)

## DNS 

To access the static site, you must vist `http://$(BUCKET_NAME).s3-website-$(REGION).amazonaws.com`. This is a pretty ugly domain name and should be changed to something more readable using Route53 or CloudDNS depending on the cloud provider.  

## CDN 

S3 buckets are regional so the performance of the static site will be dependent on where you are accessing the site from. If this is a big issue, you could host the static site with a CDN 

## Logging 
This solution does not have any logging on the site. To enable this, a logging bucket needs to be added with the bucket containing the static site pushing it's logs there. 

# Alternative Solutions 

Of course, this is not the only solution, just the solution that I thought was the simplest that met all of the requirements. Other managed services could be used across AWS and GCP and can be found below, along with the reasoning as to why they were not used.  

## GCP Cloud Storage 

Almost identical to the solution, you could use [Google Cloud Storage to host the static site](https://cloud.google.com/storage/docs/hosting-static-website-http). Not many huge differences between the two but if your organisation uses GCP, this would be the option that you would pick.

## AWS CloudFront 

Fairly similar to using S3 but this hosts the site within Amazons CDN. Obviously, this would improve the performance of the website but would also be more expensive given that you are replicating the data to multiple places. A little more complex than the S3 solution and a good first improvement. 

## Google Firebase 

Firebase provides a nice way to set up static sites and have them propagated to Googles CDN and be encrypted with HTTPS. While a great option for static sites with more complexity than this one, the overhead of setting up firebase projects and deployment methods is too large for this use case. That being said, Firebases free tier is pretty generous and a great option for developers if they want to productionize more complex static sites. 

## AWS Amplify 

AWS Amplify is a managed product/platform that can host static websites by pulling the contents from a connected Git repository. This solution was not chosen as connecting the Git repository would have to be done through the console (too manual) or through some form of Infrastructure as Code. Setting up this pipeline was deemed to be too complex/manual of a task, especially when the requirements are for a publicly accessible static site, not the full stack web or mobile application that AWS Amplify is designed for.  

## Amazon Lightsail 

AWS managed service where you can use pre-built images to create fairly standard applications. It's designed to be a simpler version of EC2. My thought was that I could host a nginx container here as a webserver for the static content but this would be an extremely complex way of meeting the requirements. Furthermore, the solution would be more expensive than hosting within S3 without any real improvement in its capabilities.

# Productionizing For A Larger Organization

## Proposed Solution

To productionise this solution, we can use AWS CloudFront with a custom domain registered using Route53. Lucky for us, this is a well-trodden path with AWS providing a tutorial on [how to configure a static website using a custom domain registered with Route 53](https://docs.aws.amazon.com/AmazonS3/latest/userguide/website-hosting-custom-domain-walkthrough.html) as well as a tutorial on setting up [AWS CloudFront for the S3 bucket configured](https://docs.aws.amazon.com/AmazonS3/latest/userguide/website-hosting-cloudfront-walkthrough.html) in the previous tutorial.

This will give us;

* S3 buckets for both a top-level domain and a subdomain, allowing us to easily expand our website in the future
* Pretty domain/subdomain names using Route53, allowing our users to identify our brands more easily
* Logging through CloudFront for analytics and audit to better understand the behaviour of our users
* HTTPS through CloudFront, allowing our users browsers to trust our websites

## Organisational Design

However, as organisations grow and teams become more specialised, it is unlikely that a single individual/team would be responsible for all of the different components listed above. 

* Network Team - Responsible for provisioning the certificates to set up DNS. This is especially important if the organisation is large enough to require centralised certificate and domain management.
* Infrastructure Team - Responsible for setting up and maintaining the AWS account as well as providing the IaC modules to deploy the S3 bucket, AWS CloudFront configuration and aliasing through Route 53. This will allow for a consistent way of constructing static sites across teams.
* Developer Experience Team - Responsible for developing and maintaining the build pipelines for both the Application, Network and Infrastructure teams. These build pipelines will allow for a unified way of deploying IaC modules and uploading new html content to the buckets created by the IaC modules.
* Application Team - Responsible for the content of the static site itself. Will only need be able to make changes to their static site through a repository that they own by using the build pipelines provided by the DevEx team

Depending on the size of the organisation, there may be some overlap in the responsibilities of the Network, Infrastructure and DevEx teams. Ultimately, the goal of the organisational design is to have a consistent framework for creating, deploying and maintaining static websites, allowing each of the teams to act independently. If there was a template for a Git repository that included;

1. The build pipeline for constructing the IaC module created by the Infrastructure Team (using the certificates and DNS provided by the Network Team)
2. The build pipeline for deploying and validating the html files
3. A standardised directory structure for the html files
The Application teams would be able to create static websites at scale.

