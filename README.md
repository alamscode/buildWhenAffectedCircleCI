The project contains two config files in .cricleci directory, namely `config.yml` and `config-client.yml`. The `config.yml` file is the demo file that is for demo purpose only. The actual configuration resides in the `config-client.yml` file and only one change is required before using it.

1. In the .circleci directory, a variable named `ROOT` is declared in the line 1 of bash file named `commit_check.sh`. That variable needs to be filled by the `path/to/directory` that contains the `requirements.txt` file. 
