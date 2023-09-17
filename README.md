# Rinha backend 2023
This project was based on the challenge 'Rinha backend 2023':
 - [Challenge instructions](https://github.com/zanfranceschi/rinha-de-backend-2023-q3/blob/main/INSTRUCOES.md)

My version was built after the competition had finished. So I could inspire on other implementations, such as:
 - https://github.com/leandronsp/rinha-backend-ruby
 - https://github.com/lazaronixon/rinha_de_backend
 - https://github.com/akitaonrails/rinhabackend-rails-api

## Versions
My intention was to do a simple version and then do performances updates:
| Version | Description | Result |
|---------|-------------|--------|
|  1.0    | First version without index in search |  14973 |


## Requirements

* [Docker](https://docs.docker.com/get-docker/)
* [Gatling](https://gatling.io/open-source/), a performance testing tool

## Stack

* 2 Ruby 3.2.2 [+YJIT](https://shopify.engineering/ruby-yjit-is-production-ready) apps
* 1 PostgreSQL
* 1 NGINX


## How to Run

To run this application:

    docker-compose up

Application should respond at:

    http://0.0.0.0:9999


Run stress test:

    wget https://repo1.maven.org/maven2/io/gatling/highcharts/gatling-charts-highcharts-bundle/3.9.5/gatling-charts-highcharts-bundle-3.9.5-bundle.zip
    unzip gatling-charts-highcharts-bundle-3.9.5-bundle.zip
    sudo mv gatling-charts-highcharts-bundle-3.9.5-bundle /opt
    sudo ln -s /opt/gatling-charts-highcharts-bundle-3.9.5-bundle /opt/gatling

Edit the stress-test stress-test/run-test.sh variables accordingly:

    GATLING_BIN_DIR=/opt/gatling/bin

    WORKSPACE=$HOME/Projects/rinha-backend-2023/stress-test

Run the stress test:

    ./stress-test/run-test.sh


## Versions Results
