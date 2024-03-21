# deploying-django-adventure
Deploying Django using Docker and setting up CI/CD pipeline using GitHub Actions &amp; Workflows

In this tutorial we are going on an adventure of Deploying Django v5 simple blog application but using GitHub Actions, GitHub 
Workflows, Docker, MySQL and other technologies.

REFERENCE: [https://www.codingforentrepreneurs.com/](https://www.codingforentrepreneurs.com/)

## Configure early, Deploy often

As the heading of this section suggests, we are going to configure this repository for CI/CD using GitHub Actions & Workflows first and 
then move onto deployment and further steps.

### GitHub Workflows

At first these all terms like CI/CD and Jenkins and GitHub Actions Workflows seems too much but they are actually very easy if dive 
right in and try them out. GitHub Workflows are really very easy to use and GitHub provides pretty nice Docs for defining your custom 
as well as many many pre-defined workflows.

For creating our custom GitHub workflows, you need to create a *.github* folder in root folder of your repository and inside that 
another folder named *workflows*

*.github/workflows/hello-world.yml*
```
name: Simple Hello World Workflow

on:
  push:
    branches: [master]

jobs:
  hello_world_from_github_workflows:
  	runs-on: ubuntu-latest
  	env:
  	  HELLO_WORLD_SECRET: "test-secret"
  	steps:
  	  - name: Checkout Code
  	    uses: actions/checkout@v3
  	  - name: Echo Hello World
  	  	run: |
  	  	  echo "Hello World"
  	  	  echo "HELLO_WORLD_SECRET: ${{ env.HELLO_WORLD_SECRET }}"
```

NOTE: You can name your files *.yml* or *.yaml* extension both and it won't matter, they both work.

And as simple as that we can define our first workflow, to break down each line,

1. `name:` defines the Name of this workflow which will shown at the time of run on the GitHub Actions Page.
2. `on:` defines the trigger at which this workflow should run, on push at branch `master`.
3. `jobs:` defines all the jobs that we would be running in this workflow.
	Followed by the name of the job and the platform on which the job's steps will run.

We can define the environment variables to be used while running this Workflow inside `env:` clause but that would mean exposing our 
secrets in the repository, so for that GitHub provides Secrets in the Settings of the Repository.

Once we have defined our repository secrets we can use them in the workflow files using the same format `${{ ... }}` but this time 
picking them up from `${{ secrets.SECRET_NAME }}`

```
name: Hello World Workflow

on:
  push:
    branches: [master]

jobs:
  hello_world_on_django_project:
    runs-on: ubuntu-latest
    env:
      HELLO_WORLD_SECRET: "${{ secrets.HELLO_WORLD_SECRET }}"
    steps:
      - name: Checkout Code
      	uses: actions/checkout@v3
      - name: Echo Hello World
        run: |
          echo "Hello World"
          echo "HELLO_WORLD_SECRET: ${{ env.HELLO_WORLD_SECRET }}"
```
