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

*.github/workflows/hello-world.yml*
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

Now for a slightly complex example we will add a basic test case in our blog app and run it using workflows.

*.github/workflows/hello-world.yml*
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
      - name: Setup Python
      	uses: actions/setup-python@v3
  	    with:
  	      python-version: "3.10"
  	  - name: Install Dependencies
  	    run: pip3 install -r requirements.txt
  	  - name: Run Django Tests
  	    run: python3 manage.py test
```

And soon as we push our code onto origin this workflow will start running with the defined steps in the job and it will run the Django 
Test case as well.

Now since this a demo app for learning purposes we have not hidden our `DJANGO_SECRET_KEY` but in production environment we have to 
use environment variables and hide our keys.

So what we'll be doing is using the GitHub Secrets for storing our environment variable and using this variable in the workflows yml 
file.

```
name: "Django Test Cases Workflow"

on:
  push:
    branches: [master]

jobs:
  test_django_project:
    runs-on: ubuntu-latest
    env:
      DJANGO_SECRET_KEY: "${{ secrets.DJANGO_SECRET_KEY }}"
    steps:
      - name: Checkout code
        uses: actions/checkout@v3
        uses: actions/setup-python@v3
        with:
          python-version: "3.10"
      - name: "Install Dependencies"
        run: pip3 install -r requirements.txt
      - name: "Run Django Tests"
        run: python3 manage.py test
```

For more information the `setup-python` actions check out this [link](https://github.com/actions/setup-python).

#### all.yml Workflow

In a production-grade project, there could be multiple workflows and managing them separately and disabling enabling them as our
project advances as well as adding more secrets and environment variables in these workflows can become hectic, so to avoid that
situation we can run all the workflows by defining them in a single workflow.

We would name this file all.yml since this workflow would run all the other workflows in our project.

*.github/workflows/all.yml*
```
name: Project's all the Workflows

on:
  workflow_dispatch:

  push:
  	branches: [master]

jobs:
  test_project:
  	uses: ./github/workflows/hello-world.yml
```

Now if we push our code then you will find that the workflow named *Project's all the Workflows* has run twice. This is because we 
have configured the workflow to run on `push` on master branch and the same has been done in the *hello-world.yml* workflow file as 
well, so to avoid this situation we will remove the `push` trigger from all the other workflow files and instead add `workflow_call` 
as the trigger.

In the above workflow file, you may have noticed `workflow_dispatch:` event trigger, this is actually very useful as this provides us 
with the option to run this workflow manually from the GitHub Actions.

#### PostgreSQL Setup for Workflow

Since in production we won't be using SQLite DB, we would want to run our tests as well on a production-grade or the database that is
being used in production by our application. I prefer PostgreSQL for Django projects and so we will have to replace our SQLite DB with
PostgreSQL in *settings.py* as well and modify the *test_project.yml* workflow to spawn up PostgreSQL DB for our workflow and use 
setup env vars for our Django as well.

This section gets a little complicated as we setup the PostgreSQL DB first locally in Docker Container then on Azure and then create a
GitHub Workflow Dispatch Action for configuring Azure PostgreSQL DB.

1. PostgreSQL Setup Locally in Docker Container

*I commonly use PostgreSQL, you are welcome to use other SQL Databases as well*

Provisioning a development environment PostgreSQL DB locally using Docker container is very easy, you just need to define a `docker-compose.yaml` file which has a postgres service in it, below is a basic example.

```
version: "3.9"

services:
  postgres_main:
    image: "postgres:16.2-alpine3.19"
    restart: unless-stopped
    volumes:
      - django_dev_db_vol:/var/lib/postgresql/data
    env_file:
      - .env
    ports:
      - 5432:5432
    expose:
      - 5432

volumes:
  - django_dev_db_vol
```

This very basic service can be broken down into,

1. `name` of the service - `postgres_main` - this name is used by Docker for name of the container
2. `image` - `postgres:...` - PostgreSQL official image available on [https://hub.docker.com/](https://hub.docker.com/) can be easily copied and pasted(I have used alpine since its smaller in size and since development env)
3. `restart` - There are a few other options available for the Docker Container `restart` policy, we are using `unless-stopped` means
to not restart the `postgres_main` service unless it has been deliberately stopped. `always` is a very commonly used option.
4. `env_file` - We can define environment variables using `environment` also and if you want to use an already existing `.env` file like in my case then define all those env files here.
5. `ports` - This is very important as it defined the target and the published port of this service, if we change this then we need
to make it same in our Django settings as well.
6. `expose` - Think of this as the outside world connection of this container, without this our service won't be accessible outside and it would just act like a VPC.
7. `volumes` - Since Docker Container can be brought up and down, the data is not persistent and DB cannot have loss of data if container crashes or is stopped down, so volumes are defined which are local machine paths where the actual data is stored of this particular service. 

If you check the official Docker Hub for PostgreSQL then you will find some pre-defined environment variables which need to be defined
in order to provision the DB, they are,

```
POSTGRES_PASSWORD=<>
POSTGRES_USER=<>
POSTGRES_DB=<>
POSTGRES_PORT=5432
```

These are the important ones, you can look more at the Docker Hub.

We will define these same in our `.env` file to be used by Django Settings for connecting to this DB in dev environment.

To start this service simply run, `docker compose up -d` (`-d` for detached mode). Use `docker compose down` for bringing down this 
service(container).

2. PostgreSQL Setup on Azure

Azure Database for PostgreSQL flexible server provides 750 hours of free usage where you can test and play around. It's very straight 
forward and simple, the values used while creating this DB from Azure UI or CLI will be used in `.env` file for connecting with the
DB using Django.

Make sure to allow Access to outside network either by whitelisting your current IP or by allowing All and making sure Database 
Password is tough.

3. DB init Script

This was a little complicated part for me since PostgreSQL does not provide command utilities like `IF NOT EXISTS`, for the alternative in psql there are `DO` statements which allow `IF PERFORM` etc code.
