/**
 * Cucumber steps for chaos testing when lambdas are out in a region
 *
 * @author Indra Basak
 * @since Jun 14, 2023
 */
const { Given, Then, When, After, setDefaultTimeout  } = require('@cucumber/cucumber');
const assert = require('assert').strict;
require('dotenv-flow').config();
const { ExperimentHelper } = require('../util/experiment-helper');
const { RestHelper } = require('../util/rest-helper');

const DEFAULT_TIMEOUT = 60000;
setDefaultTimeout(DEFAULT_TIMEOUT);

const helper = new ExperimentHelper(
  process.env.LOCALSTACK_URL,
  process.env.AWS_REGION
);

/// ////////////////////////////////////////////////////////////////////////////////
// Scenario Outline: test resiliency by injecting chaos to all lambdas in a region
/// ////////////////////////////////////////////////////////////////////////////////
Given(
  'localstack setup is up and running for testing lambdas chaos in a region',
  async () => {
    console.log('Checking if localstack is up');
    const config = {
      headers: {
        'Content-Type': 'application/json'
      }
    };

    const response = await RestHelper.get(
      `${process.env.LOCALSTACK_URL}`,
      config
    );
    assert.equal(response.status, 200);
  }
);

When(
  'check lambda by sending a request to {} gets a response code of {int}',
  async (path, code) => {
    const config = {
      headers: {
        'Content-Type': 'application/json',
        Host: `${process.env.CUSTOM_DOMAIN}`
      }
    };

    const response = await RestHelper.get(
      `${process.env.LOCALSTACK_URL}${path}`,
      config
    );
    assert.equal(response.status, code);
    console.log('END - health endpoint response successful');
  }
);

When('I inject lambda fault', async () => {
  console.log('1 ------------------------');
  await helper.startExperiment('lambda');
});

Then(
  'I send a GET request to {} and I should get a response code of {int}',
  { timeout: 50 * 1000 },
  async (path, code) => {
    const config = {
      headers: {
        'Content-Type': 'application/json',
        Host: `${process.env.CUSTOM_DOMAIN}`
      }
    };

    const response = await RestHelper.get(
      `${process.env.LOCALSTACK_URL}${path}`,
      config
    );

    assert.equal(response.status, code);
    console.log(`END - ${path} endpoint response successful`);
  }
);

Then(
  'check lambda by resending a GET request to {} and I should get a response code of {int}',
  { timeout: 50 * 1000 },
  async (path, code) => {
    const config = {
      headers: {
        'Content-Type': 'application/json',
        Host: `${process.env.CUSTOM_DOMAIN}`
      }
    };

    const response = await RestHelper.get(
      `${process.env.LOCALSTACK_URL}${path}`,
      config
    );

    assert.equal(response.status, code);
    console.log('END - health endpoint response successful');
  }
);

After(async () => {
  console.log('Cleaning up experiments');
  await helper.stopExperiment();
});
