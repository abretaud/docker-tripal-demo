# Tripal Demo using Docker

![Tripal Logo](http://tripal.info/sites/default/files/TripalLogo_dark.png)

This repository allows to run a demo instance of Tripal v2.1, loaded with test data as described in the [Tripal Tutorial](http://tripal.info/node/122).

## Using the Container

You will need docker and docker-compose to run this demo Tripal instance.

Download the code from this GitHub repository, then launch the following command to launch the Tripal instance:

```
cd docker-tripal-demo
docker-compose up
```

Wait a moment while the Chado database is being created, and tripal installed.
When ready, you should be able to browse to your new (empty) Tripal instance by going to [http://localhost:3300/tripal/](http://localhost:3300/tripal/).

The next step is to load the test data into this empty Tripal instance. To do this, run the following commands:

```
cd docker-tripal-demo/data
./load.sh
```

This command will create several Tripal jobs that will be executed one by one by a cron task.
Wait a few minutes and the data should appear on [http://localhost:3300/tripal/](http://localhost:3300/tripal/).

See [docker-tripal](https://github.com/erasche/docker-tripal) documentation for more help on configuring the Tripal image.

## Contributing

Please submit all issues and pull requests to the [abretaud/docker-tripal-demo](http://github.com/abretaud/docker-tripal-demo/) repository.

## Support

If you have any problem or suggestion please open an issue [here](https://github.com/abretaud/docker-tripal-demo/issues).
