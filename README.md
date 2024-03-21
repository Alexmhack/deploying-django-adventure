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
