<h1 align="center">Engineering Project</h1> 



<p> I was recently tasked with a project to do the following: <strong>Use the cloud provider of your choice, provision a production ready environment to host this Single Page Application (https://github.com/brandiqa/single-page-application). This should be horizontally scalable. New updates to the project should be able to be deployed in an automated fashion. Use Terraform or the IaC language of your choosing to manage as many resources as you can. Publish your code along with any other relevant configuration when you are done.</strong>
<br>
<br>
I set to work outlining my needs and work through the process to complete the task:
<br>
<ol>

1. Get the app built and make sure it is running

2. Work out the best solution to host the app

3. Keep it simple and automate the task at hand

4. Destroy and Rebuild to make sure its repeatable
</p>
<br>
<br>
<br>
<h2 align="center">Get The App Built And Make Sure It Is Running</h2>
<br>
<br>
<p>Starting out with the app I was tasked with 2 choices: clone the app, add my api keys, and just start it up or go step by step to fully understand what is going on in the app.  Throughout my entire testing process I would actually employ both choices, but I opted to build the app from the scratch to make sure I fully understood any errors that came up and boy did I have errors</p>
<br>
<br>
<p>My first run through the building the app I was thankful I was given an opportunity to test my API functions through out the build to make sure things were working smoothly prior to moving on the the next part.</p>
<br>

![API Testing](/images/API_Testing.png)

<br>
<p>This is where I found my first errors and set about trying to fix them. As this test is just a basic GET request I set about working through the request to see where my error was. Thankfully API Layer has a built in API playground for me to test out each function.  The first part we were working on was the <em>/latest,</em> I dug in there first.  Tesing the API both in the playground and using a curl GET locally I saw that my API was right and I was getting call backs. Since I had no reason to assume what I was copying and pasting from the steps was wrong I didn't look to see if the URL was correct that was sending the request.  Looking in there I found that the URL from the steps didn't match the URL I was using to test the API response. 
<br>

![Base URL](/images/Base_URL_Does_Not_Match.png)

![Example API](/images/API_GET_Example_From_Fixer.png)

![URL Locally](/images/Testing_API_GET_Locally.png)

<br>
<p>I set about updating the URL, which unforunately didn't fix my issue. I racked by brain for a bit till I realized that the GET request had a <em>--header</em> following it with the apikey for the request.  I started to dig through as many articles as I could find to append a header to the request so I can get the test to return true. I decided to move on and continue building the app in hopes that somewhere along the line I would figure it out. Unfortunately I had no such luck and ended up with an app that looked fine but didn't function</p>
<br>
<br>
<p>I decided to look for more <em>single page appication</em> examples and came across another app hosted by singlepoint.com (https://www.sitepoint.com/fetching-data-third-party-api-vue-axios/).  This app was built around a framework so it wasn't an exact match but it did reference an API.  So I set about building out this app to hopefully learn how this app requested APIs to then update my current app so I could get the requests to come thorugh.  This app build was successful and I was getting API calls from the NYT Dev API but I didn't find anything that stood out to me as an easy fix to my problem.  I went back to find ways to append a header to the <em>axios.create</em>. I dug in to all the dotenv and axios material I could find till I came across an article that had a header append within in <em>axios.create</em>function</p>

![Header Example](/images/Header_Example.png)


<p>I set about updating my code to follow this new example.  A new problem was presented though, I didn't see a way to refernce my .env file and my stored API Key.  So I moved forward with hard-coding my API key which proved successful but now my API was hardcoded to my app.  Not very secure, but the app is working so for now I moved forward to the currency converter section. This section called upon another API and another function and more errors!</p>
<br>

![Latest Success](/images/Latest_Success.png)

<p>Reading through the instructions for setting up this function I realized there was no mention of adding my converter api key to the .env file for reference. Odd. Oh well, moving on we ran into another URL problem.  Testing the converter locally the URL it was reaching out didn't match the one in the instructions.  Time for an update!. I also saw that the api key was appened at the end of url so I set about adding that to the call out URL.  Again another hard-coded API to fix after all of this.  This resolved my errors but was getting no return value.  So now 2 problems to fix. I was also seeing that in all the example api calls provided by converter api there was no mention of adding a number vaule to convert from.  My guess was this would be a combination between fixer.io and converter to get the right call back.</p>

![Converter API](/images/Testing_Converter.png)
![Converter Fail](/images/Coverter_Fail.png)

<br>
<p>Now that the app is built and sort of functioning lets move on to how am I going to host this thing on the web?!</p>
<br>
<h2 align="center">Work Out The Best Solution To Host The App, Keep It Simple, And Automate</h2>
<br>
<br>
<p>A quick Google search for <strong><em>How Do I Deploy A Web App With Terraform?</em></strong> lists a million and one ways to host an app in both AWS and Azure.  My recent experience with AWS during SANS SEC 388 proved to me that AWS would have best built in support for hosting a web app and I could bet they would have plenty of documentation for hosting any app thus providing an opportunity to get money from people. I also was able to participate in a few Terraform courses that focused on using Docker containers to build and deploy apps at will so that's where I dug into my research. I also felt like this would create the simplest option with Docker images providing an ability to be launched from anywhere, thus creating scalability and availability</p>
<br>
<p>Digging in to deploying a Docker app with Terrafrom in AWS I found that the best method was to use ECS (Elastic Container Service) with FARGATE and an ALB (Application Load Blancer).  I was able to stumble upon an article in Medium that walked through Dockerizing a simple Node app and hosting it on AWS all with Terraform (https://medium.com/avmconsulting-blog/how-to-deploy-a-dockerised-node-js-application-on-aws-ecs-with-terraform-3e6bceb48785). Huzzah!</p>
<br>
<p>I set about working through the instructions with the simple Node app to test that it did what it said it does. Doing this led me to work out a few kinks prior to trying this out with the full app.  The first problem I ran into was that I need to be able to push AWS changes into my personal/sandbox account with AWS CLI, but how do you do that if the changes I am currently making will automagicially push up to my work/production environment?. That required another Google search, which thanfully was quick as Hashicorp and AWS have extensive documentation. What I found was that in the providers section of the main.tf you can designate a <em>profile</em> within the providers section that cooresponds to a AWS CLI profile similar to designating a --profile for sending AWS commands from a specific profile. This example can be found in the main.tf</p>
<br>
<p>Now that I have worked out how to push Terraform to the right AWS account we are off to the races.  The next step after making sure that the App works is to use Docker to "Dockerize" the app.  I don't know if that's an actual word but I am betting everyone knows what I am talking about. The simple Node app have some simple enough instructions so I kept the same vibe using Docker with the SPA. I made a few tweaks to pertain to utilizing <em>npm</em> for installs and run commands. I created a Dockerfile inside the root of the app and moved on to creating a container in AWS with Terraform.</p>
<br>
<p>Starting off by running terraform init and terraform plan after creating the main.tf to make sure the changes going up were correct.  Making sure to specify the AWS CLI keys from my personal profile which I aptly named SPA-2022</p>

![Main Screen Shot](/images/Main_Provider_Example.png)
![AWS Container](/images/AWS_Container.png)

<p>The next steps are done through Terminal or Command Line depending on our OS. AWS provides all the commands needed to "Dockerize" the app and push it up to our newly created container. After going thorugh these steps we can see the image in the container ready to go! Also remembering to specify my personal CLI profile for the correct account</p>

![Container Image Screenshot](/images/Container_Image_Screen_Shot.png)

<p>Now we are going to be working within Amazon ECS which consists of 3 parts: Clusters, Tasks, & Services. Tasks being the directions for how a container should be run, Services runs the tasks and is very similar to an auto-scaling group in EC2 as it can restart or kill tasks as needed, and finally a Cluster is a logial grouping of of services and tasks</p>

![Task Service Snippet](/images/Task_Service_Description.png)

<p>Now we move to creating the cluster to then create the tasks and services in</p>

![Cluster Snippet](/images/Cluster_Snippet.png)

<p>Now we are going to work creating our first task.  This is where we will define how our container will run, defining cpu, memory, and ports open for the app to run.  We are also going to create an assume role IAM policy for the ECS Service to execute all necessary tasks.  This is also were we are going to start definging using FARGATE.  Which is a serverless compute service for containers within AWS which takes away the headache of having to manage servers and ec2 instances and allows you to pay as you go. This service is also compatible with EKS as well</p>

![Task AWS](/images/Task_AWS.png)

<p>On to creating our first service. Since we are using FARGATE we will also have to to use awsvpc (AWS Virtual Private Cloud).  Using awsvpc we will need to define our Subnets as well before this change will take hold.  Since I am running through a demo setup I am using default subnets and vpcs.  For a more production driven event we would create a private VPC and private Subnets to host multiple environments.</p>

![AWS Service](/images/AWS_Service.png)

</p>Drilling deeper into the service once its spun up you can see that the 3 containers we defined are working on spinning up. Eventually we will attach these to ALB (Application Load Balancer).  This will provide us with one IP address and will work to scale our compute as need up to 3 containers.</p>

<p>After creating the ALB I also needed to create a listner so traffic could come in and also a target group to add the containers to so the ALB knew where to listen to</p>

![AWS ALB](/images/AWS_ALB.png)
![ALB DNS](/images/ALB_DNS.png)

<p>Since we are pointing our listner to a target group now we need to add our containers to the target group. From there I needed to open up traffic to the containers by creating a security group to allow traffic only from the ALB.  ECS doesn't allow traffic by default.  Once we have finished the build we will give the containers some time for them to be healthy enough to run.  Time to test our app!</p>

<p>Initial tests of the app is that is running but not fully rendering.  I am guessing somewhere in the build the docker isn't fully dispalying the html and css files.  Time to do some research on depolying node.js apps in ECS and see if there are any tweaks that need to be made<p>

<p>Unfortunately I am unable at this time to determine why my app won't full materialize from the containers although it works just fine pulling the same image from Dockerhub. Also I am showing successful API calls when the app is running in ECS.  My initial research tells me that the java scipt dependencies are causing the page to fail to load as it is not currently bundled.  There are a few options to bundle everything to function better in the browser.  I'll update this a I do more research</p>

<h2 align="center">Destroy And Rebuild to Make Sure It Is Repeatable</h2>

<p>At the time of this writing I have spun up my infrastructure maybe 10 times. Mostly to make sure everytime the build stayed the same and also to see what would happen if I wanted to deploy it in other regions for more availability.  I also want to build an auto-scaling group with cloud watch metrics so that it can truly be a complete production environment without needing to keep an eye on metrics and spin up more containers to keep up with traffic. Also with the 10 rebuilds I did notice that I can't just spin up all the code at once and that it runs smoother if it is done in pieces.  This comes from the fact that every time I spin up the ALB from Terraform it takes about 2 - 2.5 mins which leads to other dependencies erroring out so I devised the best method to spin up infrastructure initially below.  Any updates to the infrastructure after the initial set up are pretty quick.  I spent some time also setting a handful of Dockerfiles so that I was making sure to create the best build.  I will continue to tweak this. </p>
<br>

1. Apply Main.tf

2. Navigate to Repo and Drill in for Image Push Instructions and Push App to ECR

3. Apply ECS_Cluster.tf and Apply ECS_Task.tf

4. Apply ECS_Service.tf but comment out lines 8-12 and 17 till after the ALB Apply

5. Apply AWS_ALB.tf, after complete uncomment ECS_Service.tf, then Apply

6. Give your infrastructure about 5 mins to spin up everything and get traffic in
<br>
<p>In retrospect I could spin up the ALB first since it takes the longest and then everything else after. Time for another rebuild!</p>
