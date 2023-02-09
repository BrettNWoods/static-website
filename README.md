# static-website 

This repo will set up a static website using the contents of (index.html)[] by hosting it in a publicly accessible S3 bucket within AWS. These resources are deployed, updated, tested and delete through the use of [make](https://www.gnu.org/software/make/) 
 

# Prerequisites 

* [awscli)](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html) 
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

Currently, this solution does not use SSL/TLS to encrypt the traffic going to and from the website. Unfortunately, AWS does not offer this feature with S3 and you have to host the static site with CloudFront if you want HTTPS on the endpoint and are determined to go with AWS.  

## CI/CD 

I set up a Makefile for this as I thought it was a nice middle ground between a singular bash script that would be hard to change and a deployment process using GitHub Actions that would be too complex for the task at hand. Of course, if frequent changes were going to be made to the site, the next step would be to set up the GitHub Actions pipeline with associated service accounts so that it could change the contents of the static site. 

## IaC 

This solution uses cli commands to build the infrastructure. While better than going and just clicking on the console, either CloudFormation or Terraform could be used to formalize and track what is actually being deployed. As I decided to go with AWS, CloudFormation is probably the preferred improvement as you don't have to do all of the work setting up the Terraform statefile, buckets and permissions. That being said, if this static site is being deployed in an environment that already has Terraform in it, use Terraform  

## DNS 

To access the static site, you must vist `http://$(BUCKET_NAME).s3-website-$(REGION).amazonaws.com`. This is a pretty ugly domain name and should be changed to something more readable using Route53 or CloudDNS depending on the cloud provider.  

## CDN 

S3 buckets are regional so the performance of the static site will be dependent on where you are accessing the site from. If this is a big issue, you could host the static site with a CDN 

## Logging 
This solution does not have any logging on the site. To enable this, a logging bucket needs to be added with the bucket containing the static site pushing it's logs there. 

# Alternative Solutions 

Of course, this is not the only solution, just the solution that I thought was the simplest that met all of the requirements. Other managed services could be used across AWS and GCP and can be found below, along with the reasoning as to why they were not used.  

## GCP Cloud Storage 

Almost identical to this solution but to make objects stored in GCP Cloud Storage a publicly accessible site, I believe a load balancer would need to be set up to route the traffic to the storage. While this would make it easier to add DNS records and HTTPS to the solution, these improvements are not explicit requirements and are out of scope. 

## AWS CloudFront 

Fairly similar to using S3 but this hosts the site within Amazons CDN. Obviously, this would improve the performance of the website but would also be more expensive given that you are replicating the data to multiple places. A little more complex than the S3 solution but not a terrible idea. 

## Google Firebase 

Firebase provides a nice way to set up static sites and have them propagated to Googles CDN and be encrypted with HTTPS. While a great option for static sites with more complexity than this one, the overhead of setting up firebase projects and deployment methods is too large for this use case. That being said, Firebases free tier is pretty generous and a great option for developers if they want to productionize more complex static sites. 

## AWS Amplify 

AWS Amplify is a product that can host static websites by pulling the contents from a connected Git repository. This solution was not chosen as connecting the Git repository would have to be done through the console (too manual) or through some form of Infrastructure as Code. Setting up this pipeline was deemed to be too complex/manual of a task, especially when the requirements are for a publicly accessible static site, not a fully formed deployment pipeline.  

## Amazon Lightsail 

AWS managed service where you can use pre-built images to create fairly standard applications. It's designed to be a simpler version of EC2. My thought was that I could host a nginx container here as a webserver for the static content but this would be an extremely complex way of meeting the requirements. Furthermore, the solution would be more expensive than hosting within S3 without any real improvement in its capabilities. 