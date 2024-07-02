# Setup up environment

Copy `ml_env.sh.template` to `ml_env.sh` and update the values to match your environment.

    cp ml_env.sh.template ml_env.sh
    vim ml_env.sh

# Running the script

From the TOP LEVEL directory ...

First, source your environement so the required variables are defined:

    source ./ml_env.sh

Then, set cutoff date and execute:

    cutoff_date="2022-01-01"
    bash src/start-purge.sh "$cutoff_date"
